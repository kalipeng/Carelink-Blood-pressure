#!/bin/bash

# Health Pad - Remote Connection Helper
# Run on Mac to connect to Raspberry Pi

echo "=========================================="
echo "Health Pad - Remote Connection Helper"
echo "=========================================="
echo ""

# Check if tree raspberry pi is reachable
echo "🔍 Checking Raspberry Pi availability..."
echo ""

# Try mDNS first
if ping -c 1 carelink-bp.local >/dev/null 2>&1; then
    echo "✓ Found via mDNS: carelink-bp.local"
    TARGET="carelink-bp.local"
else
    echo "✗ mDNS not responding"
    echo ""
    echo "🔎 Scanning network for Raspberry Pi..."
    
    # Try to find IP via ARP
    IP=$(arp -a | grep -i "carelink\|raspberry" | awk '{print $2}' | tr -d '()')
    
    if [ -z "$IP" ]; then
        # Scan subnet
        echo "   Scanning 172.20.10.0/28..."
        for i in {1..14}; do
            ip="172.20.10.$i"
            if timeout 0.5 bash -c "echo >/dev/tcp/$ip/22" 2>/dev/null; then
                echo "   Found SSH on: $ip"
                # Try to identify the device
                if ssh -o ConnectTimeout=1 carelink@$ip "hostname" 2>/dev/null | grep -q carelink; then
                    IP=$ip
                    break
                fi
            fi
        done
    fi
    
    if [ -n "$IP" ]; then
        echo "✓ Found Raspberry Pi at: $IP"
        TARGET=$IP
    else
        echo "✗ Could not locate Raspberry Pi"
        echo ""
        echo "Possible solutions:"
        echo "  1. Ensure Raspberry Pi is powered on and booted"
        echo "  2. Check network connection (should be on MyESP32Hotspot)"
        echo "  3. Wait 2-3 minutes for first boot to complete"
        echo "  4. Check with: nmap -sn 172.20.10.0/28"
        exit 1
    fi
fi

echo ""
echo "📡 Connecting to: $TARGET"
echo "   User: carelink"
echo "   Password: carelink2026"
echo ""

# Connect via SSH
ssh carelink@$TARGET

