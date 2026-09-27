import React, { createContext, useContext, useState, useEffect } from 'react';
import { Salon, Booking, CustomerCRM, LiveSlot, Stylist, ServiceCategory, PilotLocation } from '../types';
import { INITIAL_SALONS, INITIAL_BOOKINGS, INITIAL_CUSTOMER_CRM, PILOT_LOCATIONS } from '../data/initialData';

export type UserRole = 'consumer' | 'partner';
export type ConsumerScreen = 
  | 'home'
  | 'service_time'
  | 'salon_list'
  | 'salon_detail'
  | 'confirmation'
  | 'live_appointment'
  | 'bookings'
  | 'book_by_time'
  | 'last_minute'
  | 'profile'
  | 'location_picker'
  | 'upi_payment'
  | 'receipt';

export type PartnerScreen = 
  | 'dashboard'
  | 'manage_slots'
  | 'staff'
  | 'incoming_bookings'
  | 'walk_in'
  | 'during_service'
  | 'crm'
  | 'analytics'
  | 'settings';

interface ZalonoContextType {
  role: UserRole;
  setRole: (role: UserRole) => void;
  consumerScreen: ConsumerScreen;
  setConsumerScreen: (screen: ConsumerScreen) => void;
  partnerScreen: PartnerScreen;
  setPartnerScreen: (screen: PartnerScreen) => void;
  
  // Pilot location
  currentLocation: PilotLocation;
  setCurrentLocation: (loc: PilotLocation) => void;
  locationsList: PilotLocation[];
  
  // User Profile
  userProfile: { name: string; phone: string; isOtpVerified: boolean };
  setUserProfile: React.Dispatch<React.SetStateAction<{ name: string; phone: string; isOtpVerified: boolean }>>;

  salons: Salon[];
  selectedSalon: Salon;
  setSelectedSalon: (salon: Salon) => void;
  selectedCategory: ServiceCategory;
  setSelectedCategory: (cat: ServiceCategory) => void;
  
  bookings: Booking[];
  activeBooking: Booking | null;
  setActiveBooking: (bk: Booking | null) => void;
  customerCRM: CustomerCRM;
  
  // Real-time actions
  bookSlot: (salonId: string, slotId: string, serviceId: string, stylistName?: string) => Booking;
  cancelBooking: (bookingId: string) => void;
  advanceBookingQueueStatus: (bookingId: string) => void;
  updateSlotStatus: (salonId: string, slotId: string, newStatus: LiveSlot['status']) => void;
  addWalkIn: (customerName: string, serviceName: string, stylistName: string, durationMin: number, customAmount?: number) => void;
  updateStylistStatus: (stylistId: string, status: Stylist['status']) => void;
  completeService: (bookingId: string, paymentMethod: 'paid_salon' | 'paid_upi', details?: { addOnAmount?: number; methodUsed?: 'cash' | 'upi' | 'card' }) => void;
  submitFeedback: (bookingId: string, rating: number, startedOnTime: 'yes' | 'almost' | 'no', wouldBookAgain: 'yes' | 'maybe' | 'no', reviewText?: string) => void;
  
  // Simulated alerts & notifications
  incomingBookingNotification: Booking | null;
  dismissIncomingNotification: () => void;
  activeNotification: { title: string; message: string; actionText?: string; onAction?: () => void } | null;
  showNotification: (title: string, message: string, actionText?: string, onAction?: () => void) => void;
  clearNotification: () => void;
  
  // Reverse search & AI finder
  targetSearchTime: string;
  setTargetSearchTime: (time: string) => void;

  // Pilot tools
  resetDemoData: () => void;
  playBookingChime: () => void;
  getWhatsAppShareUrl: (phone: string, text: string) => string;
}

const ZalonoContext = createContext<ZalonoContextType | undefined>(undefined);

const LOCAL_STORAGE_KEY = 'zalono_pilot_data_v1';

