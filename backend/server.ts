import express, { Request, Response } from 'express';
import http from 'http';
import path from 'path';
import fs from 'fs';

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

// Enable CORS for Flutter web, local dev, and mobile devices
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// SSE (Server-Sent Events) Client List for Live Real-time Updates
let sseClients: Response[] = [];

function broadcastLiveEvent(eventType: string, data: any) {
  const payload = JSON.stringify({ type: eventType, data, timestamp: new Date().toISOString() });
  sseClients.forEach((client) => {
    try {
      client.write(`event: ${eventType}\ndata: ${payload}\n\n`);
    } catch {
      // client disconnected
    }
  });
}

// In-Memory Data Store (Seeded for Zalono Pilot in Bhubaneswar)
let salons = [
  {
    id: 'salon-1',
    name: 'Looks Salon',
    rating: 4.7,
    reviewsCount: 328,
    distanceKm: 0.8,
    travelTimeMin: 8,
    address: 'Plot 42, Saheed Nagar, Janpath Road',
    area: 'Saheed Nagar',
    imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=800',
    priceStart: 399,
    isOpen: true,
    openingHours: 'Open · Closes 9:00 PM',
    expectedWaitMin: '0-5 min',
    nextSlotTime: '11:30 AM',
    queueCount: 3,
    stylistsCount: 4,
    availableStylistsCount: 2,
    busyLevel: 'quiet',
    isVerified: true,
    happyCustomersCount: '1000+',
    services: [
      { id: 's1', name: 'Haircut', price: 399, durationMinutes: 45, category: 'Haircut', description: 'Consultation, precision cut, wash & styling' },
      { id: 's2', name: 'Haircut + Beard', price: 599, durationMinutes: 60, category: 'Haircut', description: 'Cut with hot towel shape' },
      { id: 's3', name: 'Premium Haircut', price: 799, durationMinutes: 60, category: 'Haircut', description: 'Director styling & wash' },
      { id: 's4', name: 'Beard Trim & Shape', price: 299, durationMinutes: 25, category: 'Beard', description: 'Sharp lines & contouring' },
      { id: 's5', name: 'De-Tan Facial', price: 799, durationMinutes: 45, category: 'Facial', description: 'Instant radiance facial' }
    ],
    stylists: [
      { id: 'sty-1', name: 'Rahul', role: 'Senior Stylist', rating: 4.9, status: 'available', shiftHours: '10:00 AM – 7:00 PM' },
      { id: 'sty-2', name: 'Priya', role: 'Hair Specialist', rating: 4.8, status: 'withCustomer', shiftHours: '10:00 AM – 7:00 PM' },
      { id: 'sty-3', name: 'Amit', role: 'Stylist', rating: 4.7, status: 'available', shiftHours: '11:00 AM – 8:00 PM' },
      { id: 'sty-4', name: 'Neha', role: 'Color Expert', rating: 4.6, status: 'onBreak', shiftHours: '10:00 AM – 7:00 PM' }
    ],
    slots: [
      { id: 'sl1', time: '11:15 AM', hourGroup: '11 AM', status: 'available', price: 399, isEarliest: true, stylistName: 'Rahul' },
      { id: 'sl2', time: '11:30 AM', hourGroup: '11 AM', status: 'available', price: 399, isEarliest: true, stylistName: 'Rahul' },
      { id: 'sl3', time: '11:40 AM', hourGroup: '11 AM', status: 'available', price: 399, isRecommended: true, travelBufferMinutes: 13, stylistName: 'Rahul' },
      { id: 'sl4', time: '12:00 PM', hourGroup: '12 PM', status: 'available', price: 399, stylistName: 'Amit' },
      { id: 'sl5', time: '12:30 PM', hourGroup: '12 PM', status: 'limited', price: 399, stylistName: 'Neha' }
    ]
  },
  {
    id: 'salon-2',
    name: 'Style Studio Unisex',
    rating: 4.5,
    reviewsCount: 194,
    distanceKm: 1.4,
    travelTimeMin: 12,
    address: 'Near BMC Bhawani Mall, Saheed Nagar',
    area: 'Saheed Nagar',
    imageUrl: 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&q=80&w=800',
    priceStart: 299,
    isOpen: true,
    openingHours: 'Open · Closes 9:30 PM',
    expectedWaitMin: '5-10 min',
    nextSlotTime: '11:45 AM',
    queueCount: 5,
    stylistsCount: 3,
    availableStylistsCount: 1,
    busyLevel: 'moderate',
    isVerified: true,
    happyCustomersCount: '850+',
    services: [
      { id: 'ss1', name: 'Standard Haircut', price: 299, durationMinutes: 35, category: 'Haircut', description: 'Clean haircut & spray styling' },
      { id: 'ss2', name: 'Beard Grooming', price: 199, durationMinutes: 20, category: 'Beard', description: 'Trimming & neck line razor shave' }
    ],
    stylists: [
      { id: 'ss-sty-1', name: 'Rohan', role: 'Hair Stylist', rating: 4.6, status: 'available', shiftHours: '10:00 AM – 8:00 PM' },
      { id: 'ss-sty-2', name: 'Sneha', role: 'Senior Stylist', rating: 4.7, status: 'withCustomer', shiftHours: '10:00 AM – 8:00 PM' }
    ],
    slots: [
      { id: 'ss-sl1', time: '11:45 AM', hourGroup: '11 AM', status: 'available', price: 299, isEarliest: true, stylistName: 'Rohan' },
      { id: 'ss-sl2', time: '12:15 PM', hourGroup: '12 PM', status: 'available', price: 299, stylistName: 'Sneha' }
    ]
  }
];

