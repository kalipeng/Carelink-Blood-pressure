# 🍓 Health Pad - Raspberry Pi Edition

A senior-friendly blood pressure monitoring system for **ELECROW 10.1" touchscreen + Raspberry Pi**.

---

## 🎯 What This Is

A complete blood pressure monitoring application that:
- ✅ Connects to **iHealth KN-550BT** blood pressure monitor via Bluetooth
- ✅ Displays measurements on **ELECROW 10.1" touchscreen** (1280x800)
- ✅ Runs on **Raspberry Pi 4B/5** (or 3B+)
- ✅ Senior-friendly large buttons and fonts
- ✅ Full-screen kiosk mode
- ✅ Auto-start on boot

---

## 📦 Hardware Requirements

### What You Need:
- ✅ **ELECROW 10.1" Touchscreen** (1280x800 IPS LCD)
- ✅ **Raspberry Pi 4B or 5** (recommended, 4GB RAM)
- ✅ **iHealth KN-550BT** Blood Pressure Monitor
- ✅ **microSD Card** (16GB+ recommended)
- ✅ **Power Supply** (5V 3A for Pi 4/5)

### Total Cost: ~$75-95
(vs $500+ for iPad)

---

## 📁 Project Structure

```
Health Pad/
├── preview.html              ← Web interface (frontend)
├── raspberry_pi/             ← Backend + Installation
│   ├── backend.py               Python server (Bluetooth + API)
│   ├── install.sh               One-click installation script
│   └── README.md                Detailed setup guide
└── README.md                 ← This file
```

---

## 🚀 Quick Start

### For First-Time Setup → See [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md)

This guide covers:
- ✅ Waiting for first boot
- ✅ Network connectivity
- ✅ SSH connection
- ✅ Remote installation
- ✅ Troubleshooting

### Step 1: Flash Raspberry Pi OS
1. Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Flash **Raspberry Pi OS (with Desktop)** to microSD card
3. Boot Raspberry Pi

### Step 2: Connect Hardware
```
ELECROW Screen → Raspberry Pi HDMI port
ELECROW USB    → Raspberry Pi USB port (for touch)
Power          → Connect 5V 3A power supply
```

### Step 3: Install Health Pad
```bash
# On Raspberry Pi terminal:
cd ~
git clone [this-repo] healthpad
cd healthpad

# Run installation script:
chmod +x raspberry_pi/install.sh
./raspberry_pi/install.sh

# Reboot after installation:
sudo reboot
```

### Step 4: Done!
After reboot, Health Pad will automatically start in full-screen mode.

---

## 🎮 How to Use

### Automatic Mode (Default):
1. Turn on Raspberry Pi
2. System boots and auto-starts Health Pad
3. Touch screen to interact
4. Turn on iHealth KN-550BT device
5. Click "Measure BP" to connect and measure

### Manual Mode:
```bash
cd ~/healthpad/raspberry_pi
source venv/bin/activate
python3 backend.py &
chromium-browser --kiosk http://localhost:8080/preview.html
```

### Exit Kiosk Mode:
Press **Alt + F4** or **Ctrl + Alt + F2** to exit

---

## 🌟 Features

### User Interface:
- ✅ **Large buttons** (120x120pt minimum)
- ✅ **Extra large fonts** (72pt for BP values)
- ✅ **High contrast** colors (T-Mobile magenta theme)
- ✅ **Touch-optimized** for seniors
- ✅ **English interface**

### Functionality:
- ✅ **Bluetooth connection** to iHealth device
- ✅ **Real-time measurement** display
- ✅ **Blood pressure classification** (Normal, High, etc.)
- ✅ **Measurement history** with date/time
- ✅ **Auto-save** measurements locally
- ✅ **WebSocket** real-time updates

### System:
- ✅ **Auto-start on boot**
- ✅ **Kiosk mode** (full-screen, no system UI)
- ✅ **24/7 operation** capable
- ✅ **Low power** consumption (~5W)

---

## 📱 Interface Preview

Open `preview.html` in any browser to preview the interface (won't connect to device).

```
┌────────────────────────────────┐
│  Health Pad     [Not Connected] │
├────────────────┬───────────────┤
│                │               │
│  Measure BP    │   History     │
│      ❤️        │      📈       │
│                │               │
└────────────────┴───────────────┘
```

---

## 🔧 Technical Details

### Backend (Python):
- **Framework**: aiohttp (async web server)
- **Bluetooth**: bleak (cross-platform BLE)
- **API**: REST + WebSocket
- **Port**: 8080

### Frontend (Web):
- **HTML5** + CSS3 + JavaScript
- **Responsive** design (adapts to screen size)
- **WebSocket** for real-time updates

### Hardware Interface:
- **Display**: HDMI (1280x800)
- **Touch**: USB (10-point capacitive)
- **Bluetooth**: Built-in Pi 4/5 (BLE 5.0)

---

## 📊 Blood Pressure Classification

| Range | Systolic | Diastolic | Status |
|-------|----------|-----------|--------|
| Normal | <120 | <80 | 🟢 Green |
| Elevated | 120-129 | <80 | 🟡 Yellow |
| High Stage 1 | 130-139 | 80-89 | 🟠 Orange |
| High Stage 2 | 140-179 | 90-119 | 🔴 Red |
| Crisis | ≥180 | ≥120 | 🔴 Dark Red |

---

## 🐛 Troubleshooting

### Touchscreen not working:
```bash
# Check USB connection
lsusb
# Should see touch device
```

### Bluetooth not working:
```bash
# Restart Bluetooth
sudo systemctl restart bluetooth
# Scan for devices
hcitool scan
```

### Backend not starting:
```bash
# Check logs
cd ~/healthpad/raspberry_pi
source venv/bin/activate
python3 backend.py
```

### Screen orientation wrong:
```bash
sudo nano /boot/config.txt
# Add: lcd_rotate=2  (180 degrees)
```

---

## 🔄 Updates

To update the system:
```bash
cd ~/healthpad
git pull  # or manually copy updated files
sudo reboot
```

---

## 🆚 Why Raspberry Pi?

| Feature | iPad | Android Tablet | Raspberry Pi + ELECROW |
|---------|------|----------------|----------------------|
| **Cost** | $500+ | $200+ | **$75-95** ✅ |
| **Bluetooth** | ✅ | ✅ | ✅ |
| **Touch** | ✅ | ✅ | ✅ |
| **Customizable** | ❌ | Limited | **Fully** ✅ |
| **24/7 Operation** | ❌ | ❌ | **Yes** ✅ |
| **No Approval** | ❌ | ❌ | **Yes** ✅ |
| **Power** | 10W | 8W | **5W** ✅ |

---

## 📞 Support

For detailed setup instructions, see:
- `raspberry_pi/README.md` - Complete installation guide
- `raspberry_pi/backend.py` - Backend source code
- `preview.html` - Frontend interface

---

## 📝 License

MIT License - Free to use and modify

---

## 🎯 Project Status

✅ **Ready to Deploy**
- Frontend: Complete
- Backend: Complete
- Installation: Automated
- Documentation: Complete

---

**Built for ELECROW 10.1" Touchscreen + Raspberry Pi + iHealth KN-550BT**

Made with ❤️ for seniors who need simple, reliable health monitoring.
