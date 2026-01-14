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
IHEALTH_SERVICE_UUID = "00001810-0000-1000-8000-00805f9b34fb"  # Blood Pressure Service
MEASUREMENT_CHAR_UUID = "00002a35-0000-1000-8000-00805f9b34fb"  # Blood Pressure Measurement

class HealthPadBackend:
    def __init__(self):
        self.device = None
        self.client = None
        self.connected = False
        self.last_measurement = None
        self.websocket_clients = set()

    async def scan_devices(self):
        """Scan for iHealth devices"""
        logger.info("Scanning for iHealth devices...")
        devices = await BleakScanner.discover(timeout=10.0)
        
        ihealth_devices = []
        for device in devices:
            if device.name and IHEALTH_DEVICE_NAME in device.name:
                ihealth_devices.append({
                    'name': device.name,
                    'address': device.address,
                    'rssi': device.rssi
                })
                logger.info(f"Found: {device.name} ({device.address})")
        
        return ihealth_devices

    async def connect_device(self, address):
        """Connect to iHealth device"""
        try:
            logger.info(f"Connecting to {address}...")
            self.client = BleakClient(address)
            await self.client.connect()
            self.connected = True
            logger.info("Connected successfully!")
            
            # Subscribe to measurement notifications
            await self.client.start_notify(
                MEASUREMENT_CHAR_UUID,
                self.measurement_callback
            )
            
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
