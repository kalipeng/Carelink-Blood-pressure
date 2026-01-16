#!/usr/bin/env python3
"""
Health Pad - Raspberry Pi Backend
Bluetooth connection to iHealth KN-550BT device
"""

import asyncio
import json
import logging
from datetime import datetime
from bleak import BleakScanner, BleakClient
from aiohttp import web
import aiohttp_cors

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# iHealth device configuration
IHEALTH_DEVICE_NAME = "KN-550BT"

# iHealth KN-550BT uses custom UUIDs (not standard BLE)
# Service UUID: com.jiuan.dev (custom UUID)
IHEALTH_SERVICE_UUID = "6d6f2e6a-6975-616e-2e64-657600000000"  # Custom iHealth service

# Characteristic UUIDs
IHEALTH_SEND_CHAR = "7365642e-6a69-7561-6e2e-646576000000"      # sed.* (send to phone)
IHEALTH_RECEIVE_CHAR = "7265632e-6a69-7561-6e2e-646576000000"    # rec.* (receive from phone)

# Fallback to standard BLE UUIDs (for compatibility)
STANDARD_SERVICE_UUID = "00001810-0000-1000-8000-00805f9b34fb"   # Blood Pressure Service
STANDARD_CHAR_UUID = "00002a35-0000-1000-8000-00805f9b34fb"      # Blood Pressure Measurement

class HealthPadBackend:
    def __init__(self):
        self.device = None
        self.client = None
        self.connected = False
        self.last_measurement = None
        self.websocket_clients = set()

    async def scan_devices(self):
        """Scan for iHealth devices with detailed information"""
        logger.info("Scanning for iHealth devices...")
        logger.info("=" * 60)
        devices = await BleakScanner.discover(timeout=10.0)
        
        ihealth_devices = []
        logger.info(f"Found {len(devices)} total BLE devices:")
        
        for device in devices:
            device_info = {
                'name': device.name or 'Unknown',
                'address': device.address,
                'rssi': device.rssi,
            }
            
            # Log all devices for debugging
            logger.info(f"  - {device.name} ({device.address}) RSSI: {device.rssi}")
            
            # Check if it's an iHealth device
            if device.name and IHEALTH_DEVICE_NAME in device.name:
                logger.info(f"✓ Found iHealth: {device.name} ({device.address})")
                
                # Try to get more details
                try:
                    # Attempt to read characteristics if connected
                    async with BleakClient(device.address) as client:
                        services = await client.get_services()
                        device_info['services'] = []
                        
                        for service in services:
                            service_info = {
                                'uuid': str(service.uuid),
                                'characteristics': []
                            }
                            
                            for char in service.characteristics:
                                char_info = {
                                    'uuid': str(char.uuid),
                                    'properties': char.properties
                                }
                                service_info['characteristics'].append(char_info)
                            
                            device_info['services'].append(service_info)
                        
                        logger.info(f"  Services found: {len(services)}")
                        for svc in services:
                            logger.info(f"    - {svc.uuid}")
                except Exception as e:
                    logger.warning(f"  Could not scan services: {e}")
                
                ihealth_devices.append(device_info)
        
        logger.info("=" * 60)
        return ihealth_devices

    async def connect_device(self, address):
        """Connect to iHealth device"""
        try:
            logger.info(f"Connecting to {address}...")
            self.client = BleakClient(address)
            await self.client.connect()
            self.connected = True
            logger.info("✓ Connected successfully!")
            
            # Get services and characteristics
            logger.info("=" * 60)
            logger.info("Device Services and Characteristics:")
            logger.info("=" * 60)
            
            services = await self.client.get_services()
            logger.info(f"Total services: {len(services)}")
            
            found_measurement_char = False
            
            for service in services:
                logger.info(f"\nService: {service.uuid}")
                
                for char in service.characteristics:
                    logger.info(f"  ├─ Characteristic: {char.uuid}")
                    logger.info(f"  │  Properties: {char.properties}")
                    
                    # Try to find measurement characteristic
                    # Check if this matches our iHealth UUIDs
                    if 'read' in char.properties or 'notify' in char.properties:
                        logger.info(f"  │  ✓ Can read/notify")
                        
                        # Check if it matches known measurement characteristics
                        uuid_str = str(char.uuid).lower()
                        if ('sed' in uuid_str or 'rec' in uuid_str or 
                            '2a35' in uuid_str or 'pressure' in char.properties):
                            logger.info(f"  │  ⭐ Possible measurement characteristic")
                            found_measurement_char = True
                            
                            # Subscribe to notifications if notify is supported
                            if 'notify' in char.properties:
                                try:
                                    await self.client.start_notify(
                                        char.uuid,
                                        self.measurement_callback
                                    )
                                    logger.info(f"  │  ✓ Subscribed to notifications")
                                except Exception as e:
                                    logger.warning(f"  │  Could not subscribe: {e}")
            
            logger.info("=" * 60)
            
            if found_measurement_char:
                logger.info("✓ Found potential measurement characteristic")
            else:
                logger.warning("⚠ No measurement characteristic found, trying fallback...")
                # Try standard UUIDs as fallback
                try:
                    await self.client.start_notify(
                        STANDARD_CHAR_UUID,
                        self.measurement_callback
                    )
                    logger.info("✓ Subscribed to standard BLE measurement characteristic")
                except Exception as e:
                    logger.warning(f"Fallback subscription failed: {e}")
            
            return True
        except Exception as e:
            logger.error(f"Connection failed: {e}")
            self.connected = False
            return False

    async def disconnect_device(self):
        """Disconnect from device"""
        if self.client:
            await self.client.disconnect()
            self.connected = False
            logger.info("Disconnected from device")

    def measurement_callback(self, sender, data):
        """Handle incoming measurement data"""
        try:
            # Parse blood pressure data (simplified)
            # Real implementation would parse the full BLE data structure
            systolic = int.from_bytes(data[1:3], 'little')
            diastolic = int.from_bytes(data[3:5], 'little')
            pulse = int.from_bytes(data[14:16], 'little') if len(data) > 15 else 0
            
            self.last_measurement = {
                'systolic': systolic,
                'diastolic': diastolic,
                'pulse': pulse,
                'timestamp': datetime.now().isoformat(),
                'classification': self.classify_bp(systolic, diastolic)
            }
            
            logger.info(f"Measurement: {systolic}/{diastolic} mmHg, HR: {pulse}")
            
            # Broadcast to all WebSocket clients
            asyncio.create_task(self.broadcast_measurement())
            
        except Exception as e:
            logger.error(f"Error parsing measurement: {e}")

    def classify_bp(self, systolic, diastolic):
        """Classify blood pressure"""
        if systolic >= 180 or diastolic >= 120:
            return {'level': 'crisis', 'name': 'Hypertensive Crisis', 'color': '#B71C1C'}
        elif systolic >= 140 or diastolic >= 90:
            return {'level': 'high2', 'name': 'High Blood Pressure Stage 2', 'color': '#F44336'}
        elif systolic >= 130 or diastolic >= 80:
            return {'level': 'high1', 'name': 'High Blood Pressure Stage 1', 'color': '#FF9800'}
        elif systolic >= 120 and diastolic < 80:
            return {'level': 'elevated', 'name': 'Elevated', 'color': '#FFC107'}
        else:
            return {'level': 'normal', 'name': 'Normal', 'color': '#00C853'}

    async def broadcast_measurement(self):
        """Broadcast measurement to all WebSocket clients"""
        if self.websocket_clients and self.last_measurement:
            message = json.dumps({
                'type': 'measurement',
                'data': self.last_measurement
            })
            
            for ws in self.websocket_clients.copy():
                try:
                    await ws.send_str(message)
                except Exception as e:
                    logger.error(f"Error sending to WebSocket: {e}")
                    self.websocket_clients.discard(ws)

    async def start_measurement(self):
        """Trigger measurement on device"""
        if not self.connected:
            return {'success': False, 'error': 'Device not connected'}
        
        try:
            # Send start command to device
            # Actual command depends on iHealth protocol
            logger.info("Starting measurement...")
            return {'success': True}
        except Exception as e:
            return {'success': False, 'error': str(e)}


