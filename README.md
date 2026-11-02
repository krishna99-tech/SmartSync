# SmartSync ⚡

> **Next-Generation IoT Smart Home Automation & Control Platform**  
> Connect custom microcontroller relays with a native Flutter mobile client through real-time Firebase cloud data pipelines.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-RTDB%20%26%20Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Release](https://img.shields.io/badge/Release-v2.0.0-2563EB)](https://github.com/krishna99-tech/SmartSync/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 📌 Overview

**SmartSync** provides a seamless, low-latency interface for smart home automation. Combining a high-performance **Flutter mobile client**, a **Firebase Realtime Database (RTDB)** backbone, and an interactive **Web Showcase**, SmartSync allows homeowners and engineers to monitor and toggle IoT devices (lighting, climate, smart plugs, security access) in sub-second real time.

---

## ✨ Key Highlights

- **⚡ Sub-Second Real-Time Sync**: Bi-directional device state updates powered by Firebase Realtime Database.
- **🎨 Modern Next.js & Shadcn Aesthetic**: Minimalist, card-based interface with high-contrast surfaces (`#FFFFFF` on `#F8FAFC` in light mode, `#111827` on `#090D16` in dark mode) and royal tech-blue accents (`#2563EB`).
- **📱 Fully Docked Bottom Navigation**: Clean zero-margin navigation bar featuring **Devices**, **Instructions**, and **Profile** views.
- **🔐 Complete Authentication Suite**: Email/Password, 2-step setup, Password Recovery, Deep Linking, and Google Sign-in.
- **📖 Hardware Guides & Schematics**: In-app wiring schematics, pinout references, and microcontroller flashing instructions.
- **🌐 Responsive Web Showcase**: Zero-dependency landing page with direct release APK downloads and interactive IoT architecture diagrams.

---

## 🏗️ Architecture

```mermaid
flowchart LR
    A[Microcontroller Relay<br/>ESP32 / NodeMCU] <-->|Wi-Fi / Realtime JSON| B[(Firebase RTDB<br/>Cloud Database)]
    B <-->|Live Stream / WebSocket| C[SmartSync Flutter App<br/>Android Client]
    D[Web Showcase<br/>Vercel / GitHub] -.->|Direct APK Download| C
```

---

## 📚 Documentation & Developer Guide

All detailed setup guides, project structures, security rules, and ecosystem resources are maintained in **[DOCUMENT.md](DOCUMENT.md)**:

- 📂 **[Project Structure](DOCUMENT.md#-project-structure)**: Directory layout and module organization.
- 🚀 **[Getting Started](DOCUMENT.md#-getting-started)**: Prerequisites, cloning, Firebase configuration, and running the app.
- 📦 **[Building Release APK](DOCUMENT.md#5-build-the-release-apk)**: Instructions for compiling the Android binary.
- 🌐 **[Web Showcase Hosting](DOCUMENT.md#-web-showcase--landing-page)**: Running and deploying the landing page.
- 🔒 **[Security Best Practices](DOCUMENT.md#-security-best-practices)**: Safe credential handling and Firebase security rules.
- 🔗 **[Ecosystem & Related Projects](DOCUMENT.md#-ecosystem--related-projects)**: Connected platforms, telemetry portals, and cyber utilities.

---

## 👨‍💻 Author & Credits

- **Author**: [Venkata Krishna](https://github.com/krishna99-tech)
- **Ecosystem**: COE-IOT ECOSYSTEM

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
