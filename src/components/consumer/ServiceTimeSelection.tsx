import React from 'react';
import { ArrowLeft, Zap, Clock, Calendar, CalendarDays, SlidersHorizontal, Star, Navigation } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const ServiceTimeSelection: React.FC = () => {
  const { 
    selectedCategory, 
    setConsumerScreen, 
    salons, 
    setSelectedSalon,
    bookSlot 
  } = useZalono();

  const handleSelectTime = (_timeChoice: string) => {
    setConsumerScreen('salon_list');
  };

  const fastestSalon = salons[0];

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-8">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center gap-3">
        <button
          onClick={() => setConsumerScreen('home')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">{selectedCategory}</h1>
      </div>

      <div className="w-full max-w-6xl mx-auto p-5 sm:px-6 space-y-5">
        <div>
          <h2 className="text-lg font-bold text-slate-900">When would you like to go?</h2>
          <p className="text-xs text-slate-500 mt-0.5">Choose when you want your service</p>
        </div>

        {/* Options list */}
        <div className="grid gap-2.5 md:grid-cols-2">
          <button
            onClick={() => handleSelectTime('now')}
            className="w-full p-4 bg-white hover:bg-rose-50/40 rounded-2xl border-2 border-[#80142B] flex items-center justify-between shadow-xs transition-all text-left"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-[#F9E8EC] text-[#80142B] flex items-center justify-center font-bold">
                <Zap className="w-5 h-5" />
              </div>
              <div>
                <div className="flex items-center gap-1.5">
                  <span className="text-sm font-bold text-slate-900">Now</span>
                  <span className="text-[10px] font-bold text-emerald-700 bg-emerald-100 px-1.5 py-0.5 rounded">FASTEST</span>
                </div>
                <p className="text-xs text-slate-500 mt-0.5">(Available immediately)</p>
              </div>
            </div>
            <span className="text-xs font-bold text-[#80142B]">Select →</span>
          </button>

          <button
            onClick={() => handleSelectTime('30min')}
            className="w-full p-4 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs transition-all text-left"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center">
                <Clock className="w-5 h-5" />
              </div>
              <div>
                <span className="text-sm font-bold text-slate-900">Within 30 min</span>
                <p className="text-xs text-slate-500 mt-0.5">Reach with current traffic</p>
              </div>
            </div>
            <span className="text-xs font-semibold text-slate-400">→</span>
          </button>

          <button
            onClick={() => handleSelectTime('later_today')}
            className="w-full p-4 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs transition-all text-left"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center">
                <Calendar className="w-5 h-5" />
              </div>
              <div>
                <span className="text-sm font-bold text-slate-900">Later today</span>
                <p className="text-xs text-slate-500 mt-0.5">Afternoon or evening slots</p>
              </div>
            </div>
            <span className="text-xs font-semibold text-slate-400">→</span>
          </button>

          <button
            onClick={() => handleSelectTime('tomorrow')}
            className="w-full p-4 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs transition-all text-left"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center">
                <CalendarDays className="w-5 h-5" />
              </div>
              <div>
                <span className="text-sm font-bold text-slate-900">Tomorrow</span>
                <p className="text-xs text-slate-500 mt-0.5">Book ahead for zero waiting</p>
              </div>
            </div>
            <span className="text-xs font-semibold text-slate-400">→</span>
          </button>

          <button
            onClick={() => setConsumerScreen('book_by_time')}
            className="w-full p-4 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 flex items-center justify-between shadow-xs transition-all text-left"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center">
                <SlidersHorizontal className="w-5 h-5" />
              </div>
              <div>
                <span className="text-sm font-bold text-slate-900">Pick a specific time</span>
                <p className="text-xs text-slate-500 mt-0.5">Reverse search: see all salons for your time</p>
              </div>
            </div>
            <span className="text-xs font-semibold text-slate-400">→</span>
          </button>
        </div>

        {/* Travel Traffic Buffer Explainer */}
        <div className="p-3.5 bg-blue-50 border border-blue-200 rounded-2xl flex items-start gap-3">
          <Navigation className="w-4 h-4 text-blue-600 mt-0.5 shrink-0" />
          <p className="text-[11px] text-blue-900 leading-relaxed">
            <strong>Smart Traffic Calculation:</strong> We'll show you salons you can reach comfortably based on your current location and live traffic with a 5-minute arrival buffer.
          </p>
        </div>

        {/* Fastest Available Near You Card */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-2">Fastest Available Near You</span>
          <div className="flex items-center gap-3">
            <img
              src={fastestSalon.image}
              alt={fastestSalon.name}
              className="w-14 h-14 rounded-xl object-cover border border-slate-100 shrink-0"
            />
            <div className="flex-1 min-w-0">
              <h3 className="text-sm font-bold text-slate-900">{fastestSalon.name}</h3>
              <p className="text-xs text-slate-500">📍 {fastestSalon.distanceKm} km · {fastestSalon.travelTimeMin} min drive</p>
              <div className="flex items-center gap-1 text-xs text-emerald-700 font-semibold mt-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                <span>Next slot: 11:20 AM</span>
              </div>
            </div>
            <button
              onClick={() => {
                bookSlot(fastestSalon.id, fastestSalon.slots[3]?.id || 'sl-4', fastestSalon.services[0].id);
                setSelectedSalon(fastestSalon);
                setConsumerScreen('confirmation');
              }}
              className="px-3.5 py-2 text-xs font-bold text-white bg-[#80142B] rounded-xl hover:bg-[#681023] shadow-xs"
            >
              Book 11:20
            </button>
          </div>
        </div>

      </div>
    </div>
  );
};
