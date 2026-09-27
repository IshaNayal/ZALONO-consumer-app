import React from 'react';
import { ArrowLeft, TrendingUp, Calendar, IndianRupee, Users, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const PartnerAnalyticsModal: React.FC = () => {
  const { setPartnerScreen } = useZalono();

  const days = [
    { day: 'Mon', count: 18, height: '45%' },
    { day: 'Tue', count: 22, height: '55%' },
    { day: 'Wed', count: 20, height: '50%' },
    { day: 'Thu', count: 25, height: '65%' },
    { day: 'Fri', count: 32, height: '80%' },
    { day: 'Sat', count: 38, height: '95%' },
    { day: 'Sun', count: 35, height: '88%' },
  ];

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setPartnerScreen('dashboard')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Analytics & Reports</h1>
        <div className="w-7"></div>
      </div>

      <div className="p-4 space-y-4">
        {/* Time Filter Pills */}
        <div className="flex items-center gap-1.5 bg-slate-200/80 p-1 rounded-xl text-xs">
          {['7D', '30D', '3M', 'Custom'].map((t, idx) => (
            <button
              key={t}
              className={`flex-1 py-1 text-center font-bold rounded-lg ${
                idx === 1 ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600'
              }`}
            >
              {t}
            </button>
          ))}
        </div>

        {/* 4 Metric Cards */}
        <div className="grid grid-cols-2 gap-2.5">
          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <span className="text-[11px] text-slate-500 font-semibold block">Total Revenue</span>
            <p className="text-xl font-bold text-slate-900 font-mono mt-1">₹1,08,420</p>
            <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-0.5 mt-1">
              <ArrowUpRight className="w-3 h-3" /> +18% vs last month
            </span>
          </div>

          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <span className="text-[11px] text-slate-500 font-semibold block">Total Bookings</span>
            <p className="text-xl font-bold text-slate-900 font-mono mt-1">152</p>
            <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-0.5 mt-1">
              <ArrowUpRight className="w-3 h-3" /> +22% vs last month
            </span>
          </div>

          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <span className="text-[11px] text-slate-500 font-semibold block">Capacity Utilised</span>
            <p className="text-xl font-bold text-[#80142B] font-mono mt-1">82%</p>
            <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-0.5 mt-1">
              <ArrowUpRight className="w-3 h-3" /> +12% vs last month
            </span>
          </div>

          <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-xs">
            <span className="text-[11px] text-slate-500 font-semibold block">No-show Rate</span>
            <p className="text-xl font-bold text-slate-900 font-mono mt-1">8%</p>
            <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-0.5 mt-1">
              <ArrowDownRight className="w-3 h-3" /> -5% (Reduced!)
            </span>
          </div>
        </div>

        {/* Bookings Trend Bar Chart */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-900">Weekly Bookings Trend</span>
            <span className="text-[11px] text-slate-500">180 slots filled</span>
          </div>

          <div className="h-36 pt-4 flex items-end justify-between gap-2 border-b border-slate-200 pb-2">
            {days.map((d) => (
              <div key={d.day} className="flex-1 flex flex-col items-center gap-1.5 h-full justify-end">
                <span className="text-[9px] font-mono text-slate-400 font-semibold">{d.count}</span>
                <div
                  style={{ height: d.height }}
                  className="w-full bg-[#80142B] rounded-t-md hover:opacity-80 transition-all cursor-pointer"
                ></div>
                <span className="text-[10px] font-bold text-slate-600">{d.day}</span>
              </div>
            ))}
          </div>

          <p className="text-[11px] text-slate-500 text-center">
            Zero-wait slot algorithm reduced empty chair time by <strong>4.2 hours/day</strong>.
          </p>
        </div>
      </div>
    </div>
  );
};
