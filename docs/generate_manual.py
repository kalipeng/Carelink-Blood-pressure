#!/usr/bin/env python3
"""
CareLink User Manual PDF Generator
Run: python3 docs/generate_manual.py
Output: docs/UserManual.pdf
"""

import sys
sys.path.insert(0, '/Users/kellypeng/Library/Python/3.9/lib/python/site-packages')

from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable, KeepTogether
)
from reportlab.platypus.flowables import HRFlowable
from reportlab.graphics.shapes import Drawing, Rect, Circle, String, Line
from reportlab.graphics import renderPDF
import os

# ── Colors ──────────────────────────────────────────────────────────────
PINK      = colors.HexColor("#E2007A")
DARK_PINK = colors.HexColor("#A8005A")
LIGHT_PINK= colors.HexColor("#FFE6F3")
DARK_GRAY = colors.HexColor("#2C2C2C")
MID_GRAY  = colors.HexColor("#666666")
LIGHT_GRAY= colors.HexColor("#F5F5F5")
WHITE     = colors.white
TABLE_HDR = colors.HexColor("#FCE4F0")

OUTPUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "UserManual.pdf")

# ── Styles ───────────────────────────────────────────────────────────────
def make_styles():
    base = getSampleStyleSheet()

    cover_title = ParagraphStyle("CoverTitle",
        fontSize=38, fontName="Helvetica-Bold",
        textColor=WHITE, alignment=TA_CENTER, spaceAfter=10, leading=44)

    cover_sub = ParagraphStyle("CoverSub",
        fontSize=16, fontName="Helvetica",
        textColor=colors.HexColor("#FFB3DC"), alignment=TA_CENTER,
        spaceAfter=6, leading=22)

    cover_meta = ParagraphStyle("CoverMeta",
        fontSize=12, fontName="Helvetica",
        textColor=WHITE, alignment=TA_CENTER, spaceAfter=4, leading=18)

    h1 = ParagraphStyle("H1",
        fontSize=22, fontName="Helvetica-Bold",
        textColor=PINK, spaceBefore=20, spaceAfter=8, leading=28)

    h2 = ParagraphStyle("H2",
        fontSize=15, fontName="Helvetica-Bold",
        textColor=DARK_GRAY, spaceBefore=14, spaceAfter=6, leading=20)

    h3 = ParagraphStyle("H3",
        fontSize=12, fontName="Helvetica-Bold",
        textColor=DARK_GRAY, spaceBefore=8, spaceAfter=4, leading=16)

    body = ParagraphStyle("Body",
        fontSize=10.5, fontName="Helvetica",
        textColor=DARK_GRAY, spaceAfter=6, leading=15, alignment=TA_JUSTIFY)

    bullet = ParagraphStyle("Bullet",
        fontSize=10.5, fontName="Helvetica",
        textColor=DARK_GRAY, spaceAfter=4, leading=15,
        leftIndent=18, bulletIndent=6)

    code = ParagraphStyle("Code",
        fontSize=9, fontName="Courier",
        textColor=colors.HexColor("#333333"),
        backColor=LIGHT_GRAY, spaceAfter=4, leading=13,
        leftIndent=12, rightIndent=12, spaceBefore=4)

    note = ParagraphStyle("Note",
        fontSize=10, fontName="Helvetica-Oblique",
        textColor=MID_GRAY, spaceAfter=4, leading=14, leftIndent=12)

    return dict(cover_title=cover_title, cover_sub=cover_sub,
                cover_meta=cover_meta, h1=h1, h2=h2, h3=h3,
                body=body, bullet=bullet, code=code, note=note)


