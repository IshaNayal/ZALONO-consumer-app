import React from 'react';
import { ArrowLeft, UserCheck, Clock, Plus, Star } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { Stylist } from '../../types';

export const StaffManagementModal: React.FC = () => {
  const { setPartnerScreen, salons, updateStylistStatus, showNotification } = useZalono();
  const salon = salons[0];

  const handleStatusChange = (st: Stylist, newStatus: Stylist['status']) => {
    updateStylistStatus(st.id, newStatus);
    showNotification(
      'Stylist Status Updated',
      `${st.name} is now marked as ${newStatus.replace('_', ' ').toUpperCase()}.`
    );
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setPartnerScreen('dashboard')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Staff Today</h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6 space-y-4">
        <p className="text-xs text-slate-600 bg-blue-50 border border-blue-200 p-2.5 rounded-xl">
          👥 <strong>Live Roster & Shifts:</strong> Toggle stylist availability or set breaks so online slot bookings sync dynamically without overbooking.
        </p>

        <div className="grid gap-3 md:grid-cols-2">
          {salon.stylists.map((st) => (
            <div key={st.id} className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs space-y-3">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <img src={st.avatar} alt={st.name} className="w-11 h-11 rounded-full object-cover border" />
                  <div>
                    <h3 className="text-sm font-bold text-slate-900">{st.name}</h3>
                    <p className="text-xs text-slate-500">{st.role}</p>
                    <div className="flex items-center gap-2 text-[11px] text-slate-600 mt-0.5">
                      <span className="flex items-center text-amber-600 font-semibold">
                        <Star className="w-3 h-3 fill-amber-500 mr-0.5" />
                        {st.rating}
                      </span>
                      <span>·</span>
                      <span>Shift: {st.shiftHours}</span>
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

              {/* Status Actions */}
              <div className="pt-2 border-t border-slate-100 flex items-center gap-2">
                <button
                  onClick={() => handleStatusChange(st, 'available')}
                  className={`flex-1 py-1.5 rounded-lg text-xs font-semibold border ${
                    st.status === 'available' ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 border-slate-200 text-slate-700'
                  }`}
                >
                  Available
                </button>
                <button
                  onClick={() => handleStatusChange(st, 'with_customer')}
                  className={`flex-1 py-1.5 rounded-lg text-xs font-semibold border ${
                    st.status === 'with_customer' ? 'bg-amber-600 text-white border-amber-600' : 'bg-slate-50 border-slate-200 text-slate-700'
                  }`}
                >
                  In Service
                </button>
                <button
                  onClick={() => handleStatusChange(st, 'break')}
                  className={`flex-1 py-1.5 rounded-lg text-xs font-semibold border ${
                    st.status === 'break' ? 'bg-slate-800 text-white border-slate-800' : 'bg-slate-50 border-slate-200 text-slate-700'
                  }`}
                >
                  Break
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
