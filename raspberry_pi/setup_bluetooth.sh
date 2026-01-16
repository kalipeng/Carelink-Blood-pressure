#!/bin/bash

# Health Pad - Bluetooth Setup Script for Raspberry Pi
# This script sets up Bluetooth and verifies iHealth KN-550BT connection

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Health Pad - Raspberry Pi Bluetooth Setup          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗ This script must be run as root${NC}"
    echo "  Try: sudo bash setup_bluetooth.sh"
    exit 1
fi

echo -e "${BLUE}STEP 1: Checking Bluetooth Service${NC}"
echo "=================================================="

# Check and enable Bluetooth daemon
if systemctl is-active --quiet bluetooth; then
    echo -e "${GREEN}✓ Bluetooth daemon is running${NC}"
else
    echo -e "${YELLOW}⚠ Bluetooth daemon is not running, starting...${NC}"
    systemctl start bluetooth
    sleep 2
    if systemctl is-active --quiet bluetooth; then
        echo -e "${GREEN}✓ Bluetooth daemon started${NC}"
    else
        echo -e "${RED}✗ Failed to start Bluetooth daemon${NC}"
        exit 1
    fi
fi

# Enable Bluetooth to start on boot
systemctl enable bluetooth
echo -e "${GREEN}✓ Bluetooth enabled on boot${NC}"

echo ""
echo -e "${BLUE}STEP 2: Installing Python Dependencies${NC}"
echo "=================================================="

# Check if running in virtual environment
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}⚠ Not in virtual environment, installing system-wide${NC}"
    pip3 install --upgrade pip
    pip3 install bleak dbus-python
else
    echo -e "${BLUE}ℹ Using virtual environment: $VIRTUAL_ENV${NC}"
    pip install --upgrade pip
    pip install bleak dbus-python
fi

echo -e "${GREEN}✓ Dependencies installed${NC}"

echo ""
echo -e "${BLUE}STEP 3: Testing Bluetooth Connection${NC}"
echo "=================================================="

# Create a test script
cat > /tmp/bluetooth_test.py << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
import asyncio
import sys
from bleak import BleakScanner, BleakClient

IHEALTH_DEVICE_NAME = "KN-550BT"

async def test_connection():
    print("\n📱 Scanning for BLE devices (10 seconds)...")
    
    try:
        devices = await BleakScanner.discover(timeout=10.0)
        
        if not devices:
            print("❌ No devices found!")
            return False
        
        print(f"✓ Found {len(devices)} devices")
        
        # Look for iHealth device
        ihealth_device = None
        for device in devices:
            if IHEALTH_DEVICE_NAME in (device.name or ""):
                ihealth_device = device
                break
        
        if not ihealth_device:
            print(f"❌ {IHEALTH_DEVICE_NAME} not found!")
            return False
        
        print(f"✓ Found {ihealth_device.name} ({ihealth_device.address})")
        
        # Try to connect
        print("\n🔗 Connecting to device...")
        async with BleakClient(ihealth_device.address) as client:
            print("✓ Connected successfully!")
            
            # Get services
            try:
                services = client.services
            except AttributeError:
                services = await client.get_services()
            
            print(f"✓ Device has {len(services)} services")
            
            # Display service UUIDs
            print("\n📋 Available services:")
            for service in list(services)[:5]:  # Show first 5
                print(f"   • {service.uuid}")
            
            if len(services) > 5:
                print(f"   ... and {len(services) - 5} more")
            
            return True
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    result = asyncio.run(test_connection())
    sys.exit(0 if result else 1)
PYTHON_SCRIPT

python3 /tmp/bluetooth_test.py

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Bluetooth connection test successful!${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠ Connection test failed${NC}"
    echo "  Make sure iHealth KN-550BT is powered on and in pairing mode"
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║               Setup Complete!                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📝 Next steps:"
echo "   1. Copy project files to ~/healthpad"
echo "   2. Run: cd ~/healthpad && bash raspberry_pi/install.sh"
echo "   3. Reboot: sudo reboot"
echo ""
echo "✅ Your iHealth BP monitor is ready to connect!"
echo ""
