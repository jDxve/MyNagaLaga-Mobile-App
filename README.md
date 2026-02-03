# MyNagaLaga Mobile App

## Overview

MyNagaLaga is a digital platform that connects citizens with their CSWDO, CDRRMO, and Barangay offices, enabling efficient service delivery and community support. The system manages citizen registries, facilitates service requests, and coordinates disaster response activities across barangays and city-level operations.

This project is a submission to the **1st Naga City Mayoral Hackathon** under the **Social Services Challenge**, addressing the need for:
- Streamlined government assistance
- Improved case tracking
- Strengthened disaster response
- Support for vulnerable sectors
- Reduced administrative barriers

**Note:** This repository contains the mobile application. The web interface and server backend are maintained in separate repositories.

---

## Architecture

### Tech Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Networking:** Retrofit + Dio
- **Dependency Injection:** GetIt
- **Architecture Pattern:** MVVM (Model-View-ViewModel)

### Project Structure

```
lib/
├── common/
│   ├── guard/          # Authentication guards and route protection
│   ├── models/         # Shared data models and DTOs
│   │   ├── dio/        # Dio client setup and interceptors
│   │   └── responses/  # Common API response models
│   ├── resources/      # App-wide resources (assets, colors, dimensions, strings)
│   ├── utils/          # Helper functions and utilities
│   └── widgets/        # Reusable UI components
├── features/           # Feature modules (account, auth, family, home, safety, services, verify_badge, welcome)
├── main.dart           # Application entry point
└── router.dart         # Navigation and routing configuration
```

### Feature Module Structure

Each feature follows a consistent MVVM structure:

```
feature/
├── components/         # Feature-specific UI components
├── models/            # Feature data models
├── notifier/          # Riverpod state notifiers
├── repository/        # Data layer (API calls, local storage)
├── screens/           # UI screens
└── services/          # Business logic and API services
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK:** 3.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart:** 3.0 or higher (comes with Flutter)
- **IDE:** VS Code or Android Studio
- **Mobile Device/Emulator:** For testing

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/jDxve/MyNagaLaga-Mobile-App.git
cd mynagalaga_mobile_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Environment

#### Find Your Local IP Address

**For macOS/Linux:**
```bash
ifconfig
```
Look for your local network IP address (usually starts with `192.168.x.x` or `172.x.x.x`)

**For Windows:**
```bash
ipconfig
```
Look for IPv4 Address under your active network adapter

#### Create Environment File

Create a `.env` file in the project root:

```env
# API Configuration
API_BASE_URL=http://YOUR_LOCAL_IP:3000/api
```

**Important Notes:**
- Replace `YOUR_LOCAL_IP` with your actual local IP address
- Do NOT use `localhost` or `127.0.0.1` when testing on physical devices
- Ensure your backend server is running on the same network

### 4. Run the Application

**Note:** Make sure you have an Android emulator running or iOS simulator open before running the app.

- **Android:** Open Android Studio and start an emulator, or run `emulator -avd <device_name>` in terminal
- **iOS:** Open Xcode and launch a simulator, or run `open -a Simulator` in terminal

```bash
flutter run
```

---
