import { Salon, CustomerCRM, Booking, PilotLocation } from '../types';

import looksSalonImg from '../assets/images/looks_salon_interior_1790539594984.jpg';
import styleStudioImg from '../assets/images/style_studio_interior_1790539608159.jpg';
import theSalonImg from '../assets/images/the_salon_interior_1790539621064.jpg';

export const PILOT_LOCATIONS: PilotLocation[] = [
  { id: 'loc-1', name: 'Saheed Nagar', landmark: 'Janpath Road, Near BMC Bhawani Mall', coordinates: { lat: 20.2915, lng: 85.8458 } },
  { id: 'loc-2', name: 'Patia / KIIT Road', landmark: 'Near KIIT Square & Infocity', coordinates: { lat: 20.3533, lng: 85.8193 } },
  { id: 'loc-3', name: 'Jayadev Vihar', landmark: 'Opposite Pal Heights Mall', coordinates: { lat: 20.3012, lng: 85.8239 } },
  { id: 'loc-4', name: 'Nayapalli', landmark: 'IRC Village, Near Mayfair Lagoon', coordinates: { lat: 20.2974, lng: 85.8164 } },
  { id: 'loc-5', name: 'Chandrasekharpur', landmark: 'Damana Square, Near Petrol Pump', coordinates: { lat: 20.3289, lng: 85.8185 } }
];