let bookings = [
  {
    id: 'bk_demo_1',
    salonId: 'salon-1',
    salonName: 'Looks Salon',
    serviceName: 'Haircut',
    servicePrice: 399,
    serviceDuration: 45,
    slotTime: '11:40 AM',
    date: 'Today, 28 Sep',
    distanceKm: 0.8,
    travelTimeMin: 8,
    stylistName: 'Rahul',
    customerName: 'Isha ',
    customerPhone: '+91 98765 43210',
    status: 'youAreNext', // booked, checkedIn, youAreNext, inService, completed, cancelled
    expectedWaitMin: '0-5 minutes',
    queuePosition: 1,
    estimatedStartTime: '11:43 AM'
  }
];

const locations = [
  { id: 'loc-1', name: 'Saheed Nagar', landmark: 'Janpath Road, Near BMC Bhawani Mall' },
  { id: 'loc-2', name: 'Patia / KIIT Road', landmark: 'Near KIIT Square & Infocity' },
  { id: 'loc-3', name: 'Jayadev Vihar', landmark: 'Opposite Pal Heights Mall' },
  { id: 'loc-4', name: 'Nayapalli', landmark: 'IRC Village, Near Mayfair Lagoon' },
  { id: 'loc-5', name: 'Chandrasekharpur', landmark: 'Damana Square' }
];

// --- ROUTES ---

// 1. Healthcheck
app.get('/api/health', (req: Request, res: Response) => {
  res.json({
    status: 'online',
    appName: 'Zalono Backend API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    stats: {
      salonsCount: salons.length,
      activeBookings: bookings.filter((b) => b.status !== 'completed' && b.status !== 'cancelled').length
    }
  });
});

// 2. Real-time Live Event Stream (Server-Sent Events)
app.get('/api/events', (req: Request, res: Response) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  sseClients.push(res);

  // Send initial ping
  res.write(`event: connected\ndata: ${JSON.stringify({ message: 'Connected to Zalono Live Stream' })}\n\n`);

  req.on('close', () => {
    sseClients = sseClients.filter((c) => c !== res);
  });
});

