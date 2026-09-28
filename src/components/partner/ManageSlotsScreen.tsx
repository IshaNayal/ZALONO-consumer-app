import React, { useState } from 'react';
import { ArrowLeft, Plus, Lock, Unlock, Check, AlertCircle } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { LiveSlot } from '../../types';

export const ManageSlotsScreen: React.FC = () => {
  const { setPartnerScreen, salons, updateSlotStatus, showNotification } = useZalono();
  const salon = salons[0];

  const [selectedDay, setSelectedDay] = useState(27);

  const days = [
    { num: 27, day: 'Mon', active: true },
    { num: 28, day: 'Tue' },
    { num: 29, day: 'Wed' },
    { num: 30, day: 'Thu' },
    { num: 1, day: 'Fri' }
  ];

  const handleToggle = (slot: LiveSlot) => {
    const nextStatus = slot.status === 'available' ? 'booked' : 'available';
    updateSlotStatus(salon.id, slot.id, nextStatus);
    showNotification(
      'Slot Updated',
      `${slot.time} slot is now marked as ${nextStatus.toUpperCase()}. Synced with customer app.`
    );
  };

  const handleAddManualSlot = () => {
    showNotification(
      'New Slot Added',
      'Manual slot 2:30 PM added and opened for online bookings.'
    );
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setPartnerScreen('dashboard')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Today's Availability</h1>
        <button
          onClick={handleAddManualSlot}
          className="p-1.5 text-[#80142B] hover:bg-rose-50 rounded-full"
        >
          <Plus className="w-5 h-5" />
        </button>
      </div>

      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6 space-y-4">
        {/* Horizontal Date Picker */}
        <div className="flex items-center justify-between gap-1.5 bg-white p-2 rounded-2xl border border-slate-200">
          {days.map((d) => (
            <button
              key={d.num}
              onClick={() => setSelectedDay(d.num)}
              className={`flex-1 py-2 rounded-xl text-center transition-all ${
                selectedDay === d.num
                  ? 'bg-slate-900 text-white font-bold shadow-xs'
                  : 'text-slate-600 hover:bg-slate-100'
              }`}
            >
              <span className="text-[10px] block uppercase">{d.day}</span>
              <span className="text-sm font-bold">{d.num}</span>
            </button>
          ))}
        </div>

        {/* Info Helper */}
        <p className="text-xs text-slate-500 px-1">
          Tap any slot toggle to instantly open or block it on the Zalono customer app in real time.
        </p>

        {/* Slots List */}
        <div className="grid gap-2 md:grid-cols-2">
          {salon.slots.map((slot) => {
            const isAvailable = slot.status === 'available';
            const isBooked = slot.status === 'booked';

            return (
              <div
                key={slot.id}
                className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between"
              >
                <div className="flex items-center gap-3">
                  <span className="text-sm font-bold text-slate-900 font-mono w-16">{slot.time}</span>
                  <div>
                    {isBooked ? (
                      <div>
                        <span className="text-xs font-bold text-slate-700">
                          Booked ({slot.stylistName || 'Stylist'})
                        </span>
                        {slot.customerName && (
                          <p className="text-[11px] text-slate-500">{slot.customerName} · {slot.serviceName}</p>
                        )}
                      </div>
                    ) : (
                      <span className="text-xs font-bold text-emerald-700 flex items-center gap-1">
                        <Check className="w-3.5 h-3.5" />
                        <span>Available Online</span>
                      </span>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleToggle(slot)}
                    className={`px-3 py-1.5 text-xs font-bold rounded-xl border transition-all ${
                      isAvailable
                        ? 'bg-emerald-50 text-emerald-800 border-emerald-300 hover:bg-emerald-100'
                        : 'bg-slate-100 text-slate-700 border-slate-300 hover:bg-slate-200'
                    }`}
                  >
                    {isAvailable ? 'Open' : 'Blocked'}
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        {/* Add Manual Slot Button */}
        <button
          onClick={handleAddManualSlot}
          className="w-full py-3 bg-white hover:bg-slate-50 border-2 border-dashed border-[#80142B] text-[#80142B] rounded-2xl font-bold text-xs flex items-center justify-center gap-2 transition-colors"
        >
          <Plus className="w-4 h-4" />
          <span>+ Add Manual Slot</span>
        </button>
      </div>
    </div>
  );
};
