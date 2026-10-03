# 📻 Nostaji Radyo — Klasik Antika Masa Radyosu

Türk nostaljik müziklerini ve canlı radyo yayınlarını antika radyo temasıyla dinleyebileceğiniz bir Android uygulamasıdır. Gerçekçi ahşap radyo tasarımı ve animasyonlu frekans kadranıyla nostalji deneyimi yaşatır.

## ✨ Özellikler

- 📻 Antika radyo arayüzü (gerçekçi 3D tasarım)
- 🎵 Türk nostaljik/klasik müzik istasyonları
- 📡 Canlı radyo yayını akışı (HLS/AAC)
- 🎨 Animasyonlu frekans kadranı (flutter_animate)
- 🔊 Arka planda müzik çalma
- 📱 Hem Flutter hem web sürümü

## 🛠️ Teknolojiler

| Katman | Teknoloji |
|--------|-----------|
| Mobil UI | Flutter 3.x (Dart) |
| Animasyon | flutter_animate ^4.5.0 |
| Ses | audioplayers ^6.0.0 |
| Font | Google Fonts |
| Web Sürümü | HTML5 + CSS3 + JavaScript |
| Platform | Android APK |

## 📋 Gereksinimler

**Flutter sürümü:**
- Flutter SDK ≥ 3.0.0
- Android SDK 21+
- Java 17+

**Web sürümü için:**
- Herhangi bir web sunucusu (Apache, Nginx veya Live Server)

## 🚀 Kurulum

### Flutter Sürümü
```bash
flutter pub get
flutter run
```

### APK Derleme
```powershell
.\apk_yap.ps1
# veya
.\apk_yap.bat
```

### Web Sürümü
```bash
# dist/ klasörünü bir web sunucusunda yayınla
# veya doğrudan www/index.html'i aç
```

## 📁 Proje Yapısı

```
├── lib/              # Flutter kaynak kodları
├── android_flutter/  # Flutter Android proje
├── android/          # Web wrapper Android proje
├── assets/           # Görseller, sesler
├── www/              # Web sürümü
├── dist/             # Derlenmiş web çıktısı
└── pubspec.yaml
```

## 👨‍💻 Geliştirici

**Yazgan Bilişim**  
E-posta: yazganbilisim2026@gmail.com
Web: [yazganbilesim.com](https://yazganbilesim.com)  
GitHub: [@nihatyazgan1962](https://github.com/nihatyazgan1962)
