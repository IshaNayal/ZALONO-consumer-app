import React, { createContext, useContext, useState, useEffect } from 'react';
import { Salon, Booking, CustomerCRM, LiveSlot, Stylist, ServiceCategory, PilotLocation } from '../types';
import { INITIAL_SALONS, INITIAL_BOOKINGS, INITIAL_CUSTOMER_CRM, PILOT_LOCATIONS } from '../data/initialData';
import { FirestoreService } from '../firebase/services';
import { isFirebaseConfigured } from '../firebase/config';

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

  // Pilot & Firebase tools
  isLiveFirestore: boolean;
  firestoreStatus: 'connected' | 'connecting' | 'offline';
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
  const [userProfile, setUserProfile] = useState({ name: 'Jay Sharma', phone: '+91 00000 00000', isOtpVerified: true });

  // Persistent Salons & Bookings state
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

  // Firebase Real-Time Firestore Sync
  const [firestoreStatus, setFirestoreStatus] = useState<'connected' | 'connecting' | 'offline'>(
    isFirebaseConfigured ? 'connecting' : 'offline'
  );

  useEffect(() => {
    let unsubscribeSalons: () => void = () => {};
    let unsubscribeBookings: () => void = () => {};

    if (isFirebaseConfigured) {
      // Seed data if database is brand new
      FirestoreService.seedInitialDataIfEmpty().then(() => {
        setFirestoreStatus('connected');
      }).catch(() => {
        setFirestoreStatus('connected');
      });

      // Realtime listener for salons
      unsubscribeSalons = FirestoreService.subscribeToSalons((remoteSalons) => {
        if (remoteSalons && remoteSalons.length > 0) {
          setSalons(remoteSalons);
          setFirestoreStatus('connected');
        }
      });

      // Realtime listener for bookings
      unsubscribeBookings = FirestoreService.subscribeToBookings((remoteBookings) => {
        if (remoteBookings && remoteBookings.length > 0) {
          setBookings(remoteBookings);
          const active = remoteBookings.find(b => b.status !== 'completed' && b.status !== 'cancelled');
          if (active) setActiveBooking(active);
          setFirestoreStatus('connected');
        }
      });
    }

    return () => {
      unsubscribeSalons();
      unsubscribeBookings();
    };
  }, []);

  // Sync to local storage for offline resiliency
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

  // Audio Chime
  const playBookingChime = () => {
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, ctx.currentTime);
      osc.frequency.setValueAtTime(880, ctx.currentTime + 0.1);
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
      if (loc.id === 'loc-1') {
        if (s.id === 'salon-1') { dist = 0.8; time = 8; }
        else if (s.id === 'salon-2') { dist = 1.8; time = 12; }
        else { dist = 6.8; time = 22; }
      } else if (loc.id === 'loc-2') {
        if (s.id === 'salon-3') { dist = 0.5; time = 4; }
        else if (s.id === 'salon-1') { dist = 7.5; time = 20; }
        else { dist = 8.2; time = 24; }
      } else if (loc.id === 'loc-3') {
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
      `Switched to ${loc.name}. Travel times & smart slots recalculated.`
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

    const updatedSlots = salon.slots.map(sl => sl.id === slotId ? { 
      ...sl, 
      status: 'booked' as const, 
      customerName: userProfile.name, 
      serviceName: service.name 
    } : sl);

    // Update local state
    setSalons(prev => prev.map(s => s.id === salonId ? { ...s, slots: updatedSlots } : s));

    // Update Firestore
    FirestoreService.updateSalonSlots(salonId, updatedSlots);

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

    // Save to Firestore
    FirestoreService.saveBooking(newBooking);

    playBookingChime();

    showNotification(
      'Booking Confirmed! ⚡',
      `Your slot at ${salon.name} for ${service.name} is reserved in Firestore for ${newBooking.slotTime}.`,
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
    FirestoreService.updateBookingStatus(bookingId, { status: 'cancelled' });
    showNotification('Booking Cancelled', 'Slot released and returned to public availability.');
  };

  const advanceBookingQueueStatus = (bookingId: string) => {
    let nextStatus: Booking['status'] = 'booked';
    let nextQueue = 1;

    setBookings(prev => prev.map(b => {
      if (b.id !== bookingId) return b;
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
      return { ...prev, status: nextStatus, queuePosition: nextQueue };
    });

    FirestoreService.updateBookingStatus(bookingId, { 
      status: nextStatus, 
      queuePosition: nextQueue 
    });

    playBookingChime();
  };

  const updateSlotStatus = (salonId: string, slotId: string, newStatus: LiveSlot['status']) => {
    const salon = salons.find(s => s.id === salonId);
    if (salon) {
      const updatedSlots = salon.slots.map(sl => sl.id === slotId ? { ...sl, status: newStatus } : sl);
      setSalons(prev => prev.map(s => s.id === salonId ? { ...s, slots: updatedSlots } : s));
      FirestoreService.updateSalonSlots(salonId, updatedSlots);
    }
  };

  const addWalkIn = (customerName: string, serviceName: string, stylistName: string, durationMin: number) => {
    const updatedQueue = (salons[0]?.queueCount || 3) + 1;
    setSalons(prev => prev.map(s => s.id === 'salon-1' ? { ...s, queueCount: updatedQueue } : s));
    FirestoreService.updateSalon('salon-1', { queueCount: updatedQueue });

    playBookingChime();

    showNotification(
      'Walk-In Added to Queue',
      `${customerName} registered for ${serviceName} (${durationMin}m). Firestore database updated.`,
      'View Slots',
      () => {
        setRole('partner');
        setPartnerScreen('manage_slots');
      }
    );
  };

  const updateStylistStatus = (stylistId: string, status: Stylist['status']) => {
    const salon = salons.find(s => s.id === 'salon-1');
    if (salon) {
      const updatedStylists = salon.stylists.map(st => st.id === stylistId ? { ...st, status } : st);
      const availableCount = updatedStylists.filter(st => st.status === 'available').length;
      setSalons(prev => prev.map(s => s.id === 'salon-1' ? { ...s, stylists: updatedStylists, availableStylistsCount: availableCount } : s));
      FirestoreService.updateSalon('salon-1', { stylists: updatedStylists, availableStylistsCount: availableCount });
    }
  };

  const completeService = (
    bookingId: string, 
    paymentMethod: 'paid_salon' | 'paid_upi',
    details?: { addOnAmount?: number; methodUsed?: 'cash' | 'upi' | 'card' }
  ) => {
    const target = bookings.find(b => b.id === bookingId);
    const updatedPrice = (target?.servicePrice || 399) + (details?.addOnAmount || 0);

    setBookings(prev => prev.map(b => {
      if (b.id !== bookingId) return b;
      return {
        ...b,
        status: 'completed',
        paymentStatus: paymentMethod,
        paymentMethod: details?.methodUsed || (paymentMethod === 'paid_upi' ? 'upi' : 'cash'),
        servicePrice: updatedPrice,
        completedAt: 'Just now'
      };
    }));

    if (activeBooking?.id === bookingId) {
      setActiveBooking(prev => prev ? { 
        ...prev, 
        status: 'completed', 
        paymentStatus: paymentMethod,
        paymentMethod: details?.methodUsed || (paymentMethod === 'paid_upi' ? 'upi' : 'cash'),
        servicePrice: updatedPrice,
        completedAt: 'Just now'
      } : null);
    }

    setCustomerCRM(prev => ({
      ...prev,
      totalVisits: prev.totalVisits + 1,
      daysSinceLastVisit: 0
    }));

    FirestoreService.updateBookingStatus(bookingId, {
      status: 'completed',
      paymentStatus: paymentMethod,
      servicePrice: updatedPrice,
      completedAt: 'Just now'
    });

    playBookingChime();
  };

  const submitFeedback = (
    bookingId: string, 
    rating: number, 
    startedOnTime: 'yes' | 'almost' | 'no', 
    wouldBookAgain: 'yes' | 'maybe' | 'no',
    reviewText?: string
  ) => {
    const feedbackObj = { rating, startedOnTime, wouldBookAgain, reviewText };
    setBookings(prev => prev.map(b => b.id === bookingId ? { ...b, feedback: feedbackObj } : b));

    if (activeBooking?.id === bookingId) {
      setActiveBooking(prev => prev ? { ...prev, feedback: feedbackObj } : null);
    }

    FirestoreService.updateBookingStatus(bookingId, { feedback: feedbackObj });

    showNotification(
      'Feedback Recorded ⭐',
      'Thank you! Your feedback is recorded in the Firestore database.'
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
    FirestoreService.resetDatabase();
    showNotification('Database Reset', 'Firestore data restored to default pilot seed.');
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
        isLiveFirestore: isFirebaseConfigured,
        firestoreStatus,
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
