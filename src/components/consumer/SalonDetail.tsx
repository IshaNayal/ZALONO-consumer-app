import React, { useState } from 'react';
import { 
  ArrowLeft, 
  Heart, 
  Share2, 
  Star, 
  CheckCircle, 
  Clock, 
  Navigation, 
  ShieldCheck, 
  Phone,
  MessageSquare
} from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { ServiceItem } from '../../types';

export const SalonDetail: React.FC = () => {
  const { 
    selectedSalon, 
    setConsumerScreen, 
    bookSlot,
    showNotification,
    currentLocation,
    getWhatsAppShareUrl 
  } = useZalono();

  const [activeTab, setActiveTab] = useState<'overview' | 'services' | 'stylists' | 'reviews'>('services');
  const [selectedService, setSelectedService] = useState<ServiceItem>(selectedSalon.services[0]);
  const [selectedHour, setSelectedHour] = useState<string>('11 AM');
  const [selectedSlotId, setSelectedSlotId] = useState<string>('sl-6'); // 11:40 AM recommended

  const hourTabs = ['10 AM', '11 AM', '12 PM', '1 PM', '2 PM'];

  const handleBook = (slotId: string) => {
    bookSlot(selectedSalon.id, slotId, selectedService.id);
    setConsumerScreen('confirmation');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-24">
      {/* Top Banner Image with Controls */}
      <div className="relative h-52 w-full bg-slate-900 shrink-0">
        <img
          src={selectedSalon.image}
          alt={selectedSalon.name}
          className="w-full h-full object-cover opacity-90"
        />
        <div className="absolute inset-0 bg-linear-to-t from-black/70 via-black/20 to-transparent"></div>
        
        {/* Floating Top Controls */}
        <div className="absolute top-3 left-4 right-4 flex items-center justify-between">
          <button
            onClick={() => setConsumerScreen('home')}
            className="w-9 h-9 rounded-full bg-white/80 backdrop-blur-md flex items-center justify-center text-slate-800 hover:bg-white shadow-xs"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          
          <div className="flex items-center gap-2">
            <button 
              onClick={() => showNotification('Saved to Favorites', `${selectedSalon.name} added to your favorite salons.`)}
              className="w-9 h-9 rounded-full bg-white/80 backdrop-blur-md flex items-center justify-center text-slate-800 hover:bg-white shadow-xs"
            >
              <Heart className="w-4 h-4 text-rose-600 fill-rose-600" />
            </button>
            <button 
              onClick={() => {
                navigator.clipboard.writeText(window.location.href);
                showNotification('Link Copied', 'Salon link copied to clipboard.');
              }}
              className="w-9 h-9 rounded-full bg-white/80 backdrop-blur-md flex items-center justify-center text-slate-800 hover:bg-white shadow-xs"
            >
              <Share2 className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Live Salon Busy Status Badge */}
        <div className="absolute bottom-3 left-4 right-4 flex items-center justify-between text-white text-xs">
          <div className="flex items-center gap-1.5 bg-black/60 backdrop-blur-md px-2.5 py-1 rounded-full border border-white/10">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            <span>Live: <strong>Quiet right now</strong> ({selectedSalon.availableStylistsCount} free)</span>
          </div>
          <span className="text-[11px] bg-white/20 backdrop-blur-md px-2 py-1 rounded-full">
            {selectedSalon.happyCustomersCount} visits
          </span>
        </div>
      </div>

      {/* Salon Basic Info Card */}
      <div className="bg-white px-5 pt-4 pb-3 border-b border-slate-200">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-xl font-bold text-slate-900">{selectedSalon.name}</h1>
            <div className="flex items-center gap-1.5 text-xs text-slate-600 mt-1">
              <span className="flex items-center font-bold text-amber-600">
                <Star className="w-3.5 h-3.5 fill-amber-500 mr-0.5" />
                {selectedSalon.rating}
              </span>
              <span>({selectedSalon.reviewsCount} reviews)</span>
              <span>·</span>
              <span>{selectedSalon.distanceKm} km</span>
              <span>·</span>
              <span className="flex items-center gap-0.5">
                <Navigation className="w-3 h-3 text-[#80142B]" />
                {selectedSalon.travelTimeMin} min from {currentLocation.name}
              </span>
            </div>
          </div>
          <span className="px-2.5 py-1 text-[11px] font-bold text-emerald-800 bg-emerald-100 rounded-full border border-emerald-200 shrink-0">
            {selectedSalon.openingHours}
          </span>
        </div>

        <div className="flex items-center gap-3 mt-3 text-xs text-slate-600">
          <span className="flex items-center gap-1 text-blue-700 font-semibold bg-blue-50 px-2 py-0.5 rounded">
            <ShieldCheck className="w-3.5 h-3.5" />
            Verified salon
          </span>
          <span className="text-slate-400">|</span>
          <span className="flex items-center gap-1">
            <Clock className="w-3 h-3 text-slate-400" />
            Expected wait: <strong className="text-slate-900">{selectedSalon.expectedWaitMin}</strong>
          </span>
        </div>

        {/* 4 Navigation Tabs */}
        <div className="grid grid-cols-4 gap-1 mt-4 pt-3 border-t border-slate-100 text-xs text-center font-semibold">
          {[
            { id: 'overview', label: 'Overview' },
            { id: 'services', label: 'Services' },
            { id: 'stylists', label: 'Stylists' },
            { id: 'reviews', label: 'Reviews' }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`py-1.5 border-b-2 transition-all ${
                activeTab === tab.id
                  ? 'border-[#80142B] text-[#80142B] font-bold'
                  : 'border-transparent text-slate-500 hover:text-slate-800'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      <div className="p-4 space-y-4">
        {activeTab === 'services' && (
          <div>
            <h2 className="text-sm font-bold text-slate-900 mb-2.5">Select Service</h2>
            <div className="space-y-2">
              {selectedSalon.services.map((srv) => {
                const isSelected = selectedService.id === srv.id;
                return (
                  <div
                    key={srv.id}
                    onClick={() => setSelectedService(srv)}
                    className={`p-3.5 rounded-2xl border transition-all cursor-pointer flex items-center justify-between ${
                      isSelected
                        ? 'bg-[#F9E8EC] border-[#80142B] shadow-xs'
                        : 'bg-white border-slate-200 hover:border-slate-300'
                    }`}
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className={`text-sm font-bold ${isSelected ? 'text-[#80142B]' : 'text-slate-900'}`}>
                          {srv.name}
                        </span>
                        <span className="text-[11px] text-slate-500">· {srv.durationMinutes} min</span>
                      </div>
                      {srv.description && (
                        <p className="text-xs text-slate-500 mt-0.5">{srv.description}</p>
                      )}
                    </div>
                    <div className="text-right">
                      <span className="text-sm font-bold text-slate-900 font-mono">₹{srv.price}</span>
                      <div className="mt-1">
                        <input
                          type="radio"
                          checked={isSelected}
                          onChange={() => setSelectedService(srv)}
                          className="accent-[#80142B]"
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {activeTab === 'stylists' && (
          <div>
            <h2 className="text-sm font-bold text-slate-900 mb-2.5">Available Stylists Today</h2>
            <div className="space-y-2.5">
              {selectedSalon.stylists.map((st) => (
                <div key={st.id} className="bg-white p-3 rounded-2xl border border-slate-200 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <img src={st.avatar} alt={st.name} className="w-11 h-11 rounded-full object-cover border" />
                    <div>
                      <h3 className="text-sm font-bold text-slate-900">{st.name}</h3>
                      <p className="text-xs text-slate-500">{st.role} · Shift: {st.shiftHours}</p>
                      <div className="flex items-center gap-1 text-[11px] text-amber-600 font-semibold mt-0.5">
                        <Star className="w-3 h-3 fill-amber-500" />
                        <span>{st.rating} rating</span>
                      </div>
                    </div>
                  </div>
                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full capitalize ${
                    st.status === 'available' ? 'bg-emerald-100 text-emerald-800' :
                    st.status === 'with_customer' ? 'bg-amber-100 text-amber-800' : 'bg-slate-100 text-slate-600'
                  }`}>
                    {st.status.replace('_', ' ')}
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'overview' && (
          <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3 text-xs text-slate-600">
            <p className="leading-relaxed">
              {selectedSalon.name} is an official partner of Zalono in {selectedSalon.area}, Bhubaneswar. Offering guaranteed zero wait time when booking live available slots.
            </p>
            <div className="p-3 bg-slate-50 rounded-xl space-y-1">
              <p><strong>Address:</strong> {selectedSalon.address}</p>
              <p><strong>Area:</strong> {selectedSalon.area}</p>
              <p><strong>Hours:</strong> {selectedSalon.openingHours}</p>
              <p><strong>Reception Phone:</strong> {selectedSalon.phone || '+91 00000 00000'}</p>
              <p><strong>UPI ID:</strong> {selectedSalon.upiId || 'zalono.pilot@icici'}</p>
            </div>
          </div>
        )}

        {activeTab === 'reviews' && (
          <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3">
            <div className="flex items-center justify-between border-b pb-2">
              <span className="text-sm font-bold text-slate-900">{selectedSalon.rating} out of 5 stars</span>
              <span className="text-xs text-slate-500">{selectedSalon.reviewsCount} verified reviews</span>
            </div>
            <div className="space-y-2 text-xs">
              {(selectedSalon.reviewsList || []).map((rev) => (
                <div key={rev.id} className="p-2.5 bg-slate-50 rounded-xl space-y-1">
                  <div className="flex items-center justify-between">
                    <strong className="text-slate-900">{rev.author}</strong>
                    <span className="text-amber-500 font-bold">{'★'.repeat(rev.rating)}</span>
                  </div>
                  <p className="text-slate-600">"{rev.comment}"</p>
                  <div className="flex items-center justify-between text-[10px] text-slate-400 pt-0.5">
                    <span>{rev.serviceName}</span>
                    <span className="text-emerald-700 font-semibold">Started on time: {rev.startedOnTime}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Live Availability Timeline Matrix */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-1.5">
              <Clock className="w-4 h-4 text-[#80142B]" />
              <h2 className="text-sm font-bold text-slate-900">Live Availability – Today</h2>
            </div>
            <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
              ● Live slots
            </span>
          </div>

          {/* Hour Tabs */}
          <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-1 text-xs">
            {hourTabs.map((hr) => (
              <button
                key={hr}
                onClick={() => setSelectedHour(hr)}
                className={`px-3 py-1.5 rounded-xl font-bold shrink-0 transition-colors ${
                  selectedHour === hr
                    ? 'bg-slate-900 text-white shadow-xs'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {hr}
              </button>
            ))}
          </div>

          {/* Slot Cards Grid */}
          <div className="grid grid-cols-4 gap-2 mt-3">
            {selectedSalon.slots
              .filter(s => s.hourGroup === selectedHour)
              .map((slot) => {
                const isSelected = selectedSlotId === slot.id;
                const isBooked = slot.status === 'booked';
                const isLimited = slot.status === 'limited';

                return (
                  <button
                    key={slot.id}
                    disabled={isBooked}
                    onClick={() => setSelectedSlotId(slot.id)}
                    className={`py-2 px-1 rounded-xl text-center border transition-all flex flex-col items-center justify-center ${
                      isBooked
                        ? 'bg-slate-100 border-slate-200 text-slate-400 opacity-60 cursor-not-allowed'
                        : isSelected
                        ? 'bg-[#80142B] border-[#80142B] text-white font-bold shadow-xs'
                        : slot.isRecommended
                        ? 'bg-emerald-50 border-emerald-300 text-emerald-900'
                        : isLimited
                        ? 'bg-amber-50 border-amber-300 text-amber-900'
                        : 'bg-white border-slate-200 text-slate-700 hover:border-slate-300'
                    }`}
                  >
                    <span className="text-xs font-bold">{slot.time}</span>
                    <span className={`text-[9px] mt-0.5 ${isSelected ? 'text-rose-100' : ''}`}>
                      {isBooked ? 'Booked' : isLimited ? 'Limited' : 'Available'}
                    </span>
                  </button>
                );
              })}
          </div>

          {/* Legend */}
          <div className="flex items-center justify-center gap-4 mt-3 pt-2 border-t border-slate-100 text-[10px] text-slate-500 font-medium">
            <span className="flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-emerald-500"></span> Available
            </span>
            <span className="flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-amber-500"></span> Limited
            </span>
            <span className="flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-slate-300"></span> Booked
            </span>
          </div>

          {/* Smart Buffer Recommendation Box */}
          <div className="mt-3.5 p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center gap-2.5">
            <CheckCircle className="w-5 h-5 text-emerald-600 shrink-0" />
            <div className="text-xs text-emerald-950">
              <div className="font-bold flex items-center gap-1">
                <span>Recommended: 11:40 AM</span>
                <span className="text-[10px] bg-emerald-600 text-white px-1.5 py-0.2 rounded font-normal">Optimal</span>
              </div>
              <p className="text-[11px] text-emerald-800 mt-0.5">
                {selectedSalon.travelTimeMin} min drive from {currentLocation.name} + 5 min arrival buffer ensures zero waiting.
              </p>
            </div>
          </div>
        </div>

      </div>

      {/* Sticky Bottom Dual CTA Bar */}
      <div className="fixed bottom-0 left-0 right-0 max-w-97.5 mx-auto bg-white/95 backdrop-blur-md p-3.5 border-t border-slate-200 shadow-xl z-30">
        <div className="grid grid-cols-2 gap-2.5">
          <button
            onClick={() => handleBook('sl-4')}
            className="py-2.5 px-2 border-2 border-[#80142B] text-[#80142B] rounded-xl font-bold text-xs hover:bg-rose-50 transition-colors text-center"
          >
            <div>Book 11:15 AM</div>
            <div className="text-[10px] font-normal">(Earliest slot)</div>
          </button>

          <button
            onClick={() => handleBook(selectedSlotId)}
            className="py-2.5 px-2 bg-[#80142B] text-white rounded-xl font-bold text-xs hover:bg-[#681023] transition-colors shadow-sm text-center"
          >
            <div>Book 11:40 AM</div>
            <div className="text-[10px] text-rose-200 font-normal">(Recommended)</div>
          </button>
        </div>
      </div>
    </div>
  );
};
