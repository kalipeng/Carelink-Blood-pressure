# Gate 12: E2E Validation, Reliability, and Failure Analysis
**CareLink – iPad Blood Pressure & Health App**  
Due: Wed Feb 18, 2026 11:59pm | 25 Points Possible

---

## 1. E2E Validation Scenarios

*Each team member must define at least two realistic scenarios. Below are example scenarios that can be assigned or adapted per member.*

### Scenario A: Full measurement flow with vision (camera → AI read → save → sync)

| Aspect | Description |
|--------|-------------|
| **Inputs** | User on Measure tab; camera pointed at BP monitor showing numbers (e.g. 128/82, 72 bpm). User taps "Capture Reading." API keys (Claude) configured in Settings. Network available. |
| **Expected outputs** | App captures image → sends to Claude Vision → receives JSON `{systolic, diastolic, pulse}` → shows confirmation alert → user confirms → reading saved locally and uploaded to CareLink dashboard; user navigated to Result screen with reading and category. |
| **Success** | Correct numbers extracted (within ±2 mmHg if possible), no crash, reading appears in History and in backend (if sync succeeds). |

---

### Scenario B: Voice input on Home (Whisper → Claude → answer)

| Aspect | Description |
|--------|-------------|
| **Inputs** | User on Home tab with mic; both OpenAI and Claude API keys set. User taps mic, speaks (e.g. "What is a normal blood pressure?"). Network available. |
| **Expected outputs** | Audio sent to OpenAI Whisper → transcript sent to Claude → text response returned and shown in chat; optionally TTS speaks the answer. |
| **Success** | User question transcribed correctly, Claude returns a relevant answer, UI updates and (if voice on) speaks. No timeout or generic error. |

---

### Scenario C: AI-guided measurement with behavior-based guidance (5s auto + manual)

| Aspect | Description |
|--------|-------------|
| **Inputs** | User on Measure tab; camera on; Claude API key set. User follows steps (cuff, start, wait). Camera sees user/posture/cuff. |
| **Expected outputs** | Every 5 seconds, latest frame sent to Claude Haiku; short guidance sentence returned and spoken (e.g. "Sit back and relax your arm."). Optional: user taps "AI Guidance" for one-off tip. |
| **Success** | Guidance is relevant to what’s visible, spoken within ~5–15 s of each tick, no repeated crashes or freezes. |

---

### Scenario D: Manual entry and history

| Aspect | Description |
|--------|-------------|
| **Inputs** | User on Measure tab; taps "Enter Manually Instead" (or vision fails). Enters systolic, diastolic, pulse in alert. Submits. |
| **Expected outputs** | Reading saved with source "manual"; appears in History list with correct values, date, time, category (e.g. Normal, Elevated). |
| **Success** | Values persist, show in History, and (if configured) upload to API with correct patientId and body. |

---

### Scenario E: Settings and API configuration

| Aspect | Description |
|--------|-------------|
| **Inputs** | User opens Settings; edits API URL and Patient ID; toggles Voice guidance; selects Voice. |
| **Expected outputs** | URL and Patient ID persisted (UserDefaults / CloudSyncService); next upload uses new baseURL and patientId; voice settings affect TTS and mic flow. |
| **Success** | No crash; after changing Patient ID, next upload shows correct patientId in backend. |

---

### Scenario F: Offline / bad network and missing keys

| Aspect | Description |
|--------|-------------|
| **Inputs** | (1) WiFi/cellular off during upload. (2) Claude or OpenAI key missing or invalid. |
| **Expected outputs** | (1) Upload fails gracefully; reading still saved locally; user can retry or continue. (2) Clear message: "Please configure Claude API key" or "Voice input requires OpenAI API key"; no silent failure. |
| **Success** | No crash; user understands what’s wrong and where to fix it (Settings). |

---

## 2. Reliability & Repeatability Test

### Test matrix (each team member runs and records)

| Run | Condition | Scenario | Result (Pass/Fail) | Notes |
|-----|-----------|----------|--------------------|------|
| 1 | Good network, keys set | A – Vision capture | | |
| 2 | Good network, keys set | A – Vision capture (different BP image) | | |
| 3 | Good network | B – Voice Q&A | | |
| 4 | Same day, different time | A or B | | |
| 5 | Manual entry only (no vision) | D | | |
| 6 | 5s auto guidance on Measure | C | | |

### Evidence to submit