# ── Logo Drawing ─────────────────────────────────────────────────────────
def make_logo(width=120, height=120):
    d = Drawing(width, height)
    d.add(Circle(width/2, height/2, width/2 - 4,
                 fillColor=colors.HexColor("#A8005A"), strokeColor=WHITE, strokeWidth=3))
    # Heart shape via two circles + polygon approximation
    cx, cy = width/2, height/2 + 5
    r = 18
    d.add(Circle(cx - r*0.6, cy + r*0.4, r*0.72,
                 fillColor=WHITE, strokeColor=None))
    d.add(Circle(cx + r*0.6, cy + r*0.4, r*0.72,
                 fillColor=WHITE, strokeColor=None))
    # Triangle bottom of heart
    from reportlab.graphics.shapes import Polygon
    d.add(Polygon([cx - r*1.28, cy + r*0.3,
                   cx + r*1.28, cy + r*0.3,
                   cx, cy - r*1.1],
                  fillColor=WHITE, strokeColor=None))
    # ECG line
    lx = [width*0.12, width*0.28, width*0.36, width*0.44,
          width*0.52, width*0.60, width*0.68, width*0.88]
    ly = [height*0.22, height*0.22, height*0.36,
          height*0.08, height*0.48, height*0.22,
          height*0.22, height*0.22]
    for i in range(len(lx)-1):
        d.add(Line(lx[i], ly[i], lx[i+1], ly[i+1],
                   strokeColor=PINK, strokeWidth=2.5))
    return d


# ── Divider ───────────────────────────────────────────────────────────────
def divider():
    return HRFlowable(width="100%", thickness=1.5, color=PINK,
                      spaceAfter=8, spaceBefore=4)


# ── Styled table helper ───────────────────────────────────────────────────
def make_table(data, col_widths, header=True):
    style = [
        ("BACKGROUND", (0,0), (-1,0), TABLE_HDR),
        ("TEXTCOLOR",  (0,0), (-1,0), DARK_PINK),
        ("FONTNAME",   (0,0), (-1,0), "Helvetica-Bold"),
        ("FONTSIZE",   (0,0), (-1,0), 10),
        ("FONTNAME",   (0,1), (-1,-1), "Helvetica"),
        ("FONTSIZE",   (0,1), (-1,-1), 10),
        ("ROWBACKGROUNDS", (0,1), (-1,-1), [WHITE, LIGHT_GRAY]),
        ("GRID",       (0,0), (-1,-1), 0.5, colors.HexColor("#DDDDDD")),
        ("VALIGN",     (0,0), (-1,-1), "MIDDLE"),
        ("LEFTPADDING",(0,0), (-1,-1), 8),
        ("RIGHTPADDING",(0,0),(-1,-1), 8),
        ("TOPPADDING", (0,0), (-1,-1), 6),
        ("BOTTOMPADDING",(0,0),(-1,-1), 6),
    ]
    t = Table(data, colWidths=col_widths)
    t.setStyle(TableStyle(style))
    return t


# ── Numbered step helper ─────────────────────────────────────────────────
def step(n, title, detail, styles):
    data = [[
        Paragraph(f"<b>{n}</b>", ParagraphStyle("StepNum",
            fontSize=13, fontName="Helvetica-Bold",
            textColor=WHITE, alignment=TA_CENTER)),
        Paragraph(f"<b>{title}</b><br/>{detail}", ParagraphStyle("StepBody",
            fontSize=10.5, fontName="Helvetica",
            textColor=DARK_GRAY, leading=15))
    ]]
    t = Table(data, colWidths=[0.45*inch, 5.85*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (0,0), PINK),
        ("VALIGN",     (0,0), (-1,-1), "MIDDLE"),
        ("LEFTPADDING",(0,0), (0,0), 4),
        ("LEFTPADDING",(1,0), (1,0), 10),
        ("TOPPADDING", (0,0), (-1,-1), 6),
        ("BOTTOMPADDING",(0,0),(-1,-1), 6),
        ("ROUNDEDCORNERS", [4]),
        ("BOX",        (0,0), (-1,-1), 0.5, colors.HexColor("#EEEEEE")),
    ]))
    return t


# ── Page template callbacks ───────────────────────────────────────────────
def on_page(canvas, doc):
    canvas.saveState()
    # Footer bar
    canvas.setFillColor(PINK)
    canvas.rect(0, 0, letter[0], 0.45*inch, fill=1, stroke=0)
    canvas.setFillColor(WHITE)
    canvas.setFont("Helvetica", 8.5)
    canvas.drawString(0.6*inch, 0.16*inch, "CareLink  •  User Manual  •  v1.0")
    canvas.drawRightString(letter[0] - 0.6*inch, 0.16*inch,
                           f"Page {doc.page}")
    canvas.restoreState()


def on_first_page(canvas, doc):
    pass  # Cover page — no footer


