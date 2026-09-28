import React, { useState } from 'react';
import { ArrowLeft, Clock, ChevronDown, Star, Sparkles } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const BookByTimeScreen: React.FC = () => {
  const { 
    setConsumerScreen, 
    salons, 
    targetSearchTime, 
    setTargetSearchTime,
    bookSlot,
    setSelectedSalon 
  } = useZalono();

  const [selectedDay, setSelectedDay] = useState<'today' | 'tomorrow'>('today');

  const times = ['11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM', '4:00 PM', '6:00 PM'];

  const handleBook = (salon: any) => {
    setSelectedSalon(salon);
    bookSlot(salon.id, salon.slots[0].id, salon.services[0].id);
    setConsumerScreen('confirmation');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setConsumerScreen('home')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Book by Time (Reverse Search)</h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6 space-y-4">
        {/* Time Selector Box */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-700">Find a salon at:</span>
            <div className="relative">
              <select
                value={targetSearchTime}
                onChange={(e) => setTargetSearchTime(e.target.value)}
                className="text-sm font-bold text-[#80142B] bg-[#F9E8EC] py-1.5 px-3 rounded-xl border border-[#80142B]/30 focus:outline-none"
              >
                {times.map(t => (
                  <option key={t} value={t}>{t}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Day selection */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 pt-1">
            <button
              onClick={() => setSelectedDay('today')}
              className={`py-2 px-3 rounded-xl text-xs font-bold border transition-all ${
                selectedDay === 'today'
                  ? 'bg-slate-900 text-white border-slate-900'
                  : 'bg-slate-50 text-slate-700 border-slate-200'
              }`}
            >
              Today, 27 Sep
            </button>
            <button
              onClick={() => setSelectedDay('tomorrow')}
              className={`py-2 px-3 rounded-xl text-xs font-bold border transition-all ${
                selectedDay === 'tomorrow'
                  ? 'bg-slate-900 text-white border-slate-900'
                  : 'bg-slate-50 text-slate-700 border-slate-200'
              }`}
            >
              Tomorrow, 28 Sep
            </button>
          </div>

          {/* Quick Filters */}
          <div className="flex items-center gap-2 pt-2 border-t border-slate-100 text-xs">
            <span className="bg-slate-100 px-2 py-1 rounded-lg text-slate-700 font-semibold">Haircut</span>
            <span className="bg-slate-100 px-2 py-1 rounded-lg text-slate-700 font-semibold">Within 2 km</span>
            <span className="bg-slate-100 px-2 py-1 rounded-lg text-slate-700 font-semibold">Under ₹500</span>
          </div>
        </div>

        {/* Results Count Banner */}
        <div className="flex items-center justify-between px-1">
          <span className="text-xs font-bold text-slate-900">
            {salons.length * 7} salons available at {targetSearchTime}
          </span>
          <span className="text-[11px] text-emerald-700 font-bold flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Instant reserve
          </span>
        </div>

        {/* Available Salons at this time */}
        <div className="grid gap-3 md:grid-cols-2">
          {salons.map((salon) => (
            <div key={salon.id} className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
              <div className="flex items-center gap-3">
                <img
                  src={salon.image}
                  alt={salon.name}
                  className="w-12 h-12 rounded-xl object-cover border"
                />
                <div>
                  <h3 className="text-sm font-bold text-slate-900">{salon.name}</h3>
                  <div className="flex items-center gap-1 text-[11px] text-slate-500">
                    <Star className="w-3 h-3 fill-amber-500 text-amber-500" />
                    <span>{salon.rating}</span>
                    <span>·</span>
                    <span>{salon.distanceKm} km</span>
                  </div>
                  <p className="text-xs font-semibold text-slate-800 mt-0.5">₹{salon.priceStart} · 40 min</p>
                </div>
              </div>

              <button
                onClick={() => handleBook(salon)}
                className="px-4 py-2 bg-[#80142B] text-white text-xs font-bold rounded-xl hover:bg-[#681023] shadow-xs shrink-0"
              >
                Book
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
