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

import { ALL_SALONS } from './salonsData';

export const INITIAL_SALONS: Salon[] = ALL_SALONS;

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
