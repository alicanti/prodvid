import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// RevenueCat webhook authorization header secret (set via Firebase config)
// To set: firebase functions:config:set revenuecat.webhook_secret="your_secret"
const getWebhookSecret = (): string => {
  return functions.config().revenuecat?.webhook_secret || process.env.REVENUECAT_WEBHOOK_SECRET || '';
};

/**
 * Credit amounts for each product
 * Update these IDs to match your RevenueCat product identifiers
 */
const PRODUCT_CREDITS: Record<string, number> = {
  // Consumables - $49.99, $99.99, $199.99
  'credits_3000': 3000,
  'credits_7500': 7500,
  'credits_15000': 15000,
  // Alternative consumable IDs (add your actual RC product IDs here)
  'com.prodvid.credits.3000': 3000,
  'com.prodvid.credits.7500': 7500,
  'com.prodvid.credits.15000': 15000,
  // Subscriptions (reset to this amount on each renewal)
  'weekly.prodvid.app': 1500,
  'yearly.prodvid.app': 10000,
  // Alternative subscription IDs
  'weekly_sub': 1500,
  'yearly_sub': 10000,
};

/**
 * RevenueCat Event Types
 * https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields
 */
type RevenueCatEventType =
  | 'INITIAL_PURCHASE'
  | 'RENEWAL'
  | 'CANCELLATION'
  | 'UNCANCELLATION'
  | 'NON_RENEWING_PURCHASE'
  | 'SUBSCRIPTION_PAUSED'
  | 'SUBSCRIPTION_EXTENDED'
  | 'EXPIRATION'
  | 'BILLING_ISSUE'
  | 'PRODUCT_CHANGE'
  | 'TRANSFER';

/**
 * RevenueCat Webhook Event Structure
 */
interface RevenueCatEvent {
  api_version: string;
  event: {
    type: RevenueCatEventType;
    id: string;
    app_id: string;
    app_user_id: string;
    original_app_user_id: string;
    aliases: string[];
    product_id: string;
    entitlement_ids: string[];
    store: string;
    environment: 'SANDBOX' | 'PRODUCTION';
    presented_offering_id?: string;
    period_type?: 'NORMAL' | 'INTRO' | 'TRIAL';
    purchased_at_ms?: number;
    expiration_at_ms?: number;
    is_family_share?: boolean;
    country_code?: string;
    subscriber_attributes?: Record<string, { value: string; updated_at_ms: number }>;
    // For cancellation
    cancel_reason?: string;
    // For billing issues
    grace_period_expiration_at_ms?: number;
    // For product change (upgrade/downgrade)
    new_product_id?: string;
  };
}

/**
 * Get Firebase user ID from RevenueCat app_user_id
 * RevenueCat stores the Firebase UID as the app_user_id
 */
function getFirebaseUserId(event: RevenueCatEvent['event']): string | null {
  // Check if app_user_id is a Firebase UID (not anonymous)
  const userId = event.app_user_id;
  
  // Skip anonymous users (RevenueCat generates IDs starting with $RCAnonymousID:)
  if (userId.startsWith('$RCAnonymousID:')) {
    // Try to get from aliases
    const firebaseAlias = event.aliases.find(
      (alias) => !alias.startsWith('$RCAnonymousID:')
    );
    return firebaseAlias || null;
  }
  
  return userId;
}

/**
 * Add credits to user account
 */
