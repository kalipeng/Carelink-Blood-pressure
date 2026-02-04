# 📱 CareLink - AI Blood Pressure Monitor

A senior-friendly iOS app that uses **GPT-4 Vision** to read blood pressure monitors automatically.

---

## 🎯 What This Is

An iOS app that helps seniors track blood pressure by:

- 📷 **AI Camera Reading** - Point camera at BP monitor, AI reads the numbers
- 🎤 **Voice Guidance** - Step-by-step audio instructions
- 🗣️ **Voice Assistant** - Ask questions, get health advice
- 📊 **History Tracking** - View all past readings
- ☁️ **Cloud Sync** - Upload to clinician dashboard

---

## ✨ Features

### 🤖 AI-Powered Measurement
| Feature | Description |
|---------|-------------|
| **GPT-4 Vision** | Reads BP monitor screen automatically |
| **High Accuracy** | Reads each digit carefully, validates results |
| **Confirmation** | Shows detected values for user verification |
| **Manual Fallback** | Enter values manually if needed |

### 🎤 Voice Features
| Feature | Description |
|---------|-------------|
| **Auto Voice Guide** | Speaks each step automatically |
| **Whisper API** | Voice-to-text for hands-free input |
| **AI Chat** | Ask health questions via voice |

### 📱 User Interface
| Feature | Description |
|---------|-------------|
| **Large Buttons** | Easy touch targets for seniors |
| **High Contrast** | T-Mobile pink theme, clear text |
| **Simple Flow** | Home → Measure → Result → History |

---

## 📸 How It Works

### Measurement Flow

```
1. Open App
      ↓
2. Tap "Measure" tab
      ↓
3. Voice Guide Starts Automatically
   - "Turn on your blood pressure monitor..."
   - "Put on the cuff..."
   - "Press START..."
   - "Wait for measurement..." (60 seconds)
   - "Point camera at the screen..."
      ↓
4. Tap "📸 Capture Reading" (anytime numbers are visible)
      ↓
5. AI Reads the Numbers
   - GPT-4 Vision analyzes the image
   - Extracts systolic, diastolic, pulse
      ↓
6. Confirm Reading
   - "I read 120 over 80, pulse 72. Is this correct?"
   - [Correct, Save] [Wrong, Re-capture] [Edit Manually]
      ↓
7. Result Saved
   - Stored locally
   - Uploaded to cloud API
```

---

## 🛠️ Technical Stack

### iOS App (Swift/UIKit)
```
carelink/
├── ViewControllers/
│   ├── HomeViewController.swift      # AI Voice Assistant
│   ├── MeasureViewController.swift   # Camera + GPT-4 Vision
│   ├── ResultViewController.swift    # Display results
│   ├── HistoryViewController.swift   # Past readings
│   └── SettingsViewController.swift  # API key config
├── Services/
│   ├── OpenAIService.swift           # GPT-4 Vision + Whisper + Chat
│   ├── AudioRecorderService.swift    # Voice recording
│   ├── VoiceService.swift            # Text-to-speech
│   ├── CloudSyncService.swift        # API upload
│   └── VoiceAIAssistantService.swift # Voice assistant
├── Models/
│   └── BloodPressureReading.swift    # Data model
└── Extensions/
    └── ...
```

### APIs Used
| API | Purpose |
|-----|---------|
| **GPT-4o Vision** | Read BP monitor screens |
| **Whisper** | Voice-to-text transcription |
| **GPT-4o Chat** | AI assistant responses |

---

## ⚙️ Setup

### 1. Requirements
- iOS 15.0+
- iPhone or iPad with camera
- OpenAI API key

### 2. Configure API Key

**Option A: In App**
1. Open app → Home screen
2. Tap "⚙️ Configure API" 
3. Enter your OpenAI API key

**Option B: In Code**
```swift
// OpenAIService.swift, line 22
return "sk-YOUR-OPENAI-API-KEY-HERE"
```

### 3. Build & Run
```bash
# Open in Xcode
open carelink.xcodeproj

# Build and run on device (camera requires real device)
# ⌘ + R
```

---

## 📱 Screens

### Home Screen
```
┌─────────────────────────────┐
│                             │
│     ○ ○ ○  (wave animation) │
│                             │
│   How can I help you today? │
│     Tap to start talking    │
│                             │
│      [Configure API]        │
│                             │
├─────────────────────────────┤
│  🏠    📏    📊    ⚙️      │
│ Home  Measure History Settings│
└─────────────────────────────┘
```

### Measure Screen
```
┌─────────────────────────────┐
│ ← Back   AI-Guided   00:30 🔄│
│                             │
│     ┌─────────────────┐     │
│     │                 │     │
│     │  Camera Preview │     │
│     │                 │     │
│     │  [📸 Capture]   │     │
│     └─────────────────┘     │
├─────────────────────────────┤
│ 🩺 Blood Pressure Measurement│
│                             │
│ ● Step 1: Turn on monitor   │
│ ○ Step 2: Put on cuff       │
│ ○ Step 3: Press START       │
│ ○ Step 4: Wait (60 sec)     │
│ ○ Step 5: Point camera      │
│                             │
│ [✏️ Manual] [🎤 Voice]      │
└─────────────────────────────┘
```

---

## 🔧 Configuration

### Cloud API Endpoint
```swift
// CloudSyncService.swift
// For Simulator:
private let baseURL = "http://localhost:5001/api"

// For Physical Device (use your Mac's IP):
private let baseURL = "http://192.168.1.100:5001/api"
```

### Voice Settings
```swift
// VoiceService.swift
// Speech rate (0.4-0.5 is slow, good for seniors)
utterance.rate = 0.45
```

---

## 📊 Blood Pressure Classification

| Category | Systolic | Diastolic | Color |
|----------|----------|-----------|-------|
| Normal | < 120 | < 80 | 🟢 Green |
| Elevated | 120-129 | < 80 | 🟡 Yellow |
| High Stage 1 | 130-139 | 80-89 | 🟠 Orange |
| High Stage 2 | 140-179 | 90-119 | 🔴 Red |
| Crisis | ≥ 180 | ≥ 120 | 🔴 Dark Red |

---

## 🐛 Troubleshooting

### "API key not configured"
→ Go to Home → Configure API → Enter your OpenAI key

### Camera not working
→ Must run on real device (not simulator)
→ Check camera permissions in Settings

### AI can't read the numbers
→ Make sure screen is well-lit
→ Hold camera steady
→ Numbers should fill most of the frame
→ Try switching to front/back camera (🔄 button)

### Voice not working
→ Check device is not on silent mode
→ Check volume is turned up

---

## 📁 Related Projects

| Branch | Platform | Description |
|--------|----------|-------------|
| `ios-app` | iOS | This app - GPT-4 Vision |
| `api` | Raspberry Pi | Python backend + ELECROW screen |

---

## 📝 License

MIT License - Free to use and modify

---

**Built for seniors who need simple, reliable blood pressure monitoring** ❤️

Made with GPT-4 Vision + Whisper + Swift
