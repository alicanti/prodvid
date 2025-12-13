# ProdVid - Implementation Plan

**Versiyon:** 1.0  
**Tarih:** 13 Aralık 2025  
**Durum:** Planning

---

## Genel Bakış

Bu doküman, ProdVid uygulamasının teknik implementasyonu için adım adım iş planını içerir. Her faz ve görev için bağımlılıklar, öncelikler ve kontrol noktaları belirlenmiştir.

---

## Phase 0: Proje Kurulumu

### 0.1 Flutter Proje Oluşturma
- [ ] Flutter projesi oluşturma (`flutter create`)
- [ ] Klasör yapısı düzenleme (feature-first architecture)
- [ ] Temel paketlerin eklenmesi
- [ ] Linting ve code style yapılandırması
- [ ] Git repository kurulumu
- [ ] .gitignore düzenleme

**Tahmini Süre:** 2-3 saat

### 0.2 Temel Paketler

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.x.x
  
  # Navigation
  go_router: ^x.x.x
  
  # Firebase
  firebase_core: ^x.x.x
  firebase_auth: ^x.x.x
  cloud_firestore: ^x.x.x
  firebase_storage: ^x.x.x
  cloud_functions: ^x.x.x
  
  # RevenueCat
  purchases_flutter: ^x.x.x
  
  # UI
  flutter_svg: ^x.x.x
  cached_network_image: ^x.x.x
  shimmer: ^x.x.x
  
  # Utilities
  image_picker: ^x.x.x
  share_plus: ^x.x.x
  url_launcher: ^x.x.x
  path_provider: ^x.x.x
  
  # Storage
  shared_preferences: ^x.x.x
  
dev_dependencies:
  flutter_lints: ^x.x.x
  build_runner: ^x.x.x
```

---

## Phase 1: Firebase Kurulumu

### 1.1 Firebase Projesi Oluşturma
- [ ] Firebase Console'da yeni proje oluşturma
- [ ] iOS uygulaması ekleme (Bundle ID)
- [ ] Android uygulaması ekleme (Package Name)
- [ ] `google-services.json` indirme (Android)
- [ ] `GoogleService-Info.plist` indirme (iOS)
- [ ] FlutterFire CLI kurulumu ve yapılandırma

**Bağımlılık:** Yok  
**Tahmini Süre:** 1-2 saat

### 1.2 Firebase Auth Yapılandırma
- [ ] Email/Password authentication aktifleştirme
- [ ] Google Sign-In aktifleştirme
  - [ ] iOS: URL schemes yapılandırma
  - [ ] Android: SHA-1/SHA-256 ekleme
- [ ] Apple Sign-In aktifleştirme
  - [ ] Apple Developer hesabında Sign in with Apple yapılandırma
  - [ ] Service ID oluşturma

**Bağımlılık:** 1.1  
**Tahmini Süre:** 2-3 saat

### 1.3 Cloud Firestore Yapılandırma
- [ ] Firestore database oluşturma (Production mode)
- [ ] Security Rules yazma
- [ ] Indexes oluşturma
- [ ] Collections yapısı:
  - [ ] `users`
  - [ ] `users/{userId}/products`
  - [ ] `users/{userId}/videos`
  - [ ] `users/{userId}/transactions`
  - [ ] `templates` (admin-managed)

**Bağımlılık:** 1.1  
**Tahmini Süre:** 2-3 saat

#### Firestore Security Rules (Başlangıç)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users - sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections
      match /products/{productId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /videos/{videoId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /transactions/{transactionId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if false; // Sadece Cloud Functions yazabilir
      }
    }
    
    // Templates - herkes okuyabilir, sadece admin yazabilir
    match /templates/{templateId} {
      allow read: if request.auth != null;
      allow write: if false; // Sadece admin/Cloud Functions
    }
  }
}
```

### 1.4 Firebase Storage Yapılandırma
- [ ] Storage bucket oluşturma
- [ ] Security Rules yazma
- [ ] CORS yapılandırma
- [ ] Folder yapısı:
  - [ ] `users/{userId}/products/{productId}/`
  - [ ] `users/{userId}/videos/{videoId}/`