- **Video (required):** One video per member showing the full E2E flow (e.g. open app → Measure → capture or manual → confirm → see in History). Submit via Canvas comment or link in slides.
- **Short test log:** Table or bullets (e.g. above) with Run #, condition, scenario, Pass/Fail, notes.
- **Variability notes:** e.g. "Vision accuracy depends on lighting and angle"; "First API call after cold start sometimes 2–3 s slower."

### Definition of “reliable” for this gate

- Same scenario (e.g. Scenario A) run 3+ times yields success at least 2 times with no crash.
- Failures are identifiable (e.g. "Vision returned null" or "Network timeout") rather than silent or random.

---

## 3. Failure Mode & Boundary Analysis

*Answers should be data-driven (from test runs, logs, or reproducible steps), not opinion.*

### Where does the system break?

| Area | Observed failure | Trigger | Evidence |
|------|------------------|--------|----------|
| **Vision (BP read)** | Wrong or null reading | Poor lighting, blur, wrong crop, non-standard monitor layout | Test with 5–10 different photos; log systolic/diastolic/pulse vs expected. |
| **Vision (BP read)** | Timeout / no response | Large image, slow network, API rate limit | Log request time and response code; try with 1280px vs 640px. |
| **Guidance (5s auto)** | No speech or wrong tip | Haiku timeout, frame too dark, no person in frame | Log success/fail per tick; note "no person" vs "person visible." |
| **Voice (Whisper)** | "Didn’t understand" or wrong transcript | Accent, background noise, no OpenAI key | Test with/without key; test in quiet vs noisy room. |
| **Claude chat** | Generic error or timeout | Invalid key, 429, very long prompt | Log status code and error message from API. |
| **Upload** | "Uploaded" but data not in backend | success ≠ true in response, wrong patientId/body | Compare response JSON and Firestore/dashboard; log patientId and baseURL. |
| **Camera** | Crash on Measure open | No camera permission or missing usage description | Test on device with permission denied once; check Info.plist. |

### Fragile assumptions

- **Network:** All AI and upload features assume the device can reach the internet; no offline AI.
- **API keys:** Correct format and balance; no in-app validation of key validity until first call.
- **Monitor layout:** Vision prompt assumes “top = systolic, middle = diastolic, bottom = pulse”; odd UIs may break.
- **Single patient:** Patient ID is app-wide; no in-app multi-patient switching.
- **English UI:** App and prompts are English; non-English speech may reduce Whisper/guidance quality.

### Bad, missing, or unexpected inputs

| Input type | Bad/missing/unexpected | Observed behavior | Recommended handling |
|------------|------------------------|-------------------|----------------------|
| **BP image** | Blurry, no numbers, multiple devices | Vision may return null or wrong values | Show "Could not read clearly; try again or enter manually." |
| **Manual entry** | Empty or out-of-range (e.g. 300/50) | Saves anyway; category may be odd | Optional: clamp or validate range (e.g. 60–300 SYS, 40–200 DIA). |
| **API key** | Empty, invalid, revoked | 401 or 4xx; we show message and point to Settings | Already in place; ensure message is clear. |
| **Upload body** | Missing patientNote | Backend may write undefined → 500 | We send `patientNote: ""` when none; verify in tests. |
| **Camera** | No permission | Crash if not handled | Request permission before starting session; show message if denied. |

---

## 4. Iteration Plan

### Must fix next (before stakeholder testing)

- **Vision:** If BP reading wrong or null rate is high in tests, improve prompt or image preprocessing (crop/contrast) or add “retry once” and clearer manual-entry path.
- **Upload:** Confirm success only when response has `success === true`; show clear “Upload failed” when not.
- **Errors:** Ensure every API failure path shows a user-facing message (no silent failures).

### Can wait (post–Gate 12)

- Offline mode or queue for uploads.
- Multi-patient or patient switcher.
- Localization / non-English UI and prompts.
- iHealth SDK integration (if still placeholder).

### Risks going into stakeholder testing

- **Accuracy:** Stakeholders may assume vision is medical-grade; we should state it is “best effort” and recommend manual entry when in doubt.
- **Availability:** Dependency on Anthropic/OpenAI and network; brief outages will affect AI and guidance.
- **Device mix:** Tested mainly on iPad; different devices/cameras may change vision and camera behavior.

---

## Submission checklist

- [ ] Slide deck with sections 1–4 (and optional test log / variability notes).
- [ ] Video(s) per team member: E2E flow submitted via Canvas comment or linked in slides.
- [ ] Test log (table or bullets) for Reliability & Repeatability.
- [ ] All members have demonstrated the workflow and reported results.
