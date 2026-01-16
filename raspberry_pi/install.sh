#!/bin/bash

# Health Pad - Raspberry Pi Installation Script
# For Raspberry Pi 3B+/4B/5 with ELECROW touchscreen

echo "=========================================="
echo "Health Pad - Raspberry Pi Setup"
echo "=========================================="
echo ""

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
    echo "⚠️  Warning: This doesn't appear to be a Raspberry Pi"
    echo "   Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Enabling SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh
echo "✓ SSH enabled"

echo ""
echo "Step 2: Updating system..."
sudo apt-get update
sudo apt-get upgrade -y

echo ""
echo "Step 3: Installing core dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv
sudo apt-get install -y bluez bluez-tools avahi-daemon

echo ""
echo "Step 4: Configuring mDNS hostname..."
CURRENT_HOSTNAME=$(hostname)
if [ "$CURRENT_HOSTNAME" != "carelink-bp" ]; then
    echo "Current hostname: $CURRENT_HOSTNAME"
    sudo hostnamectl set-hostname carelink-bp
    echo "✓ Hostname set to: carelink-bp"
fi

# Enable avahi daemon for .local domain resolution
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
echo "✓ mDNS (Avahi) enabled"

echo ""
echo "Step 5: Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo ""
echo "Step 6: Installing Python packages..."
pip install --upgrade pip
pip install bleak aiohttp aiohttp-cors websockets

echo ""
echo "Step 7: Installing Chromium browser..."
sudo apt-get install -y chromium-browser unclutter

echo ""
echo "Step 8: Configuring touchscreen..."
# ELECROW 10.1" touchscreen usually works out of the box
# If rotation needed:
# sudo sh -c 'echo "lcd_rotate=2" >> /boot/config.txt'

echo ""
echo "Step 9: Setting up autostart..."
mkdir -p ~/.config/autostart

# Create desktop entry for kiosk mode
# Get home directory dynamically (works for any username)
HOME_DIR=$(eval echo ~$USER)
cat > ~/.config/autostart/healthpad.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Health Pad
Exec=$HOME_DIR/healthpad/start_kiosk.sh
EOF

echo ""
echo "Step 10: Creating startup script..."
cat > ~/healthpad/start_kiosk.sh <<'EOF'
#!/bin/bash

# Start backend server
cd ~/healthpad/raspberry_pi
source venv/bin/activate
python3 backend.py &

# Wait for server to start
sleep 3

# Hide mouse cursor
unclutter -idle 0.1 &

# Start Chromium in kiosk mode
chromium-browser \
    --kiosk \
    --noerrdialogs \
    --disable-infobars \
    --no-first-run \
    --enable-features=OverlayScrollbar \
    --disable-pinch \
    --overscroll-history-navigation=0 \
    http://localhost:8080/preview.html
EOF

chmod +x ~/healthpad/start_kiosk.sh

echo ""
echo "Step 11: Enabling Bluetooth..."
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
echo "✓ Bluetooth enabled"

echo ""
echo "=========================================="
echo "✅ Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reboot your Raspberry Pi: sudo reboot"
echo "2. After reboot, Health Pad will start automatically"
echo "3. Touch the screen to interact"
echo "4. Turn on iHealth KN-550BT device"
echo "5. Click 'Measure BP' to connect"
echo ""
echo "Manual start:"
echo "  cd ~/healthpad/raspberry_pi"
echo "  ./start_kiosk.sh"
echo ""
echo "To exit kiosk mode: Alt+F4"
echo "=========================================="