async function addCredits(userId: string, productId: string, amount: number): Promise<void> {
  const userRef = db.collection('users').doc(userId);
  
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    
    if (!userDoc.exists) {
      // Create user document if doesn't exist
      transaction.set(userRef, {
        credits: amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      transaction.update(userRef, {
        credits: admin.firestore.FieldValue.increment(amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });
  
  // Log the transaction
  await db.collection('credit_transactions').add({
    userId,
    productId,
    amount,
    type: 'purchase',
    source: 'revenuecat_webhook',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  console.log(`✅ Added ${amount} credits to user ${userId} for ${productId}`);
}

/**
 * Reset credits for subscription (on renewal)
 */
async function resetCreditsForSubscription(
  userId: string,
  productId: string,
  amount: number
): Promise<void> {
  const userRef = db.collection('users').doc(userId);
  
  await userRef.update({
    credits: amount,
    lastRenewal: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  // Log the transaction
  await db.collection('credit_transactions').add({
    userId,
    productId,
    amount,
    type: 'subscription_renewal',
    source: 'revenuecat_webhook',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  console.log(`✅ Reset credits to ${amount} for user ${userId} (renewal: ${productId})`);
}

/**
 * Update subscription status
 */
async function updateSubscriptionStatus(
  userId: string,
  isSubscribed: boolean,
  expirationMs?: number,
  productId?: string
): Promise<void> {
  const userRef = db.collection('users').doc(userId);
  
  const updateData: Record<string, unknown> = {
    isSubscribed,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  
  if (expirationMs) {
    updateData.subscriptionExpiry = admin.firestore.Timestamp.fromDate(new Date(expirationMs));
  }
  
  if (productId) {
    updateData.subscriptionProductId = productId;
  }
  
  if (!isSubscribed) {
    updateData.subscriptionExpiry = null;
    updateData.subscriptionProductId = null;
  }
  
  await userRef.update(updateData);
  
  console.log(`✅ Updated subscription status for user ${userId}: isSubscribed=${isSubscribed}`);
}

/**
 * Handle INITIAL_PURCHASE event
 * First subscription purchase
 */
async function handleInitialPurchase(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  const productId = event.product_id;
  const credits = PRODUCT_CREDITS[productId];
  
  if (!credits) {
    console.log(`⚠️ Unknown product: ${productId}`);
    return;
  }
  
  // Add credits
  await addCredits(userId, productId, credits);
  
  // If this is a subscription, update subscription status
  if (productId.includes('weekly') || productId.includes('yearly')) {
    await updateSubscriptionStatus(
      userId,
      true,
      event.expiration_at_ms,
      productId
    );
  }
}

/**
 * Handle RENEWAL event
 * Subscription renewed - reset credits to subscription amount
 */
async function handleRenewal(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  const productId = event.product_id;
  const credits = PRODUCT_CREDITS[productId];
  
  if (!credits) {
    console.log(`⚠️ Unknown product: ${productId}`);
    return;
  }
  
  // Reset credits to subscription amount
  await resetCreditsForSubscription(userId, productId, credits);
  
  // Update subscription expiry
  await updateSubscriptionStatus(
    userId,
    true,
    event.expiration_at_ms,
    productId
  );
}

/**
 * Handle NON_RENEWING_PURCHASE event
 * One-time purchase (consumables)
 */
async function handleNonRenewingPurchase(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  const productId = event.product_id;
  const credits = PRODUCT_CREDITS[productId];
  
  if (!credits) {
    console.log(`⚠️ Unknown product: ${productId}`);
    return;
  }
  
  // Add credits
  await addCredits(userId, productId, credits);
}

/**
 * Handle CANCELLATION event
 * User cancelled subscription (but may still have access until expiry)
 */
async function handleCancellation(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  // Log cancellation but don't remove access yet (user has access until expiry)
  console.log(`📝 User ${userId} cancelled subscription. Reason: ${event.cancel_reason}`);
  
  await db.collection('subscription_events').add({
    userId,
    productId: event.product_id,
    type: 'cancellation',
    reason: event.cancel_reason,
    expiresAt: event.expiration_at_ms ? new Date(event.expiration_at_ms) : null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Handle EXPIRATION event
 * Subscription expired - remove access
 */
async function handleExpiration(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  // Update subscription status to inactive
  await updateSubscriptionStatus(userId, false);
  
  await db.collection('subscription_events').add({
    userId,
    productId: event.product_id,
    type: 'expiration',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Handle UNCANCELLATION event
 * User reactivated cancelled subscription
 */
async function handleUncancellation(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  console.log(`✅ User ${userId} uncancelled subscription`);
  
  await db.collection('subscription_events').add({
    userId,
    productId: event.product_id,
    type: 'uncancellation',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Handle BILLING_ISSUE event
 * Payment failed - subscription at risk
 */
async function handleBillingIssue(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  console.log(`⚠️ Billing issue for user ${userId}`);
  
  // Store billing issue for potential follow-up
  await db.collection('subscription_events').add({
    userId,
    productId: event.product_id,
    type: 'billing_issue',
    gracePeriodExpiresAt: event.grace_period_expiration_at_ms
      ? new Date(event.grace_period_expiration_at_ms)
      : null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  // TODO: Send push notification to user about billing issue
}

/**
 * Handle PRODUCT_CHANGE event
 * User upgraded/downgraded subscription (e.g., weekly -> yearly)
 */
async function handleProductChange(event: RevenueCatEvent['event']): Promise<void> {
  const userId = getFirebaseUserId(event);
  if (!userId) {
    console.log('⚠️ Skipping: No Firebase user ID found');
    return;
  }
  
  const oldProductId = event.product_id;
  const newProductId = event.new_product_id;
  
  if (!newProductId) {
    console.log('⚠️ No new_product_id found in PRODUCT_CHANGE event');
    return;
  }
  
  const oldCredits = PRODUCT_CREDITS[oldProductId] || 0;
  const newCredits = PRODUCT_CREDITS[newProductId] || 0;
  
  console.log(`🔄 Product change for user ${userId}: ${oldProductId} → ${newProductId}`);
  console.log(`   Credits: ${oldCredits} → ${newCredits}`);
  
  // If upgrading to a higher tier, add the difference in credits
  if (newCredits > oldCredits) {
    const creditDifference = newCredits - oldCredits;
    await addCredits(userId, newProductId, creditDifference);
    console.log(`✅ Added ${creditDifference} bonus credits for upgrade`);
  }
  
  // Update subscription status with new product
  await updateSubscriptionStatus(
    userId,
    true,
    event.expiration_at_ms,
    newProductId
  );
  
  // Log the product change
  await db.collection('subscription_events').add({
    userId,
    oldProductId,
    newProductId,
    type: 'product_change',
    creditDifference: newCredits - oldCredits,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * RevenueCat Webhook Handler
 */
export const revenuecatWebhook = functions.https.onRequest(async (req, res) => {
  // Only accept POST requests
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed');
    return;
  }
  
  // Verify authorization header
  const authHeader = req.headers.authorization;
  const expectedSecret = getWebhookSecret();
    
    if (expectedSecret && authHeader !== `Bearer ${expectedSecret}`) {
      console.error('❌ Invalid authorization header');
      res.status(401).send('Unauthorized');
      return;
    }
    
    try {
      const webhookData = req.body as RevenueCatEvent;
      const event = webhookData.event;
      
      console.log(`📥 Received RevenueCat webhook: ${event.type}`);
      console.log(`   Product: ${event.product_id}`);
      console.log(`   User: ${event.app_user_id}`);
      console.log(`   Environment: ${event.environment}`);
      
      // Skip sandbox events in production (optional - remove if you want sandbox testing)
      // if (event.environment === 'SANDBOX') {
      //   console.log('⚠️ Skipping sandbox event');
      //   res.status(200).send('OK');
      //   return;
      // }
      
      // Handle event based on type
      switch (event.type) {
        case 'INITIAL_PURCHASE':
          await handleInitialPurchase(event);
          break;
          
        case 'RENEWAL':
          await handleRenewal(event);
          break;
          
        case 'NON_RENEWING_PURCHASE':
          await handleNonRenewingPurchase(event);
          break;
          
        case 'CANCELLATION':
          await handleCancellation(event);
          break;
          
        case 'EXPIRATION':
          await handleExpiration(event);
          break;
          
        case 'UNCANCELLATION':
          await handleUncancellation(event);
          break;
          
        case 'BILLING_ISSUE':
          await handleBillingIssue(event);
          break;
          
        case 'PRODUCT_CHANGE':
          await handleProductChange(event);
          break;
          
        case 'SUBSCRIPTION_PAUSED':
          console.log(`⏸️ Subscription paused for user ${event.app_user_id}`);
          break;
          
        case 'SUBSCRIPTION_EXTENDED':
          console.log(`⏭️ Subscription extended for user ${event.app_user_id}`);
          await updateSubscriptionStatus(
            getFirebaseUserId(event) || '',
            true,
            event.expiration_at_ms,
            event.product_id
          );
          break;
          
        case 'TRANSFER':
          console.log(`🔄 Transfer event for user ${event.app_user_id}`);
          break;
          
        default:
          console.log(`⚠️ Unhandled event type: ${event.type}`);
      }
      
      // Store webhook event for debugging
      await db.collection('webhook_logs').add({
        source: 'revenuecat',
        eventType: event.type,
        eventId: event.id,
        productId: event.product_id,
        userId: event.app_user_id,
        environment: event.environment,
        rawData: webhookData,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      res.status(200).send('OK');
    } catch (error) {
      console.error('❌ Webhook processing error:', error);
      res.status(500).send('Internal error');
    }
  });

