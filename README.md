# CareLink — AI-Powered Blood Pressure Monitor

A senior-friendly iOS application that uses Claude AI Vision to read blood pressure monitors automatically, guide users through the measurement process, and sync readings to a clinician dashboard.

---

## Project Structure

```
carelink/
├── carelink.xcodeproj/              # Xcode project file
├── carelink/
│   ├── AppDelegate.swift            # App lifecycle
│   ├── SceneDelegate.swift          # Tab bar & root view setup
│   ├── Info.plist                   # Permissions & app metadata
│   ├── ViewControllers/
│   │   ├── HomeViewController.swift      # AI voice chat assistant
│   │   ├── MeasureViewController.swift   # Camera + AI BP reading
│   │   ├── ResultViewController.swift    # Reading confirmation & save
│   │   ├── HistoryViewController.swift   # Past readings by date
│   │   └── SettingsViewController.swift  # API key & configuration
│   ├── Services/
│   │   ├── OpenAIService.swift           # Claude Vision/Chat + Whisper STT
│   │   ├── AudioRecorderService.swift    # Mic recording + silence detection
│   │   ├── VoiceService.swift            # Text-to-speech (AVSpeechSynthesizer)
│   │   ├── CloudSyncService.swift        # REST API upload to backend
│   │   ├── VoiceAIAssistantService.swift # Voice assistant pipeline
│   │   ├── iHealthService.swift          # iHealth Bluetooth device support
│   │   └── iHealthHistoryService.swift   # iHealth reading history
│   ├── Models/
│   │   └── BloodPressureReading.swift    # Core data model
│   └── Extensions/
│       └── UIColor+HealthPad.swift       # Custom color palette
└── docs/
    ├── UserManual.pdf                    # Full user manual (this document)
    ├── firestore-patient-template.json   # Firestore patient schema
    └── firestore-patient-README.md       # Firestore setup guide
```

---

## How to Run

### Requirements
- macOS 13+ with Xcode 15+
- iPhone running iOS 15.0+ (camera & microphone required — simulator will not work)
- An Anthropic API key (Claude)
- An OpenAI API key (Whisper speech-to-text)

### Steps

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd carelink
   ```

2. **Open in Xcode**
   ```bash
   open carelink.xcodeproj
   ```

3. **Select your iPhone as the run target** (⌘ + Shift + ,)

4. **Build and run** (⌘ + R)

5. **Configure API keys in-app**
   - Open the app → tap **Settings** tab
   - Enter your **Claude (Anthropic) API key** — used for BP image reading and AI chat
   - Enter your **OpenAI API key** — used for Whisper voice-to-text
   - Enter the **Backend API URL** — e.g. `http://192.168.1.100:5001/api`

---

## What to Expect

| Screen | What happens |
|--------|-------------|
| **Home** | Tap the microphone to ask health questions by voice. The AI responds in text and reads the answer aloud. |
| **Measure** | Voice guidance walks through all 5 steps. After Step 5, the **Take Photo** button pulses and auto-captures in 10 seconds. Claude reads the BP numbers from the photo. |
| **Result** | Confirms the detected systolic/diastolic/pulse values. User can re-capture or edit manually. Saves to local storage and uploads to cloud. |
| **History** | Readings grouped by date. Days with 2+ readings show a daily average row. Tip label encourages up to 5 readings per day. |
| **Settings** | Configure API keys, cloud endpoint, and preferences. |

---

## AI Models Used

| Task | Model | Provider |
|------|-------|----------|
| Blood pressure image reading | `claude-opus-4-6` | Anthropic |
| AI chat assistant | `claude-sonnet-4-6` | Anthropic |
| Behavior-based guidance | `claude-haiku-4-5-20251001` | Anthropic |
| Speech-to-text | `whisper-1` | OpenAI |

---

## Blood Pressure Classification

