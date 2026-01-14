# 🚀 START HERE - Quick Setup Guide

## ✅ Your Project is Ready!

Everything is set up for **Raspberry Pi + ELECROW touchscreen** deployment.

---

## 📦 What You Have

```
Health Pad/
├── preview.html              ← Web interface (frontend)
├── raspberry_pi/             ← Backend & installation
│   ├── backend.py               Python server (350 lines)
│   ├── install.sh               One-click installer
│   ├── requirements.txt         Python dependencies
│   └── README.md                Detailed guide
├── README.md                 ← Project overview
└── START_HERE.md             ← This file
```

---

## 🎯 Next Steps

### Step 1: Get Hardware (if you don't have it yet)
- 🍓 Raspberry Pi 4B or 5 (4GB RAM) - **$55**
- 💾 microSD card 32GB - **$10**
- 🔌 Power supply 5V 3A - **$10**
- 🖥️ ELECROW 10.1" touchscreen - **You have this ✅**
- 📱 iHealth KN-550BT - **You have this ✅**

**Total: ~$75**

---

### Step 2: Flash Raspberry Pi OS

1. Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Insert microSD card into computer
3. Flash **Raspberry Pi OS (64-bit, with Desktop)**
4. Insert SD card into Raspberry Pi
5. Boot up

---

### Step 3: Connect Hardware

```
[ELECROW Screen] → [Raspberry Pi HDMI]
[ELECROW USB]    → [Raspberry Pi USB]  (for touch)
[Power Supply]   → [Raspberry Pi USB-C]
```

---

### Step 4: Copy Files to Raspberry Pi

**Option A: USB Drive**
```bash
# Copy this entire folder to USB drive
# On Raspberry Pi:
cp -r /media/pi/USB/Health\ Pad ~/healthpad
```

**Option B: Network Transfer**
```bash
# On Raspberry Pi:
cd ~
# Use file manager to download or copy files
```

**Option C: Git (if you use GitHub)**
```bash
# Upload to GitHub first, then on Raspberry Pi:
git clone [your-repo-url] healthpad
```

---

### Step 5: Install & Run

```bash
# On Raspberry Pi terminal:
cd ~/healthpad/raspberry_pi

# Make installer executable
chmod +x install.sh

# Run installation (takes 5-10 minutes)
./install.sh

# Reboot
sudo reboot
```

---

### Step 6: Done! 🎉

After reboot:
- ✅ Health Pad starts automatically
- ✅ Full-screen interface
- ✅ Touch the screen to use
- ✅ Turn on iHealth device and click "Measure BP"

---

## 🎮 How to Use

### Measure Blood Pressure:
1. Turn on **iHealth KN-550BT** device
2. Touch **"Measure BP"** button
3. System auto-scans and connects
4. Wear cuff on left arm
5. Touch **"Start Measurement"**
6. Results display in 30 seconds

### View History:
1. Touch **"History"** button
2. See all past measurements
3. Touch any measurement for details

---

## 🔧 Manual Control

### Start Backend Manually:
```bash
cd ~/healthpad/raspberry_pi
source venv/bin/activate
python3 backend.py
```

### Access from Browser:
```bash
# On Raspberry Pi or any computer on same network:
http://localhost:8080/preview.html
# Or from another device:
http://[raspberry-pi-ip]:8080/preview.html
```

### Exit Kiosk Mode:
- Press **Alt + F4**
- Or **Ctrl + Alt + F2** to switch to terminal

---

## 📱 Test on Your Computer First

You can preview the interface on your Mac:

```bash
# Just open in any browser:
open preview.html
```

**Note:** Web preview won't connect to device (browser limitation), but you can see the interface design.

---

## 🐛 Troubleshooting

### Screen shows black/no signal:
- Check HDMI cable connection
- Try different HDMI port
- Ensure Raspberry Pi is powered on

### Touch not working:
- Check USB cable from ELECROW to Pi
- Run: `lsusb` (should see touch device)
- Replug USB cable

### Bluetooth not finding device:
```bash
# Check Bluetooth status
sudo systemctl status bluetooth

# Restart Bluetooth
sudo systemctl restart bluetooth

# Manual scan
bluetoothctl
scan on
```

### Backend won't start:
```bash
# Check Python version (need 3.7+)
python3 --version

# Reinstall dependencies
cd ~/healthpad/raspberry_pi
source venv/bin/activate
pip install -r requirements.txt
```

---

## 📊 System Architecture

```
┌─────────────────────────────┐
│  ELECROW 10.1" Screen       │  ← User Interface
│  Touch Input + Display      │
└──────────────┬──────────────┘
               │ HDMI + USB
┌──────────────▼──────────────┐
│  Raspberry Pi 4B/5          │  ← Main Computer
│  ┌─────────────────────┐    │
│  │ Chromium Browser    │    │  ← Displays preview.html
│  │ (Kiosk Mode)        │    │
│  ├─────────────────────┤    │
│  │ Python Backend      │    │  ← Handles Bluetooth
│  │ (backend.py)        │    │
│  └─────────────────────┘    │
└──────────────┬──────────────┘
               │ Bluetooth LE
┌──────────────▼──────────────┐
│  iHealth KN-550BT           │  ← Blood Pressure Monitor
└─────────────────────────────┘
```

---

## 🌟 Key Features

- ✅ **No SDK needed** - Direct Bluetooth connection
- ✅ **Auto-start** - Boots into app automatically
- ✅ **Touch-optimized** - Large buttons for seniors
- ✅ **Real-time** - WebSocket updates
- ✅ **Local storage** - History saved on device
- ✅ **24/7 capable** - Can run continuously
- ✅ **Low power** - Only 5W consumption

---

## 📚 More Information

- `README.md` - Project overview
- `raspberry_pi/README.md` - Detailed setup instructions
- `raspberry_pi/backend.py` - Source code with comments
- `preview.html` - Frontend interface code

---

## ✨ Tips

### For Best Performance:
- Use Raspberry Pi 4 or 5 (not 3B+)
- 4GB RAM recommended
- Class 10 microSD card
- Keep system updated: `sudo apt update && sudo apt upgrade`

### For Remote Access:
```bash
# Enable SSH in raspi-config
sudo raspi-config
# Interface Options → SSH → Enable

# Find IP address
hostname -I

# SSH from another computer
ssh pi@[raspberry-pi-ip]
```

### To Add More Features:
- Edit `backend.py` for new functionality
- Edit `preview.html` for UI changes
- Restart: `sudo systemctl restart healthpad`

---

## 🎯 You're All Set!

Your Health Pad is ready to deploy on Raspberry Pi + ELECROW touchscreen!

**Questions?** Check `raspberry_pi/README.md` for detailed documentation.

---

**Happy monitoring! 💙**
