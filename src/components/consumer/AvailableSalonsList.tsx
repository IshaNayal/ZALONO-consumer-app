import React, { useState } from 'react';
import { ArrowLeft, Star, ChevronDown, Check, SlidersHorizontal, Navigation } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { Salon } from '../../types';

export const AvailableSalonsList: React.FC = () => {
  const { 
    salons, 
    setConsumerScreen, 
    setSelectedSalon, 
    selectedCategory,
    bookSlot 
  } = useZalono();

  const [activeFilter, setActiveFilter] = useState<'available_now' | 'top_rated'>('available_now');

  const filteredSalons = [...salons].sort((a, b) => {
    if (activeFilter === 'top_rated') return b.rating - a.rating;
    return a.travelTimeMin - b.travelTimeMin;
  });

  const handleBook = (salon: Salon, slotId: string, _slotTime: string) => {
    setSelectedSalon(salon);
    bookSlot(salon.id, slotId, salon.services[0].id);
    setConsumerScreen('confirmation');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <div className="flex items-center gap-3">
          <button
            onClick={() => setConsumerScreen('home')}
            className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <span className="text-base font-bold text-slate-900">{selectedCategory} · Now</span>
        </div>
        <button 
          onClick={() => setConsumerScreen('book_by_time')}
          className="text-xs font-semibold text-[#80142B] flex items-center gap-1"
        >
          <SlidersHorizontal className="w-3.5 h-3.5" />
          <span>Filters</span>
        </button>
      </div>

      {/* Filter Row */}
      <div className="px-4 py-2.5 bg-white border-b border-slate-100 flex items-center gap-2 overflow-x-auto no-scrollbar text-xs">
        <button className="flex items-center gap-1 px-2.5 py-1 rounded-lg border border-slate-200 text-slate-700 font-medium shrink-0">
          <span>Sort</span>
          <ChevronDown className="w-3 h-3 text-slate-400" />
        </button>
        <button className="flex items-center gap-1 px-2.5 py-1 rounded-lg border border-slate-200 text-slate-700 font-medium shrink-0">
          <span>Distance</span>
          <ChevronDown className="w-3 h-3 text-slate-400" />
        </button>
        <button className="flex items-center gap-1 px-2.5 py-1 rounded-lg border border-slate-200 text-slate-700 font-medium shrink-0">
          <span>Price</span>
          <ChevronDown className="w-3 h-3 text-slate-400" />
        </button>
        <button 
          onClick={() => setActiveFilter('available_now')}
          className={`flex items-center gap-1 px-2.5 py-1 rounded-lg font-semibold shrink-0 transition-colors ${
            activeFilter === 'available_now' 
              ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' 
              : 'border border-slate-200 text-slate-600'
          }`}
        >
          <Check className="w-3 h-3" />
          <span>Available now</span>
        </button>
        <button 
          onClick={() => setActiveFilter('top_rated')}
          className={`flex items-center gap-1 px-2.5 py-1 rounded-lg font-semibold shrink-0 transition-colors ${
            activeFilter === 'top_rated' 
              ? 'bg-[#F9E8EC] text-[#80142B] border border-[#80142B]' 
              : 'border border-slate-200 text-slate-600'
          }`}
        >
          <span>Top rated</span>
        </button>
      </div>

      {/* Salons list with Smart Slots */}
      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6">
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {filteredSalons.map((salon, index) => (
          <div
            key={salon.id}
            className="bg-white rounded-2xl border border-slate-200/90 p-4 shadow-xs"
          >
            {/* Header info */}
            <div className="flex items-center justify-between pb-2 border-b border-slate-100">
              <div className="flex items-center gap-1.5 text-xs text-emerald-700 font-bold">
                <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
                <span>Available at {salon.nextSlotTime}</span>
              </div>
              {index === 0 && (
                <span className="text-[10px] font-bold text-amber-700 bg-amber-100 px-1.5 py-0.5 rounded">
                  Best match
                </span>
              )}
            </div>

            {/* Salon Details */}
            <div className="flex items-start gap-3 py-3">
              <img
                src={salon.image}
                alt={salon.name}
                className="w-16 h-16 rounded-xl object-cover shrink-0 border border-slate-100"
              />
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <h2 className="text-sm font-bold text-slate-900">{salon.name}</h2>
                </div>
                <div className="flex items-center gap-1 text-xs text-slate-500 mt-0.5">
                  <span className="flex items-center text-amber-600 font-bold">
                    <Star className="w-3 h-3 fill-amber-500 mr-0.5" />
                    {salon.rating}
                  </span>
                  <span>({salon.reviewsCount})</span>
                  <span>·</span>
                  <span>{salon.distanceKm} km</span>
                  <span>·</span>
                  <span className="flex items-center gap-0.5 text-slate-700 font-medium">
                    <Navigation className="w-2.5 h-2.5" />
                    {salon.travelTimeMin} min away
                  </span>
                </div>
                <div className="text-xs font-semibold text-slate-800 mt-1">
                  ₹{salon.priceStart} · 45 min
                </div>
              </div>
            </div>

            {/* Smart Slots Section: Earliest vs Recommended */}
            <div className="pt-2 border-t border-slate-100">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-2">
                Smart Slot Selection (Traffic Aware)
              </span>
              <div className="grid grid-cols-2 gap-2">
                {/* Earliest Slot */}
                <div className="p-2.5 bg-slate-50 border border-slate-200 rounded-xl flex flex-col justify-between">
                  <div>
                    <span className="text-[10px] text-slate-500 block">Earliest you can make</span>
                    <span className="text-xs font-bold text-slate-900">{salon.slots[3]?.time || '11:30 AM'}</span>
                  </div>
                  <button
                    onClick={() => handleBook(salon, salon.slots[3]?.id || 'sl-4', salon.slots[3]?.time || '11:30 AM')}
                    className="mt-2 w-full py-1.5 text-xs font-bold text-[#80142B] bg-white border border-[#80142B] rounded-lg hover:bg-rose-50 transition-colors"
                  >
                    Book {salon.slots[3]?.time || '11:30'}
                  </button>
                </div>

                {/* Recommended Slot with buffer */}
                <div className="p-2.5 bg-[#F9E8EC] border border-[#80142B]/30 rounded-xl flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] text-[#80142B] font-bold">Recommended</span>
                      <span className="text-[9px] bg-emerald-600 text-white px-1 rounded font-bold">+5m buffer</span>
                    </div>
                    <span className="text-xs font-bold text-[#80142B]">{salon.slots[5]?.time || '11:40 AM'}</span>
                  </div>
                  <button
                    onClick={() => handleBook(salon, salon.slots[5]?.id || 'sl-6', salon.slots[5]?.time || '11:40 AM')}
                    className="mt-2 w-full py-1.5 text-xs font-bold text-white bg-[#80142B] rounded-lg hover:bg-[#681023] transition-colors shadow-xs"
                  >
                    Book {salon.slots[5]?.time || '11:40'}
                  </button>
                </div>
              </div>
            </div>

            {/* View Full Timeline Button */}
            <button
              onClick={() => {
                setSelectedSalon(salon);
                setConsumerScreen('salon_detail');
              }}
              className="mt-3 w-full py-2 text-xs font-semibold text-slate-600 hover:text-slate-900 bg-slate-50 hover:bg-slate-100 rounded-xl text-center transition-colors"
            >
              View Full Availability Timeline & Stylists →
            </button>
          </div>
        ))}
        </div>
      </div>
    </div>
  );
};
