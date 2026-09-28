import React, { useState } from 'react';
import { 
  Scissors, 
  Sparkles, 
  Smile, 
  MapPin, 
  ChevronDown, 
  Bell, 
  Store, 
  Star, 
  Clock, 
  Search, 
  Calendar, 
  User, 
  Compass, 
  Zap, 
  ArrowRight,
  Flame
} from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { ServiceCategory, TimePreference } from '../../types';

export const ConsumerHome: React.FC = () => {
  const { 
    setRole, 
    setConsumerScreen, 
    salons, 
    setSelectedSalon, 
    selectedCategory, 
    setSelectedCategory, 
    activeBooking,
    bookSlot,
    currentLocation,
    showNotification
  } = useZalono();

  const [activeTimeFilter, setActiveTimeFilter] = useState<TimePreference>('now');
  const [aiSearchInput, setAiSearchInput] = useState('');

  const categories: { label: ServiceCategory; icon: React.ReactNode }[] = [
    { label: 'Haircut', icon: <Scissors className="w-5 h-5" /> },
    { label: 'Hair Color', icon: <Sparkles className="w-5 h-5" /> },
    { label: 'Facial', icon: <Smile className="w-5 h-5" /> },
    { label: 'Beard', icon: <Scissors className="w-5 h-5 rotate-90" /> },
    { label: 'Hair Spa', icon: <Sparkles className="w-5 h-5" /> },
    { label: 'Manicure', icon: <Sparkles className="w-5 h-5" /> },
    { label: 'Pedicure', icon: <Sparkles className="w-5 h-5" /> },
    { label: 'More', icon: <Store className="w-5 h-5" /> },
  ];

  const handleSelectCategory = (cat: ServiceCategory) => {
    setSelectedCategory(cat);
    setConsumerScreen('service_time');
  };

  const handleQuickBook = (salonId: string, slotId: string, serviceId: string) => {
    bookSlot(salonId, slotId, serviceId);
    setConsumerScreen('confirmation');
  };

  const handleAiSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (!aiSearchInput.trim()) return;
    showNotification(
      'AI Slot Match Found ⚡',
      `Found 3 open slots in ${currentLocation.name} matching "${aiSearchInput}" with zero waiting!`,
      'View Match',
      () => setConsumerScreen('salon_list')
    );
    setAiSearchInput('');
  };

  return (
    <div className="flex-1 flex flex-col pb-20 bg-[#FAF9F6]">
      {/* Top Header */}
      <header className="px-5 pt-3 pb-3 flex items-center justify-between bg-white border-b border-slate-100">
        <div className="flex items-center gap-2.5">
          <span className="font-zalono text-2xl font-bold tracking-tight text-[#80142B]">
            Zalono
          </span>
          {/* Location Trigger */}
          <button 
            onClick={() => setConsumerScreen('location_picker')}
            className="flex items-center gap-1 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 px-2.5 py-1 rounded-full transition-colors border border-slate-200/60"
            title="Change pilot area in Bhubaneswar"
          >
            <MapPin className="w-3 h-3 text-[#80142B]" />
            <span className="max-w-25 truncate">{currentLocation.name}</span>
            <ChevronDown className="w-3 h-3 text-slate-500" />
          </button>
        </div>

        <div className="flex items-center gap-1">
          {/* Switch to Partner Role */}
          <button
            onClick={() => setRole('partner')}
            className="px-2 py-1 text-[11px] font-semibold text-[#80142B] bg-[#F9E8EC] rounded-lg hover:bg-[#f3d0d8] transition-colors"
            title="Switch to Salon Owner / Partner App"
          >
            Partner App
          </button>
          <button 
            onClick={() => showNotification('Notifications', 'Pilot Beta: Zero-wait monitoring active for Bhubaneswar.')}
            className="p-2 text-slate-600 hover:text-slate-900 rounded-full hover:bg-slate-100 transition-colors"
          >
            <Bell className="w-4 h-4" />
          </button>
        </div>
      </header>

      {/* Main Content Body */}
      <div className="w-full max-w-6xl mx-auto px-4 sm:px-6 pt-4 pb-6 space-y-4">
        
        {/* User Greeting */}
        <div>
          <p className="text-xs font-medium text-slate-500">Good morning, Jay 👋</p>
          <h1 className="text-lg font-bold text-slate-900 tracking-tight mt-0.5">
            What do you need today?
          </h1>
        </div>

        {/* AI Natural Language Slot Finder */}
        <form onSubmit={handleAiSearch} className="relative">
          <input
            type="text"
            value={aiSearchInput}
            onChange={(e) => setAiSearchInput(e.target.value)}
            placeholder="AI Slot Finder: 'Haircut tomorrow after 6 near Patia'..."
            className="w-full text-xs pl-8 pr-16 py-2.5 bg-white border border-slate-200 rounded-xl shadow-xs focus:outline-none focus:ring-1 focus:ring-[#80142B] focus:border-[#80142B]"
          />
          <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-3" />
          <button
            type="submit"
            className="absolute right-1.5 top-1.5 px-2.5 py-1 text-[10px] font-bold bg-[#80142B] text-white rounded-lg hover:bg-[#681023]"
          >
            Find
          </button>
        </form>

        {/* Service Categories Grid */}
        <div className="grid grid-cols-4 md:grid-cols-8 gap-2.5">
          {categories.map((cat) => {
            const isSelected = selectedCategory === cat.label;
            return (
              <button
                key={cat.label}
                onClick={() => handleSelectCategory(cat.label)}
                className={`flex flex-col items-center justify-center p-2.5 rounded-2xl border transition-all ${
                  isSelected 
                    ? 'bg-[#F9E8EC] border-[#80142B] text-[#80142B] shadow-xs' 
                    : 'bg-white border-slate-200/80 text-slate-700 hover:border-slate-300'
                }`}
              >
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${isSelected ? 'bg-white text-[#80142B]' : 'bg-slate-50 text-slate-600'}`}>
                  {cat.icon}
                </div>
                <span className="text-[11px] font-semibold mt-1.5 whitespace-nowrap">{cat.label}</span>
              </button>
            );
          })}
        </div>

        {/* When do you want to go? selector */}
        <div className="bg-white p-3.5 rounded-2xl border border-slate-200/80 shadow-xs">
          <div className="flex items-center justify-between mb-2.5">
            <span className="text-xs font-bold text-slate-900">When do you want to go?</span>
            <button
              onClick={() => setConsumerScreen('book_by_time')}
              className="text-[11px] font-semibold text-[#80142B] hover:underline flex items-center gap-0.5"
            >
              <span>Reverse Search</span>
              <ArrowRight className="w-3 h-3" />
            </button>
          </div>
          
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-1.5">
            {[
              { id: 'now', label: '⚡ Now', sub: 'Fastest' },
              { id: '30min', label: '30 min', sub: 'On the way' },
              { id: 'later_today', label: 'Today', sub: 'After work' },
              { id: 'tomorrow', label: 'Tomorrow', sub: 'Planned' }
            ].map((t) => (
              <button
                key={t.id}
                onClick={() => {
                  setActiveTimeFilter(t.id as TimePreference);
                  setConsumerScreen('salon_list');
                }}
                className={`py-2 px-1 text-center rounded-xl border text-xs transition-all ${
                  activeTimeFilter === t.id
                    ? 'bg-[#80142B] border-[#80142B] text-white font-bold shadow-xs'
                    : 'bg-slate-50 border-slate-200 text-slate-700 font-medium hover:bg-slate-100'
                }`}
              >
                <div>{t.label}</div>
              </button>
            ))}
          </div>
        </div>

        {/* Live Active Booking Bar */}
        {activeBooking && activeBooking.status !== 'completed' && (
          <div 
            onClick={() => setConsumerScreen('live_appointment')}
            className="p-3.5 bg-linear-to-r from-emerald-500 to-teal-600 text-white rounded-2xl shadow-md cursor-pointer hover:opacity-95 transition-all flex items-center justify-between"
          >
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center backdrop-blur-xs">
                <Clock className="w-5 h-5 text-white animate-pulse" />
              </div>
              <div>
                <div className="flex items-center gap-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider bg-white/25 px-1.5 py-0.5 rounded">Live Queue</span>
                  <span className="text-xs font-semibold">Position: {activeBooking.queuePosition}</span>
                </div>
                <p className="text-xs font-bold mt-0.5">{activeBooking.salonName} · {activeBooking.slotTime}</p>
              </div>
            </div>
            <div className="text-right">
              <span className="text-[11px] font-bold underline">Track Live →</span>
            </div>
          </div>
        )}

        {/* "Your usual salon" Rebook Card */}
        <div className="bg-white p-3.5 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img
              src={salons[0].image}
              alt={salons[0].name}
              className="w-12 h-12 rounded-xl object-cover border border-slate-200"
            />
            <div>
              <span className="text-[10px] font-semibold uppercase tracking-wider text-slate-400">Your Usual Salon</span>
              <h2 className="text-sm font-bold text-slate-900 leading-snug">{salons[0].name}</h2>
              <div className="flex items-center gap-1.5 text-xs text-slate-600 mt-0.5">
                <span className="flex items-center text-amber-600 font-semibold">
                  <Star className="w-3 h-3 fill-amber-500 text-amber-500 mr-0.5" />
                  {salons[0].rating}
                </span>
                <span>·</span>
                <span>{salons[0].distanceKm} km</span>
                <span>·</span>
                <span className="text-emerald-700 font-semibold">Next: {salons[0].nextSlotTime}</span>
              </div>
            </div>
          </div>
          <button
            onClick={() => {
              setSelectedSalon(salons[0]);
              setConsumerScreen('salon_detail');
            }}
            className="px-3 py-1.5 text-xs font-bold text-white bg-[#80142B] rounded-xl hover:bg-[#681023] shadow-xs shrink-0"
          >
            Book Again
          </button>
        </div>

        {/* Last-Minute Slots Banner */}
        <div 
          onClick={() => setConsumerScreen('last_minute')}
          className="p-3 bg-amber-50 border border-amber-200 rounded-2xl flex items-center justify-between cursor-pointer hover:bg-amber-100/60 transition-colors"
        >
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-amber-500 text-white flex items-center justify-center font-bold text-xs">
              <Flame className="w-4 h-4" />
            </div>
            <div>
              <p className="text-xs font-bold text-amber-950">Last-Minute Openings</p>
              <p className="text-[11px] text-amber-800">Slots opening in next 90 min near {currentLocation.name}</p>
            </div>
          </div>
          <span className="text-xs font-bold text-amber-900">View →</span>
        </div>

        {/* Available Salons Near You */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <div>
              <h2 className="text-sm font-bold text-slate-900">Available near {currentLocation.name}</h2>
              <p className="text-[11px] text-slate-500">Real-time slots with live traffic buffers</p>
            </div>
            <button 
              onClick={() => setConsumerScreen('salon_list')}
              className="text-xs font-semibold text-[#80142B] hover:underline"
            >
              See all ({salons.length})
            </button>
          </div>

          <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
            {salons.map((salon) => (
              <div 
                key={salon.id}
                className="bg-white p-3.5 rounded-2xl border border-slate-200/90 shadow-xs hover:border-slate-300 transition-all"
              >
                {/* Live Status Header */}
                <div className="flex items-center justify-between pb-2 border-b border-slate-100 text-xs">
                  <div className="flex items-center gap-1.5">
                    <span className="inline-block w-2 h-2 rounded-full bg-emerald-500"></span>
                    <span className="font-semibold text-emerald-700">Available now</span>
                  </div>
                  <span className="text-[11px] text-slate-500 font-medium">
                    Expected wait: <strong className="text-slate-800">{salon.expectedWaitMin}</strong>
                  </span>
                </div>

                {/* Card Body */}
                <div className="flex items-center gap-3 pt-2.5">
                  <img
                    src={salon.image}
                    alt={salon.name}
                    className="w-16 h-16 rounded-xl object-cover border border-slate-100 shrink-0"
                  />
                  <div className="flex-1 min-w-0">
                    <h3 className="text-sm font-bold text-slate-900 truncate">{salon.name}</h3>
                    <div className="flex items-center gap-1 text-[11px] text-slate-500 mt-0.5">
                      <span className="flex items-center font-bold text-amber-600">
                        <Star className="w-3 h-3 fill-amber-500 text-amber-500 mr-0.5" />
                        {salon.rating}
                      </span>
                      <span>({salon.reviewsCount})</span>
                      <span>·</span>
                      <span>{salon.distanceKm} km</span>
                      <span>·</span>
                      <span>{salon.travelTimeMin} min drive</span>
                    </div>
                    <div className="text-xs font-semibold text-slate-800 mt-1">
                      Haircut · ₹{salon.priceStart} · 45 min
                    </div>
                  </div>
                </div>

                {/* Next Slot Quick Action */}
                <div className="mt-3 pt-2 border-t border-slate-100 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] text-slate-400 font-medium block">Earliest Slot</span>
                    <span className="text-xs font-bold text-slate-900">{salon.nextSlotTime}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => {
                        setSelectedSalon(salon);
                        setConsumerScreen('salon_detail');
                      }}
                      className="px-3 py-1.5 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors"
                    >
                      Details
                    </button>
                    <button
                      onClick={() => handleQuickBook(salon.id, salon.slots[3]?.id || 'sl-4', salon.services[0].id)}
                      className="px-3 py-1.5 text-xs font-bold text-white bg-[#80142B] hover:bg-[#681023] rounded-xl shadow-xs transition-colors"
                    >
                      Book {salon.nextSlotTime}
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>

      {/* Fixed Bottom Navigation Bar (Consumer) */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-md border-t border-slate-200 z-30 shadow-lg">
        <div className="w-full max-w-6xl mx-auto py-2 px-4 sm:px-6 flex items-center justify-between">
        <button 
          onClick={() => setConsumerScreen('home')}
          className="flex flex-col items-center text-[#80142B]"
        >
          <Store className="w-5 h-5 stroke-[2.2]" />
          <span className="text-[10px] font-bold mt-1">Home</span>
        </button>

        <button 
          onClick={() => setConsumerScreen('salon_list')}
          className="flex flex-col items-center text-slate-400 hover:text-slate-800 transition-colors"
        >
          <Compass className="w-5 h-5" />
          <span className="text-[10px] font-medium mt-1">Explore</span>
        </button>

        <button 
          onClick={() => setConsumerScreen('bookings')}
          className="flex flex-col items-center text-slate-400 hover:text-slate-800 transition-colors"
        >
          <Calendar className="w-5 h-5" />
          <span className="text-[10px] font-medium mt-1">Bookings</span>
        </button>

        <button 
          onClick={() => setConsumerScreen('profile')}
          className="flex flex-col items-center text-slate-400 hover:text-slate-800 transition-colors"
        >
          <User className="w-5 h-5" />
          <span className="text-[10px] font-medium mt-1">Profile</span>
        </button>
        </div>
      </nav>
    </div>
  );
};