# ── Document builder ──────────────────────────────────────────────────────
def build_pdf():
    doc = SimpleDocTemplate(
        OUTPUT,
        pagesize=letter,
        leftMargin=0.75*inch, rightMargin=0.75*inch,
        topMargin=0.75*inch,  bottomMargin=0.75*inch,
        title="CareLink User Manual",
        author="CareLink Team",
    )

    S = make_styles()
    story = []

    # ════════════════════════════════════════════════════════════════
    # COVER PAGE
    # ════════════════════════════════════════════════════════════════
    cover_bg = Table(
        [[Paragraph("", S["body"])]],
        colWidths=[7*inch], rowHeights=[9.5*inch]
    )
    cover_bg.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,-1), DARK_PINK),
        ("TOPPADDING", (0,0), (-1,-1), 0),
        ("BOTTOMPADDING",(0,0),(-1,-1), 0),
    ]))
    story.append(cover_bg)

    # Re-build as layered content on cover
    cover_content = []
    cover_content.append(Spacer(1, 0.9*inch))
    cover_content.append(make_logo(130, 130))
    cover_content.append(Spacer(1, 0.3*inch))
    cover_content.append(Paragraph("CareLink", S["cover_title"]))
    cover_content.append(Paragraph("AI-Powered Blood Pressure Monitor", S["cover_sub"]))
    cover_content.append(Spacer(1, 0.5*inch))

    meta = [
        ("User Manual", True),
        ("Version 1.0", False),
        ("", False),
        ("Team Members", True),
        ("Jialu Huang  •  Diana Ding  •  Kelly Peng", False),
        ("", False),
        ("Industrial Sponsor", True),
        ("Candice  •  Justin Ho", False),
        ("", False),
        ("Submission Date: March 12, 2026", False),
    ]
    for text, bold in meta:
        if not text:
            cover_content.append(Spacer(1, 0.05*inch))
        elif bold:
            cover_content.append(Paragraph(f"<b>{text}</b>",
                ParagraphStyle("CM", fontSize=11, fontName="Helvetica-Bold",
                               textColor=colors.HexColor("#FFB3DC"),
                               alignment=TA_CENTER, leading=16)))
        else:
            cover_content.append(Paragraph(text, S["cover_meta"]))

    cover_table = Table([[cover_content]], colWidths=[7*inch])
    cover_table.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,-1), DARK_PINK),
        ("VALIGN",     (0,0), (-1,-1), "TOP"),
    ]))
    story = [cover_table, PageBreak()]

    # ════════════════════════════════════════════════════════════════
    # 1. PRODUCT OVERVIEW
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("1. Product Overview", S["h1"]))
    story.append(divider())
    story.append(Paragraph(
        "CareLink is a smartphone application designed to make blood pressure monitoring "
        "easy, accurate, and worry-free for seniors and patients with limited technical experience. "
        "Instead of asking users to manually read and record numbers from a blood pressure cuff, "
        "CareLink's built-in AI camera simply looks at the monitor screen and reads the numbers "
        "automatically — no typing required.",
        S["body"]))
    story.append(Spacer(1, 6))

    story.append(Paragraph("The Problem It Solves", S["h2"]))
    story.append(Paragraph(
        "Many older adults struggle to accurately read small numbers on blood pressure monitors "
        "and record them into a notebook or phone. Misread values, forgotten readings, and lack "
        "of clinician visibility are common problems that can lead to undetected hypertension. "
        "CareLink eliminates this friction entirely.",
        S["body"]))

    story.append(Paragraph("Who It Is Designed For", S["h2"]))
    for item in [
        "Seniors (65+) with limited smartphone experience",
        "Patients managing hypertension or cardiovascular conditions",
        "Caregivers who assist elderly family members with health monitoring",
        "Clinicians who need remote visibility into patient BP trends",
    ]:
        story.append(Paragraph(f"• {item}", S["bullet"]))

    story.append(Paragraph("Primary Features", S["h2"]))
    features = [
        ["Feature", "Description"],
        ["AI Camera Reading", "Point the phone at the BP monitor; Claude AI reads the numbers automatically"],
        ["Voice Guidance", "Step-by-step spoken instructions walk users through the entire measurement process"],
        ["Auto Photo Capture", "The app takes the photo automatically (10-second countdown) if the user forgets to tap"],
        ["AI Voice Assistant", "Ask health questions by voice and receive spoken answers"],
        ["History & Trends", "All readings saved and grouped by day; daily averages displayed at a glance"],
        ["Cloud Sync", "Readings securely uploaded to the clinician dashboard in real time"],
    ]
    story.append(make_table(features, [1.7*inch, 5.0*inch]))
    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 2. SYSTEM REQUIREMENTS
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("2. System Requirements", S["h1"]))
    story.append(divider())

    story.append(Paragraph("Patient iOS App", S["h2"]))
    reqs = [
        ["Requirement", "Specification"],
        ["Operating System", "iOS 15.0 or later"],
        ["Device", "iPhone 8 or later (physical device required — camera & microphone)"],
        ["Storage", "Minimum 100 MB free space"],
        ["Internet", "Wi-Fi or cellular data required for AI analysis and cloud sync"],
        ["Camera", "Rear or front camera (auto-selected by user)"],
        ["Microphone", "Required for voice input and voice guidance"],
        ["Claude API Key", "Anthropic account with active API access"],
        ["OpenAI API Key", "OpenAI account with Whisper API access (speech-to-text)"],
        ["Backend URL", "Network access to the CareLink REST API server"],
    ]
    story.append(make_table(reqs, [2.0*inch, 4.7*inch]))

    story.append(Paragraph("Clinician Dashboard (Web)", S["h2"]))
    web_reqs = [
        ["Requirement", "Specification"],
        ["Browser", "Chrome 110+, Safari 16+, Firefox 110+, or Edge 110+"],
        ["Internet", "Broadband connection required"],
        ["Backend", "CareLink Node.js/Python API server running and accessible"],
    ]
    story.append(make_table(web_reqs, [2.0*inch, 4.7*inch]))

    story.append(Paragraph("Development Environment (for building from source)", S["h2"]))
    dev_reqs = [
        ["Requirement", "Specification"],
        ["macOS", "macOS 13.0 (Ventura) or later"],
        ["Xcode", "Xcode 15.0 or later"],
        ["Swift", "Swift 5.9 (included with Xcode 15)"],
        ["CocoaPods / SPM", "Not required — no third-party dependencies"],
        ["Apple Developer Account", "Free account sufficient for personal device testing"],
    ]
    story.append(make_table(dev_reqs, [2.0*inch, 4.7*inch]))
    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 3. INSTALLATION & SETUP
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("3. Installation & Setup", S["h1"]))
    story.append(divider())
    story.append(Paragraph(
        "Follow these steps carefully. No prior programming experience is needed to run the app "
        "on your phone. The build steps require a Mac.",
        S["body"]))
    story.append(Spacer(1, 6))

    steps_setup = [
        ("1", "Accept the GitHub Assignment",
         "Click the assignment link provided by your instructor. This creates a private GitHub "
         "repository for your team. Accept the invitation and note the repository URL."),
        ("2", "Clone the Repository",
         "Open Terminal (Finder → Applications → Utilities → Terminal) and run:\n"
         "   git clone https://github.com/[your-org]/[repo-name].git\n"
         "   cd [repo-name]"),
        ("3", "Open the Project in Xcode",
         "Double-click carelink.xcodeproj, or in Terminal run:\n"
         "   open carelink.xcodeproj\n"
         "Xcode will open. Wait for indexing to complete (progress bar in top center)."),
        ("4", "Connect Your iPhone",
         "Plug your iPhone into your Mac with a USB cable. If prompted on iPhone, tap 'Trust'. "
         "In Xcode, click the device selector (top bar, left of the play button) and choose your iPhone."),
        ("5", "Set the Development Team",
         "In Xcode: click the project name (carelink) in the left panel → select the carelink target → "
         "go to Signing & Capabilities → choose your Apple ID under Team. "
         "If you don't see your Apple ID, go to Xcode → Settings → Accounts → add your Apple ID."),
        ("6", "Build and Install",
         "Press ⌘ + R (or click the triangular Play button). Xcode compiles the app and installs it "
         "on your phone. The first build takes 1–3 minutes."),
        ("7", "Trust the Developer Certificate on iPhone",
         "On iPhone: Settings → General → VPN & Device Management → your Apple ID → Trust. "
         "This one-time step is required for apps not distributed through the App Store."),
        ("8", "Configure API Keys (in-app)",
         "Open CareLink on your phone → tap Settings (bottom right tab).\n"
         "• Enter your Claude API Key (from console.anthropic.com).\n"
         "• Enter your OpenAI API Key (from platform.openai.com) for voice input.\n"
         "• Enter the Backend API URL (ask your team's backend developer for the IP address)."),
        ("9", "Grant Permissions",
         "The first time you tap Measure or the microphone, iOS will ask for Camera and Microphone "
         "permission. Tap Allow for both. These permissions can be reviewed later in iPhone Settings → CareLink."),
    ]

    for num, title, detail in steps_setup:
        story.append(step(num, title, detail, S))
        story.append(Spacer(1, 6))

    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 4. OPERATING INSTRUCTIONS
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("4. Operating Instructions", S["h1"]))
    story.append(divider())

    story.append(Paragraph("Starting the App", S["h2"]))
    story.append(Paragraph(
        "Tap the CareLink icon on your iPhone home screen. The app opens to the Home tab "
        "(voice assistant). Ensure your volume is turned up — the app speaks aloud throughout.",
        S["body"]))

    story.append(Paragraph("Taking a Blood Pressure Measurement", S["h2"]))
    bp_steps = [
        ("1", "Open the Measure tab",
         "Tap the heart icon at the bottom center of the screen labeled Measure."),
        ("2", "Tap Start Measurement",
         "The app begins voice guidance immediately. Listen carefully and follow each spoken instruction."),
        ("3", "Step 1 — Turn on your BP monitor",
         "Power on your blood pressure device."),
        ("4", "Step 2 — Put on the cuff",
         "Wrap the cuff around your upper arm as instructed by your device's manual."),
        ("5", "Step 3 — Press START on the monitor",
         "Press the START button on your blood pressure device."),
        ("6", "Step 4 — Wait for the measurement",
         "Sit still for approximately 60 seconds while the cuff inflates and deflates. "
         "The app will announce progress at the 30-second mark."),
        ("7", "Step 5 — Point camera at screen",
         "When numbers appear on the monitor display, hold your phone camera toward the screen. "
         "The large pink Take Photo button will pulse. Either tap it OR wait 10 seconds — the app "
         "takes the photo automatically."),
        ("8", "Review the result",
         "The app shows the detected systolic, diastolic, and pulse values. "
         "Tap Save if correct, Re-capture to try again, or Edit to type values manually."),
        ("9", "Reading is saved",
         "The reading is saved locally and uploaded to the clinician dashboard automatically."),
    ]
    for num, title, detail in bp_steps:
        story.append(step(num, title, detail, S))
        story.append(Spacer(1, 4))

    story.append(Paragraph("Using the AI Voice Assistant", S["h2"]))
    story.append(Paragraph(
        "Tap the Home tab → tap the microphone button → speak your question (e.g., "
        "\"Is 130 over 85 high?\"). The app transcribes your speech, sends it to the AI, "
        "and reads the answer aloud. The microphone disables itself during analysis to prevent "
        "accidental double-taps. It re-enables automatically when the response is ready.",
        S["body"]))

    story.append(Paragraph("Viewing History", S["h2"]))
    story.append(Paragraph(
        "Tap the History tab. Readings are grouped by date. If you took 2 or more readings in "
        "one day, an Avg row appears at the bottom of that day showing the average values. "
        "Tap any individual row to see details. A tip at the top encourages 5 readings per day "
        "for better accuracy.",
        S["body"]))

    story.append(Paragraph("Shutting Down", S["h2"]))
    story.append(Paragraph(
        "CareLink does not require a formal shutdown. Simply press the iPhone home button or swipe "
        "up to return to the home screen. All data is saved automatically. Pending cloud uploads "
        "complete in the background.",
        S["body"]))

    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 5. TECHNICAL SPECIFICATIONS
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("5. Technical Specifications", S["h1"]))
    story.append(divider())

    story.append(Paragraph("Architecture", S["h2"]))
    story.append(Paragraph(
        "CareLink follows an MVC (Model-View-Controller) pattern implemented in Swift/UIKit. "
        "The app communicates with external AI APIs over HTTPS and syncs data to a REST backend. "
        "All local data is persisted using UserDefaults and in-memory arrays. "
        "There is no local database — readings are stored in a JSON-serializable array keyed "
        "in UserDefaults and mirrored to Firestore via the backend.",
        S["body"]))

    story.append(Paragraph("Technologies Used", S["h2"]))
    tech = [
        ["Layer", "Technology", "Purpose"],
        ["UI", "Swift 5.9 / UIKit", "Native iOS interface, all screens"],
        ["Camera", "AVFoundation (AVCaptureSession)", "Live camera feed, photo capture, video frames"],
        ["Speech Output", "AVSpeechSynthesizer", "Text-to-speech for voice guidance"],
        ["Speech Input", "AVAudioRecorder + OpenAI Whisper", "Record audio; transcribe to text"],
        ["AI Vision", "Claude claude-opus-4-6 (Anthropic)", "Read BP numbers from photos"],
        ["AI Chat", "Claude claude-sonnet-4-6 (Anthropic)", "Answer health questions"],
        ["AI Guidance", "Claude claude-haiku-4-5-20251001", "Behavior-based measurement tips"],
        ["Image Processing", "Core Image (CIColorControls)", "Enhance contrast before sending to AI"],
        ["Networking", "URLSession", "HTTPS API calls to Anthropic, OpenAI, backend"],
        ["Local Storage", "UserDefaults", "API keys, settings, readings cache"],
        ["Cloud", "REST API → Firestore", "Sync readings to clinician dashboard"],
    ]
    story.append(make_table(tech, [1.4*inch, 2.1*inch, 3.2*inch]))

    story.append(Paragraph("AI Model Configuration", S["h2"]))
    models = [
        ["Task", "Model", "Max Tokens", "Timeout"],
        ["BP Image Reading", "claude-opus-4-6", "120", "50 s"],
        ["AI Chat", "claude-sonnet-4-6", "500", "60 s"],
        ["Behavior Guidance", "claude-haiku-4-5-20251001", "56", "25 s"],
        ["Speech-to-Text", "whisper-1 (OpenAI)", "—", "30 s"],
    ]
    story.append(make_table(models, [2.0*inch, 2.4*inch, 1.0*inch, 1.3*inch]))

    story.append(Paragraph("Data Flow", S["h2"]))
    story.append(Paragraph(
        "1. User completes measurement → 2. Photo captured by AVCapturePhotoOutput → "
        "3. Image resized (max 1536 px) and contrast-enhanced (Core Image) → "
        "4. Base64-encoded and sent to Claude Vision API → "
        "5. JSON response parsed (systolic, diastolic, pulse) → "
        "6. User confirms → 7. BloodPressureReading saved to UserDefaults → "
        "8. CloudSyncService POSTs reading to backend REST API → "
        "9. Backend writes to Firestore under patient document.",
        S["body"]))

    story.append(Paragraph("Firestore Patient Schema", S["h2"]))
    firestore = [
        ["Field", "Type", "Example"],
        ["id", "string", "P-2025-001"],
        ["firstName / lastName", "string", "Robert / Anderson"],
        ["dateOfBirth", "string (ISO 8601)", "1958-03-15"],
        ["diagnosis", "array of strings", "['Hypertension', 'Type 2 Diabetes']"],
        ["medications", "array of maps", "{name, dosage, frequency, startDate}"],
        ["targetSystolic / targetDiastolic", "number", "130 / 80"],
        ["riskLevel", "string", "high"],
        ["assignedClinicianId", "string", "clinician-001"],
        ["address", "map", "{street, city, state, zipCode}"],
        ["emergencyContact", "map", "{name, phone, relationship}"],
    ]
    story.append(make_table(firestore, [2.0*inch, 1.6*inch, 3.1*inch]))

    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 6. DATA PRIVACY, SECURITY & LIMITATIONS
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("6. Data Privacy, Security & Known Limitations", S["h1"]))
    story.append(divider())

    story.append(Paragraph("Data Privacy", S["h2"]))
    for item in [
        "Camera images taken for BP reading are transmitted directly to the Anthropic API over TLS/HTTPS "
        "and are NOT stored on Anthropic servers beyond the API call duration per Anthropic's data usage policy.",
        "Voice recordings are sent to OpenAI's Whisper API over HTTPS and are subject to OpenAI's privacy policy. "
        "Audio is not stored locally after transcription.",
        "Blood pressure readings and patient identifiers are transmitted to the backend server. "
        "Ensure the backend is hosted on a HIPAA-compliant infrastructure if used in a clinical setting.",
        "API keys are stored in iOS UserDefaults (device local storage). Keys are not transmitted anywhere other "
        "than the respective API endpoints.",
        "No analytics, crash reporting, or third-party tracking SDKs are included in this application.",
    ]:
        story.append(Paragraph(f"• {item}", S["bullet"]))

    story.append(Paragraph("Security Warnings", S["h2"]))
    for item in [
        "Never share your Claude or OpenAI API keys. Anyone with your key can incur charges on your account.",
        "The backend API URL should use HTTPS in production. Using HTTP (e.g., http://192.168.x.x) is acceptable "
        "only on a private LAN during development.",
        "Patient health data (BP readings) should only be stored on HIPAA-compliant servers in a real clinical deployment.",
        "Lock your iPhone with a passcode to prevent unauthorized access to stored readings and API keys.",
    ]:
        story.append(Paragraph(f"• {item}", S["bullet"]))

    story.append(Paragraph("Known Operational Limitations", S["h2"]))
    limitations = [
        ["Limitation", "Details / Workaround"],
        ["Camera required", "The app cannot run on the iOS Simulator. A physical iPhone is mandatory."],
        ["AI reading accuracy", "Claude Vision performs best with clear, well-lit monitor screens. Poor lighting, glare, or blurry images may result in incorrect readings. Use the Re-capture option or enter values manually."],
        ["Whisper language", "Voice input defaults to auto-detect. Performance is best in English. Non-English languages may transcribe with errors."],
        ["Silence detection", "Auto-stop for voice recording triggers at −40 dB after 2 seconds of silence. Very quiet environments may cause premature stopping."],
        ["Offline mode", "AI features (camera reading, voice chat) require an internet connection. Readings can be saved locally offline, but cloud sync will retry when connectivity is restored."],
        ["BP monitor compatibility", "The AI reads digital display screens. Analog (dial) manometers are not supported."],
        ["API rate limits", "Heavy usage may hit Anthropic or OpenAI rate limits. If errors occur, wait 30 seconds and retry."],
    ]
    story.append(make_table(limitations, [1.8*inch, 4.9*inch]))

    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 6b. CLINICIAN DASHBOARD
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("6b. Clinician Dashboard", S["h1"]))
    story.append(divider())
    story.append(Paragraph(
        "CareLink includes a separate web-based dashboard for clinicians to monitor patients "
        "remotely, review blood pressure trends, manage medications, and send care reminders. "
        "It is built with Next.js 16 (App Router) and Firebase Firestore.",
        S["body"]))
    story.append(Paragraph(
        "⚠  Important: This dashboard is a demo/MVP for product validation. Do not use with "
        "real PHI or production clinical workflows without security and compliance hardening.",
        ParagraphStyle("Warn", fontSize=10, fontName="Helvetica-Bold",
                       textColor=DARK_PINK, backColor=LIGHT_PINK,
                       spaceAfter=8, spaceBefore=4, leading=15,
                       leftIndent=10, rightIndent=10)))

    story.append(Paragraph("Features", S["h2"]))
    dash_features = [
        ["#", "Feature", "Description"],
        ["1", "Clinician Auth", "Login/logout with session in localStorage; protected pages via AuthProvider and route redirect"],
        ["2", "Patient Overview (/)", "Risk-priority patient list, latest BP per patient, daily aggregate support, Add Patient drawer"],
        ["3", "Patient Details (/patients/[id])", "BP history charts, readings table, medication list, Adjust Medication drawer, PDF report export"],
        ["4", "Alert Management", "Alert triage workflow, state updates, messaging entry points from all pages"],
        ["5", "BP Reminders", "Email delivery via Resend API; SMS path returns demo success response"],
    ]
    story.append(make_table(dash_features, [0.3*inch, 1.8*inch, 4.6*inch]))

    story.append(Paragraph("Demo Login Credentials", S["h2"]))
    story.append(Paragraph("Email: sarah.chen@carelink.health", S["code"]))
    story.append(Paragraph("Password: carelink2025", S["code"]))

    story.append(Paragraph("Tech Stack", S["h2"]))
    dash_tech = [
        ["Layer", "Technology"],
        ["Framework", "Next.js 16 (App Router)"],
        ["Language", "TypeScript + React 19"],
        ["Styling", "Tailwind CSS"],
        ["Charts", "Recharts"],
        ["PDF Export", "jsPDF + html2canvas"],
        ["Database", "Firebase Firestore + Firebase Admin SDK"],
        ["Email", "Resend REST API"],
    ]
    story.append(make_table(dash_tech, [2.0*inch, 4.7*inch]))

    story.append(Paragraph("API Routes", S["h2"]))
    api_routes = [
        ["Method", "Route", "Purpose"],
        ["GET / POST", "/api/patients", "List or create patients"],
        ["GET / PUT / DELETE", "/api/patients/[id]", "Patient profile, update, delete"],
        ["GET / POST", "/api/readings", "Reading retrieval and ingest"],
        ["POST", "/api/blood-pressure", "iOS-compatible BP ingest alias"],
        ["GET / PATCH", "/api/alerts", "Alert list and state updates"],
        ["GET / POST / DELETE", "/api/notes", "Clinician notes CRUD"],
        ["POST", "/api/reminders", "Email reminder (Resend) + SMS demo"],
    ]
    story.append(make_table(api_routes, [1.5*inch, 2.0*inch, 3.2*inch]))

    story.append(Paragraph("Local Setup", S["h2"]))
    dash_steps = [
        ("1", "Navigate to dashboard folder",
         "cd carelink_clinician-dashboard-main"),
        ("2", "Install dependencies",
         "npm install"),
        ("3", "Configure environment variables",
         "Copy .env.example to .env.local and fill in Firebase project credentials "
         "and your Resend API key. Without Firebase admin config the app runs in demo fallback mode."),
        ("4", "Start development server",
         "npm run dev\nOpen http://localhost:3000 in your browser."),
        ("5", "Log in",
         "Use the demo credentials above or configure your own Firestore-backed clinician accounts."),
    ]
    for num, title, detail in dash_steps:
        story.append(step(num, title, detail, S))
        story.append(Spacer(1, 4))

    story.append(Paragraph("Security & Compliance Notes", S["h2"]))
    for item in [
        "Demo-oriented auth/session behavior — no HIPAA-grade audit trail or enterprise IAM integration.",
        "Do not store real patient PHI (Protected Health Information) until security controls are implemented.",
        "The Resend API key must be kept private and never committed to source control.",
        "Firebase Admin SDK credentials (service account JSON) must never be committed to the repository.",
        "In production, replace localStorage session persistence with a secure, server-side session mechanism.",
    ]:
        story.append(Paragraph(f"• {item}", S["bullet"]))

    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════════
    # 7. TROUBLESHOOTING
    # ════════════════════════════════════════════════════════════════
    story.append(Paragraph("7. Troubleshooting", S["h1"]))
    story.append(divider())
    trouble = [
        ["Symptom", "Likely Cause", "Solution"],
        ['"API key not configured"', "No API key entered in Settings", "Settings tab → enter Claude API key"],
        ["Camera shows black screen", "Running on Simulator or permission denied", "Use real iPhone; grant camera permission in iOS Settings → CareLink"],
        ["AI cannot read numbers", "Poor lighting, blurry image, or small display", "Hold phone steady, move closer, ensure good lighting; try Re-capture"],
        ['"Model error" in chat', "Incorrect or expired API key", "Settings → re-enter a valid Claude API key"],
        ["Voice reads emoji aloud", "Should not occur (fixed)", "Update to latest version — emoji are stripped before TTS"],
        ["Cloud sync fails", "Wrong backend URL or server offline", "Settings → verify backend URL; check server is running"],
        ["Mic button unresponsive", "Analysis still in progress", "Wait for the current response to finish — mic re-enables automatically"],
        ["Auto photo not firing", "User stopped the measurement flow", "Re-tap Start Measurement and proceed through all 5 steps"],
    ]
    story.append(make_table(trouble, [1.8*inch, 2.1*inch, 2.8*inch]))

    # ════════════════════════════════════════════════════════════════
    # Back matter
    # ════════════════════════════════════════════════════════════════
    story.append(Spacer(1, 0.4*inch))
    story.append(HRFlowable(width="100%", thickness=1, color=PINK))
    story.append(Spacer(1, 8))
    story.append(Paragraph(
        "CareLink v1.0  •  User Manual  •  Built for seniors who need simple, reliable blood pressure monitoring.",
        ParagraphStyle("Footer", fontSize=9, fontName="Helvetica-Oblique",
                       textColor=MID_GRAY, alignment=TA_CENTER)))

    doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
    print(f"PDF generated: {OUTPUT}")


if __name__ == "__main__":
    build_pdf()
