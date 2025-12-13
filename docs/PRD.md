# ProdVid - Product Requirements Document

**Versiyon:** 1.0  
**Tarih:** 13 Aralık 2025  
**Durum:** Draft

---

## 1. Giriş

### 1.1 Vizyon

ProdVid, e-ticaret satıcılarının ve içerik üreticilerinin ürünleri için profesyonel kalitede pazarlama videoları oluşturmasını sağlayan, AI destekli bir mobil uygulamadır.

### 1.2 Misyon

Küçük ve orta ölçekli işletmelerin, pahalı video prodüksiyon süreçlerine ihtiyaç duymadan, dakikalar içinde sosyal medya ve e-ticaret platformları için çekici ürün videoları oluşturmasını demokratikleştirmek.

### 1.3 Hedef Kitle

| Segment | Açıklama |
|---------|----------|
| E-ticaret Satıcıları | Shopify, Etsy, Amazon vb. platformlarda ürün satan bireysel satıcılar |
| Küçük İşletmeler | Sosyal medyada ürün tanıtımı yapmak isteyen küçük mağazalar |
| İçerik Üreticileri | Influencer'lar ve affiliate pazarlamacılar |
| Sosyal Medya Yöneticileri | Markalar için içerik üreten profesyoneller |

### 1.4 Problem Tanımı

- Profesyonel ürün videoları oluşturmak pahalı ve zaman alıcı
- Küçük işletmelerin video prodüksiyon bütçesi kısıtlı
- Video düzenleme becerileri gerektiren araçlar karmaşık
- Sosyal medya platformları video içeriği tercih ediyor

### 1.5 Çözüm

ProdVid, kullanıcıların sadece ürün fotoğrafları ve açıklama metni girerek AI destekli profesyonel videolar oluşturmasını sağlar. wiro.ai template'leri kullanılarak çeşitli stil ve formatlarda videolar üretilir.

---

## 2. Özellikler

### 2.1 Temel Özellikler (MVP)

#### 2.1.1 Kullanıcı Yönetimi
- Email/şifre ile kayıt ve giriş
- Google Sign-In
- Apple Sign-In
- Şifre sıfırlama
- Profil yönetimi

#### 2.1.2 Ürün Ekleme
- Birden fazla ürün fotoğrafı yükleme (galeri/kamera)
- Ürün başlığı girişi
- Ürün açıklaması girişi
- Fiyat bilgisi (opsiyonel)
- Öne çıkan özellikler (bullet points)

#### 2.1.3 Video Oluşturma
- Template kategorileri görüntüleme
- Template önizleme
- Template seçimi
- Video boyutu seçimi (9:16, 16:9, 1:1)
- AI video oluşturma
- Video oluşturma ilerleme takibi

#### 2.1.4 Video Yönetimi
- Oluşturulan videoları listeleme
- Video önizleme
- Video indirme (cihaza kaydetme)
- Video silme
- Video yeniden oluşturma

#### 2.1.5 Paylaşım
- Direkt sosyal medya paylaşımı (Instagram, TikTok, Facebook, YouTube)
- Link kopyalama
- Diğer uygulamalara paylaşım

### 2.2 Gelecek Özellikler (Post-MVP)

- Video düzenleme (metin, müzik değiştirme)
- Marka kiti (logo, renkler, fontlar)
- Toplu video oluşturma
- Video zamanlama (scheduled posting)
- Analytics dashboard
- Team/workspace desteği

---

## 3. Teknik Mimari

### 3.1 Teknoloji Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Flutter Application                        │ │
│  │                  iOS / Android                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND SERVICES                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Firebase   │  │   Cloud      │  │   Firebase   │       │
│  │     Auth     │  │  Firestore   │  │   Storage    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │    Cloud     │  │   Secret     │                         │
│  │  Functions   │  │   Manager    │                         │
│  └──────────────┘  └──────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES                          │
│  ┌──────────────────────┐  ┌──────────────────────┐         │
│  │       wiro.ai        │  │     RevenueCat       │         │
│  │  (Video Generation)  │  │   (Subscriptions)    │         │
│  └──────────────────────┘  └──────────────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Güvenlik Mimarisi

API key'ler ve hassas bilgiler **asla client-side'da tutulmayacak**:

| Servis | Anahtar Tipi | Saklama Yeri | Erişim Yöntemi |
|--------|--------------|--------------|----------------|
| wiro.ai | API Key | Secret Manager | Cloud Functions üzerinden |
| RevenueCat | Public API Key | Client-side (güvenli) | Direkt SDK |
| RevenueCat | Secret API Key | Secret Manager | Cloud Functions |
| Firebase | Config | google-services.json / Info.plist | Build-time |

