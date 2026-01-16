#!/bin/bash

# Health Pad - Quick Start for Remote Setup
# This file provides step-by-step instructions for setting up from a Mac

cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║     Health Pad - Raspberry Pi Remote Setup Guide               ║
╚════════════════════════════════════════════════════════════════╝

Your Raspberry Pi Configuration:
  Hostname:    carelink-bp
  Username:    carelink
  Password:    carelink2026
  WiFi:        MyESP32Hotspot
  SSH Target:  ssh carelink@carelink-bp.local

═══════════════════════════════════════════════════════════════════

📋 STEP-BY-STEP SETUP

STEP 1: Wait for First Boot (2-5 minutes)
──────────────────────────────────────────
After flashing with Imager, the Raspberry Pi needs time to:
  • Expand filesystem
  • Install initial packages
  • Start network services
  • Enable SSH daemon

ACTION: Wait 2-5 minutes, then proceed to STEP 2.

═══════════════════════════════════════════════════════════════════

STEP 2: Verify Network Connectivity
────────────────────────────────────
Check if Pi is on the network:

  # Scan for the Pi (should find hosts on 172.20.10.0/28)
  nmap -sn 172.20.10.0/28

  # Look for 2 active hosts - one should be your Raspberry Pi

═══════════════════════════════════════════════════════════════════

STEP 3: Ensure SSH is Running on Raspberry Pi
──────────────────────────────────────────────
If mDNS not yet working, boot the Pi with HDMI monitor and run:

  sudo systemctl enable ssh
  sudo systemctl start ssh
  sudo systemctl restart avahi-daemon

Or use the first_boot.sh script on the Pi:
  
  bash /boot/firmware/first_boot.sh

═══════════════════════════════════════════════════════════════════

STEP 4: Connect from Mac
────────────────────────

METHOD A: Using mDNS (Preferred)
  
  ssh carelink@carelink-bp.local
  
  Password: carelink2026

METHOD B: Using IP Address

  # Try common Raspberry Pi addresses
  ssh carelink@172.20.10.8
  ssh carelink@172.20.10.7
  ssh carelink@172.20.10.6
  
  # Or scan to find the exact IP
  arp -a | grep 172.20.10

METHOD C: Using Helper Script (from repo root)

  chmod +x remote_connect.sh
  ./remote_connect.sh

═══════════════════════════════════════════════════════════════════

STEP 5: Run Installation on Raspberry Pi
─────────────────────────────────────────

After SSH connection, run:

  # Create project directory
  mkdir -p ~/healthpad
  cd ~/healthpad
  
  # Copy files (do this BEFORE running install.sh)
  # SCP from Mac:
  scp -r /path/to/Carelink-Blood-pressure/raspberry_pi/* carelink@carelink-bp.local:~/healthpad/
  
  # Back on Pi terminal:
  cd ~/healthpad
  chmod +x install.sh
  ./install.sh
  
  # After installation completes
  sudo reboot

═══════════════════════════════════════════════════════════════════

STEP 6: Verify Installation
────────────────────────────
After reboot, SSH back in and run:

  bash diagnose.sh

This will show:
  ✓ Service status (SSH, Bluetooth, mDNS)
  ✓ Network connectivity
  ✓ Python environment
  ✓ Bluetooth devices

═══════════════════════════════════════════════════════════════════

TROUBLESHOOTING

Problem: "Could not resolve hostname carelink-bp.local"
────────────────────────────────────────────────────────
Solutions:
  1. Verify Pi is on MyESP32Hotspot network
  2. Check hostname with: nmap -sn 172.20.10.0/28
  3. Ensure Avahi is running: ssh carelink@PI_IP "systemctl status avahi-daemon"
  4. Restart mDNS: ssh carelink@PI_IP "sudo systemctl restart avahi-daemon"

Problem: "Connection refused" on SSH
─────────────────────────────────────
Solutions:
  1. Wait another 2-3 minutes for SSH to start
  2. SSH service may need to be enabled:
     - Connect with HDMI monitor
     - Run: sudo systemctl enable ssh && sudo systemctl start ssh
  3. Check firewall on network is not blocking SSH

Problem: Screen doesn't show output
────────────────────────────────────
Solutions:
  1. ELECROW screen may need rotation config
  2. Check display: cat /proc/device-tree/chosen/bootargs | grep -i lcd
  3. Edit /boot/config.txt and add: lcd_rotate=2 (for 180° rotation)

═══════════════════════════════════════════════════════════════════

QUICK REFERENCE

On Mac:
  # Test connectivity
  ping carelink-bp.local
  
  # Connect via SSH
  ssh carelink@carelink-bp.local
  
  # Copy files to Pi
  scp -r ./raspberry_pi carelink@carelink-bp.local:~/healthpad/
  
  # Remote command execution
  ssh carelink@carelink-bp.local "systemctl status ssh"

On Raspberry Pi (via SSH or HDMI):
  # Diagnose system
  bash ~/healthpad/diagnose.sh
  
  # Check services
  systemctl status ssh
  systemctl status bluetooth
  systemctl status avahi-daemon
  
  # Get IP address
  hostname -I
  
  # Reboot
  sudo reboot

═══════════════════════════════════════════════════════════════════

USEFUL SCRIPTS

First Boot Configuration (run early):
  bash raspberry_pi/first_boot.sh

Diagnostics (check system status):
  bash raspberry_pi/diagnose.sh

Main Installation (after files are copied):
  bash raspberry_pi/install.sh

═══════════════════════════════════════════════════════════════════

EOF

