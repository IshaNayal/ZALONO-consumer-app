import React from 'react';
import { ArrowLeft, Bell, Check, RotateCcw, User, Phone, Scissors, Calendar } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const IncomingBookingModal: React.FC = () => {
  const { 
    setPartnerScreen, 
    dismissIncomingNotification, 
    showNotification,
    bookings 
  } = useZalono();

  const handleAccept = () => {
    dismissIncomingNotification();
    showNotification(
      'Booking Accepted',
      'Isha  has been notified that his 11:30 AM appointment is confirmed.'
    );
    setPartnerScreen('dashboard');
  };

  const handleReschedule = () => {
    dismissIncomingNotification();
    showNotification(
      'Reschedule Prompt Sent',
      'Alternative slot options sent to Isha.'
    );
    setPartnerScreen('dashboard');
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
        <h1 className="text-base font-bold text-slate-900">Incoming Bookings</h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6 space-y-4">
        {/* Urgent New Booking Card */}
        <div className="bg-white p-4 rounded-2xl border-2 border-[#80142B] shadow-md space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-[#80142B] flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#80142B] animate-ping"></span>
              <span>New Booking Alert! 🎉</span>
            </span>
            <span className="text-[10px] text-slate-400">Just now</span>
          </div>

          <div className="flex items-start gap-3 pt-1">
            <div className="w-12 h-12 rounded-full bg-[#F9E8EC] text-[#80142B] flex items-center justify-center font-bold text-lg">
              J
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-sm font-bold text-slate-900">Isha </h2>
                <span className="text-[10px] bg-blue-100 text-blue-800 px-1.5 py-0.2 rounded font-semibold">New Client</span>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">+91 00000 00000</p>
            </div>
          </div>

          <div className="p-3 bg-slate-50 rounded-xl space-y-1.5 text-xs text-slate-700">
            <div className="flex items-center justify-between">
              <span>Service:</span>
              <strong className="text-slate-900">Haircut (45 min)</strong>
            </div>
            <div className="flex items-center justify-between">
              <span>Requested Time:</span>
              <strong className="text-slate-900">Today, 11:30 AM</strong>
            </div>
            <div className="flex items-center justify-between">
              <span>Assigned Stylist:</span>
              <strong className="text-[#80142B]">Rahul (Senior Stylist)</strong>
            </div>
            <div className="flex items-center justify-between">
              <span>Bill Amount:</span>
              <strong className="text-emerald-700 font-bold">₹399 (Pay at salon)</strong>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2 pt-2">
            <button
              onClick={handleReschedule}
              className="py-2.5 px-3 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-bold text-xs flex items-center justify-center gap-1"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Reschedule</span>
            </button>
            <button
              onClick={handleAccept}
              className="py-2.5 px-3 bg-[#80142B] hover:bg-[#681023] text-white rounded-xl font-bold text-xs flex items-center justify-center gap-1 shadow-xs"
            >
              <Check className="w-3.5 h-3.5" />
              <span>Accept</span>
            </button>
          </div>
        </div>

        {/* Upcoming Day Bookings list */}
        <div>
          <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Upcoming Today</h3>
          <div className="grid gap-2 md:grid-cols-2">
            <div className="p-3 bg-white rounded-xl border border-slate-200 flex items-center justify-between text-xs">
              <div>
                <span className="font-bold text-slate-900">12:15 PM · Facial Glow</span>
                <p className="text-slate-500">Stylist: Priya · Client: Ananya</p>
              </div>
              <span className="text-emerald-700 font-bold bg-emerald-50 px-2 py-0.5 rounded">Confirmed</span>
            </div>

            <div className="p-3 bg-white rounded-xl border border-slate-200 flex items-center justify-between text-xs">
              <div>
                <span className="font-bold text-slate-900">01:00 PM · Haircut + Beard</span>
                <p className="text-slate-500">Stylist: Amit · Client: Rohan</p>
              </div>
              <span className="text-emerald-700 font-bold bg-emerald-50 px-2 py-0.5 rounded">Confirmed</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