**Bağımlılık:** 1.1  
**Tahmini Süre:** 1-2 saat

#### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 1.5 Cloud Functions Projesi Kurulumu
- [ ] Functions projesi oluşturma (TypeScript)
- [ ] Secret Manager yapılandırma
- [ ] Emulator kurulumu (local development)
- [ ] Deployment pipeline (staging/production)

**Bağımlılık:** 1.1  
**Tahmini Süre:** 2-3 saat

---

## Phase 2: Flutter - Firebase Entegrasyonu

### 2.1 Firebase Core Entegrasyonu
- [ ] `firebase_core` paketi ekleme
- [ ] `firebase_options.dart` oluşturma (FlutterFire CLI)
- [ ] Main.dart'ta Firebase initialization
- [ ] iOS/Android platform yapılandırmaları

**Bağımlılık:** Phase 1  
**Tahmini Süre:** 1-2 saat

### 2.2 Auth Service Implementasyonu
- [ ] AuthService sınıfı oluşturma
- [ ] Email/Password sign up
- [ ] Email/Password sign in
- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Password reset
- [ ] Sign out
- [ ] Auth state listener
- [ ] User session management

**Bağımlılık:** 2.1  
**Tahmini Süre:** 4-6 saat

### 2.3 Firestore Service Implementasyonu
- [ ] FirestoreService sınıfı oluşturma
- [ ] User CRUD operations
- [ ] Product CRUD operations
- [ ] Video CRUD operations
- [ ] Transaction read operations
- [ ] Template read operations
- [ ] Real-time listeners

**Bağımlılık:** 2.1  
**Tahmini Süre:** 4-6 saat

### 2.4 Storage Service Implementasyonu
- [ ] StorageService sınıfı oluşturma
- [ ] Image upload (with compression)
- [ ] Video download
- [ ] Progress tracking
- [ ] File deletion
- [ ] URL generation

**Bağımlılık:** 2.1  
**Tahmini Süre:** 3-4 saat

### 2.5 Cloud Functions Client
- [ ] FunctionsService sınıfı oluşturma
- [ ] Callable functions için wrapper
- [ ] Error handling
- [ ] Retry logic

**Bağımlılık:** 2.1  
**Tahmini Süre:** 2-3 saat

---

## Phase 3: RevenueCat Entegrasyonu

### 3.1 RevenueCat Dashboard Kurulumu
- [ ] RevenueCat hesabı oluşturma
- [ ] Proje oluşturma
- [ ] iOS App ekleme
  - [ ] App Store Connect entegrasyonu
  - [ ] Shared Secret ekleme
- [ ] Android App ekleme
  - [ ] Google Play Console entegrasyonu
  - [ ] Service Account JSON ekleme

**Bağımlılık:** Yok  
**Tahmini Süre:** 2-3 saat

### 3.2 App Store / Play Store Ürün Tanımlama
- [ ] **App Store Connect:**
  - [ ] `prodvid_weekly_subscription` - Auto-renewable ($19.99/hafta)
  - [ ] `prodvid_yearly_subscription` - Auto-renewable ($199.99/yıl)
  - [ ] `prodvid_credits_2000` - Consumable ($39.99)
  - [ ] `prodvid_credits_7000` - Consumable ($99.99)
  - [ ] `prodvid_credits_15000` - Consumable ($199.00)
- [ ] **Google Play Console:**
  - [ ] Aynı ürünler için tanımlama
  - [ ] Base plans ve offers

**Bağımlılık:** 3.1  
**Tahmini Süre:** 3-4 saat

### 3.3 RevenueCat Yapılandırma
- [ ] Products oluşturma (RevenueCat dashboard)
- [ ] Entitlements oluşturma (`premium`)
- [ ] Offerings oluşturma
  - [ ] `default` offering
  - [ ] Packages: weekly, yearly, credits
- [ ] API Keys alma (Public + Secret)

**Bağımlılık:** 3.2  
**Tahmini Süre:** 1-2 saat

