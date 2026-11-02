# SmartSync — Technical Documentation & Developer Guide 📖

> Detailed documentation, project directory tree, setup steps, security practices, and ecosystem links for the SmartSync platform.

---

## 📂 Project Structure

```text
SmartSync/
├── smart_control_flutter/       # Native Flutter Mobile Client
│   ├── android/                 # Android native gradle wrapper & manifests
│   ├── assets/                  # App icons and vector SVG illustrations
│   │   └── svg/                 # Modern auth & feature SVG illustrations
│   ├── lib/
│   │   ├── config/              # App themes (Light / Dark mode palettes)
│   │   ├── screens/             # UI views (Control, Guide, Profile, Auth)
│   │   ├── services/            # Firebase RTDB & Auth service layer
│   │   ├── widgets/             # Reusable Shadcn UI cards, inputs & headers
│   │   ├── firebase_options.dart.example # Template for Firebase setup
│   │   └── main.dart            # Flutter entry point & route definitions
│   └── pubspec.yaml             # Flutter dependencies & asset registration
│
├── web_sync/                    # Web Showcase & APK Landing Page
│   ├── app-release.apk          # Precompiled release APK
│   ├── style/                   # Web SVG diagrams & assets
│   └── index.html               # Responsive landing page & documentation
│
├── .gitignore                   # Safe Git ignore patterns (protects credentials)
├── LICENSE                      # MIT License
├── README.md                    # Project overview & quick start
└── DOCUMENT.md                  # Comprehensive technical documentation
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Flutter SDK**: `^3.12.0` or later ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Android Studio / VS Code** with Flutter & Dart extensions
- **Firebase Account** with a configured project (Auth + Realtime Database)

### 2. Clone the Repository
```bash
git clone https://github.com/krishna99-tech/SmartSync.git
cd SmartSync
```

### 3. Configure Firebase Credentials
For security reasons, production credentials are excluded from version control. Configure your local configuration file:

1. Copy the example template:
   ```bash
   cp smart_control_flutter/lib/firebase_options.dart.example smart_control_flutter/lib/firebase_options.dart
   ```
2. Open `smart_control_flutter/lib/firebase_options.dart` and fill in your Firebase project IDs, API keys, and Realtime Database URL:
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'YOUR_API_KEY',
     appId: 'YOUR_APP_ID',
     messagingSenderId: 'YOUR_SENDER_ID',
     projectId: 'YOUR_PROJECT_ID',
     databaseURL: 'https://YOUR_DATABASE_NAME.firebaseio.com',
     storageBucket: 'YOUR_STORAGE_BUCKET.appspot.com',
   );
   ```
   > *Alternatively, use `flutterfire configure` to generate the file automatically.*

### 4. Run the Mobile App
```bash
cd smart_control_flutter
flutter pub get
flutter run
```

### 5. Build the Release APK
```bash
flutter build apk --release
```
The compiled APK will be output to:
`smart_control_flutter/build/app/outputs/flutter-apk/app-release.apk`

---

## 🌐 Web Showcase & Landing Page

The `web_sync/` directory contains a standalone, zero-dependency landing page for hosting on **Vercel**, **Netlify**, or **GitHub Pages**.

To preview locally:
```bash
cd web_sync
# Using Python built-in server:
python -m http.server 3000
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🔒 Security Best Practices

- **Never Commit Sensitive Keys**: `firebase_options.dart` and Android keystore files are strictly ignored via `.gitignore`.
- **Firebase Security Rules**: Ensure your Firebase Realtime Database rules enforce user authentication:
  ```json
  {
    "rules": {
      "users": {
        "$uid": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        }
      }
    }
  }
  ```

---

## 🔗 Ecosystem & Related Projects

| Project | Description | Link |
| :--- | :--- | :--- |
| **Thingsnxt** | Official IoT & Smart Technology Portal | [thingsnxt.com](https://thingsnxt.com) |
| **ThingsNxt Platform** | Cloud Device Management & Telemetry Hub | [thingsnxt.vercel.app](https://thingsnxt.vercel.app) |
| **UtilityNexus** | Kronos Utility & Energy Monitoring Dashboard | [utility.thingsnxt.com](https://utility.thingsnxt.com/kronos/v2/overview) |
| **Nxtzenta** | Cloud Infrastructure & Sync Services | [cloud.thingsnxt.com](https://cloud.thingsnxt.com) |
| **AuthLog Platform** | Full-Stack Identity & Authentication Platform | [authlog.vercel.app](https://fullstack-auth-platform-topaz.vercel.app/) |
| **Cyberkit** | Security, Encryption & Penetration Utilities | [cyberkit.vercel.app](https://cyberkit-mu.vercel.app/) |

