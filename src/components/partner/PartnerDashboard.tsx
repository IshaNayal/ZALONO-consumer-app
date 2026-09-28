import React from 'react';
import { 
  Calendar, 
  IndianRupee, 
  Users, 
  Clock, 
  Store, 
  UserCheck, 
  PlusCircle, 
  TrendingUp, 
  MoreHorizontal,
  ChevronDown,
  Bell,
  Play,
  ArrowRight,
  Sparkles
} from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const PartnerDashboard: React.FC = () => {
  const { 
    setRole, 
    setPartnerScreen, 
    salons, 
    updateStylistStatus,
    incomingBookingNotification,
    showNotification 
  } = useZalono();

  const salon = salons[0]; // Looks Salon

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Partner App Bar */}
      <header className="px-5 pt-3 pb-3 flex items-center justify-between bg-white border-b border-slate-100">
        <div className="flex items-center gap-2">
          <span className="font-zalono text-xl font-bold tracking-tight text-[#80142B]">
            Zalono Partner
          </span>
          <button className="flex items-center gap-1 text-[11px] font-semibold text-slate-700 bg-slate-100 px-2 py-0.5 rounded-md">
            <span>Looks Salon</span>
            <ChevronDown className="w-3 h-3 text-slate-400" />
          </button>
        </div>

        <div className="flex items-center gap-1">
          <button
            onClick={() => setRole('consumer')}
            className="px-2 py-1 text-[11px] font-semibold text-slate-700 bg-slate-100 rounded-lg hover:bg-slate-200 transition-colors"
          >
            Customer View
          </button>
          <button 
            onClick={() => showNotification('Partner Alerts', 'All 4 styling stations are synced with live bookings.')}
            className="p-1.5 text-slate-600 hover:text-slate-900 rounded-full"
          >
            <Bell className="w-4 h-4" />
          </button>
        </div>
      </header>

      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6 space-y-4">
        {/* Salon Greeting & Status Banner */}
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-slate-500">Good morning!</p>
            <h1 className="text-lg font-bold text-slate-900">Today's Salon Status</h1>
          </div>
          <span className="flex items-center gap-1.5 px-2.5 py-1 text-[11px] font-bold text-emerald-800 bg-emerald-100 rounded-full border border-emerald-200">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>Open · Closes 9:00 PM</span>
          </span>
        </div>

        {/* Incoming Booking Notification Alert (if any) */}
        {incomingBookingNotification && (
          <div 
            onClick={() => setPartnerScreen('incoming_bookings')}
            className="p-3.5 bg-amber-500 text-white rounded-2xl shadow-md cursor-pointer hover:bg-amber-600 transition-all flex items-center justify-between animate-bounce"
          >
            <div className="flex items-center gap-2.5">
              <Bell className="w-5 h-5 text-white" />
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider bg-white/20 px-1 rounded">New Booking!</span>
                <p className="text-xs font-bold mt-0.5">{incomingBookingNotification.customerName} · {incomingBookingNotification.serviceName}</p>
              </div>
            </div>
            <span className="text-xs font-bold underline">Review (Accept/Reschedule) →</span>
          </div>
        )}

        {/* 4 Metric Cards Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-2.5">
          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <div className="flex items-center justify-between text-slate-500">
              <span className="text-xs font-semibold">Appointments</span>
              <Calendar className="w-4 h-4 text-[#80142B]" />
            </div>
            <div className="mt-2 flex items-baseline gap-2">
              <span className="text-2xl font-bold text-slate-900 font-mono">28</span>
              <span className="text-[10px] font-bold text-emerald-600">+4 vs yest</span>
            </div>
          </div>

          <div className="bg-[#F9E8EC] p-3.5 rounded-2xl border border-[#80142B]/30 shadow-xs">
            <div className="flex items-center justify-between text-[#80142B]">
              <span className="text-xs font-semibold">Expected Revenue</span>
              <IndianRupee className="w-4 h-4" />
            </div>
            <div className="mt-2 flex items-baseline gap-2">
              <span className="text-2xl font-bold text-[#80142B] font-mono">₹18,420</span>
              <span className="text-[10px] font-bold text-emerald-700 bg-emerald-100 px-1 rounded">+12%</span>
            </div>
          </div>

          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <div className="flex items-center justify-between text-slate-500">
              <span className="text-xs font-semibold">Walk-ins</span>
              <Users className="w-4 h-4 text-blue-600" />
            </div>
            <div className="mt-2 flex items-baseline gap-2">
              <span className="text-2xl font-bold text-slate-900 font-mono">{salon.queueCount}</span>
              <span className="text-[10px] text-slate-500">in live queue</span>
            </div>
          </div>

          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <div className="flex items-center justify-between text-slate-500">
              <span className="text-xs font-semibold">Available Slots</span>
              <Clock className="w-4 h-4 text-emerald-600" />
            </div>
            <div className="mt-2 flex items-baseline gap-2">
              <span className="text-2xl font-bold text-emerald-700 font-mono">4</span>
              <span className="text-[10px] text-slate-500">for today</span>
            </div>
          </div>
        </div>

        {/* Quick Operations Hub (6 Action Buttons) */}
        <div>
          <h2 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Salon Operations</h2>
          <div className="grid grid-cols-3 lg:grid-cols-6 gap-2">
            <button
              onClick={() => setPartnerScreen('manage_slots')}
              className="p-3 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 text-center flex flex-col items-center shadow-xs transition-colors"
            >
              <div className="w-9 h-9 rounded-xl bg-[#F9E8EC] text-[#80142B] flex items-center justify-center mb-1.5">
                <Clock className="w-4 h-4" />
              </div>
              <span className="text-[11px] font-bold text-slate-900">Manage Slots</span>
            </button>

            <button
              onClick={() => setPartnerScreen('staff')}
              className="p-3 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 text-center flex flex-col items-center shadow-xs transition-colors"
            >
              <div className="w-9 h-9 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center mb-1.5">
                <UserCheck className="w-4 h-4" />
              </div>
              <span className="text-[11px] font-bold text-slate-900">Staff Shift</span>
            </button>

            <button
              onClick={() => setPartnerScreen('walk_in')}
              className="p-3 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 text-center flex flex-col items-center shadow-xs transition-colors"
            >
              <div className="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center mb-1.5">
                <PlusCircle className="w-4 h-4" />
              </div>
              <span className="text-[11px] font-bold text-slate-900">Add Walk-in</span>
            </button>

            <button
              onClick={() => setPartnerScreen('during_service')}
              className="p-3 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 text-center flex flex-col items-center shadow-xs transition-colors"
            >
              <div className="w-9 h-9 rounded-xl bg-amber-50 text-amber-700 flex items-center justify-center mb-1.5">
                <Play className="w-4 h-4" />
              </div>
              <span className="text-[11px] font-bold text-slate-900">Live Service</span>
            </button>

            <button
              onClick={() => setPartnerScreen('crm')}
              className="p-3 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 text-center flex flex-col items-center shadow-xs transition-colors"
            >
              <div className="w-9 h-9 rounded-xl bg-purple-50 text-purple-700 flex items-center justify-center mb-1.5">
                <Users className="w-4 h-4" />
              </div>
              <span className="text-[11px] font-bold text-slate-900">Customer CRM</span>
            </button>

            <button
              onClick={() => setPartnerScreen('analytics')}
              className="p-3 bg-white hover:bg-slate-50 rounded-2xl border border-slate-200 text-center flex flex-col items-center shadow-xs transition-colors"
            >
              <div className="w-9 h-9 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center mb-1.5">
                <TrendingUp className="w-4 h-4" />
              </div>
              <span className="text-[11px] font-bold text-slate-900">Analytics</span>
            </button>
          </div>
        </div>

        {/* Live Staff Status Section */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-bold text-slate-900">Live Stylists Status</h2>
            <button
              onClick={() => setPartnerScreen('staff')}
              className="text-xs text-[#80142B] font-semibold hover:underline"
            >
              Manage Staff
            </button>
          </div>

          <div className="space-y-2.5">
            {salon.stylists.map((st) => (
              <div key={st.id} className="flex items-center justify-between p-2 rounded-xl bg-slate-50">
                <div className="flex items-center gap-2.5">
                  <img src={st.avatar} alt={st.name} className="w-8 h-8 rounded-full object-cover border" />
                  <div>
                    <span className="text-xs font-bold text-slate-900">{st.name}</span>
                    <p className="text-[10px] text-slate-500">{st.role}</p>
                  </div>
                </div>

                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => updateStylistStatus(st.id, st.status === 'available' ? 'with_customer' : 'available')}
                    className={`text-[10px] font-bold px-2.5 py-1 rounded-lg border transition-all ${
                      st.status === 'available'
                        ? 'bg-emerald-100 text-emerald-800 border-emerald-300'
                        : st.status === 'with_customer'
                        ? 'bg-amber-100 text-amber-800 border-amber-300'
                        : 'bg-slate-200 text-slate-600 border-slate-300'
                    }`}
                  >
                    {st.status === 'available' ? '🟢 Available' : st.status === 'with_customer' ? '✂️ With Customer' : '☕ On Break'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
};