// 3. Locations
app.get('/api/locations', (req: Request, res: Response) => {
  res.json(locations);
});

// 4. Salons
app.get('/api/salons', (req: Request, res: Response) => {
  const { area } = req.query;
  if (area && typeof area === 'string') {
    return res.json(salons.filter((s) => s.area.toLowerCase() === area.toLowerCase()));
  }
  res.json(salons);
});

app.get('/api/salons/:id', (req: Request, res: Response) => {
  const salon = salons.find((s) => s.id === req.params.id);
  if (!salon) return res.status(404).json({ error: 'Salon not found' });
  res.json(salon);
});

// 5. Toggle Slot Availability
app.patch('/api/salons/:salonId/slots/:slotId/toggle', (req: Request, res: Response) => {
  const { salonId, slotId } = req.params;
  const salon = salons.find((s) => s.id === salonId);
  if (!salon) return res.status(404).json({ error: 'Salon not found' });

  const slot = salon.slots.find((s) => s.id === slotId);
  if (!slot) return res.status(404).json({ error: 'Slot not found' });

  slot.status = slot.status === 'available' ? 'booked' : 'available';

  broadcastLiveEvent('SLOT_UPDATED', { salonId, slotId, status: slot.status });
  res.json({ message: 'Slot updated', slot });
});

// 6. Stylist Status Update
app.patch('/api/salons/:salonId/stylists/:stylistId/status', (req: Request, res: Response) => {
  const { salonId, stylistId } = req.params;
  const { status } = req.body;
  const salon = salons.find((s) => s.id === salonId);
  if (!salon) return res.status(404).json({ error: 'Salon not found' });

  const stylist = salon.stylists.find((st) => st.id === stylistId);
  if (!stylist) return res.status(404).json({ error: 'Stylist not found' });

  stylist.status = status;
  broadcastLiveEvent('STYLIST_STATUS_CHANGED', { salonId, stylistId, status });
  res.json({ message: 'Stylist status updated', stylist });
});

// 7. Bookings
app.get('/api/bookings', (req: Request, res: Response) => {
  const { phone, salonId } = req.query;
  let filtered = bookings;
  if (phone && typeof phone === 'string') {
    filtered = filtered.filter((b) => b.customerPhone === phone);
  }
  if (salonId && typeof salonId === 'string') {
    filtered = filtered.filter((b) => b.salonId === salonId);
  }
  res.json(filtered);
});

app.post('/api/bookings', (req: Request, res: Response) => {
  const { salonId, serviceId, slotId, stylistName, customerName, customerPhone } = req.body;

  const salon = salons.find((s) => s.id === salonId);
  if (!salon) return res.status(404).json({ error: 'Salon not found' });

  const service = salon.services.find((s) => s.id === serviceId) || salon.services[0];
  const slot = salon.slots.find((s) => s.id === slotId);

  if (slot) {
    slot.status = 'booked';
  }

  const newBooking = {
    id: `bk_${Date.now()}`,
    salonId: salon.id,
    salonName: salon.name,
    serviceName: service.name,
    servicePrice: service.price,
    serviceDuration: service.durationMinutes,
    slotTime: slot ? slot.time : '12:00 PM',
    date: 'Today, 28 Sep',
    distanceKm: salon.distanceKm,
    travelTimeMin: salon.travelTimeMin,
    stylistName: stylistName || (slot?.stylistName ?? salon.stylists[0].name),
    customerName: customerName || 'Isha ',
    customerPhone: customerPhone || '+91 98765 43210',
    status: 'booked',
    expectedWaitMin: '0-5 minutes',
    queuePosition: salon.queueCount + 1,
    estimatedStartTime: slot ? slot.time : '12:00 PM'
  };

  salon.queueCount += 1;
  bookings.unshift(newBooking);

  broadcastLiveEvent('NEW_BOOKING', newBooking);
  broadcastLiveEvent('QUEUE_UPDATED', { salonId: salon.id, queueCount: salon.queueCount });

  res.status(201).json(newBooking);
});

