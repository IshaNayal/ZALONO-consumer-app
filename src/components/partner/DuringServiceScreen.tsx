import React, { useState, useEffect } from 'react';
import { ArrowLeft, Play, Pause, CheckCircle, IndianRupee, Scissors, Clock } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const DuringServiceScreen: React.FC = () => {
  const { setPartnerScreen, completeService, bookings, showNotification } = useZalono();
  
  const [seconds, setSeconds] = useState(720); // 12 mins elapsed
  const [isRunning, setIsRunning] = useState(true);
  const [step, setStep] = useState<'tracking' | 'payment'>('tracking');
  const [paymentMethod, setPaymentMethod] = useState<'paid_salon' | 'paid_upi'>('paid_salon');
  const [hasAddOn, setHasAddOn] = useState(false);

  useEffect(() => {
    let interval: any = null;
    if (isRunning && step === 'tracking') {
      interval = setInterval(() => setSeconds(s => s + 1), 1000);
    }
    return () => clearInterval(interval);
  }, [isRunning, step]);

  const formatTimer = (totalSeconds: number) => {
    const mins = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    const secs = (totalSeconds % 60).toString().padStart(2, '0');
    return `${mins}:${secs}`;
  };

  const handleFinish = () => {
    completeService(bookings[0]?.id || 'bk-101', paymentMethod);
    showNotification(
      'Service Finished & Payment Recorded',
      `₹${hasAddOn ? 599 : 399} recorded. Slot opened for next customer.`
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
        <h1 className="text-base font-bold text-slate-900">
          {step === 'tracking' ? 'Service in Progress' : 'Complete & Payment'}
        </h1>
        <div className="w-7"></div>
      </div>

      <div className="p-4 space-y-4">
        {/* Customer Header */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex items-center gap-3">
          <div className="w-12 h-12 rounded-full bg-[#F9E8EC] text-[#80142B] flex items-center justify-center font-bold text-lg">
            J
          </div>
          <div>
            <h2 className="text-sm font-bold text-slate-900">Jay Sharma</h2>
            <p className="text-xs text-slate-500">Haircut · 45 min · Stylist Rahul</p>
          </div>
        </div>

        {step === 'tracking' ? (
          <>
            {/* Live Progress Milestones */}
            <div className="bg-white p-4 rounded-2xl border border-slate-200 space-y-2 text-xs">
              <div className="flex items-center gap-2 text-emerald-700 font-semibold">
                <CheckCircle className="w-4 h-4" />
                <span>Checked in: 11:28 AM</span>
              </div>
              <div className="flex items-center gap-2 text-emerald-700 font-semibold">
                <CheckCircle className="w-4 h-4" />
                <span>Service started: 11:32 AM</span>
              </div>
              <div className="flex items-center gap-2 text-slate-500">
                <Clock className="w-4 h-4 text-slate-400" />
                <span>Estimated finish: 12:17 PM</span>
              </div>
            </div>

            {/* Big Stopwatch Timer */}
            <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-xs text-center space-y-4">
              <span className="text-[11px] font-bold text-slate-400 uppercase tracking-widest block">
                Active Styling Time
              </span>
              <div className="text-5xl font-mono font-bold text-slate-900 tracking-tight">
                {formatTimer(seconds)}
              </div>

              <div className="flex items-center justify-center gap-3 pt-2">
                <button
                  onClick={() => setIsRunning(!isRunning)}
                  className="px-4 py-2 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-bold text-slate-700 flex items-center gap-1.5 transition-colors"
                >
                  {isRunning ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
                  <span>{isRunning ? 'Pause' : 'Resume'}</span>
                </button>
                <button
                  onClick={() => setStep('payment')}
                  className="px-5 py-2 bg-[#80142B] hover:bg-[#681023] text-white rounded-xl text-xs font-bold shadow-xs transition-colors"
                >
                  Complete Service
                </button>
              </div>
            </div>
          </>
        ) : (
          /* Payment & Billing Step */
          <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs space-y-4">
            <h3 className="text-sm font-bold text-slate-900 border-b pb-2">Invoice & Payment Summary</h3>
            
            <div className="space-y-2 text-xs">
              <div className="flex justify-between text-slate-700">
                <span>Haircut:</span>
                <span className="font-semibold">₹399</span>
              </div>

              <div className="flex items-center justify-between text-slate-700">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={hasAddOn}
                    onChange={(e) => setHasAddOn(e.target.checked)}
                    className="accent-[#80142B]"
                  />
                  <span>Add-on: Beard Trim (+₹200)</span>
                </label>
                <span className="font-semibold">{hasAddOn ? '₹200' : '₹0'}</span>
              </div>

              <div className="flex justify-between text-sm font-bold text-slate-900 pt-2 border-t">
                <span>Total Amount:</span>
                <span className="text-[#80142B] font-mono">₹{hasAddOn ? 599 : 399}</span>
              </div>
            </div>

            {/* Payment Method Selector */}
            <div className="pt-2">
              <label className="text-xs font-bold text-slate-700 block mb-2">Select Payment Status</label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={() => setPaymentMethod('paid_salon')}
                  className={`py-2 px-3 text-xs font-bold rounded-xl border transition-all ${
                    paymentMethod === 'paid_salon'
                      ? 'bg-slate-900 text-white border-slate-900'
                      : 'bg-slate-50 text-slate-700 border-slate-200'
                  }`}
                >
                  💵 Paid Cash / Salon
                </button>
                <button
                  onClick={() => setPaymentMethod('paid_upi')}
                  className={`py-2 px-3 text-xs font-bold rounded-xl border transition-all ${
                    paymentMethod === 'paid_upi'
                      ? 'bg-slate-900 text-white border-slate-900'
                      : 'bg-slate-50 text-slate-700 border-slate-200'
                  }`}
                >
                  📱 Paid via UPI
                </button>
              </div>
            </div>

            <button
              onClick={handleFinish}
              className="w-full py-3 bg-[#80142B] text-white rounded-xl font-bold text-xs hover:bg-[#681023] shadow-md transition-colors mt-2"
            >
              Complete & Next Customer →
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
