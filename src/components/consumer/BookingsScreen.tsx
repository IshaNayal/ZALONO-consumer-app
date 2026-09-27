import React, { useState } from 'react';
import { ArrowLeft, Calendar, Clock, Star, RefreshCw, CheckCircle2 } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { Booking } from '../../types';

export const BookingsScreen: React.FC = () => {
  const { 
    bookings, 
    setConsumerScreen, 
    setActiveBooking,
    setSelectedSalon,
    salons,
    bookSlot 
  } = useZalono();

  const [tab, setTab] = useState<'upcoming' | 'past'>('upcoming');

  const upcomingBookings = bookings.filter(b => b.status !== 'completed' && b.status !== 'cancelled');
  const pastBookings = bookings.filter(b => b.status === 'completed' || b.status === 'cancelled');

  const handleRebook = (b: Booking) => {
    const salon = salons.find(s => s.id === b.salonId) || salons[0];
    setSelectedSalon(salon);
    bookSlot(salon.id, salon.slots[3]?.id || 'sl-4', b.serviceId);
    setConsumerScreen('confirmation');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-20">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setConsumerScreen('home')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">My Beauty Time</h1>
        <div className="w-7"></div>
      </div>

      {/* Segmented Control */}
      <div className="p-4">
        <div className="bg-slate-200/80 p-1 rounded-xl flex items-center">
          <button
            onClick={() => setTab('upcoming')}
            className={`flex-1 py-1.5 text-xs font-bold rounded-lg transition-all ${
              tab === 'upcoming' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Upcoming ({upcomingBookings.length})
          </button>
          <button
            onClick={() => setTab('past')}
            className={`flex-1 py-1.5 text-xs font-bold rounded-lg transition-all ${
              tab === 'past' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Past ({pastBookings.length})
          </button>
        </div>

        {/* Rebook Your Last Service Banner */}
        <div className="mt-4 p-3.5 bg-white border border-slate-200 rounded-2xl shadow-xs">
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-2">
            Rebook Your Last Service
          </span>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs font-bold text-slate-900">Haircut · Looks Salon</p>
              <p className="text-[11px] text-slate-500">₹399 · 45 min · Stylist Rahul</p>
            </div>
            <button
              onClick={() => handleRebook(bookings[0])}
              className="px-3 py-1.5 text-xs font-bold text-white bg-[#80142B] rounded-xl hover:bg-[#681023] shadow-xs flex items-center gap-1"
            >
              <RefreshCw className="w-3 h-3" />
              <span>Book Again</span>
            </button>
          </div>
        </div>

        {/* Bookings List */}
        <div className="mt-4 space-y-3">
          {(tab === 'upcoming' ? upcomingBookings : pastBookings).map((bk) => (
            <div key={bk.id} className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
              <div className="flex items-center justify-between pb-2 border-b border-slate-100">
                <span className="text-xs font-bold text-slate-900">{bk.date} · {bk.slotTime}</span>
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full capitalize ${
                  bk.status === 'completed' ? 'bg-slate-100 text-slate-700' :
                  bk.status === 'you_are_next' ? 'bg-rose-100 text-[#80142B]' : 'bg-emerald-100 text-emerald-800'
                }`}>
                  {bk.status.replace(/_/g, ' ')}
                </span>
              </div>

              <div className="flex items-center gap-3 py-2.5">
                <img
                  src={bk.salonImage}
                  alt={bk.salonName}
                  className="w-12 h-12 rounded-xl object-cover border"
                />
                <div className="flex-1">
                  <h3 className="text-sm font-bold text-slate-900">{bk.salonName}</h3>
                  <p className="text-xs text-slate-500">{bk.serviceName} · ₹{bk.servicePrice} · {bk.serviceDuration} min</p>
                </div>
                <button
                  onClick={() => {
                    setActiveBooking(bk);
                    setConsumerScreen('live_appointment');
                  }}
                  className="px-3 py-1.5 text-xs font-semibold text-[#80142B] bg-[#F9E8EC] rounded-xl hover:bg-rose-100"
                >
                  View
                </button>
              </div>

              {bk.feedback && (
                <div className="mt-2 pt-2 border-t border-slate-100 text-[11px] text-slate-500 flex items-center justify-between">
                  <span>Rated: {'★'.repeat(bk.feedback.rating)}</span>
                  <span>Started on time: <strong>{bk.feedback.startedOnTime}</strong></span>
                </div>
              )}
            </div>
          ))}

          {(tab === 'upcoming' ? upcomingBookings : pastBookings).length === 0 && (
            <div className="text-center py-10 text-slate-400 text-xs">
              No {tab} bookings right now.
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