### 3.4 Flutter RevenueCat SDK Entegrasyonu
- [ ] `purchases_flutter` paketi ekleme
- [ ] RevenueCatService sınıfı oluşturma
- [ ] SDK initialization
- [ ] User identification (Firebase UID ile)
- [ ] Offerings fetch
- [ ] Purchase flow (subscription)
- [ ] Purchase flow (consumable credits)
- [ ] Restore purchases
- [ ] Subscription status check
- [ ] Entitlement listener

**Bağımlılık:** 3.3, 2.2  
**Tahmini Süre:** 4-6 saat

### 3.5 RevenueCat Webhook Entegrasyonu
- [ ] Cloud Function: `onRevenueCatWebhook`
- [ ] Webhook URL'i RevenueCat'e ekleme
- [ ] Event handling:
  - [ ] `INITIAL_PURCHASE` - İlk subscription
  - [ ] `RENEWAL` - Subscription yenileme (kredileri sıfırla + yükle)
  - [ ] `CANCELLATION` - İptal
  - [ ] `EXPIRATION` - Süre dolumu (subscription kredilerini sil)
  - [ ] `NON_RENEWING_PURCHASE` - Kredi paketi satın alma
- [ ] Kredi güncelleme logic
- [ ] Transaction logging

**Bağımlılık:** 1.5, 3.3  
**Tahmini Süre:** 4-6 saat

#### Webhook Cloud Function (Taslak)

```typescript
// functions/src/webhooks/revenuecat.ts

export const onRevenueCatWebhook = functions.https.onRequest(async (req, res) => {
  const event = req.body;
  const userId = event.app_user_id; // Firebase UID
  
  switch (event.event.type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
      await handleSubscriptionRenewal(userId, event);
      break;
    case 'EXPIRATION':
    case 'CANCELLATION':
      await handleSubscriptionEnd(userId, event);
      break;
    case 'NON_RENEWING_PURCHASE':
      await handleCreditPurchase(userId, event);
      break;
  }
  
  res.status(200).send('OK');
});

async function handleSubscriptionRenewal(userId: string, event: any) {
  const productId = event.product.id;
  const credits = productId.includes('weekly') ? 500 : 4000;
  
  await db.collection('users').doc(userId).update({
    'credits.subscription': credits,
    'subscription.status': 'active',
    'subscription.plan': productId.includes('weekly') ? 'weekly' : 'yearly',
    'subscription.currentPeriodEnd': event.expiration_at_ms,
  });
  
  await logTransaction(userId, 'subscription_renewal', credits, productId);
}

async function handleCreditPurchase(userId: string, event: any) {
  const productId = event.product.id;
  const creditMap = {
    'prodvid_credits_2000': 2000,
    'prodvid_credits_7000': 7000,
    'prodvid_credits_15000': 15000,
  };
  const credits = creditMap[productId] || 0;
  
  await db.collection('users').doc(userId).update({
    'credits.purchased': FieldValue.increment(credits),
  });
  
  await logTransaction(userId, 'credit_purchase', credits, productId);
}
```

---

## Phase 4: wiro.ai Entegrasyonu

> **Not:** wiro.ai API detayları kullanıcı tarafından sağlanacak. Bu bölüm placeholder olarak hazırlanmıştır.

### 4.1 wiro.ai API Araştırma
- [ ] API documentation inceleme
- [ ] Authentication yöntemi belirleme
- [ ] Rate limits ve quotas öğrenme
- [ ] Pricing model anlama
- [ ] Template structure anlama

**Bağımlılık:** Yok  
**Tahmini Süre:** TBD

### 4.2 API Key Güvenliği
- [ ] wiro.ai API key'i Secret Manager'a ekleme
- [ ] Cloud Function'dan erişim yapılandırma

**Bağımlılık:** 1.5, 4.1  
**Tahmini Süre:** 1 saat

### 4.3 Cloud Functions - wiro.ai Proxy
- [ ] `createVideo` function
  - [ ] Kredi kontrolü
  - [ ] wiro.ai API çağrısı
  - [ ] Video job başlatma
  - [ ] Firestore video document oluşturma