### 3.3 Cloud Functions Rolleri

1. **Video Generation Proxy**
   - wiro.ai API çağrılarını yönetme
   - Rate limiting ve quota kontrolü
   - Error handling ve retry logic

2. **Credit Management**
   - Kredi doğrulama
   - Kredi düşme işlemleri
   - Transaction logging

3. **Webhook Handlers**
   - RevenueCat subscription events
   - wiro.ai video completion events

4. **Scheduled Jobs**
   - Expired video cleanup
   - Usage analytics aggregation

---

## 4. Veri Modelleri

### 4.1 Users Collection

```
users/{userId}
├── email: string
├── displayName: string
├── photoURL: string?
├── createdAt: timestamp
├── updatedAt: timestamp
├── credits: {
│   ├── subscription: number      // Abonelikten gelen krediler (yenilenince sıfırlanır)
│   └── purchased: number         // Satın alınan ek krediler (süresiz)
│   }
├── subscription: {
│   ├── status: 'active' | 'expired' | 'cancelled' | 'none'
│   ├── plan: 'weekly' | 'yearly' | null
│   ├── currentPeriodStart: timestamp?
│   ├── currentPeriodEnd: timestamp?
│   └── revenueCatId: string?
│   }
└── settings: {
    ├── notifications: boolean
    └── language: string
    }
```

**Kredi Kullanım Logic:**
```
totalCredits = credits.subscription + credits.purchased

// Video oluşturulurken:
if (credits.subscription >= templateCost) {
    credits.subscription -= templateCost
} else {
    remaining = templateCost - credits.subscription
    credits.subscription = 0
    credits.purchased -= remaining
}
```

### 4.2 Products Collection

```
users/{userId}/products/{productId}
├── title: string
├── description: string
├── price: string?
├── features: string[]
├── images: string[] (Storage URLs)
├── createdAt: timestamp
└── updatedAt: timestamp
```

### 4.3 Videos Collection

```
users/{userId}/videos/{videoId}
├── productId: string
├── templateId: string
├── status: 'pending' | 'processing' | 'completed' | 'failed'
├── aspectRatio: '9:16' | '16:9' | '1:1'
├── videoUrl: string? (Storage URL)
├── thumbnailUrl: string?
├── duration: number? (seconds)
├── createdAt: timestamp
├── completedAt: timestamp?
├── error: string?
└── wiroJobId: string?
```

### 4.4 Transactions Collection

```
users/{userId}/transactions/{transactionId}
├── type: 'subscription_renewal' | 'credit_purchase' | 'credit_used' | 'subscription_expired'
├── creditType: 'subscription' | 'purchased'
├── amount: number (positive for add, negative for use)
├── balanceAfter: {
│   ├── subscription: number
│   └── purchased: number
│   }
├── description: string
├── relatedVideoId: string?
├── relatedProductId: string? (RevenueCat product ID)
├── createdAt: timestamp
└── metadata: map
```

**Transaction Örnekleri:**
- `subscription_renewal`: Abonelik yenilendi, subscription kredileri sıfırlandı ve yeniden yüklendi
- `credit_purchase`: Ek kredi paketi satın alındı
- `credit_used`: Video oluşturmak için kredi harcandı
- `subscription_expired`: Abonelik sona erdi, kalan subscription kredileri silindi

### 4.5 Templates Collection (Read-only, synced from wiro.ai)

```
templates/{templateId}
├── name: string
├── category: string
├── thumbnailUrl: string
├── previewVideoUrl: string
├── supportedAspectRatios: string[]
├── creditCost: number
├── isActive: boolean
└── metadata: map
```

---

## 5. Monetization

### 5.1 Subscription Planları

| Plan | Süre | Krediler | Fiyat | Kredi/$ | Özellikler |
|------|------|----------|-------|---------|------------|
| **Haftalık** | 7 gün | 500 | $19.99 | 25 | Tüm template'ler, Watermark yok, HD export |
| **Yıllık** | 365 gün | 4000 | $199.99 | 20 | Haftalık ile aynı + öncelikli destek |

> **Not:** Yıllık plan, haftalık plana göre yaklaşık %80 tasarruf sağlar (52 hafta × $19.99 = $1039.48 vs $199.99)

### 5.2 Kredi Paketleri

Abonelik dışında ek kredi satın alma:

| Paket | Kredi | Fiyat | Kredi/$ | Tasarruf |
|-------|-------|-------|---------|----------|
| **Starter** | 2,000 | $39.99 | 50 | - |
| **Pro** | 7,000 | $99.99 | 70 | %40 bonus |
| **Business** | 15,000 | $199.00 | 75 | %50 bonus |

