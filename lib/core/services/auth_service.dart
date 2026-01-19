import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'video_cache_service.dart';
import 'video_player_manager.dart';

/// Initial credits for new users
const int initialCredits = 100;

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

/// User credits provider - watches Firestore for real-time credit updates
final userCreditsProvider = StreamProvider<int>((ref) {
  // Watch auth state to rebuild when user changes
  final authState = ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(0);
      }
      return firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => (doc.data()?['credits'] as num?)?.toInt() ?? 0);
    },
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

/// User subscription status provider - watches Firestore for subscription status
final userSubscriptionProvider = StreamProvider<bool>((ref) {
  // Watch auth state to rebuild when user changes
  final authState = ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(false);
      }
      return firestore.collection('users').doc(user.uid).snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return false;

        // Check if subscription is active
        final isSubscribed = data['isSubscribed'] as bool? ?? false;
        
        if (!isSubscribed) return false;
        
        // Handle subscriptionExpiry - can be Timestamp, String, or null
        final expiryData = data['subscriptionExpiry'];
        if (expiryData == null) return isSubscribed;
        
        DateTime? expiryDate;
        if (expiryData is Timestamp) {
          expiryDate = expiryData.toDate();
        } else if (expiryData is String) {
          expiryDate = DateTime.tryParse(expiryData);
        }
        
        if (expiryDate == null) return isSubscribed;

        // Check if subscription hasn't expired
        return expiryDate.isAfter(DateTime.now());
      });
    },
    loading: () => Stream.value(false),
    error: (_, __) => Stream.value(false),
  );
});

/// User video project model
class VideoProject {
  VideoProject({
    required this.taskId,
    required this.modelType,
    required this.effectType,
    required this.videoMode,
    required this.status,
    this.videoUrl,
    this.createdAt,
    this.completedAt,
  });

  factory VideoProject.fromFirestore(Map<String, dynamic> data) {
    // Try to get videoUrl directly first, then fall back to extracting from outputs
    final directVideoUrl = data['videoUrl'] as String?;
    final extractedVideoUrl = _extractVideoUrl(data['outputs']);

    return VideoProject(
      taskId: data['taskId'] as String? ?? '',
      modelType: data['modelType'] as String? ?? '',
      effectType: data['effectType'] as String? ?? '',
      videoMode: data['videoMode'] as String? ?? 'std',
      status: data['status'] as String? ?? 'pending',
      videoUrl: directVideoUrl ?? extractedVideoUrl,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  final String taskId;
  final String modelType;
  final String effectType;
  final String videoMode;
  final String status;
  final String? videoUrl;
  final DateTime? createdAt;
  final DateTime? completedAt;

  bool get isCompleted => status == 'completed';
  bool get isPending =>
      status == 'pending' || status == 'processing' || status == 'preparing';
  bool get isFailed => status == 'failed' || status == 'cancelled';

  /// Get display name from effect type (e.g., "smoky-pedestal" -> "Smoky Pedestal")
  String get displayName {
    return effectType
        .replaceAll('-', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  /// Extract video URL from outputs array
  static String? _extractVideoUrl(dynamic outputs) {
    if (outputs == null) return null;
    if (outputs is List && outputs.isNotEmpty) {
      final firstOutput = outputs[0];
      if (firstOutput is Map) {
        return firstOutput['url'] as String?;
      }
    }
    return null;
  }
}

/// User videos provider - watches Firestore for user's video projects
final userVideosProvider = StreamProvider<List<VideoProject>>((ref) {
  // Watch auth state to rebuild when user changes
  final authState = ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }
      // Query the root tasks collection filtered by userId, ordered by creation date
      return firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => VideoProject.fromFirestore(doc.data()))
                .toList(),
          );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Authentication service for handling anonymous auth
class AuthService {
  AuthService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Get user ID
  String? get userId => _auth.currentUser?.uid;

  /// Sign in anonymously and create Firestore user document
  ///
  /// Creates a new anonymous user if not already signed in.
  /// Also creates a Firestore document with initial credits.
  /// Returns the User object on success.
  Future<User?> signInAnonymously() async {
    try {
      User? user;

      // If already signed in, use current user
      if (_auth.currentUser != null) {
        user = _auth.currentUser;
      } else {
        // Sign in anonymously
        final userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
      }

      if (user != null) {
        // Create or update user document in Firestore
        await _createUserDocument(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed', e.code);
    } catch (e) {
      throw AuthException('An unexpected error occurred', 'unknown');
    }
  }

  /// Create user document in Firestore with initial credits
  Future<void> _createUserDocument(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Create new user document with initial credits
      await userRef.set({
        'credits': initialCredits,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('📝 Created new user document with $initialCredits initial credits');
    } else {
      // Document exists but might not have credits (created by RevenueCat sync)
      final data = userDoc.data();
      if (data != null && !data.containsKey('credits')) {
        await userRef.update({
          'credits': initialCredits,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('📝 Added $initialCredits initial credits to existing user document');
      }
    }
  }

  /// Get current user's credits
  Future<int> getCredits() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return (userDoc.data()?['credits'] as num?)?.toInt() ?? 0;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account and all associated data
  /// This completely resets the app to first-launch state
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;
    debugPrint('🗑️ Starting account deletion for user: $userId');

    try {
      // STEP 1: Dispose all video players to prevent errors during navigation
      debugPrint('🎬 Disposing all video players...');
      await VideoPlayerManager.instance.disposeAll();

      // STEP 2: Clear video cache from device
      debugPrint('🗂️ Clearing video cache...');
      await VideoCacheManager.clearCache();
      VideoPreloader.clearTracking();

      // STEP 3: Logout from RevenueCat
      debugPrint('💳 Logging out from RevenueCat...');
      try {
        await Purchases.logOut();
      } catch (e) {
        // Ignore RevenueCat errors - user might not be logged in
        debugPrint('⚠️ RevenueCat logout warning: $e');
      }

      // STEP 4: Delete all user's tasks (videos) from Firestore
      debugPrint('📹 Deleting user videos...');
      final tasksQuery = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in tasksQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('📹 Deleted ${tasksQuery.docs.length} video tasks');

      // STEP 5: Delete user document from Firestore
      debugPrint('👤 Deleting user document...');
      await _firestore.collection('users').doc(userId).delete();

      // STEP 6: Clear SharedPreferences (onboarding flag, etc.)
      debugPrint('⚙️ Clearing local preferences...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // STEP 7: Delete Firebase Auth account (must be last)
      debugPrint('🔐 Deleting Firebase Auth account...');
      await user.delete();

      debugPrint('✅ Account deletion complete!');
    } catch (e) {
      debugPrint('❌ Error during account deletion: $e');
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

/// Custom auth exception
class AuthException implements Exception {
  AuthException(this.message, this.code);

  final String message;
  final String code;

  @override
  String toString() => 'AuthException: $message (code: $code)';
}
