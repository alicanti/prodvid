import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notification_service.dart';
import 'core/services/revenuecat_service.dart';
import 'core/services/video_player_manager.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize RevenueCat
  final revenueCatService = RevenueCatService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
  await revenueCatService.initialize();

  // Initialize Local Notifications
  await NotificationService().initialize();
  await NotificationService().requestPermission();

  runApp(const ProviderScope(child: ProdVidApp()));
}

class ProdVidApp extends ConsumerStatefulWidget {
  const ProdVidApp({super.key});

  @override
  ConsumerState<ProdVidApp> createState() => _ProdVidAppState();
}

class _ProdVidAppState extends ConsumerState<ProdVidApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose all video players when app is closed
    VideoPlayerManager.instance.disposeAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Pause all videos when app goes to background
        VideoPlayerManager.instance.pauseAll();
      case AppLifecycleState.resumed:
        // Videos will resume when they become visible again
        break;
      case AppLifecycleState.detached:
        // Dispose all videos when app is detached
        VideoPlayerManager.instance.disposeAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ProdVid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