### 5.3 Kredi Sistemi

#### Kredi Tipleri

| Tip | Kaynak | Süre | Yenilenme Davranışı |
|-----|--------|------|---------------------|
| **Subscription Kredisi** | Haftalık/Yıllık abonelik | Abonelik süresi boyunca | Yenilendiğinde sıfırlanır, yeni krediler yüklenir |
| **Ek Kredi** | Kredi paketi satın alma | Süresiz | Hiçbir zaman expire olmaz |

#### Kredi Kullanım Kuralları

1. **Öncelik Sırası:** Video oluşturulurken önce subscription kredileri kullanılır, bittikten sonra ek krediler kullanılır
2. **Subscription Yenilenme:** 
   - Kalan subscription kredileri **sıfırlanır** (silinir)
   - Yeni dönem kredileri yüklenir (500 haftalık / 4000 yıllık)
   - Ek krediler **etkilenmez**, aynen kalır
3. **Subscription İptal:** 
   - Subscription kredileri dönem sonunda silinir
   - Ek krediler kullanılabilir olarak kalır
4. **Template Maliyeti:** Template'e göre kredi maliyeti değişebilir (TBD)

### 5.4 RevenueCat Entegrasyonu

RevenueCat ile yönetilecek öğeler:

| Product ID | Tip | Fiyat | Krediler |
|------------|-----|-------|----------|
| `prodvid_weekly_subscription` | Auto-renewable | $19.99/hafta | 500 |
| `prodvid_yearly_subscription` | Auto-renewable | $199.99/yıl | 4000 |
| `prodvid_credits_2000` | Consumable | $39.99 | 2000 |
| `prodvid_credits_7000` | Consumable | $99.99 | 7000 |
| `prodvid_credits_15000` | Consumable | $199.00 | 15000 |

**Entitlement:** `premium` - Aktif subscription olan kullanıcılar için

---

## 6. Kullanıcı Akışları

### 6.1 Onboarding Flow

```
App Launch
    │
    ▼
┌─────────────┐
│  Splash     │
│  Screen     │
└─────────────┘
    │
    ▼
┌─────────────┐     ┌─────────────┐
│  Welcome    │────▶│   Login/    │
│  Screens    │     │  Register   │
└─────────────┘     └─────────────┘
                         │
                         ▼
                    ┌─────────────┐
                    │   Home      │
                    │  Dashboard  │
                    └─────────────┘
```

### 6.2 Video Oluşturma Flow

```
Home Screen
    │
    ▼
┌─────────────┐
│  New Video  │
│   Button    │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Upload    │
│   Photos    │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Enter     │
│ Product Info│
└─────────────┘
    │
    ▼
┌─────────────┐
│   Select    │
│  Template   │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Select    │
│ Aspect Ratio│
└─────────────┘
    │
    ▼
┌─────────────┐     ┌─────────────┐
│   Confirm   │────▶│   Credit    │ (if insufficient)
│  & Create   │     │  Purchase   │
└─────────────┘     └─────────────┘
    │
    ▼
┌─────────────┐
│  Processing │
│   Screen    │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Video     │
│   Ready     │
└─────────────┘
    │
    ▼
┌─────────────────────────────────┐
│  Preview / Download / Share     │
└─────────────────────────────────┘
```

### 6.3 Subscription Satın Alma Flow

```
Paywall Trigger (Insufficient credits, premium feature, etc.)
    │
    ▼
┌─────────────┐
│   Paywall   │
│   Screen    │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Select    │
│    Plan     │
└─────────────┘
    │
    ▼
┌─────────────┐
│   App Store │
│   Payment   │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Success   │
│   Screen    │
└─────────────┘
    │
    ▼
┌─────────────┐
│  Credits    │
│   Added     │
└─────────────┘
```

---

## 7. UI/UX Gereksinimleri

### 7.1 Ekranlar

| Ekran | Açıklama | Öncelik |
|-------|----------|---------|
| Splash Screen | Uygulama başlatma | P0 |
| Onboarding | Uygulama tanıtımı (3-4 slide) | P0 |
| Login/Register | Auth ekranları | P0 |
| Home/Dashboard | Video listesi, istatistikler | P0 |
| New Video - Photos | Fotoğraf yükleme | P0 |
| New Video - Info | Ürün bilgileri girişi | P0 |
| New Video - Template | Template seçimi | P0 |
| Processing | Video oluşturma bekleme | P0 |
| Video Detail | Video önizleme/paylaşım | P0 |
| Paywall | Subscription seçimi | P0 |
| Profile | Kullanıcı ayarları | P1 |
| Credits | Kredi geçmişi | P1 |
| Settings | Uygulama ayarları | P1 |