export const INITIAL_SALONS: Salon[] = [
  {
    id: 'salon-1',
    name: 'Looks Salon',
    rating: 4.7,
    reviewsCount: 328,
    distanceKm: 0.8,
    travelTimeMin: 8,
    address: 'Plot 42, Saheed Nagar, Janpath Road',
    area: 'Saheed Nagar',
    image: looksSalonImg,
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
    upiId: 'lookssalon.bbsr@icici',
    phone: '+91 00000 00000',
    services: [
      { id: 'srv-1', name: 'Haircut', price: 399, durationMinutes: 45, category: 'Haircut', description: 'Consultation, precision cut, wash & premium styling' },
      { id: 'srv-2', name: 'Haircut + Beard', price: 599, durationMinutes: 60, category: 'Haircut', description: 'Haircut with hot towel beard shape & oil finish' },
      { id: 'srv-3', name: 'Premium Haircut', price: 799, durationMinutes: 60, category: 'Haircut', description: 'Director styling, scalp massage, blowout & finish' },
      { id: 'srv-4', name: 'Beard Trim & Shape', price: 299, durationMinutes: 25, category: 'Beard', description: 'Sharp lines, contouring & organic beard balm' },
      { id: 'srv-5', name: 'De-Tan Facial', price: 799, durationMinutes: 45, category: 'Facial', description: 'Revitalizing glow facial with instant radiance' },
      { id: 'srv-6', name: 'Global Hair Color', price: 1899, durationMinutes: 90, category: 'Hair Color', description: 'Ammonia-free rich pigment color with keratin mask' },
      { id: 'srv-7', name: 'Express Hair Spa', price: 899, durationMinutes: 50, category: 'Hair Spa', description: 'Deep conditioning steam treatment for smooth hair' },
    ],
    stylists: [
      {
        id: 'sty-1',
        name: 'Rahul',
        role: 'Senior Stylist',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        rating: 4.9,
        status: 'available',
        shiftHours: '10:00 AM – 7:00 PM',
        phone: '+91 00000 00000'
      },
      {
        id: 'sty-2',
        name: 'Priya',
        role: 'Hair Specialist',
        avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=200',
        rating: 4.8,
        status: 'with_customer',
        currentCustomer: 'Ananya S.',
        currentService: 'Hair Color',
        shiftHours: '10:00 AM – 7:00 PM',
        phone: '+91 00000 00000'
      },
      {
        id: 'sty-3',
        name: 'Amit',
        role: 'Stylist',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        rating: 4.7,
        status: 'available',
        shiftHours: '11:00 AM – 8:00 PM',
        phone: '+91 98765 33333'
      },
      {
        id: 'sty-4',
        name: 'Neha',
        role: 'Color Expert',
        avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200',
        rating: 4.6,
        status: 'break',
        shiftHours: '10:00 AM – 7:00 PM',
        phone: '+91 98765 44444'
      }
    ],
    slots: [
      { id: 'sl-1', time: '10:00 AM', hourGroup: '10 AM', status: 'booked', stylistName: 'Rahul', customerName: 'Vikas P.', serviceName: 'Haircut', price: 399 },
      { id: 'sl-2', time: '10:30 AM', hourGroup: '10 AM', status: 'booked', stylistName: 'Priya', customerName: 'Sunil K.', serviceName: 'Beard Trim', price: 299 },
      { id: 'sl-3', time: '11:00 AM', hourGroup: '11 AM', status: 'booked', stylistName: 'Amit', customerName: 'Rohan D.', serviceName: 'Haircut', price: 399 },
      { id: 'sl-4', time: '11:15 AM', hourGroup: '11 AM', status: 'available', stylistName: 'Rahul', isEarliest: true, price: 399 },
      { id: 'sl-5', time: '11:30 AM', hourGroup: '11 AM', status: 'available', stylistName: 'Rahul', isEarliest: true, price: 399 },
      { id: 'sl-6', time: '11:40 AM', hourGroup: '11 AM', status: 'available', stylistName: 'Rahul', isRecommended: true, travelBufferMinutes: 13, price: 399 },
      { id: 'sl-7', time: '12:00 PM', hourGroup: '12 PM', status: 'available', stylistName: 'Amit', price: 399 },
      { id: 'sl-8', time: '12:30 PM', hourGroup: '12 PM', status: 'limited', stylistName: 'Neha', price: 399 },
      { id: 'sl-9', time: '12:45 PM', hourGroup: '12 PM', status: 'available', stylistName: 'Priya', price: 399 },
      { id: 'sl-10', time: '1:00 PM', hourGroup: '1 PM', status: 'available', stylistName: 'Rahul', price: 399 },
      { id: 'sl-11', time: '1:30 PM', hourGroup: '1 PM', status: 'available', stylistName: 'Amit', price: 399 },
      { id: 'sl-12', time: '2:00 PM', hourGroup: '2 PM', status: 'available', stylistName: 'Priya', price: 399 }
    ],
    reviewsList: [
      { id: 'rev-1', author: 'Rohit Samal', rating: 5, date: 'Yesterday', comment: 'Zero waiting just like Zalono promised! Rahul was ready right at 11:40 AM. Best salon tech in Odisha.', startedOnTime: 'yes', serviceName: 'Haircut' },
      { id: 'rev-2', author: 'Sneha Mohanty', rating: 5, date: '3 days ago', comment: 'The travel buffer is genius. Reached peacefully without feeling rushed. Clean salon and great sanitization.', startedOnTime: 'yes', serviceName: 'Facial' },
      { id: 'rev-3', author: 'Subham Pattnaik', rating: 4, date: '1 week ago', comment: 'Fastest service in Saheed Nagar. Loved the live queue tracker.', startedOnTime: 'almost', serviceName: 'Haircut + Beard' }
    ]
  },
  {
    id: 'salon-2',
    name: 'Style Studio',
    rating: 4.5,
    reviewsCount: 210,
    distanceKm: 1.1,
    travelTimeMin: 11,
    address: 'Shop 14, Master Canteen Square, Kharvel Nagar',
    area: 'Kharvel Nagar',
    image: styleStudioImg,
    priceStart: 349,
    isOpen: true,
    openingHours: 'Open · Closes 8:30 PM',
    expectedWaitMin: '10-15 min',
    nextSlotTime: '11:45 AM',
    queueCount: 4,
    stylistsCount: 3,
    availableStylistsCount: 1,
    busyLevel: 'moderate',
    isVerified: true,
    happyCustomersCount: '800+',
    upiId: 'stylestudio.bbsr@okhdfcbank',
    phone: '+91 98765 55555',
    services: [
      { id: 'srv-201', name: 'Classic Haircut', price: 349, durationMinutes: 40, category: 'Haircut', description: 'Standard grooming haircut' },
      { id: 'srv-202', name: 'Beard Styling', price: 249, durationMinutes: 20, category: 'Beard', description: 'Shape and trim' },
      { id: 'srv-203', name: 'Facial Glow', price: 699, durationMinutes: 45, category: 'Facial', description: 'Instant deep-cleanse' },
    ],
    stylists: [
      { id: 'sty-21', name: 'Karan', role: 'Stylist', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200', rating: 4.6, status: 'available', shiftHours: '10:00 AM – 7:00 PM', phone: '+91 00000 00000' },
      { id: 'sty-22', name: 'Tanvi', role: 'Specialist', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200', rating: 4.5, status: 'with_customer', shiftHours: '10:00 AM – 7:00 PM', phone: '+91 00000 00000' }
    ],
    slots: [
      { id: 'sl-21', time: '11:45 AM', hourGroup: '11 AM', status: 'available', isEarliest: true, stylistName: 'Karan', price: 349 },
      { id: 'sl-22', time: '12:00 PM', hourGroup: '12 PM', status: 'available', isRecommended: true, stylistName: 'Karan', price: 349 },
      { id: 'sl-23', time: '12:30 PM', hourGroup: '12 PM', status: 'limited', stylistName: 'Tanvi', price: 349 },
    ],
    reviewsList: [
      { id: 'rev-21', author: 'Alok Jena', rating: 5, date: '2 days ago', comment: 'Very professional. Karan gave an awesome fade cut.', startedOnTime: 'yes', serviceName: 'Classic Haircut' }
    ]
  },
  {
    id: 'salon-3',
    name: 'The Salon',
    rating: 4.6,
    reviewsCount: 178,
    distanceKm: 1.5,
    travelTimeMin: 9,
    address: 'Near KIIT Road, Patia',
    area: 'Patia',
    image: theSalonImg,
    priceStart: 399,
    isOpen: true,
    openingHours: 'Open · Closes 9:30 PM',
    expectedWaitMin: '20-30 min',
    nextSlotTime: '11:50 AM',
    queueCount: 5,
    stylistsCount: 5,
    availableStylistsCount: 2,
    busyLevel: 'moderate',
    isVerified: true,
    happyCustomersCount: '650+',
    upiId: 'thesalon.patia@paytm',
    phone: '+91 98765 88888',
    services: [
      { id: 'srv-301', name: 'Precision Haircut', price: 399, durationMinutes: 45, category: 'Haircut', description: 'Designer men & women styling' },
      { id: 'srv-302', name: 'Organic Beard Trim', price: 299, durationMinutes: 25, category: 'Beard', description: 'Essential oils trim' },
    ],
    stylists: [
      { id: 'sty-31', name: 'Kabir', role: 'Director', avatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=200', rating: 4.8, status: 'available', shiftHours: '10:00 AM – 8:00 PM', phone: '+91 98765 99999' }
    ],
    slots: [
      { id: 'sl-31', time: '11:50 AM', hourGroup: '11 AM', status: 'available', isEarliest: true, stylistName: 'Kabir', price: 399 },
      { id: 'sl-32', time: '12:00 PM', hourGroup: '12 PM', status: 'available', isRecommended: true, stylistName: 'Kabir', price: 399 }
    ],
    reviewsList: [
      { id: 'rev-31', author: 'Debashish Ray', rating: 5, date: 'Yesterday', comment: 'Patia branch is super convenient for tech park workers.', startedOnTime: 'yes', serviceName: 'Precision Haircut' }
    ]
  }
];

export const INITIAL_BOOKINGS: Booking[] = [
  {
    id: 'bk-101',
    salonId: 'salon-1',
    salonName: 'Looks Salon',
    salonImage: looksSalonImg,
    salonAddress: 'Plot 42, Saheed Nagar, Janpath Road',
    serviceId: 'srv-1',
    serviceName: 'Haircut',
    servicePrice: 399,
    serviceDuration: 45,
    slotTime: '11:40 AM',
    date: 'Today, 27 Sep',
    distanceKm: 0.8,
    travelTimeMin: 8,
    stylistId: 'sty-1',
    stylistName: 'Rahul',
    customerName: 'Isha ',
    customerPhone: '+91 00000 00000',
    status: 'you_are_next',
    expectedWaitMin: '0-5 minutes',
    queuePosition: 1,
    estimatedStartTime: '11:43 AM',
    bookedAt: '11:15 AM',
    paymentStatus: 'pending',
    invoiceId: 'ZAL-2026-0927-101'
  },
  {
    id: 'bk-102',
    salonId: 'salon-2',
    salonName: 'Style Studio',
    salonImage: styleStudioImg,
    salonAddress: 'Shop 14, Master Canteen Square',
    serviceId: 'srv-203',
    serviceName: 'Facial Glow',
    servicePrice: 699,
    serviceDuration: 45,
    slotTime: '4:00 PM',
    date: 'Saturday, 20 Sep',
    distanceKm: 1.2,
    travelTimeMin: 12,
    stylistId: 'sty-21',
    stylistName: 'Karan',
    customerName: 'Isha ',
    customerPhone: '+91 00000 00000',
    status: 'completed',
    expectedWaitMin: '0 min',
    queuePosition: 0,
    estimatedStartTime: '4:00 PM',
    bookedAt: '19 Sep 2:00 PM',
    completedAt: '20 Sep 4:50 PM',
    paymentStatus: 'paid_salon',
    paymentMethod: 'cash',
    invoiceId: 'ZAL-2026-0920-042',
    feedback: {
      rating: 5,
      startedOnTime: 'yes',
      wouldBookAgain: 'yes',
      reviewText: 'Punctual and very relaxing facial session.'
    }
  }
];

export const INITIAL_CUSTOMER_CRM: CustomerCRM = {
  id: 'cust-1',
  name: 'Isha ',
  phone: '+91 00000 00000',
  customerSince: 'Aug 2025',
  totalVisits: 5,
  avgSpend: 470,
  daysSinceLastVisit: 42,
  preferredStylist: 'Rahul',
  usualServices: ['Haircut', 'Beard Trim'],
  notes: 'Prefers evening slots, likes quick scissor work with minimum clipper heat.'
};
