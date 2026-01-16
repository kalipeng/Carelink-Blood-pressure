#!/bin/bash

# Health Pad - First Boot Setup
# Run this BEFORE the regular install.sh to ensure SSH and mDNS are ready

echo "=========================================="
echo "Health Pad - First Boot Configuration"
echo "=========================================="
echo ""

echo "⚙️  This script configures essential services"
echo "   SSH, mDNS, and hostname"
echo ""

# Step 1: Update and install essential packages
echo "Step 1: Installing essential packages..."
sudo apt-get update
sudo apt-get install -y avahi-daemon openssh-server

# Step 2: Enable SSH
echo ""
echo "Step 2: Enabling SSH service..."
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh | grep "active"

# Step 3: Set hostname
echo ""
echo "Step 3: Setting hostname to 'carelink-bp'..."
sudo hostnamectl set-hostname carelink-bp
echo "✓ Hostname: $(hostname)"

# Step 4: Enable mDNS
echo ""
echo "Step 4: Enabling mDNS (Avahi daemon)..."
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
sudo systemctl status avahi-daemon | grep "active"

echo ""
echo "=========================================="
echo "✅ First Boot Setup Complete!"
echo "=========================================="
echo ""
echo "Your Raspberry Pi is now accessible via:"
echo "  SSH: ssh carelink@carelink-bp.local"
echo "  IP:  $(hostname -I)"
echo ""
echo "Next steps:"
echo "  1. Return to your Mac terminal"
echo "  2. Run: ssh carelink@carelink-bp.local"
echo "  3. Run install.sh to complete setup"
echo ""
echo "=========================================="