// 8. Advance Queue Status
app.patch('/api/bookings/:id/advance', (req: Request, res: Response) => {
  const booking = bookings.find((b) => b.id === req.params.id);
  if (!booking) return res.status(404).json({ error: 'Booking not found' });

  const statusOrder = ['booked', 'checkedIn', 'youAreNext', 'inService', 'completed'];
  const currentIndex = statusOrder.indexOf(booking.status);
  if (currentIndex >= 0 && currentIndex < statusOrder.length - 1) {
    booking.status = statusOrder[currentIndex + 1];
    if (booking.status === 'youAreNext') {
      booking.queuePosition = 1;
    } else if (booking.status === 'inService' || booking.status === 'completed') {
      booking.queuePosition = 0;
    }
  }

  broadcastLiveEvent('BOOKING_STATUS_CHANGED', booking);
  res.json(booking);
});

// 9. Add Walk-In Customer
app.post('/api/walk-ins', (req: Request, res: Response) => {
  const { salonId, customerName, serviceName, stylistName, durationMin } = req.body;
  const salon = salons.find((s) => s.id === (salonId || 'salon-1'));
  if (salon) {
    salon.queueCount += 1;
  }

  const walkInBooking = {
    id: `wi_${Date.now()}`,
    salonId: salon?.id || 'salon-1',
    salonName: salon?.name || 'Looks Salon',
    serviceName: serviceName || 'Walk-In Haircut',
    servicePrice: 399,
    serviceDuration: durationMin || 30,
    slotTime: 'Now',
    date: 'Today, 28 Sep',
    distanceKm: 0,
    travelTimeMin: 0,
    stylistName: stylistName || 'Rahul',
    customerName: customerName || 'Walk-in Guest',
    customerPhone: '+91 00000 00000',
    status: 'checkedIn',
    expectedWaitMin: '10 min',
    queuePosition: salon ? salon.queueCount : 2,
    estimatedStartTime: 'Now'
  };

  bookings.unshift(walkInBooking);
  broadcastLiveEvent('WALK_IN_ADDED', walkInBooking);

  res.status(201).json(walkInBooking);
});

// 10. CRM Records
app.get('/api/crm', (req: Request, res: Response) => {
  res.json({
    id: 'crm-default',
    totalClients: 412,
    frequentVisitors: 128,
    activeMemberships: 45,
    topStylists: [
      { name: 'Rahul', clientRating: 4.9, completedAppointments: 142 },
      { name: 'Priya', clientRating: 4.8, completedAppointments: 118 }
    ],
    recentClients: [
      { name: 'Isha ', phone: '+91 98765 43210', visits: 8, lastVisit: 'Today', preferredStylist: 'Rahul', vip: true },
      { name: 'Ananya Dash', phone: '+91 98111 22334', visits: 5, lastVisit: 'Yesterday', preferredStylist: 'Priya', vip: false }
    ]
  });
});

// Serve the built frontends.
//
// The Flutter app is the primary site and is served at the root. The older
// React demo, when built, stays available under /react for comparison.
const flutterWebPath = path.resolve(process.cwd(), 'flutter_zalono', 'build', 'web');
const reactDistPath = path.resolve(process.cwd(), 'dist');

if (fs.existsSync(reactDistPath) && fs.existsSync(path.join(reactDistPath, 'index.html'))) {
  app.use('/react', express.static(reactDistPath));
  app.get('/react/*', (req: Request, res: Response, next) => {
    res.sendFile(path.join(reactDistPath, 'index.html'));
  });
  console.log(`[server] React demo available at /react`);
}

