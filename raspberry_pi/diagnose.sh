#!/bin/bash

# Health Pad - Diagnostic Script
# Run this on Raspberry Pi to check system status

echo "=========================================="
echo "Health Pad - System Diagnostic"
echo "=========================================="
echo ""

echo "📋 System Information:"
echo "  Hostname: $(hostname)"
echo "  IP Address: $(hostname -I)"
echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo ""

echo "🔧 Service Status:"
echo -n "  SSH: "
systemctl is-active ssh >/dev/null 2>&1 && echo "✓ Running" || echo "✗ Not running"

echo -n "  Bluetooth: "
systemctl is-active bluetooth >/dev/null 2>&1 && echo "✓ Running" || echo "✗ Not running"

echo -n "  Avahi (mDNS): "
systemctl is-active avahi-daemon >/dev/null 2>&1 && echo "✓ Running" || echo "✗ Not running"

echo ""

echo "🌐 Network Connectivity:"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "  ✓ Internet access verified"
else
    echo "  ✗ No internet connection"
fi

echo ""

echo "🐍 Python Environment:"
if command -v python3 >/dev/null 2>&1; then
    echo "  Python 3: $(python3 --version)"
else
    echo "  ✗ Python 3 not found"
fi

if [ -d "venv" ]; then
    echo "  ✓ Virtual environment exists"
    source venv/bin/activate
    pip list | grep -E "bleak|aiohttp|websockets" | sed 's/^/    /'
else
    echo "  ✗ Virtual environment not found"
fi

echo ""

echo "📡 Bluetooth Devices:"
if command -v hciconfig >/dev/null 2>&1; then
    hciconfig | grep -E "hci|UP|DOWN"
else
    echo "  Bluetooth tools not installed"
fi

echo ""

echo "✅ Quick Fix Commands (if needed):"
echo ""
echo "  # Enable SSH:"
echo "  sudo systemctl enable ssh && sudo systemctl start ssh"
echo ""
echo "  # Enable mDNS:"
echo "  sudo systemctl enable avahi-daemon && sudo systemctl start avahi-daemon"
echo ""
echo "  # Set hostname to carelink-bp:"
echo "  sudo hostnamectl set-hostname carelink-bp"
echo ""
echo "  # Restart all services:"
echo "  sudo systemctl restart ssh bluetooth avahi-daemon"
echo ""

echo "=========================================="