- [ ] `getVideoStatus` function (veya webhook)
- [ ] `listTemplates` function (veya Firestore sync)

**Bağımlılık:** 4.2  
**Tahmini Süre:** 6-8 saat

### 4.4 wiro.ai Webhook Handler
- [ ] Video tamamlandığında notification
- [ ] Video URL'ini Firestore'a kaydetme
- [ ] Hata durumunda kullanıcı bilgilendirme
- [ ] Kredi iade logic (hata durumunda)

**Bağımlılık:** 4.3  
**Tahmini Süre:** 3-4 saat

### 4.5 Flutter - Video Service
- [ ] VideoService sınıfı oluşturma
- [ ] Template listesi çekme
- [ ] Video oluşturma isteği
- [ ] Video durumu takibi
- [ ] Video indirme

**Bağımlılık:** 4.3, 2.5  
**Tahmini Süre:** 4-6 saat

---

## Phase 5: UI Implementation

### 5.1 Design System
- [ ] Colors, typography, spacing
- [ ] Common widgets
- [ ] Theme (light/dark)
- [ ] Asset management

**Tahmini Süre:** 4-6 saat

### 5.2 Auth Screens
- [ ] Splash screen
- [ ] Onboarding screens (3-4)
- [ ] Login screen
- [ ] Register screen
- [ ] Forgot password screen

**Bağımlılık:** 5.1, 2.2  
**Tahmini Süre:** 6-8 saat

### 5.3 Main Screens
- [ ] Home/Dashboard
- [ ] Video list
- [ ] Profile
- [ ] Settings
- [ ] Credits/Transactions

**Bağımlılık:** 5.1, 2.3  
**Tahmini Süre:** 8-10 saat

### 5.4 Video Creation Flow
- [ ] Photo upload screen
- [ ] Product info screen
- [ ] Template selection screen
- [ ] Aspect ratio selection
- [ ] Confirmation screen
- [ ] Processing screen
- [ ] Video ready screen

**Bağımlılık:** 5.1, 4.5  
**Tahmini Süre:** 10-12 saat

### 5.5 Paywall & Purchases
- [ ] Paywall screen
- [ ] Subscription options
- [ ] Credit packages
- [ ] Success/failure screens

**Bağımlılık:** 5.1, 3.4  
**Tahmini Süre:** 4-6 saat

### 5.6 Video Detail & Sharing
- [ ] Video player
- [ ] Download functionality
- [ ] Share sheet
- [ ] Social media deep links

**Bağımlılık:** 5.3  
**Tahmini Süre:** 4-6 saat

---

## Phase 6: Testing & QA

### 6.1 Unit Tests
- [ ] Services tests
- [ ] Business logic tests
- [ ] Model tests

### 6.2 Integration Tests
- [ ] Auth flow
- [ ] Video creation flow
- [ ] Purchase flow

### 6.3 Manual Testing
- [ ] Full flow testing (iOS)
- [ ] Full flow testing (Android)
- [ ] Edge cases
- [ ] Error scenarios

### 6.4 Sandbox Testing
- [ ] RevenueCat sandbox purchases
- [ ] Subscription renewal testing
- [ ] Credit purchase testing

---

## Phase 7: Deployment

### 7.1 Pre-launch
- [ ] App icons ve splash screens
- [ ] Store assets (screenshots, descriptions)
- [ ] Privacy policy
- [ ] Terms of service

### 7.2 Cloud Functions Deployment
- [ ] Staging environment test
- [ ] Production deployment
- [ ] Monitoring setup

### 7.3 App Store Submission
- [ ] iOS build
- [ ] App Store Connect submission
- [ ] Review process

### 7.4 Play Store Submission
- [ ] Android build
- [ ] Play Console submission
- [ ] Review process

---

## Görev Takip Tablosu