### 7.2 Tasarım Prensipleri

- Modern ve minimalist UI
- Karanlık mod desteği
- Kolay kullanılabilir, 3 adımda video oluşturma
- Hızlı yükleme ve geçişler
- Tutarlı renk paleti ve tipografi

---

## 8. wiro.ai Entegrasyonu

> **Not:** wiro.ai API detayları ve template bilgileri sonra eklenecektir.

### 8.1 Beklenen Entegrasyon Noktaları

- Template listesi çekme
- Video oluşturma isteği gönderme
- Video durumu sorgulama
- Tamamlanan video URL'si alma

### 8.2 Placeholder API Endpoints

```
GET  /templates          - Template listesi
POST /videos/create      - Video oluşturma başlat
GET  /videos/{id}/status - Video durumu
GET  /videos/{id}        - Video detayları
```

---

## 9. Analytics & Tracking

### 9.1 Takip Edilecek Eventler

| Event | Açıklama |
|-------|----------|
| `app_open` | Uygulama açılışı |
| `sign_up` | Kayıt |
| `sign_in` | Giriş |
| `video_create_started` | Video oluşturma başlatıldı |
| `video_create_completed` | Video tamamlandı |
| `video_download` | Video indirildi |
| `video_share` | Video paylaşıldı |
| `template_selected` | Template seçildi |
| `subscription_started` | Abonelik başladı |
| `subscription_cancelled` | Abonelik iptal edildi |
| `credits_purchased` | Kredi satın alındı |
| `paywall_shown` | Paywall gösterildi |

### 9.2 Analytics Araçları

- Firebase Analytics (varsayılan)
- RevenueCat Analytics (subscription metrics)

---

## 10. Riskler ve Kısıtlamalar

### 10.1 Teknik Riskler

| Risk | Etki | Azaltma |
|------|------|---------|
| wiro.ai API kesintileri | Yüksek | Retry logic, kullanıcı bildirimi |
| Video oluşturma gecikmesi | Orta | Queue sistemi, push notification |
| Storage maliyetleri | Orta | Video retention policy, compression |

### 10.2 İş Riskleri

| Risk | Etki | Azaltma |
|------|------|---------|
| Düşük dönüşüm oranı | Yüksek | A/B test, paywall optimizasyonu |
| Yüksek churn | Yüksek | Engagement features, push notifications |
| Rekabet | Orta | Unique template'ler, better UX |

---

## 11. Başarı Metrikleri

### 11.1 KPI'lar

| Metrik | Hedef (İlk 3 ay) |
|--------|------------------|
| DAU (Daily Active Users) | TBD |
| Video Oluşturma/Gün | TBD |
| Trial-to-Paid Conversion | TBD |
| Monthly Recurring Revenue | TBD |
| Customer Acquisition Cost | TBD |
| Lifetime Value | TBD |

---

## 12. Yol Haritası

### Phase 1: MVP (v1.0)
- Temel auth
- Ürün ekleme
- Video oluşturma (wiro.ai)
- Video indirme/paylaşım
- Subscription & credits

### Phase 2: Enhancement (v1.1)
- Video düzenleme özellikleri
- Marka kiti
- Analytics dashboard
- Performance optimizasyonları

### Phase 3: Growth (v1.2+)
- Toplu video oluşturma
- Team/workspace
- API erişimi
- Gelişmiş template özelleştirme

---

## 13. Açık Sorular

- [ ] wiro.ai pricing ve API limitleri
- [ ] wiro.ai template detayları ve kategorileri
- [x] ~~Haftalık/yıllık subscription kredi miktarları~~ ✓
- [x] ~~Kredi paketleri fiyatlandırma~~ ✓
- [ ] Template başına kredi maliyeti
- [ ] Video saklama süresi (retention policy)
- [ ] Desteklenecek diller

---

## Appendix

### A. Terminoloji

| Terim | Açıklama |
|-------|----------|
| Template | wiro.ai'dan sağlanan video şablonu |
| Credit | Video oluşturmak için kullanılan birim |
| Aspect Ratio | Video en-boy oranı (9:16, 16:9, 1:1) |
| Paywall | Ödeme/abonelik ekranı |

### B. Referanslar

- wiro.ai: [Detaylar eklenecek]
- RevenueCat: https://www.revenuecat.com/
- Firebase: https://firebase.google.com/
- Flutter: https://flutter.dev/

