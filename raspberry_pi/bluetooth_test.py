#!/usr/bin/env python3
"""
Health Pad - Bluetooth Diagnostic Tool
Tests Bluetooth connectivity and discovers iHealth KN-550BT devices
"""

import asyncio
import sys
from bleak import BleakScanner, BleakClient

# iHealth device info
IHEALTH_DEVICE_NAME = "KN-550BT"
IHEALTH_SERVICE_UUID = "6d6f2e6a-6975-616e-2e64-657600000000"
IHEALTH_SEND_CHAR = "7365642e-6a69-7561-6e2e-646576000000"
IHEALTH_RECEIVE_CHAR = "7265632e-6a69-7561-6e2e-646576000000"

def print_header(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)

def print_success(msg):
    print(f"✓ {msg}")

def print_error(msg):
    print(f"✗ {msg}")

def print_info(msg):
    print(f"ℹ {msg}")

def print_warning(msg):
    print(f"⚠ {msg}")

async def scan_devices():
    """Scan for all BLE devices"""
    print_header("SCANNING FOR BLE DEVICES")
    
    try:
        print_info("Scanning... (this may take 10 seconds)")
        devices = await BleakScanner.discover(timeout=10.0)
        
        if not devices:
            print_error("No devices found")
            return None
        
        print_success(f"Found {len(devices)} devices\n")
        
        ihealth_device = None
        
        for device in devices:
            device_name = device.name or "Unknown"
            print(f"  • {device_name}")
            print(f"    Address:  {device.address}")
            # RSSI may not be available on all platforms (e.g., macOS)
            try:
                rssi = device.rssi
                print(f"    RSSI:     {rssi} dBm")
            except (AttributeError, TypeError):
                print(f"    RSSI:     N/A")
            
            if IHEALTH_DEVICE_NAME in device_name:
                print_success("This is the iHealth device!")
                ihealth_device = device
            print()
        
        return ihealth_device
    
    except Exception as e:
        print_error(f"Scan failed: {e}")
        print_info("Make sure Bluetooth is enabled: sudo systemctl status bluetooth")
        return None

async def connect_and_inspect(device):
    """Connect to device and inspect services"""
    print_header("CONNECTING TO DEVICE")
    
    try:
        print_info(f"Connecting to {device.name} ({device.address})...")
        async with BleakClient(device.address) as client:
            print_success("Connected!")
            
            print_header("DEVICE SERVICES AND CHARACTERISTICS")
            
            # Use client.services (newer bleak API) or client.get_services() (older)
            try:
                services = client.services
                service_list = list(services)
            except (AttributeError, TypeError):
                services = await client.get_services()
                service_list = list(services) if hasattr(services, '__iter__') else [services]
            
            print_info(f"Total services: {len(service_list)}\n")
            
            measurement_chars = []
            
            for service in service_list:
                print(f"Service: {service.uuid}")
                print(f"  Description: {service.description or 'N/A'}")
                
                for i, char in enumerate(service.characteristics):
                    print(f"\n  Characteristic {i+1}: {char.uuid}")
                    print(f"    Properties:  {', '.join(char.properties)}")
                    print(f"    Descriptors: {len(char.descriptors)}")
                    
                    # Check if this looks like a measurement characteristic
                    uuid_str = str(char.uuid).lower()
                    properties = char.properties
                    
                    if ('notify' in properties or 'read' in properties):
                        if ('2a35' in uuid_str or  # Standard BP UUID
                            'sed' in uuid_str or    # iHealth send
                            'rec' in uuid_str or    # iHealth receive
                            '8b9b' in uuid_str):    # Other common measurement UUIDs
                            
                            print_success("    ⭐ POSSIBLE MEASUREMENT CHARACTERISTIC")
                            measurement_chars.append({
                                'uuid': char.uuid,
                                'properties': char.properties,
                                'service': service.uuid
                            })
                
                print()
            
            return measurement_chars
    
    except Exception as e:
        print_error(f"Connection failed: {e}")
        return None

async def test_notifications(device, char_uuid):
    """Test subscribing to notifications"""
    print_header("TESTING NOTIFICATIONS")
    
    try:
        print_info(f"Connecting to {device.address}...")
        async with BleakClient(device.address) as client:
            print_success("Connected")
            
            print_info(f"Subscribing to notifications on {char_uuid}...")
            
            def notification_callback(sender, data):
                print_success(f"Received data ({len(data)} bytes): {data.hex()}")
                # Try to parse as hex string for debugging
                try:
                    ascii_repr = ''.join(chr(b) if 32 <= b < 127 else '.' for b in data)
                    print_info(f"ASCII representation: {ascii_repr}")
                except:
                    pass
            
            await client.start_notify(char_uuid, notification_callback)
            print_success("Subscribed!")
            
            print_info("Waiting for data... (30 seconds)")
            print_info("Try measuring on the iHealth device now")
            
            await asyncio.sleep(30)
            
            await client.stop_notify(char_uuid)
            print_info("Unsubscribed")
    
    except Exception as e:
        print_error(f"Notification test failed: {e}")

async def main():
    """Main diagnostic routine"""
    print("\n")
    print("╔════════════════════════════════════════════════════════╗")
    print("║    Health Pad - Bluetooth Diagnostic Tool              ║")
    print("║    For iHealth KN-550BT Blood Pressure Monitor          ║")
    print("╚════════════════════════════════════════════════════════╝")
    
    # Step 1: Check Bluetooth
    print_header("CHECKING BLUETOOTH SYSTEM")
    import subprocess
    try:
        result = subprocess.run(
            ['systemctl', 'status', 'bluetooth'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            print_success("Bluetooth daemon is running")
        else:
            print_error("Bluetooth daemon is not running")
            print_info("To enable: sudo systemctl start bluetooth")
            return
    except Exception as e:
        print_warning(f"Could not check Bluetooth status: {e}")
    
    # Step 2: Scan for devices
    ihealth_device = await scan_devices()
    if not ihealth_device:
        print_error("\nNo iHealth device found!")
        print_info("Make sure:")
        print_info("  1. iHealth KN-550BT is powered on and in pairing mode")
        print_info("  2. It's within Bluetooth range (typically <10 meters)")
        print_info("  3. Raspberry Pi Bluetooth is enabled")
        return
    
    # Step 3: Connect and inspect
    measurement_chars = await connect_and_inspect(ihealth_device)
    
    if not measurement_chars:
        print_error("No measurement characteristics found!")
        return
    
    # Step 4: Test notifications
    print_header("NEXT STEPS")
    print_info("Would you like to test receiving measurements?")
    print_info("(This will wait 30 seconds for data from the iHealth device)")
    
    try:
        response = input("\nTest notifications? (y/n): ").strip().lower()
        if response == 'y':
            char = measurement_chars[0]  # Use first measurement characteristic
            await test_notifications(ihealth_device, char['uuid'])
    except KeyboardInterrupt:
        print("\nCancelled")
    
    print_header("DIAGNOSTIC COMPLETE")
    print_success("Bluetooth communication is working!")
    
    if measurement_chars:
        print(f"\nFound {len(measurement_chars)} measurement characteristic(s):")
        for i, char in enumerate(measurement_chars):
            print(f"  {i+1}. UUID: {char['uuid']}")
            print(f"     Properties: {', '.join(char['properties'])}")
            print(f"     Service: {char['service']}")

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\nFatal error: {e}")
        sys.exit(1)
