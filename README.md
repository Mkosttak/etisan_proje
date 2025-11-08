# 📱 ETİSAN - Üniversite Yemekhane Yönetim Sistemi

![ETİSAN Logo](assets/images/logo.png)

## 🎯 Proje Hakkında

**ETİSAN**, üniversite yemekhaneleri için geliştirilmiş modern, akıllı ve israfı azaltan bir yönetim sistemidir. Hem mobil (Android/iOS) hem de web platformunda çalışan, Flutter ile geliştirilmiş cross-platform bir uygulamadır.

### Ana Özellikler

✅ **Nakitsiz Ödeme Sistemi** - Dijital cüzdan ile hızlı ve güvenli ödemeler  
✅ **Akıllı Rezervasyon** - Önceden rezervasyon yaparak yemek garantisi  
✅ **İsraf Azaltma** - Tahmine dayalı üretim ile gıda israfını minimize etme  
✅ **Rezervasyon Takası** - Gelemeyecek öğrenciler rezervasyonlarını devredebilir  
✅ **QR Kod Sistemi** - Hızlı ve temassız yemek teslimi  
✅ **Fiyat Avantajı** - Rezervasyonlu yemekler walk-in'den daha ucuz  
✅ **Yönetim Paneli** - Detaylı raporlar ve analitikler  
✅ **Çoklu Dil Desteği** - Türkçe ve İngilizce

---

## 🏗️ Teknoloji Stack

- **Framework:** Flutter 3.9.2
- **State Management:** Provider
- **Backend:** Supabase (PostgreSQL)
- **UI:** Material Design 3 + Google Fonts
- **QR Code:** qr_flutter, mobile_scanner
- **Grafik:** fl_chart
- **Animasyon:** Lottie, Shimmer

---

## 📂 Proje Yapısı

```
lib/
├── core/
│   ├── constants/      # Sabitler (renkler, strings, constants)
│   ├── theme/          # Tema konfigürasyonları
│   ├── utils/          # Yardımcı fonksiyonlar
│   └── widgets/        # Ortak widget'lar
├── data/
│   ├── models/         # Data modelleri
│   └── services/       # API servisleri
├── providers/          # State management
├── screens/            # Uygulama ekranları
│   ├── auth/           # Giriş, kayıt
│   ├── home/           # Ana sayfa
│   ├── reservations/   # Rezervasyon ekranları
│   ├── balance/        # Bakiye yönetimi
│   ├── swap/           # Takas sistemi
│   ├── profile/        # Profil ayarları
│   └── admin/          # Yönetici paneli
└── main.dart           # Uygulama giriş noktası
```

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK (3.9.2 veya üzeri)
- Dart SDK
- Android Studio / VS Code
- Supabase hesabı (backend için)

### Adımlar

1. **Projeyi klonlayın:**
```bash
git clone https://github.com/your-username/etisan_proje3.git
cd etisan_proje3
```

2. **Paketleri yükleyin:**
```bash
flutter pub get
```

3. **Supabase Konfigürasyonu:**
   - Supabase'de yeni bir proje oluşturun
   - `lib/core/constants/app_constants.dart` dosyasında Supabase bilgilerinizi güncelleyin:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Uygulamayı çalıştırın:**
