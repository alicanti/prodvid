/// Firestore collection and field names
abstract class FirestoreCollections {
  // Collections
  static const String users = 'users';
  static const String products = 'products';
  static const String videos = 'videos';
  static const String transactions = 'transactions';
  static const String templates = 'templates';
  
  // User fields
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoURL = 'photoURL';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String credits = 'credits';
  static const String creditsSubscription = 'credits.subscription';
  static const String creditsPurchased = 'credits.purchased';
  static const String subscription = 'subscription';
  static const String subscriptionStatus = 'subscription.status';
  static const String subscriptionPlan = 'subscription.plan';
  static const String settings = 'settings';
  
  // Product fields
  static const String title = 'title';
  static const String description = 'description';
  static const String price = 'price';
  static const String features = 'features';
  static const String images = 'images';
  
  // Video fields
  static const String productId = 'productId';
  static const String templateId = 'templateId';
  static const String status = 'status';
  static const String aspectRatio = 'aspectRatio';
  static const String videoUrl = 'videoUrl';
  static const String thumbnailUrl = 'thumbnailUrl';
  static const String duration = 'duration';
  static const String completedAt = 'completedAt';
  static const String error = 'error';
  static const String wiroJobId = 'wiroJobId';
  
  // Transaction fields
  static const String type = 'type';
  static const String creditType = 'creditType';
  static const String amount = 'amount';
  static const String balanceAfter = 'balanceAfter';
  static const String relatedVideoId = 'relatedVideoId';
  static const String relatedProductId = 'relatedProductId';
  static const String metadata = 'metadata';
  
  // Template fields
  static const String name = 'name';
  static const String category = 'category';
  static const String previewVideoUrl = 'previewVideoUrl';
  static const String supportedAspectRatios = 'supportedAspectRatios';
  static const String creditCost = 'creditCost';
  static const String isActive = 'isActive';
}

/// Video status enum values
abstract class VideoStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
}

/// Subscription status enum values
abstract class SubscriptionStatus {
  static const String active = 'active';
  static const String expired = 'expired';
  static const String cancelled = 'cancelled';
  static const String none = 'none';
}

/// Transaction type enum values
abstract class TransactionType {
  static const String subscriptionRenewal = 'subscription_renewal';
  static const String creditPurchase = 'credit_purchase';
  static const String creditUsed = 'credit_used';
  static const String subscriptionExpired = 'subscription_expired';
}

/// Credit type enum values
abstract class CreditType {
  static const String subscription = 'subscription';
  static const String purchased = 'purchased';
}