| Phase | Görev | Durum | Öncelik | Bağımlılık | Tahmini Süre |
|-------|-------|-------|---------|------------|--------------|
| 0.1 | Flutter Proje Kurulumu | ⬜ Bekliyor | P0 | - | 2-3 saat |
| 0.2 | Paketlerin Eklenmesi | ⬜ Bekliyor | P0 | 0.1 | 1 saat |
| 1.1 | Firebase Projesi | ⬜ Bekliyor | P0 | - | 1-2 saat |
| 1.2 | Firebase Auth | ⬜ Bekliyor | P0 | 1.1 | 2-3 saat |
| 1.3 | Firestore | ⬜ Bekliyor | P0 | 1.1 | 2-3 saat |
| 1.4 | Storage | ⬜ Bekliyor | P0 | 1.1 | 1-2 saat |
| 1.5 | Cloud Functions | ⬜ Bekliyor | P0 | 1.1 | 2-3 saat |
| 2.1 | Firebase Core | ⬜ Bekliyor | P0 | 1.x | 1-2 saat |
| 2.2 | Auth Service | ⬜ Bekliyor | P0 | 2.1 | 4-6 saat |
| 2.3 | Firestore Service | ⬜ Bekliyor | P0 | 2.1 | 4-6 saat |
| 2.4 | Storage Service | ⬜ Bekliyor | P1 | 2.1 | 3-4 saat |
| 2.5 | Functions Client | ⬜ Bekliyor | P1 | 2.1 | 2-3 saat |
| 3.1 | RevenueCat Dashboard | ⬜ Bekliyor | P0 | - | 2-3 saat |
| 3.2 | Store Products | ⬜ Bekliyor | P0 | 3.1 | 3-4 saat |
| 3.3 | RC Yapılandırma | ⬜ Bekliyor | P0 | 3.2 | 1-2 saat |
| 3.4 | RC Flutter SDK | ⬜ Bekliyor | P0 | 3.3, 2.2 | 4-6 saat |
| 3.5 | RC Webhooks | ⬜ Bekliyor | P0 | 1.5, 3.3 | 4-6 saat |
| 4.1 | wiro.ai Araştırma | ⬜ Bekliyor | P0 | - | TBD |
| 4.2 | API Key Güvenliği | ⬜ Bekliyor | P0 | 4.1 | 1 saat |
| 4.3 | wiro.ai Functions | ⬜ Bekliyor | P0 | 4.2 | 6-8 saat |
| 4.4 | wiro.ai Webhooks | ⬜ Bekliyor | P1 | 4.3 | 3-4 saat |
| 4.5 | Video Service | ⬜ Bekliyor | P0 | 4.3 | 4-6 saat |
| 5.1 | Design System | ⬜ Bekliyor | P0 | 0.x | 4-6 saat |
| 5.2 | Auth Screens | ⬜ Bekliyor | P0 | 5.1, 2.2 | 6-8 saat |
| 5.3 | Main Screens | ⬜ Bekliyor | P0 | 5.1 | 8-10 saat |
| 5.4 | Video Creation | ⬜ Bekliyor | P0 | 5.1, 4.5 | 10-12 saat |
| 5.5 | Paywall | ⬜ Bekliyor | P0 | 5.1, 3.4 | 4-6 saat |
| 5.6 | Video Detail | ⬜ Bekliyor | P1 | 5.3 | 4-6 saat |

---

## Notlar

- ⬜ Bekliyor
- 🔄 Devam Ediyor
- ✅ Tamamlandı
- ❌ İptal/Bloke

---

## Tahmini Toplam Süre

| Phase | Süre |
|-------|------|
| Phase 0: Proje Kurulumu | 3-4 saat |
| Phase 1: Firebase Kurulumu | 8-13 saat |
| Phase 2: Firebase Entegrasyonu | 14-21 saat |
| Phase 3: RevenueCat | 14-21 saat |
| Phase 4: wiro.ai | 14-20 saat (TBD) |
| Phase 5: UI | 36-48 saat |
| Phase 6: Testing | 10-15 saat |
| Phase 7: Deployment | 8-12 saat |
| **TOPLAM** | **~100-150 saat** |

> Bu tahminler solo developer için hesaplanmıştır. Ekip boyutuna göre değişebilir.

