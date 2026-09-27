import React from 'react';
import { ArrowLeft, User, Calendar, IndianRupee, Heart, Scissors, Send } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const CustomerCRMModal: React.FC = () => {
  const { setPartnerScreen, customerCRM, showNotification } = useZalono();

  const handleSendInvite = () => {
    showNotification(
      'Smart Rebooking Reminder Sent',
      `Sent SMS & WhatsApp invite to ${customerCRM.name}: "Hey Jay! It's been 42 days since your last haircut at Looks Salon. Rahul has slots this weekend!"`
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
        <h1 className="text-base font-bold text-slate-900">Customer Details (CRM)</h1>
        <div className="w-7"></div>
      </div>

      <div className="p-4 space-y-4">
        {/* Profile Card */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex items-center gap-3">
          <div className="w-14 h-14 rounded-full bg-[#F9E8EC] text-[#80142B] flex items-center justify-center font-bold text-xl">
            J
          </div>
          <div>
            <h2 className="text-base font-bold text-slate-900">{customerCRM.name}</h2>
            <p className="text-xs text-slate-500">Customer since {customerCRM.customerSince}</p>
            <p className="text-xs font-mono text-slate-600 mt-0.5">{customerCRM.phone}</p>
          </div>
        </div>

        {/* 3 Metric Summary Boxes */}
        <div className="grid grid-cols-3 gap-2">
          <div className="bg-white p-3 rounded-xl border border-slate-200 text-center">
            <span className="text-[10px] text-slate-400 font-bold uppercase">Visits</span>
            <p className="text-lg font-bold text-slate-900 font-mono mt-0.5">{customerCRM.totalVisits}</p>
          </div>
          <div className="bg-white p-3 rounded-xl border border-slate-200 text-center">
            <span className="text-[10px] text-slate-400 font-bold uppercase">Avg Spend</span>
            <p className="text-lg font-bold text-[#80142B] font-mono mt-0.5">₹{customerCRM.avgSpend}</p>
          </div>
          <div className="bg-white p-3 rounded-xl border border-slate-200 text-center">
            <span className="text-[10px] text-slate-400 font-bold uppercase">Last Visit</span>
            <p className="text-lg font-bold text-amber-700 font-mono mt-0.5">{customerCRM.daysSinceLastVisit}d</p>
          </div>
        </div>

        {/* Customer Preferences */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-3 text-xs">
          <div className="flex items-center justify-between pb-2 border-b border-slate-100">
            <span className="text-slate-500 font-medium">Preferred Stylist:</span>
            <strong className="text-slate-900">{customerCRM.preferredStylist} (Senior)</strong>
          </div>

          <div className="flex items-center justify-between pb-2 border-b border-slate-100">
            <span className="text-slate-500 font-medium">Usual Services:</span>
            <strong className="text-slate-900">{customerCRM.usualServices.join(' · ')}</strong>
          </div>

          <div>
            <span className="text-slate-500 font-medium block mb-1">Stylist Notes:</span>
            <p className="p-2.5 bg-slate-50 rounded-xl text-slate-700 italic">
              "{customerCRM.notes}"
            </p>
          </div>
        </div>

        {/* Smart Rebooking Outreach Card */}
        <div className="p-4 bg-[#F9E8EC] border border-[#80142B]/30 rounded-2xl space-y-2">
          <div className="flex items-center gap-2 text-xs font-bold text-[#80142B]">
            <Heart className="w-4 h-4 fill-[#80142B]" />
            <span>Smart Rebooking Reminder</span>
          </div>
          <p className="text-xs text-slate-700 leading-relaxed">
            Customer is overdue for a haircut (42 days). Send a personalized rebooking invitation for this weekend.
          </p>
          <button
            onClick={handleSendInvite}
            className="w-full mt-2 py-2.5 bg-[#80142B] hover:bg-[#681023] text-white font-bold text-xs rounded-xl shadow-xs flex items-center justify-center gap-1.5 transition-colors"
          >
            <Send className="w-3.5 h-3.5" />
            <span>Send Rebooking Invite</span>
          </button>
        </div>
      </div>
    </div>
  );
};
