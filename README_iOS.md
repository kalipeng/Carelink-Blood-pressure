# 🏥 Carelink Blood Pressure - iOS Edition

> A senior-friendly blood pressure monitoring application for **iPad**, designed for elderly users with large buttons, clear visuals, and voice guidance.

[![Platform](https://img.shields.io/badge/platform-iOS%2015.0%2B-lightgrey.svg)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/language-Swift%205-orange.svg)](https://swift.org/)
[![Device](https://img.shields.io/badge/device-iPad-blue.svg)](https://www.apple.com/ipad/)

---

## 📱 Overview

Carelink is an iOS application that connects to **iHealth KN-550BT** blood pressure monitors via Bluetooth, providing a beautiful, accessible interface specifically designed for seniors on iPad devices.

### ✨ Key Features

- **🎨 Modern UI**: Clean, colorful interface with T-Mobile magenta theme
- **👴 Senior-Friendly**: Extra large buttons (300x300pt) and fonts (42-96pt)
- **📊 Real-Time Measurement**: Live blood pressure and heart rate monitoring
- **🔊 Voice Guidance**: Audio feedback for every action (optional)
- **📈 History Tracking**: Complete measurement history with color-coded categories
- **🩺 Health Classification**: Automatic BP categorization (Normal, Elevated, High, Crisis)
- **☁️ Cloud Sync**: T-Mobile 5G integration for data backup (optional)
- **♿ Accessibility**: High contrast, large touch targets, voice support

---

## 🖼️ Screenshots

### Main Screen
Large buttons for easy navigation with device connection status.

### Measurement Screen
Step-by-step instructions with visual guides.

### Results Screen
Three-card layout displaying:
- **Systolic Pressure** (mmHg)
- **Diastolic Pressure** (mmHg)
- **Heart Rate** (beats/min)

Color-coded status banner with health recommendations.

### History Screen
Card-based list with measurement history and category badges.

---

## 🔧 Technical Specifications

### Requirements

- **Platform**: iOS 15.0+
- **Device**: iPad (all models)
- **Language**: Swift 5
- **Frameworks**:
  - UIKit (UI framework)
  - CoreBluetooth (Bluetooth connectivity)
  - AVFoundation (Voice synthesis)
  - ExternalAccessory (iHealth device protocol)

### Compatible Devices

- ✅ **iHealth KN-550BT** Blood Pressure Monitor
- ✅ **iHealth BP5** (with firmware update)
- ✅ Other iHealth Bluetooth BP monitors

---

## 📦 Project Structure

```
carelink/
├── ViewControllers/              # UI View Controllers
│   ├── HomeViewController.swift          Main screen with large buttons
│   ├── MeasureViewController.swift       Measurement screen with steps
│   ├── ResultViewController.swift        Results display (NEW)
│   ├── HistoryViewController.swift       History list view
│   └── SettingsViewController.swift      Settings and preferences
├── Models/                       # Data Models
│   └── BloodPressureReading.swift        BP reading model
├── Services/                     # Business Logic
│   ├── iHealthService.swift              Bluetooth communication
│   ├── VoiceService.swift                Text-to-speech
│   └── CloudSyncService.swift            Cloud backup (optional)
├── Extensions/                   # Swift Extensions
│   ├── UIColor+HealthPad.swift           Color scheme
│   └── Notification+Extensions.swift     Notification names
├── AppDelegate.swift             # App lifecycle
├── SceneDelegate.swift           # Scene management
└── Info.plist                    # App configuration
```

---

## 🎨 Design System

### Color Palette

Based on the web preview design:

| Color | Hex | Usage |
|-------|-----|-------|
| **Primary Pink** | `#E20074` | Main action buttons, branding |
| **Cyan** | `#00BCD4` | History button, secondary actions |
| **Success Green** | `#00C853` | Start measurement, normal status |
| **Text Dark** | `#212121` | Primary text |
| **Text Gray** | `#757575` | Secondary text |
| **Background** | `#FAFAFA` | Screen background |

### Typography

- **Titles**: 36-48pt, Bold
- **Buttons**: 36-42pt, Semibold
- **Values**: 96pt, Bold (measurement results)
- **Body**: 20-24pt, Regular

### Component Sizes

- **Large Buttons**: 300x300pt minimum
- **Touch Targets**: 44x44pt minimum (iOS standard)
- **Card Corner Radius**: 20-28pt
- **Spacing**: 24-48pt between major elements

---

## 🚀 Installation & Setup

### Prerequisites

1. **macOS** with Xcode 13.0+
2. **Apple Developer Account** (free or paid)
3. **iPad** for testing (or iPad Simulator)

### Step 1: Clone the Repository

```bash
git clone https://github.com/kalipeng/Carelink-Blood-pressure.git
cd Carelink-Blood-pressure
git checkout ios-carelink
```

### Step 2: Open in Xcode

```bash
cd carelink
open carelink.xcodeproj
```

### Step 3: Configure Signing

1. Select project in Xcode
2. Go to **Signing & Capabilities**
3. Check **Automatically manage signing**
4. Select your **Team**

### Step 4: Build and Run

1. Select an iPad device or simulator
2. Press **Cmd + R** to build and run
3. Grant Bluetooth permissions when prompted

---

## 📱 How to Use

### First Time Setup

1. **Launch the app** on your iPad
2. **Grant Bluetooth permission** when prompted
3. **Turn on** your iHealth blood pressure monitor
4. The device will auto-connect when in range

### Taking a Measurement

1. **Tap "Measure BP"** on the home screen
2. **Follow the 3-step guide**:
   - ⚡ Ensure device is powered on
   - 🩹 Wear the cuff correctly on left arm
   - 🔗 Tap "Start Measurement" to connect
3. **Stay still** during measurement (30-60 seconds)
4. **View results** automatically when complete

### Viewing History

1. **Tap "History"** on the home screen
2. **Browse** past measurements
3. **Tap any entry** to see detailed results

---

## 🔊 Voice Guidance

Voice guidance helps seniors understand what's happening:

- **Connection status**: "Device connected"
- **Measurement start**: "Starting measurement, please stay still"
- **Results**: "Your blood pressure is 120 over 80, normal range"
- **Errors**: Clear audio error messages

Toggle voice on/off with the speaker icon (🔊/🔇) on the home screen.

---

## 🩺 Blood Pressure Classification

Based on American Heart Association guidelines:

| Category | Systolic | Diastolic | Display |
|----------|----------|-----------|---------|
| **Normal** | <120 | <80 | 🟢 Green |
| **Elevated** | 120-129 | <80 | 🟡 Yellow |
| **High BP Stage 1** | 130-139 | 80-89 | 🟠 Orange |
| **High BP Stage 2** | 140-179 | 90-119 | 🔴 Red |
| **Hypertensive Crisis** | ≥180 | ≥120 | 🔴 Dark Red + Warning |

---

## 🔐 Privacy & Security

- ✅ **Local Storage**: All data stored on device using `UserDefaults`
- ✅ **No Analytics**: No tracking or data collection
- ✅ **Bluetooth Only**: Direct device-to-iPad communication
- ✅ **Optional Cloud**: Cloud sync is opt-in only
- ✅ **HIPAA Consideration**: Designed with health data privacy in mind

---

## 🐛 Troubleshooting

### Bluetooth Connection Issues

**Problem**: Device won't connect

**Solutions**:
1. Ensure Bluetooth is enabled: **Settings → Bluetooth**
2. Turn blood pressure monitor off and on
3. Move iPad closer to device (within 3 feet)
4. Restart the app

### Measurement Errors

**Problem**: Measurement fails or shows error

**Solutions**:
1. Check cuff is properly positioned
2. Ensure arm is at heart level
3. Stay still during measurement
4. Replace batteries in BP monitor if low

### App Crashes

**Problem**: App closes unexpectedly

**Solutions**:
1. Update to latest iOS version
2. Reinstall the app
3. Check Console logs in Xcode
4. Reset all settings

---

## 🔄 Updates & Roadmap

### Current Version: 1.0

### Completed Features ✅

- [x] Home screen with large buttons
- [x] Step-by-step measurement guide
- [x] Three-card result display
- [x] History list with categories
- [x] Voice guidance
- [x] Color-coded health status
- [x] Bluetooth connectivity

### Planned Features 🔜

- [ ] Chart view for trends
- [ ] Multiple user profiles
- [ ] Medication reminders
- [ ] Export to PDF/CSV
- [ ] HealthKit integration
- [ ] Apple Watch companion app
- [ ] Multiple language support (Chinese, Spanish)

---

## 🆚 Platform Comparison

| Feature | iOS (iPad) | Raspberry Pi | Android Tablet |
|---------|-----------|--------------|----------------|
| **Cost** | $350+ | $75-95 | $200+ |
| **Screen Quality** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Touch Response** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Setup Difficulty** | Easy | Medium | Easy |
| **Portability** | ✅ | ❌ | ✅ |
| **Battery Powered** | ✅ | ❌ | ✅ |
| **App Store** | ✅ | ❌ | ✅ |

---

## 👥 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

MIT License - Free to use and modify.

See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **iHealth Labs** for the KN-550BT device and SDK documentation
- **T-Mobile** for 5G connectivity support (optional)
- **Apple** for UIKit and development tools
- **ELECROW** for Raspberry Pi comparison insights

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/kalipeng/Carelink-Blood-pressure/issues)
- **Documentation**: See project README files
- **Contact**: Open an issue for questions

---

## 🎯 Project Philosophy

> "Technology should serve people, not complicate their lives."

This project is built with seniors in mind:
- **Simplicity** over complexity
- **Clarity** over features
- **Accessibility** over aesthetics
- **Reliability** over innovation

---

**Made with ❤️ for seniors who deserve simple, reliable health monitoring.**

---

## 📊 Project Status

✅ **Production Ready** - Fully functional iOS application

- UI: Complete ✨
- Bluetooth: Complete 📡
- Voice: Complete 🔊
- History: Complete 📈
- Documentation: Complete 📚

**Ready to deploy to App Store or TestFlight**

---

*Last Updated: January 2026*