# Create backend instance
backend = HealthPadBackend()

# HTTP API handlers
async def handle_scan(request):
    """Scan for devices"""
    devices = await backend.scan_devices()
    return web.json_response({'devices': devices})

async def handle_connect(request):
    """Connect to device"""
    data = await request.json()
    address = data.get('address')
    success = await backend.connect_device(address)
    return web.json_response({'success': success})

async def handle_disconnect(request):
    """Disconnect from device"""
    await backend.disconnect_device()
    return web.json_response({'success': True})

async def handle_start_measurement(request):
    """Start measurement"""
    result = await backend.start_measurement()
    return web.json_response(result)

async def handle_status(request):
    """Get connection status"""
    return web.json_response({
        'connected': backend.connected,
        'last_measurement': backend.last_measurement
    })

async def websocket_handler(request):
    """WebSocket connection for real-time updates"""
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    
    backend.websocket_clients.add(ws)
    logger.info(f"WebSocket client connected. Total: {len(backend.websocket_clients)}")
    
    try:
        async for msg in ws:
            if msg.type == aiohttp.WSMsgType.TEXT:
                # Handle incoming WebSocket messages if needed
                pass
            elif msg.type == aiohttp.WSMsgType.ERROR:
                logger.error(f"WebSocket error: {ws.exception()}")
    finally:
        backend.websocket_clients.discard(ws)
        logger.info(f"WebSocket client disconnected. Total: {len(backend.websocket_clients)}")
    
    return ws

async def init_app():
    """Initialize web application"""
    app = web.Application()
    
    # Configure CORS
    cors = aiohttp_cors.setup(app, defaults={
        "*": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
        )
    })
    
    # Add routes
    app.router.add_get('/api/scan', handle_scan)
    app.router.add_post('/api/connect', handle_connect)
    app.router.add_post('/api/disconnect', handle_disconnect)
    app.router.add_post('/api/measure', handle_start_measurement)
    app.router.add_get('/api/status', handle_status)
    app.router.add_get('/ws', websocket_handler)
    
    # Configure CORS for all routes
    for route in list(app.router.routes()):
        cors.add(route)
    
    # Serve static files (preview.html)
    app.router.add_static('/', path='../web/', name='static')
    
    return app

if __name__ == '__main__':
    print("=" * 50)
    print("Health Pad - Raspberry Pi Backend")
    print("=" * 50)
    print("Starting server on http://localhost:8080")
    print("WebSocket: ws://localhost:8080/ws")
    print("=" * 50)
    
    app = asyncio.run(init_app())
    web.run_app(app, host='0.0.0.0', port=8080)
