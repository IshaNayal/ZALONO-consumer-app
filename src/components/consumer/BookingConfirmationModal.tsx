import React from 'react';
import { CheckCircle2, Calendar, MapPin, Clock, Scissors, RotateCcw, Navigation } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const BookingConfirmationModal: React.FC = () => {
  const { 
    activeBooking, 
    setConsumerScreen,
    showNotification 
  } = useZalono();

  if (!activeBooking) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-6 text-center">
        <p className="text-sm text-slate-500">No active booking found.</p>
        <button
          onClick={() => setConsumerScreen('home')}
          className="mt-4 px-4 py-2 bg-[#80142B] text-white rounded-xl text-xs font-bold"
        >
          Go to Home
        </button>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col justify-between bg-white p-6">
      <div className="flex flex-col items-center text-center pt-6 space-y-4">
        {/* Animated Checkmark Circle */}
        <div className="w-20 h-20 rounded-full bg-emerald-100 flex items-center justify-center ring-8 ring-emerald-50">
          <CheckCircle2 className="w-12 h-12 text-emerald-600 stroke-[2.5]" />
        </div>

        <div>
          <h1 className="text-2xl font-bold text-slate-900">You're booked! 🎉</h1>
          <p className="text-sm text-slate-500 mt-1">Your slot is reserved with zero wait promise.</p>
        </div>

        {/* Booking Summary Card */}
        <div className="w-full bg-slate-50 rounded-2xl border border-slate-200 p-4 text-left space-y-3 mt-2">
          <div className="flex items-center gap-3 pb-3 border-b border-slate-200">
            <img
              src={activeBooking.salonImage}
              alt={activeBooking.salonName}
              className="w-12 h-12 rounded-xl object-cover border border-slate-200"
            />
            <div>
              <h2 className="text-sm font-bold text-slate-900">{activeBooking.salonName}</h2>
              <p className="text-xs text-slate-500">Stylist: {activeBooking.stylistName}</p>
            </div>
          </div>

          <div className="space-y-2 text-xs text-slate-700">
            <div className="flex items-center gap-2.5">
              <Calendar className="w-4 h-4 text-[#80142B]" />
              <span className="font-semibold">{activeBooking.date}, {activeBooking.slotTime}</span>
            </div>

            <div className="flex items-center gap-2.5">
              <Scissors className="w-4 h-4 text-[#80142B]" />
              <span>{activeBooking.serviceName} · ₹{activeBooking.servicePrice} ({activeBooking.serviceDuration} min)</span>
            </div>

            <div className="flex items-center gap-2.5">
              <MapPin className="w-4 h-4 text-[#80142B]" />
              <span>{activeBooking.distanceKm} km · ~{activeBooking.travelTimeMin} min from you</span>
            </div>
          </div>

          {/* Expected Wait Time Badge */}
          <div className="mt-2 p-2.5 bg-emerald-100/70 border border-emerald-300 rounded-xl flex items-center gap-2">
            <Clock className="w-4 h-4 text-emerald-700" />
            <span className="text-xs font-bold text-emerald-900">
              Expected wait time: {activeBooking.expectedWaitMin}
            </span>
          </div>
        </div>

        {/* Action Buttons Row */}
        <div className="w-full space-y-2 pt-2">
          <button
            onClick={() => showNotification('Navigation Route', `Opening turn-by-turn directions to ${activeBooking.salonName} (~8 min drive).`)}
            className="w-full py-2.5 px-4 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-semibold text-slate-800 flex items-center justify-center gap-2 transition-colors"
          >
            <Navigation className="w-3.5 h-3.5 text-blue-600" />
            <span>Get Directions</span>
          </button>

          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => showNotification('Calendar', 'Appointment added to your Google Calendar.')}
              className="py-2.5 px-3 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-semibold text-slate-700 flex items-center justify-center gap-1.5 transition-colors"
            >
              <Calendar className="w-3.5 h-3.5" />
              <span>Add to Calendar</span>
            </button>
            <button
              onClick={() => showNotification('Reschedule', 'Choose another time slot from the salon details.')}
              className="py-2.5 px-3 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-semibold text-slate-700 flex items-center justify-center gap-1.5 transition-colors"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Reschedule</span>
            </button>
          </div>
        </div>
      </div>

      {/* Done Button */}
      <div className="pt-6">
        <button
          onClick={() => setConsumerScreen('live_appointment')}
          className="w-full py-3 bg-[#80142B] text-white rounded-xl font-bold text-sm shadow-md hover:bg-[#681023] transition-colors"
        >
          Track Live Appointment →
        </button>
      </div>
    </div>
  );
};
