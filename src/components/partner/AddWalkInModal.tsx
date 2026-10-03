import React, { useState, useMemo } from 'react';
import { ArrowLeft, UserPlus, Clock, Scissors, UserCheck, Sparkles, ChevronDown } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { ServiceItem } from '../../types';

const DUMMY_SERVICES: ServiceItem[] = [
  { id: 'd_beard', name: 'Beard Sculpt & Hot Towel Shape', price: 349, durationMinutes: 30, category: 'Beard', description: 'Razor edge detailing' },
  { id: 'd_massage', name: 'Head & Shoulder Stress-Relief Massage', price: 449, durationMinutes: 35, category: 'Head Massage', description: 'Warm herbal oil relaxation' },
  { id: 'd_color', name: 'Hair Color & Highlights', price: 1299, durationMinutes: 90, category: 'Hair Color', description: 'Ammonia-free global color' },
  { id: 'd_pedicure', name: 'Deluxe Pedicure & Foot Reflexology', price: 799, durationMinutes: 50, category: 'Pedicure', description: 'Soak & foot massage' },
  { id: 'd_manicure', name: 'Classic Hand Spa & Manicure', price: 549, durationMinutes: 40, category: 'Manicure', description: 'Nail shaping & massage' },
  { id: 'd_cleanse', name: 'Deep Cleanse Charcoal Facial', price: 799, durationMinutes: 50, category: 'Facial', description: 'Charcoal mask & skin revival' },
  { id: 'd_keratin', name: 'Keratin Express Smoothening', price: 1899, durationMinutes: 90, category: 'Hair Spa', description: 'Frizz-free smoothness' },
];

export const AddWalkInModal: React.FC = () => {
  const { setPartnerScreen, addWalkIn, salons } = useZalono();
  const salon = salons[0];

  const [customerName, setCustomerName] = useState('Ankit Mehra');
  const [service, setService] = useState('Haircut');
  const [stylist, setStylist] = useState('Rahul');
  const [duration, setDuration] = useState(45);
  const [showAllServices, setShowAllServices] = useState(false);

  const allAvailableServices = useMemo(() => {
    const base = salon?.services || [];
    if (!showAllServices) return base;
    const baseNames = new Set(base.map(s => s.name.toLowerCase().trim()));
    const extra = DUMMY_SERVICES.filter(d => !baseNames.has(d.name.toLowerCase().trim()));
    return [...base, ...extra];
  }, [salon, showAllServices]);

  const handleAdd = () => {
    addWalkIn(customerName, service, stylist, duration);
    setPartnerScreen('dashboard');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6]">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setPartnerScreen('dashboard')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Add Walk-in Customer</h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-2xl mx-auto p-5 sm:px-6 space-y-4">
        <div className="space-y-1">
          <label className="text-xs font-bold text-slate-700">Customer Name</label>
          <input
            type="text"
            value={customerName}
            onChange={(e) => setCustomerName(e.target.value)}
            className="w-full text-xs p-3 bg-white border border-slate-200 rounded-xl focus:ring-1 focus:ring-[#80142B] focus:outline-none"
            placeholder="e.g. Walk-in Customer"
          />
        </div>

        <div className="space-y-1">
          <label className="text-xs font-bold text-slate-700">Select Service</label>
          <select
            value={service}
            onChange={(e) => setService(e.target.value)}
            className="w-full text-xs p-3 bg-white border border-slate-200 rounded-xl focus:outline-none"
          >
            {allAvailableServices.map(s => (
              <option key={s.id} value={s.name}>{s.name} ({s.category} · ₹{s.price} · {s.durationMinutes}m)</option>
            ))}
          </select>

          {/* Explore More Services Bar */}
          <button
            type="button"
            onClick={() => setShowAllServices(!showAllServices)}
            className="w-full mt-2 p-2.5 bg-white border border-rose-200 hover:border-[#80142B] rounded-xl flex items-center justify-between text-left transition-all shadow-xs cursor-pointer"
          >
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded-lg bg-[#F9E8EC] flex items-center justify-center text-[#80142B]">
                <Sparkles className="w-3.5 h-3.5" />
              </div>
              <div>
                <span className="text-[11px] font-bold text-slate-900 block">Explore More Services</span>
                <span className="text-[10px] text-slate-500">
                  {showAllServices ? 'All treatments visible' : '+5 more dummy & specialty services'}
                </span>
              </div>
            </div>
            <div className="flex items-center gap-1 text-[11px] font-bold text-[#80142B]">
              <span>{showAllServices ? 'Less' : 'More'}</span>
              <ChevronDown className={`w-3.5 h-3.5 transition-transform duration-200 ${showAllServices ? 'rotate-180' : ''}`} />
            </div>
          </button>
        </div>

        <div className="space-y-1">
          <label className="text-xs font-bold text-slate-700">Assign Stylist</label>
          <select
            value={stylist}
            onChange={(e) => setStylist(e.target.value)}
            className="w-full text-xs p-3 bg-white border border-slate-200 rounded-xl focus:outline-none"
          >
            <option value="Any available">Any Available Stylist</option>
            {salon.stylists.map(st => (
              <option key={st.id} value={st.name}>{st.name} ({st.role})</option>
            ))}
          </select>
        </div>

        <div className="space-y-1">
          <label className="text-xs font-bold text-slate-700">Estimated Duration</label>
          <div className="flex items-center justify-between p-3 bg-white border border-slate-200 rounded-xl">
            <span className="text-xs font-bold text-slate-900">{duration} minutes</span>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setDuration(Math.max(15, duration - 15))}
                className="w-7 h-7 bg-slate-100 rounded-lg flex items-center justify-center font-bold text-slate-700 hover:bg-slate-200"
              >
                -
              </button>
              <button
                type="button"
                onClick={() => setDuration(duration + 15)}
                className="w-7 h-7 bg-slate-100 rounded-lg flex items-center justify-center font-bold text-slate-700 hover:bg-slate-200"
              >
                +
              </button>
            </div>
          </div>
        </div>

        <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl text-xs text-amber-900 leading-relaxed">
          ℹ️ <strong>Auto-Sync Queue:</strong> Walk-ins are instantly added to your live queue so online customer wait times and availability adjust automatically.
        </div>

        <div className="pt-4">
          <button
            onClick={handleAdd}
            className="w-full py-3 bg-[#80142B] text-white rounded-xl font-bold text-xs hover:bg-[#681023] shadow-md transition-colors"
          >
            Add Walk-in & Update Live Queue
          </button>
        </div>
      </div>
    </div>
  );
};
