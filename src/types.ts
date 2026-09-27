export type ServiceCategory = 
  | 'Haircut'
  | 'Hair Color'
  | 'Facial'
  | 'Beard'
  | 'Hair Spa'
  | 'Manicure'
  | 'Pedicure'
  | 'Body Spa'
  | 'More';

export type TimePreference = 'now' | '30min' | 'later_today' | 'tomorrow' | 'specific';

export interface ServiceItem {
  id: string;
  name: string;
  price: number;
  durationMinutes: number;
  description?: string;
  category: ServiceCategory;
}

export interface Stylist {
  id: string;
  name: string;
  role: string;
  avatar: string;
  rating: number;
  status: 'available' | 'with_customer' | 'break' | 'off';
  currentCustomer?: string;
  currentService?: string;
  shiftHours: string;
  phone?: string;
}

export interface LiveSlot {
  id: string;
  time: string; // e.g. "11:00 AM"
  hourGroup: string; // e.g. "11 AM"
  status: 'available' | 'limited' | 'booked' | 'blocked';
  stylistId?: string;
  stylistName?: string;
  customerName?: string;
  serviceName?: string;
  price?: number;
  isRecommended?: boolean;
  isEarliest?: boolean;
  travelBufferMinutes?: number;
  dateStr?: string; // YYYY-MM-DD
}

export interface SalonReview {
  id: string;
  author: string;
  rating: number;
  date: string;
  comment: string;
  startedOnTime: 'yes' | 'almost' | 'no';
  serviceName: string;
}

export interface Salon {
  id: string;
  name: string;
  rating: number;
  reviewsCount: number;
  distanceKm: number;
  travelTimeMin: number;
  address: string;
  area: string;
  image: string;
  priceStart: number;
  isOpen: boolean;
  openingHours: string;
  expectedWaitMin: string;
  nextSlotTime: string;
  queueCount: number;
  stylistsCount: number;
  availableStylistsCount: number;
  busyLevel: 'quiet' | 'moderate' | 'busy';
  services: ServiceItem[];
  stylists: Stylist[];
  slots: LiveSlot[];
  isVerified: boolean;
  happyCustomersCount: string;
  upiId?: string;
  phone?: string;
  reviewsList?: SalonReview[];
}

export interface Booking {
  id: string;
  salonId: string;
  salonName: string;
  salonImage: string;
  salonAddress: string;
  serviceId: string;
  serviceName: string;
  servicePrice: number;
  serviceDuration: number;
  slotTime: string;
  date: string;
  distanceKm: number;
  travelTimeMin: number;
  stylistId: string;
  stylistName: string;
  customerName: string;
  customerPhone: string;
  status: 'booked' | 'checked_in' | 'you_are_next' | 'in_service' | 'completed' | 'cancelled';
  expectedWaitMin: string;
  queuePosition: number;
  estimatedStartTime: string;
  bookedAt: string;
  serviceStartedAt?: string;
  completedAt?: string;
  paymentStatus: 'paid_salon' | 'paid_upi' | 'pending';
  paymentMethod?: 'cash' | 'upi' | 'card';
  invoiceId?: string;
  feedback?: {
    rating: number;
    startedOnTime: 'yes' | 'almost' | 'no';
    wouldBookAgain: 'yes' | 'maybe' | 'no';
    reviewText?: string;
  };
}

export interface CustomerCRM {
  id: string;
  name: string;
  phone: string;
  customerSince: string;
  totalVisits: number;
  avgSpend: number;
  daysSinceLastVisit: number;
  preferredStylist: string;
  usualServices: string[];
  notes: string;
}

export interface PilotLocation {
  id: string;
  name: string;
  landmark: string;
  coordinates: { lat: number; lng: number };
}
