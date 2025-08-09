# Alarm Bayi Flutter App

Aplikasi Flutter untuk sistem alarm bayi dengan Firebase Authentication.

## 🚀 Features

- 📱 Aplikasi mobile native untuk Android
- 🔊 Audio alarm menggunakan audioplayers plugin
- 🔐 Firebase Authentication
- 📡 Real-time communication (Socket.IO integration ready)
- 🎨 Modern Material Design UI

## 📋 Requirements

- **Flutter SDK**: 3.0+
- **Dart SDK**: 2.17+
- **Android SDK**: Minimum version 23 (Android 6.0)
- **Target SDK**: 35
- **Firebase Project** dengan Authentication enabled

## 🛠️ Setup

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/alarm-bayi-flutter.git
cd alarm-bayi-flutter
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
1. Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication dengan email/password
3. Download `google-services.json` ke `android/app/`
4. Jalankan `flutter pub run firebase_tools:flutter_tools_installer`

### 4. Build & Run
```bash
# Debug mode
flutter run

# Release APK
flutter build apk --release
```

## 📁 Project Structure

```
lib/
├── main.dart              # Entry point aplikasi
├── screens/               # UI screens
├── widgets/               # Reusable widgets
├── services/              # Firebase & API services
├── models/                # Data models
└── utils/                 # Helper functions
```

## 🔧 Configuration

### Android SDK Versions
- **compileSdk**: 35
- **minSdk**: 23
- **targetSdk**: 35

### Dependencies
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `audioplayers` - Audio playback
- `socket_io_client` - Real-time communication

## 🐛 Troubleshooting

### Build Issues
1. **SDK Version Error**: Pastikan Android SDK 35 terinstall
2. **Firebase Auth Error**: Periksa `google-services.json` sudah benar
3. **Audio Player Error**: Verifikasi permissions di `AndroidManifest.xml`

### Common Commands
```bash
# Clean build
flutter clean && flutter pub get

# Check Flutter doctor
flutter doctor

# List connected devices
flutter devices
```

## 📝 Notes

- Aplikasi ini memerlukan koneksi internet untuk Firebase Auth
- Audio permissions akan diminta saat pertama kali digunakan
- Kompatibel dengan Android 6.0+ (API level 23+)

## 🤝 Contributing

1. Fork repository ini
2. Buat feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/amazing-feature`)
5. Buat Pull Request

## 📄 License

Project ini menggunakan MIT License. Lihat file `LICENSE` untuk detail.

## 👨‍💻 Author

**GALREXA** - [GitHub Profile](https://github.com/galrexa)

---

⭐ Jangan lupa untuk star repository ini jika berguna!
