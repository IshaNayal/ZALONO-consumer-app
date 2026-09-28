import React, { useState } from 'react';
import { ArrowLeft, UserPlus, Clock, Scissors, UserCheck } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const AddWalkInModal: React.FC = () => {
  const { setPartnerScreen, addWalkIn, salons } = useZalono();
  const salon = salons[0];

  const [customerName, setCustomerName] = useState('Ankit Mehra');
  const [service, setService] = useState('Haircut');
  const [stylist, setStylist] = useState('Rahul');
  const [duration, setDuration] = useState(45);

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
            {salon.services.map(s => (
              <option key={s.id} value={s.name}>{s.name} (₹{s.price} · {s.durationMinutes}m)</option>
            ))}
          </select>
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
