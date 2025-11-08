# Assets / Animations

Bu klasöre Lottie animasyon dosyalarını (.json) ekleyiniz.

## Önerilen Animasyonlar

### Loading / Splash
- **loading.json** - Yükleme animasyonu
- **splash.json** - Splash screen animasyonu

### Empty States
- **empty_reservations.json** - Boş rezervasyon listesi
- **empty_cart.json** - Boş sepet
- **empty_search.json** - Arama sonucu bulunamadı

### Success / Error
- **success.json** - Başarılı işlem animasyonu
- **error.json** - Hata animasyonu
- **payment_success.json** - Ödeme başarılı

### Feature Specific
- **qr_scan.json** - QR kod tarama animasyonu
- **food_animation.json** - Yemek animasyonu
- **wallet_animation.json** - Cüzdan animasyonu

## Lottie Kaynakları

Ücretsiz Lottie animasyonları bulabileceğiniz siteler:

- [LottieFiles](https://lottiefiles.com/)
- [IconScout](https://iconscout.com/lottie-animations)
- [Lordicon](https://lordicon.com/)

## Kullanım

```dart
import 'package:lottie/lottie.dart';

Lottie.asset('assets/animations/loading.json')
```

## Not

Animasyonlar opsiyoneldir. Uygulama animasyonlar olmadan da çalışacaktır.