export const ZalonoProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [role, setRole] = useState<UserRole>('consumer');
  const [consumerScreen, setConsumerScreen] = useState<ConsumerScreen>('home');
  const [partnerScreen, setPartnerScreen] = useState<PartnerScreen>('dashboard');
  
  const [currentLocation, setCurrentLocationState] = useState<PilotLocation>(PILOT_LOCATIONS[0]);
  const [userProfile, setUserProfile] = useState({ name: 'Jay Sharma', phone: '+91 98765 43210', isOtpVerified: true });

  // Persistent Salons & Bookings with fallback to Initial Data
  const [salons, setSalons] = useState<Salon[]>(() => {
    try {
      const saved = localStorage.getItem(`${LOCAL_STORAGE_KEY}_salons`);
      return saved ? JSON.parse(saved) : INITIAL_SALONS;
    } catch {
      return INITIAL_SALONS;
    }
  });

  const [selectedSalon, setSelectedSalon] = useState<Salon>(salons[0] || INITIAL_SALONS[0]);
  const [selectedCategory, setSelectedCategory] = useState<ServiceCategory>('Haircut');
  
  const [bookings, setBookings] = useState<Booking[]>(() => {
    try {
      const saved = localStorage.getItem(`${LOCAL_STORAGE_KEY}_bookings`);
      return saved ? JSON.parse(saved) : INITIAL_BOOKINGS;
    } catch {
      return INITIAL_BOOKINGS;
    }
  });

  const [activeBooking, setActiveBooking] = useState<Booking | null>(() => {
    return bookings.find(b => b.status !== 'completed' && b.status !== 'cancelled') || bookings[0] || null;
  });

  const [customerCRM, setCustomerCRM] = useState<CustomerCRM>(INITIAL_CUSTOMER_CRM);
  const [incomingBookingNotification, setIncomingBookingNotification] = useState<Booking | null>(null);
  
  const [activeNotification, setActiveNotification] = useState<{ title: string; message: string; actionText?: string; onAction?: () => void } | null>({
    title: 'Zalono Pilot · Leave in 8 minutes',
    message: 'Your slot at Looks Salon (Saheed Nagar) is at 11:40 AM. Live traffic is 8 min. Leave now for zero-wait arrival! 🚗',
    actionText: 'View Route',
    onAction: () => setConsumerScreen('live_appointment')
  });
  
  const [targetSearchTime, setTargetSearchTime] = useState<string>('12:30 PM');

  // Sync to local storage
  useEffect(() => {
    try {
      localStorage.setItem(`${LOCAL_STORAGE_KEY}_salons`, JSON.stringify(salons));
    } catch (e) {
      console.warn('Storage quota error', e);
    }
  }, [salons]);

  useEffect(() => {
    try {
      localStorage.setItem(`${LOCAL_STORAGE_KEY}_bookings`, JSON.stringify(bookings));
    } catch (e) {
      console.warn('Storage quota error', e);
    }
  }, [bookings]);

  // Synthetic Audio Chime for pilot sound feedback
  const playBookingChime = () => {
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
      osc.frequency.setValueAtTime(880, ctx.currentTime + 0.1); // A5
      gain.gain.setValueAtTime(0.2, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.4);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 0.4);
    } catch (e) {
      // Audio autoplay policy catch
    }
  };

  const setCurrentLocation = (loc: PilotLocation) => {
    setCurrentLocationState(loc);
    // Recalculate realistic travel times for pilot based on location
    setSalons(prev => prev.map(s => {
      let dist = 1.0;
      let time = 10;
      if (loc.id === 'loc-1') { // Saheed Nagar
        if (s.id === 'salon-1') { dist = 0.8; time = 8; }
        else if (s.id === 'salon-2') { dist = 1.8; time = 12; }
        else { dist = 6.8; time = 22; }
      } else if (loc.id === 'loc-2') { // Patia
        if (s.id === 'salon-3') { dist = 0.5; time = 4; }
        else if (s.id === 'salon-1') { dist = 7.5; time = 20; }
        else { dist = 8.2; time = 24; }
      } else if (loc.id === 'loc-3') { // Jayadev Vihar
        if (s.id === 'salon-1') { dist = 2.4; time = 9; }
        else if (s.id === 'salon-2') { dist = 3.1; time = 12; }
        else { dist = 5.2; time = 15; }
      } else {
        dist = 2.0; time = 11;
      }
      return {
        ...s,
        distanceKm: dist,
        travelTimeMin: time
      };
    }));

    showNotification(
      'Location Updated',
      `Switched to ${loc.name}. Travel times & smart slots recalculated for local traffic.`
    );
  };

  const showNotification = (title: string, message: string, actionText?: string, onAction?: () => void) => {
    setActiveNotification({ title, message, actionText, onAction });
  };

  const clearNotification = () => {
    setActiveNotification(null);
  };

  const dismissIncomingNotification = () => {
    setIncomingBookingNotification(null);
  };

  const getWhatsAppShareUrl = (phone: string, text: string) => {
    const cleanPhone = phone.replace(/[^0-9]/g, '');
    return `https://wa.me/${cleanPhone}?text=${encodeURIComponent(text)}`;
  };

  const bookSlot = (salonId: string, slotId: string, serviceId: string, stylistName?: string): Booking => {
    const salon = salons.find(s => s.id === salonId) || salons[0];
    const service = salon.services.find(s => s.id === serviceId) || salon.services[0];
    const slot = salon.slots.find(sl => sl.id === slotId);
    const chosenStylist = stylistName || slot?.stylistName || salon.stylists[0].name;

    // Mark slot as booked in salon
    setSalons(prev => prev.map(s => {
      if (s.id !== salonId) return s;
      return {
        ...s,
        slots: s.slots.map(sl => sl.id === slotId ? { 
          ...sl, 
          status: 'booked', 
          customerName: userProfile.name, 
          serviceName: service.name 
        } : sl)
      };
    }));

    const invoiceId = `ZAL-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`;

    const newBooking: Booking = {
      id: `bk-${Date.now()}`,
      salonId: salon.id,
      salonName: salon.name,
      salonImage: salon.image,
      salonAddress: salon.address,
      serviceId: service.id,
      serviceName: service.name,
      servicePrice: service.price,
      serviceDuration: service.durationMinutes,
      slotTime: slot?.time || '11:40 AM',
      date: 'Today, 27 Sep',
      distanceKm: salon.distanceKm,
      travelTimeMin: salon.travelTimeMin,
      stylistId: salon.stylists.find(st => st.name === chosenStylist)?.id || 'sty-1',
      stylistName: chosenStylist,
      customerName: userProfile.name,
      customerPhone: userProfile.phone,
      status: 'booked',
      expectedWaitMin: '0-5 minutes',
      queuePosition: 1,
      estimatedStartTime: slot?.time || '11:40 AM',
      bookedAt: 'Just now',
      paymentStatus: 'pending',
      invoiceId
    };

    setBookings(prev => [newBooking, ...prev]);
    setActiveBooking(newBooking);
    setIncomingBookingNotification(newBooking);

    // Audio chime for pilot experience
    playBookingChime();

    showNotification(
      'Booking Confirmed! ⚡',
      `Your slot at ${salon.name} for ${service.name} is reserved for ${newBooking.slotTime}. Zero-wait promise active.`,
      'Track Live',
      () => setConsumerScreen('live_appointment')
    );

    return newBooking;
  };

  const cancelBooking = (bookingId: string) => {
    setBookings(prev => prev.map(b => b.id === bookingId ? { ...b, status: 'cancelled' } : b));
    if (activeBooking?.id === bookingId) {
      setActiveBooking(null);
    }
    showNotification('Booking Cancelled', 'Slot released and returned to public availability.');
  };

  const advanceBookingQueueStatus = (bookingId: string) => {
    setBookings(prev => prev.map(b => {
      if (b.id !== bookingId) return b;
      let nextStatus: Booking['status'] = b.status;
      let nextQueue = b.queuePosition;
      if (b.status === 'booked') {
        nextStatus = 'checked_in';
        nextQueue = 1;
      } else if (b.status === 'checked_in') {
        nextStatus = 'you_are_next';
        nextQueue = 1;
      } else if (b.status === 'you_are_next') {
        nextStatus = 'in_service';
        nextQueue = 0;
      } else if (b.status === 'in_service') {
        nextStatus = 'completed';
      }
      return { ...b, status: nextStatus, queuePosition: nextQueue };
    }));

    setActiveBooking(prev => {
      if (!prev || prev.id !== bookingId) return prev;
      let nextStatus: Booking['status'] = prev.status;
      let nextQueue = prev.queuePosition;
      if (prev.status === 'booked') nextStatus = 'checked_in';
      else if (prev.status === 'checked_in') nextStatus = 'you_are_next';
      else if (prev.status === 'you_are_next') { nextStatus = 'in_service'; nextQueue = 0; }
      else if (prev.status === 'in_service') nextStatus = 'completed';
      return { ...prev, status: nextStatus, queuePosition: nextQueue };
    });

    playBookingChime();
  };

  const updateSlotStatus = (salonId: string, slotId: string, newStatus: LiveSlot['status']) => {
    setSalons(prev => prev.map(s => {
      if (s.id !== salonId) return s;
      return {
        ...s,
        slots: s.slots.map(sl => sl.id === slotId ? { ...sl, status: newStatus } : sl)
      };
    }));
  };

  const addWalkIn = (customerName: string, serviceName: string, stylistName: string, durationMin: number, customAmount?: number) => {
    setSalons(prev => prev.map(s => {
      if (s.id !== 'salon-1') return s;
      return {
        ...s,
        queueCount: s.queueCount + 1,
      };
    }));

    playBookingChime();

    showNotification(
      'Walk-In Added to Queue',
      `${customerName} registered for ${serviceName} (${durationMin}m) with ${stylistName}. Live wait time adjusted.`,
      'View Slots',
      () => {
        setRole('partner');
        setPartnerScreen('manage_slots');
      }
    );
  };

  const updateStylistStatus = (stylistId: string, status: Stylist['status']) => {
    setSalons(prev => prev.map(s => {
      if (s.id !== 'salon-1') return s;
      return {
        ...s,
        stylists: s.stylists.map(st => st.id === stylistId ? { ...st, status } : st),
        availableStylistsCount: s.stylists.filter(st => (st.id === stylistId ? status === 'available' : st.status === 'available')).length
      };
    }));
  };

  const completeService = (
    bookingId: string, 
    paymentMethod: 'paid_salon' | 'paid_upi',
    details?: { addOnAmount?: number; methodUsed?: 'cash' | 'upi' | 'card' }
  ) => {
    setBookings(prev => prev.map(b => {
      if (b.id !== bookingId) return b;
      return {
        ...b,
        status: 'completed',
        paymentStatus: paymentMethod,
        paymentMethod: details?.methodUsed || (paymentMethod === 'paid_upi' ? 'upi' : 'cash'),
        servicePrice: b.servicePrice + (details?.addOnAmount || 0),
        completedAt: 'Just now'
      };
    }));

    if (activeBooking?.id === bookingId) {
      setActiveBooking(prev => prev ? { 
        ...prev, 
        status: 'completed', 
        paymentStatus: paymentMethod,
        paymentMethod: details?.methodUsed || (paymentMethod === 'paid_upi' ? 'upi' : 'cash'),
        servicePrice: prev.servicePrice + (details?.addOnAmount || 0),
        completedAt: 'Just now'
      } : null);
    }

    setCustomerCRM(prev => ({
      ...prev,
      totalVisits: prev.totalVisits + 1,
      daysSinceLastVisit: 0
    }));

    playBookingChime();
  };

  const submitFeedback = (
    bookingId: string, 
    rating: number, 
    startedOnTime: 'yes' | 'almost' | 'no', 
    wouldBookAgain: 'yes' | 'maybe' | 'no',
    reviewText?: string
  ) => {
    setBookings(prev => prev.map(b => b.id === bookingId ? { 
      ...b, 
      feedback: { rating, startedOnTime, wouldBookAgain, reviewText } 
    } : b));

    if (activeBooking?.id === bookingId) {
      setActiveBooking(prev => prev ? { 
        ...prev, 
        feedback: { rating, startedOnTime, wouldBookAgain, reviewText } 
      } : null);
    }

    // Add to salon review list
    const currentBk = bookings.find(b => b.id === bookingId);
    if (currentBk) {
      setSalons(prev => prev.map(s => {
        if (s.id !== currentBk.salonId) return s;
        const newReview = {
          id: `rev-${Date.now()}`,
          author: currentBk.customerName,
          rating,
          date: 'Just now',
          comment: reviewText || (startedOnTime === 'yes' ? 'Punctual and very efficient service.' : 'Good overall experience.'),
          startedOnTime,
          serviceName: currentBk.serviceName
        };
        return {
          ...s,
          reviewsCount: s.reviewsCount + 1,
          reviewsList: [newReview, ...(s.reviewsList || [])]
        };
      }));
    }

    showNotification(
      'Feedback Recorded ⭐',
      'Thank you! Your feedback helps keep salon wait times honest and accurate.'
    );
  };

  const resetDemoData = () => {
    localStorage.removeItem(`${LOCAL_STORAGE_KEY}_salons`);
    localStorage.removeItem(`${LOCAL_STORAGE_KEY}_bookings`);
    setSalons(INITIAL_SALONS);
    setBookings(INITIAL_BOOKINGS);
    setActiveBooking(INITIAL_BOOKINGS[0]);
    setSelectedSalon(INITIAL_SALONS[0]);
    setCustomerCRM(INITIAL_CUSTOMER_CRM);
    setCurrentLocationState(PILOT_LOCATIONS[0]);
    showNotification('Pilot Data Reset', 'Initial pilot state restored.');
  };

  return (
    <ZalonoContext.Provider
      value={{
        role,
        setRole,
        consumerScreen,
        setConsumerScreen,
        partnerScreen,
        setPartnerScreen,
        currentLocation,
        setCurrentLocation,
        locationsList: PILOT_LOCATIONS,
        userProfile,
        setUserProfile,
        salons,
        selectedSalon,
        setSelectedSalon,
        selectedCategory,
        setSelectedCategory,
        bookings,
        activeBooking,
        setActiveBooking,
        customerCRM,
        bookSlot,
        cancelBooking,
        advanceBookingQueueStatus,
        updateSlotStatus,
        addWalkIn,
        updateStylistStatus,
        completeService,
        submitFeedback,
        incomingBookingNotification,
        dismissIncomingNotification,
        activeNotification,
        showNotification,
        clearNotification,
        targetSearchTime,
        setTargetSearchTime,
        resetDemoData,
        playBookingChime,
        getWhatsAppShareUrl,
      }}
    >
      {children}
    </ZalonoContext.Provider>
  );
};

export const useZalono = () => {
  const context = useContext(ZalonoContext);
  if (!context) throw new Error('useZalono must be used within ZalonoProvider');
  return context;
};