```bash
# Mobil (Android/iOS)
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

---

## 🎨 Ekran Görüntüleri

### Mobil Ekranlar

| Giriş Ekranı | Ana Sayfa | Rezervasyon |
|:---:|:---:|:---:|
| ![Login](assets/screenshots/login.png) | ![Home](assets/screenshots/home.png) | ![Reservation](assets/screenshots/reservation.png) |

### Admin Paneli

| Dashboard | Raporlar | Menü Yönetimi |
|:---:|:---:|:---:|
| ![Dashboard](assets/screenshots/admin_dashboard.png) | ![Reports](assets/screenshots/reports.png) | ![Menu](assets/screenshots/menu.png) |

---

## 👥 Kullanıcı Rolleri

### 1. **Öğrenci (Student)**
- ✅ Rezervasyon oluşturma
- ✅ Bakiye yükleme
- ✅ QR kod ile ödeme
- ✅ Rezervasyon iptali/takası
- ✅ İşlem geçmişi görüntüleme

### 2. **Personel (Staff)**
- Öğrencilerle aynı yetkiler

### 3. **Yönetici (Admin)**
- ✅ Tüm öğrenci yetkileri
- ✅ Menü yönetimi
- ✅ Öğrenci yönetimi
- ✅ Raporlama ve analitik
- ✅ Sistem ayarları

---

## 🎯 Demo Kullanıcılar

Uygulamayı test etmek için aşağıdaki hesapları kullanabilirsiniz:

| Rol | E-posta | Şifre |
|---|---|---|
| **Öğrenci** | student@etisan.com | password123 |
| **Yönetici** | admin@etisan.com | password123 |

---

## 📱 Özellik Detayları

### Rezervasyon Sistemi
- 7 gün önceden rezervasyon
- Yemek türü filtreleme (Normal, Vejetaryen, Vegan, Glutensiz)
- Öğün bazlı rezervasyon (Kahvaltı, Öğle, Akşam)
- Kontenjan takibi
- Alerjen uyarıları

### Fiyatlandırma
- **Rezervasyonlu:** İndirimli fiyat (örn. ₺15)
- **Anında Alım:** Tam fiyat (örn. ₺22)
- Öğrencileri önceden planlama yapmaya teşvik eder

### İptal Politikası
- Yemek tarihinden **24 saat önce** iptal edilebilir
- **%50 iade** yapılır (ayarlanabilir)
- Son gün iptal edilemez

### Takas Sistemi
- Yemek tarihinden **48 saat önce** takas açılabilir
- Diğer öğrenciler rezervasyonu devralabilir
- Otomatik transfer ve bildirim
- Takas ücretsiz

### Bakiye Yönetimi
- Minimum: ₺10 - Maksimum: ₺1000
- Hızlı seçim butonları (₺50, ₺100, ₺200, ₺500)
- Detaylı işlem geçmişi
- Mock ödeme sistemi (gerçek üretimde banka entegrasyonu)

---

## 🔐 Güvenlik

- ✅ Supabase Row Level Security (RLS)
- ✅ JWT tabanlı authentication
- ✅ Şifreleme ve güvenli veri saklama
- ✅ API rate limiting
- ✅ XSS ve SQL injection koruması

---

## 🌍 Çoklu Dil Desteği

Uygulama şu anda 2 dili desteklemektedir:
- 🇹🇷 Türkçe (Varsayılan)
- 🇬🇧 İngilizce

Yeni diller eklemek için `lib/core/constants/app_strings.dart` dosyasını güncelleyin.

---

## 📊 Database Şeması (Supabase)

### Users Tablosu
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  school_email TEXT,
  phone TEXT,
  student_number TEXT,
  role TEXT DEFAULT 'student',
  balance DECIMAL(10,2) DEFAULT 0,
  school TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

### Meals Tablosu
```sql
CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  meal_type TEXT NOT NULL,
  meal_period TEXT NOT NULL,
  meal_date TIMESTAMP NOT NULL,
  reservation_price DECIMAL(10,2) NOT NULL,
  walk_in_price DECIMAL(10,2) NOT NULL,
  total_spots INTEGER NOT NULL,
  available_spots INTEGER NOT NULL,
  allergens TEXT[],
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

### Reservations Tablosu
```sql
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  meal_id UUID REFERENCES meals(id),
  meal_name TEXT NOT NULL,
  meal_type TEXT NOT NULL,
  meal_period TEXT NOT NULL,
  meal_date TIMESTAMP NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'reserved',
  qr_code TEXT,
  is_transfer_open BOOLEAN DEFAULT FALSE,
  transferred_to_user_id UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP,
  consumed_at TIMESTAMP,
  cancelled_at TIMESTAMP
);
```

### Transactions Tablosu
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  type TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  balance_after DECIMAL(10,2) NOT NULL,
  description TEXT,
  reservation_id UUID REFERENCES reservations(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🧪 Test

```bash
# Unit testleri çalıştır
flutter test

# Integration testleri
flutter test integration_test

# Widget testleri
flutter test test/widget_test.dart
```

---

## 📦 Build

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

---

## 🔮 Gelecek Özellikler

- [ ] Push bildirimleri
- [ ] Sosyal medya entegrasyonu
- [ ] Yemek değerlendirme ve yorum sistemi
- [ ] Favori yemekler
- [ ] Beslenme bilgileri ve kalori takibi
- [ ] Gerçek banka API entegrasyonu
- [ ] Mobil ödeme (Apple Pay, Google Pay)
- [ ] Yemek fotoğrafları
- [ ] AI tabanlı yemek önerileri

---

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

---

## 📄 Lisans

Bu proje MIT lisansı ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 📞 İletişim

**Proje Sahibi:** ETİSAN Team

- 📧 Email: info@etisan.com
- 🌐 Website: www.etisan.com
- 📱 GitHub: [@etisan](https://github.com/etisan)

---

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Supabase ekibine backend altyapısı için
- Tüm açık kaynak katkıda bulunanlara

---

**ETİSAN** ile üniversite yemekhanelerinde dijital dönüşüm! 🍽️📱