| Category | Systolic | Diastolic | Color |
|----------|----------|-----------|-------|
| Normal | < 120 | < 80 | Green |
| Elevated | 120–129 | < 80 | Yellow |
| High Stage 1 | 130–139 | 80–89 | Orange |
| High Stage 2 | 140–179 | 90–119 | Red |
| Hypertensive Crisis | ≥ 180 | ≥ 120 | Dark Red |

---

## Troubleshooting

**"API key not configured"** → Settings tab → enter Claude API key

**Camera not working** → Must use a real device; check camera permission in iOS Settings

**AI cannot read the numbers** → Ensure display is well-lit; hold camera steady; numbers should fill most of the frame

**Voice not working** → Check that the device is not on silent mode and volume is up

**Cloud sync fails** → Verify the backend URL in Settings matches your server's IP address

---

## Clinician Dashboard

A separate web application provides a clinician-facing hypertension Remote Patient Monitoring (RPM) dashboard.

> **Important:** This project is a demo/MVP for product validation. Do not use with real PHI or production clinical workflows without security and compliance hardening.

### Current Features

| # | Feature | Description |
|---|---------|-------------|
| 1 | **Clinician Auth** | Login/logout with session persisted in localStorage; protected pages via `AuthProvider` + route redirect |
| 2 | **Patient Overview** (`/`) | Risk-priority patient list, latest BP per patient, daily aggregate support, Add Patient drawer |
| 3 | **Patient Details** (`/patients/[id]`) | BP history charts, recent readings table, medication list, Adjust Medication drawer, PDF report export |
| 4 | **Alert Management** | Alert triage workflow, state updates, messaging entry points |
| 5 | **BP Reminders** | Email delivery via Resend API; SMS path returns demo response (no provider wired yet) |

**Demo login**
```
Email:    sarah.chen@carelink.health
Password: carelink2025
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 16 (App Router) |
| Language | TypeScript + React 19 |
| Styling | Tailwind CSS |
| Charts | Recharts |
| PDF Export | jsPDF + html2canvas |
| Database | Firebase Firestore + Firebase Admin SDK |
| Email | Resend REST API |

### API Routes

| Method | Route | Purpose |
|--------|-------|---------|
| GET / POST | `/api/patients` | List or create patients |
| GET / PUT / DELETE | `/api/patients/[id]` | Patient profile, update, delete |
| GET / POST | `/api/readings` | Reading retrieval and ingest |
| POST | `/api/blood-pressure` | iOS-compatible BP ingest alias |
| GET / PATCH | `/api/alerts` | Alert list and state updates |
| GET / POST / DELETE | `/api/notes` | Clinician notes |
| POST | `/api/reminders` | Email reminder (Resend) + SMS demo |

### Local Setup

```bash
cd carelink_clinician-dashboard-main
npm install
npm run dev
# Open http://localhost:3000
```

Copy `.env.example` to `.env.local` and fill in Firebase + Resend keys.
Without Firebase admin config the app runs in demo fallback mode.

### Project Structure

```
src/
  app/
    login/page.tsx
    page.tsx                        # Patient overview dashboard
    alerts/page.tsx
    messages/page.tsx
    analytics/page.tsx
    patients/[id]/page.tsx
    api/                            # All API route handlers
  components/
    Header.tsx  Sidebar.tsx  AppShell.tsx
    ui/Drawer.tsx
    drawers/TreatmentPlanDrawer.tsx
  contexts/AuthContext.tsx
  lib/firebase-admin.ts
```

### Security & Compliance Notes

- Demo-oriented auth/session behavior — no HIPAA-grade audit trail yet
- No enterprise IAM integration
- **Do not store real patient PHI until security controls are implemented**

---

## Related Components

| Branch / Folder | Platform | Description |
|-----------------|----------|-------------|
| `ios-carelink` | iOS (Swift) | This app |
| `carelink_clinician-dashboard-main` | Web (Next.js) | Clinician-facing RPM dashboard |
| `api` | Python / Raspberry Pi | Backend REST API |
