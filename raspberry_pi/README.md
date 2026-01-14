# 🍓 Health Pad for Raspberry Pi + ELECROW Touchscreen

## Hardware Requirements

### Required:
- ✅ **Raspberry Pi 4B or 5** (recommended) or 3B+
- ✅ **ELECROW 10.1" Touchscreen** (1280x800)
- ✅ **iHealth KN-550BT** Blood Pressure Monitor
- ✅ **Power Supply** (5V 3A for Pi 4/5)
- ✅ **microSD Card** (16GB+ recommended)

### Optional:
- Case for Raspberry Pi
- Ethernet cable (or use WiFi)

---

## 🚀 Quick Start

### 1. Prepare SD Card
```bash
# Download Raspberry Pi OS (with desktop)
# Use Raspberry Pi Imager to flash SD card
# Boot Raspberry Pi
```

### 2. Connect Hardware
```
ELECROW Screen → Raspberry Pi HDMI port
ELECROW USB → Raspberry Pi USB port (for touch)
iHealth Device → Turn on (will connect via Bluetooth)
```

### 3. Install Health Pad
```bash
# Copy project files to Raspberry Pi
cd ~
mkdir healthpad
cd healthpad

# Copy all files from this folder

# Run installation script
chmod +x install.sh
./install.sh
```

### 4. Reboot
```bash
sudo reboot
```

### 5. Done!
After reboot, Health Pad will start automatically in fullscreen mode.

---

## 📱 Features

✅ **Full touchscreen support**
- Large buttons optimized for touch
- Responsive design
- No keyboard/mouse needed

✅ **Bluetooth connectivity**
- Auto-scan for iHealth devices
- Reliable connection
- Real-time measurement data

✅ **Kiosk mode**
- Fullscreen interface
- Auto-start on boot
- Hide system UI

✅ **Data storage**
- Local SQLite database
- Measurement history
- Export to CSV

---

## 🔧 Architecture

```
┌─────────────────────────────────────┐
│   ELECROW 10.1" Touchscreen         │
│   (1280x800 Display + Touch)        │
└─────────────────┬───────────────────┘
                  │ HDMI + USB
┌─────────────────▼───────────────────┐
│      Raspberry Pi 4B/5               │
│  ┌───────────────────────────────┐  │
│  │  Chromium (Fullscreen)        │  │
│  │  └─ preview.html (Frontend)   │  │
│  ├───────────────────────────────┤  │
│  │  Python Backend (API)         │  │
│  │  └─ Bluetooth Handler         │  │
│  └───────────────────────────────┘  │
└─────────────────┬───────────────────┘
                  │ Bluetooth
┌─────────────────▼───────────────────┐
│   iHealth KN-550BT                  │
│   (Blood Pressure Monitor)          │
└─────────────────────────────────────┘
```

---

## 🌐 API Endpoints

Backend runs on `http://localhost:8080`

### REST API:
```
GET  /api/scan          - Scan for devices
POST /api/connect       - Connect to device
POST /api/disconnect    - Disconnect
POST /api/measure       - Start measurement
GET  /api/status        - Get status
```

### WebSocket:
```
ws://localhost:8080/ws  - Real-time updates
```

---

## 🎮 Usage

### Automatic Mode (Kiosk):
1. Power on Raspberry Pi
2. System boots automatically
3. Health Pad starts fullscreen
4. Touch screen to interact

### Manual Mode:
```bash
cd ~/healthpad/raspberry_pi
source venv/bin/activate
python3 backend.py &
chromium-browser --kiosk http://localhost:8080/preview.html
```

### Exit Kiosk Mode:
- Press **Alt + F4**
- Or: **Ctrl + Alt + F2** (terminal), then kill chromium

---

## 📊 Screen Specifications

### ELECROW 10.1" Touchscreen:
- **Resolution**: 1280 x 800 pixels
- **Touch**: 10-point capacitive touch
- **Connection**: HDMI + USB
- **Compatibility**: Plug and play with Raspberry Pi
- **Stand**: Adjustable viewing angle

### Display Settings:
```bash
# If screen orientation is wrong:
sudo nano /boot/config.txt

# Add one of these:
lcd_rotate=0  # Normal
lcd_rotate=1  # 90 degrees
lcd_rotate=2  # 180 degrees
lcd_rotate=3  # 270 degrees
```

---

## 🔐 Security

### Enable SSH (for remote access):
```bash
sudo raspi-config
# Interface Options → SSH → Enable
```

### WiFi Setup:
```bash
sudo raspi-config
# System Options → Wireless LAN
```

---

## 🐛 Troubleshooting

### Touchscreen not working:
```bash
# Check USB connection
lsusb

# Should see touch device listed
# Reconnect USB cable if not found
```

### Bluetooth not working:
```bash
# Check Bluetooth status
sudo systemctl status bluetooth

# Restart Bluetooth
sudo systemctl restart bluetooth

# Check if device is detected
hcitool scan
```

### Backend not starting:
```bash
# Check logs
cd ~/healthpad/raspberry_pi
source venv/bin/activate
python3 backend.py

# Check if port is in use
sudo netstat -tulpn | grep 8080
```

### Screen blank after boot:
```bash
# Disable screen blanking
sudo nano /etc/lightdm/lightdm.conf

# Add under [Seat:*]:
xserver-command=X -s 0 -dpms
```

---

## 📈 Performance

### Raspberry Pi 4B/5:
- ✅ Smooth UI rendering
- ✅ Fast Bluetooth scanning
- ✅ Real-time updates
- ✅ 24/7 operation capable

### Raspberry Pi 3B+:
- ⚠️ Slightly slower UI
- ✅ Still functional
- ⚠️ May need to reduce animations

---

## 🔄 Updates

```bash
cd ~/healthpad
git pull  # If using git

# Or manually copy updated files
# Then restart:
sudo reboot
```

---

## 💡 Advantages over iPad/Android

✅ **Cost**: $100-150 vs $500+ for iPad
✅ **Customization**: Full Linux control
✅ **24/7 Operation**: No sleep mode issues
✅ **No App Store**: No approval needed
✅ **Open Source**: Complete freedom
✅ **Expandable**: Add sensors, displays, etc.
✅ **Ethernet**: Wired network option

---

## 📝 Notes

- First boot takes longer (system setup)
- Bluetooth pairing may require touching device
- For best performance, use Raspberry Pi 4 or 5
- ELECROW screen is plug-and-play, no drivers needed
- Touch calibration usually not required

---

## 🆘 Support

For issues:
1. Check logs: `~/healthpad/raspberry_pi/backend.log`
2. Test Bluetooth: `sudo bluetoothctl`
3. Test screen: Touch should work immediately
4. Check WiFi: `iwconfig`

---

## 🎯 Summary

Your setup:
```
ELECROW 10.1" Touchscreen + Raspberry Pi = 
Perfect Health Pad platform!

✅ Bluetooth: Yes
✅ Touch: Yes  
✅ iHealth Connect: Yes
✅ Cost: Low
✅ Reliability: High
```

Ready to deploy! 🚀
