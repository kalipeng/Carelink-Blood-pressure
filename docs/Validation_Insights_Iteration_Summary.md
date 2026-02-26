# Validation Insights & Iteration Summary
**CareLink – TECHIN 542 Integrated Launch Studio II**  
*Document for recent validation-driven changes*

---

## 1. Validation Insights Summary

| # | Finding | Evidence | Why it matters |
|---|---------|----------|----------------|
| 1 | Firestore patient data had no standard format for adding new patients; app uses `patientId` (e.g. P-2025-005) but backend needs matching patient documents. | Firestore console: `patients` collection uses structured fields (address, diagnosis, medications, etc.). New patients must match this schema. | Ensures uploaded readings can be linked to the right patient; clinicians see consistent patient info in the dashboard. |
| 2 | Voice (TTS) read out emoji characters from AI responses, sounding odd. | User report: “语音不要每次后面都有emoji读出来很奇怪”. | Poor UX and confusion for elderly users who expect natural speech only. |

**Evidence sources:** User testing feedback, Firestore console structure, in-app voice output.

---

## 2. Iteration Decision Matrix

| Finding | Decision | Action |
|---------|----------|--------|
| Firebase / Firestore: need a clear way to add patients in the same format as existing ones (e.g. P-2025-001). | **Fix** | Added `docs/firestore-patient-template.json` — a full patient document in the same schema (address map, diagnosis array, emergencyContact map, medications array, targetSystolic/targetDiastolic number, etc.). Added `docs/firestore-patient-README.md` with field descriptions and steps to add a patient in Firestore (e.g. P-2025-005) so app uploads match. |
| Voice reading emoji aloud | **Fix** | In `VoiceService.speak()`, added `stripEmoji()` to remove emoji/symbol Unicode ranges before TTS. Collapse multiple spaces after strip. All spoken content (Home AI reply, Measure guidance, steps) is now emoji-free. |

**Evidence:** New files `docs/firestore-patient-template.json`, `docs/firestore-patient-README.md`; code changes in `VoiceService.swift`.

---

## 3. Iterated System Demo (Before → After)

- **Firebase / Patient data:** Before: No documented format for adding patients; risk of mismatch with app’s `patientId`. After: Template JSON + README so new patients (e.g. P-2025-005) can be added in Firestore with the same structure; app uploads align with dashboard.
- **Voice:** Before: TTS read emoji (e.g. “heart emoji”). After: Only plain text is spoken; emoji stripped before synthesis.

---

## 4. Updated System & Integration Notes

- **What changed in integration:** Firestore patient schema is now documented; no change to app’s API contract or upload payload. Template supports consistent patient docs when using the same `patientId` in Settings.
- **Risks reduced:** Voice output no longer confusing; adding new patients is clearer and consistent with existing data.

---

## 5. Demo Readiness Assessment

- **Stable enough to demo:** Voice guidance without emoji; uploads to backend with correct `patientId` when the matching patient document exists in Firestore (using the template if needed).
- **Contingency:** Manual entry and History still work if backend or Firestore is not configured.