if (
  fs.existsSync(flutterWebPath) &&
  fs.existsSync(path.join(flutterWebPath, 'index.html'))
) {
  // Flutter ships its own bootstrap and service worker; long-cache the
  // fingerprinted assets and keep index.html fresh so deploys take effect.
  app.use(
    express.static(flutterWebPath, {
      setHeaders: (res, filePath) => {
        if (filePath.endsWith('index.html') || filePath.endsWith('flutter_bootstrap.js')) {
          res.setHeader('Cache-Control', 'no-cache');
        } else if (filePath.endsWith('.wasm') || filePath.endsWith('.js')) {
          res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
        }
      },
    }),
  );
  app.get('*', (req: Request, res: Response, next) => {
    if (req.path.startsWith('/api')) return next();
    res.sendFile(path.join(flutterWebPath, 'index.html'));
  });
} else if (
  fs.existsSync(reactDistPath) &&
  fs.existsSync(path.join(reactDistPath, 'index.html'))
) {
  // Flutter not built — fall back to serving the React app at the root.
  app.use(express.static(reactDistPath));
  app.get('*', (req: Request, res: Response, next) => {
    if (req.path.startsWith('/api')) return next();
    res.sendFile(path.join(reactDistPath, 'index.html'));
  });
} else {
  // Graceful fallback root route if frontend was not built
  app.get('/', (req: Request, res: Response) => {
    res.send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>Zalono Backend API</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #faf9f8; color: #222; margin: 0; padding: 40px 20px; display: flex; justify-content: center; }
          .card { background: white; border-radius: 16px; padding: 32px; max-width: 600px; width: 100%; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #eae7e4; }
          h1 { color: #5a0a1e; margin-top: 0; }
          .status { display: inline-block; background: #e8f5e9; color: #2e7d32; padding: 4px 12px; border-radius: 20px; font-weight: bold; font-size: 13px; margin-bottom: 20px; }
          ul { list-style: none; padding: 0; }
          li { margin: 12px 0; }
          a { color: #5a0a1e; font-weight: 600; text-decoration: none; background: #fcf4f6; padding: 6px 12px; border-radius: 8px; display: inline-block; }
          a:hover { background: #f8e5e9; }
          .tip { margin-top: 24px; padding: 14px; background: #fff8e1; border-left: 4px solid #ffa000; border-radius: 4px; font-size: 13px; color: #5d4037; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>Zalono Backend API</h1>
          <div class="status">● Status: ONLINE</div>
          <p>The backend service is running successfully on Render.</p>
          <h3>Available Endpoints:</h3>
          <ul>
            <li><a href="/api/health" target="_blank">GET /api/health</a> - Server status & statistics</li>
            <li><a href="/api/salons" target="_blank">GET /api/salons</a> - Partner salons & live slots</li>
            <li><a href="/api/bookings" target="_blank">GET /api/bookings</a> - Active bookings & queue tracker</li>
            <li><a href="/api/locations" target="_blank">GET /api/locations</a> - Pilot locations in Bhubaneswar</li>
            <li><a href="/api/crm" target="_blank">GET /api/crm</a> - Customer CRM metrics</li>
            <li><a href="/api/events" target="_blank">GET /api/events</a> - Server-Sent Events (SSE) stream</li>
          </ul>
          <div class="tip">
            💡 <strong>Want to see the app UI here?</strong><br/>
            Build with <code>npm install &amp;&amp; npm run build</code> and reload.
            The Flutter web build is served at <code>/</code>; the older React
            demo, if built, is served at <code>/react</code>.
          </div>
        </div>
      </body>
      </html>
    `);
  });
}

const server = http.createServer(app);

server.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`🚀 Zalono Backend API Server running on port ${PORT}`);
  console.log(`📡 Endpoints available:`);
  console.log(`   - GET  /api/health`);
  console.log(`   - GET  /api/salons`);
  console.log(`   - GET  /api/bookings`);
  console.log(`   - POST /api/bookings`);
  console.log(`   - GET  /api/events (Server-Sent Events)`);
  console.log(`===============================================`);
});

export default app;
