import { 
  collection, 
  doc, 
  setDoc, 
  getDocs, 
  onSnapshot, 
  updateDoc, 
  query, 
  orderBy, 
  deleteDoc 
} from 'firebase/firestore';
import { db } from './config';
import { Salon, Booking, LiveSlot, CustomerCRM } from '../types';
import { INITIAL_SALONS, INITIAL_BOOKINGS, INITIAL_CUSTOMER_CRM } from '../data/initialData';

const SALONS_COLLECTION = 'salons';
const BOOKINGS_COLLECTION = 'bookings';
const CRM_COLLECTION = 'crm';

export const FirestoreService = {
  // Initialize Firestore with default seed salons if empty
  async seedInitialDataIfEmpty(): Promise<void> {
    try {
      const snap = await getDocs(collection(db, SALONS_COLLECTION));
      if (snap.empty) {
        // Seed salons
        for (const salon of INITIAL_SALONS) {
          await setDoc(doc(db, SALONS_COLLECTION, salon.id), salon);
        }
        // Seed initial bookings
        for (const booking of INITIAL_BOOKINGS) {
          await setDoc(doc(db, BOOKINGS_COLLECTION, booking.id), booking);
        }
        // Seed CRM
        await setDoc(doc(db, CRM_COLLECTION, INITIAL_CUSTOMER_CRM.id), INITIAL_CUSTOMER_CRM);
      }
    } catch (err) {
      console.warn('Firestore seeding skipped or network offline:', err);
    }
  },

  // Real-time listener for salons
  subscribeToSalons(onUpdate: (salons: Salon[]) => void) {
    try {
      return onSnapshot(collection(db, SALONS_COLLECTION), (snapshot) => {
        if (!snapshot.empty) {
          const salons: Salon[] = [];
          snapshot.forEach((docSnap) => {
            salons.push(docSnap.data() as Salon);
          });
          onUpdate(salons);
        }
      }, (err) => {
        console.warn('Salons subscription error:', err);
      });
    } catch (e) {
      console.warn('Firestore subscribe error', e);
      return () => {};
    }
  },

  // Real-time listener for bookings
  subscribeToBookings(onUpdate: (bookings: Booking[]) => void) {
    try {
      const q = query(collection(db, BOOKINGS_COLLECTION));
      return onSnapshot(q, (snapshot) => {
        if (!snapshot.empty) {
          const bookings: Booking[] = [];
          snapshot.forEach((docSnap) => {
            bookings.push(docSnap.data() as Booking);
          });
          // Sort newest first
          bookings.sort((a, b) => b.id.localeCompare(a.id));
          onUpdate(bookings);
        }
      }, (err) => {
        console.warn('Bookings subscription error:', err);
      });
    } catch (e) {
      console.warn('Firestore bookings subscribe error', e);
      return () => {};
    }
  },

  // Create new booking
  async saveBooking(booking: Booking): Promise<void> {
    try {
      await setDoc(doc(db, BOOKINGS_COLLECTION, booking.id), booking);
    } catch (e) {
      console.warn('Failed to save booking to Firestore:', e);
    }
  },

  // Update booking status
  async updateBookingStatus(bookingId: string, updates: Partial<Booking>): Promise<void> {
    try {
      await updateDoc(doc(db, BOOKINGS_COLLECTION, bookingId), updates);
    } catch (e) {
      console.warn('Failed to update booking status in Firestore:', e);
    }
  },

  // Update Salon Slots
  async updateSalonSlots(salonId: string, slots: LiveSlot[]): Promise<void> {
    try {
      await updateDoc(doc(db, SALONS_COLLECTION, salonId), { slots });
    } catch (e) {
      console.warn('Failed to update salon slots in Firestore:', e);
    }
  },

  // Update Stylist Status
  async updateSalon(salonId: string, updates: Partial<Salon>): Promise<void> {
    try {
      await updateDoc(doc(db, SALONS_COLLECTION, salonId), updates);
    } catch (e) {
      console.warn('Failed to update salon in Firestore:', e);
    }
  },

  // Reset database to initial seed
  async resetDatabase(): Promise<void> {
    try {
      for (const salon of INITIAL_SALONS) {
        await setDoc(doc(db, SALONS_COLLECTION, salon.id), salon);
      }
      for (const booking of INITIAL_BOOKINGS) {
        await setDoc(doc(db, BOOKINGS_COLLECTION, booking.id), booking);
      }
    } catch (e) {
      console.warn('Failed to reset database:', e);
    }
  }
};
