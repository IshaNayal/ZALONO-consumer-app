import React from 'react';
import { 
  ArrowLeft, 
  Check, 
  Clock, 
  Scissors, 
  MessageSquare, 
  Phone, 
  HelpCircle, 
  Sparkles,
  Play,
  CreditCard,
  Share2,
  Navigation
} from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const LiveAppointmentTracker: React.FC = () => {
  const { 
    activeBooking, 
    setConsumerScreen, 
    advanceBookingQueueStatus,
    showNotification,
    getWhatsAppShareUrl 
  } = useZalono();

  if (!activeBooking) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center p-6 text-center">
        <p className="text-sm text-slate-500">No active appointment.</p>
        <button
          onClick={() => setConsumerScreen('home')}
          className="mt-4 px-4 py-2 bg-[#80142B] text-white rounded-xl text-xs font-bold"
        >
          Back to Home
        </button>
      </div>
    );
  }

  const steps = [
    { key: 'booked', label: 'Booked', time: activeBooking.bookedAt, desc: 'Seat confirmed with zero-wait guarantee' },
    { key: 'checked_in', label: 'Checked in', time: '11:28 AM', desc: 'Arrived at salon' },
    { key: 'you_are_next', label: "You're next ✂️", time: `Est. ${activeBooking.estimatedStartTime}`, desc: `Position: ${activeBooking.queuePosition} in queue` },
    { key: 'in_service', label: 'In service', time: '~45 min', desc: 'Stylist active with customer' },
    { key: 'completed', label: 'Completed', time: 'Finish', desc: 'Service & payment complete' }
  ];

  const getStepIndex = (status: string) => {
    switch (status) {
      case 'booked': return 0;
      case 'checked_in': return 1;
      case 'you_are_next': return 2;
      case 'in_service': return 3;
      case 'completed': return 4;
      default: return 0;
    }
  };

  const currentStepIndex = getStepIndex(activeBooking.status);

  const whatsappMessage = `Hi ${activeBooking.stylistName}, I am ${activeBooking.customerName}. I have a ${activeBooking.serviceName} booking at ${activeBooking.slotTime} via Zalono.`;

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setConsumerScreen('home')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Your Appointment</h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-6xl mx-auto p-4 sm:px-6 space-y-4">
        {/* Salon Summary Card */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <img
                src={activeBooking.salonImage}
                alt={activeBooking.salonName}
                className="w-12 h-12 rounded-xl object-cover border border-slate-100"
              />
              <div>
                <h2 className="text-sm font-bold text-slate-900">{activeBooking.salonName}</h2>
                <p className="text-xs text-slate-500">Stylist: {activeBooking.stylistName}</p>
                <p className="text-xs font-semibold text-slate-800 mt-0.5">
                  {activeBooking.serviceName} · ₹{activeBooking.servicePrice}
                </p>
              </div>
            </div>
            <span className="px-2.5 py-1 text-[11px] font-bold text-emerald-800 bg-emerald-100 rounded-full flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse"></span>
              <span>On time</span>
            </span>
          </div>

          <div className="mt-3 pt-2.5 border-t border-slate-100 flex items-center justify-between text-xs text-slate-600">
            <span>📍 {activeBooking.salonAddress}</span>
            <span className="text-[#80142B] font-bold">{activeBooking.travelTimeMin} min drive</span>
          </div>
        </div>

        {/* Live Stepper Tracker */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-bold text-slate-900">Live Status Tracker</h3>
            <span className="text-[11px] font-semibold text-slate-400">Real-time salon feed</span>
          </div>

          <div className="relative pl-6 space-y-6 before:absolute before:left-2.5 before:top-2 before:bottom-2 before:w-0.5 before:bg-slate-200">
            {steps.map((st, idx) => {
              const isPast = idx < currentStepIndex;
              const isCurrent = idx === currentStepIndex;

              return (
                <div key={st.key} className="relative flex items-start justify-between">
                  {/* Indicator Dot */}
                  <div
                    className={`absolute -left-7.25 top-0.5 w-6 h-6 rounded-full flex items-center justify-center ring-4 ring-white transition-all ${
                      isPast
                        ? 'bg-emerald-600 text-white'
                        : isCurrent
                        ? 'bg-[#80142B] text-white shadow-sm ring-rose-100'
                        : 'bg-slate-200 text-slate-400'
                    }`}
                  >
                    {isPast ? (
                      <Check className="w-3.5 h-3.5 stroke-3" />
                    ) : isCurrent ? (
                      <Scissors className="w-3 h-3 stroke-[2.5]" />
                    ) : (
                      <span className="w-1.5 h-1.5 rounded-full bg-slate-400"></span>
                    )}
                  </div>

                  {/* Content */}
                  <div>
                    <div className="flex items-center gap-2">
                      <span className={`text-xs font-bold ${isCurrent ? 'text-[#80142B]' : isPast ? 'text-slate-900' : 'text-slate-400'}`}>
                        {st.label}
                      </span>
                      {isCurrent && (
                        <span className="text-[10px] font-bold text-emerald-800 bg-emerald-100 px-1.5 py-0.2 rounded-full">
                          ACTIVE NOW
                        </span>
                      )}
                    </div>
                    <p className={`text-[11px] mt-0.5 ${isCurrent ? 'text-slate-700 font-medium' : 'text-slate-400'}`}>
                      {st.desc}
                    </p>
                  </div>

                  <span className="text-[11px] text-slate-400 font-mono shrink-0">
                    {st.time}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Live Simulator Controls */}
        <div className="p-3 bg-rose-50/70 border border-rose-200 rounded-2xl flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-[#80142B]" />
            <div>
              <p className="text-xs font-bold text-slate-900">Simulate Queue Event</p>
              <p className="text-[10px] text-slate-500">Advance queue to test real-time steps</p>
            </div>
          </div>
          <button
            onClick={() => advanceBookingQueueStatus(activeBooking.id)}
            className="px-3 py-1.5 text-xs font-bold text-white bg-[#80142B] hover:bg-[#681023] rounded-xl flex items-center gap-1 transition-colors"
          >
            <Play className="w-3 h-3 fill-white" />
            <span>Advance Step</span>
          </button>
        </div>

        {/* Pilot Payment / Complete Action Button */}
        <button
          onClick={() => setConsumerScreen('upi_payment')}
          className="w-full py-3 bg-slate-900 hover:bg-slate-800 text-white rounded-xl font-bold text-xs flex items-center justify-center gap-2 shadow-sm transition-colors"
        >
          <CreditCard className="w-4 h-4 text-emerald-400" />
          <span>Pay & Feedback (UPI / Cash / Receipt) →</span>
        </button>

        {/* Salon Communication Actions */}
        <div className="space-y-2 pt-1">
          <a
            href={getWhatsAppShareUrl('+919876543210', whatsappMessage)}
            target="_blank"
            rel="noreferrer"
            className="w-full py-2.5 px-4 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold flex items-center justify-center gap-2 shadow-xs transition-colors"
          >
            <MessageSquare className="w-4 h-4" />
            <span>WhatsApp Stylist ({activeBooking.stylistName})</span>
          </a>

          <button
            onClick={() => showNotification('Calling Looks Salon', 'Calling +91 00000 00000 (Saheed Nagar reception)...')}
            className="w-full py-2.5 px-4 bg-white hover:bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800 flex items-center justify-center gap-2 shadow-xs transition-colors"
          >
            <Phone className="w-4 h-4 text-[#80142B]" />
            <span>Call Salon Reception</span>
          </button>

          <button
            onClick={() => showNotification('Zero-Wait Guarantee', 'Zalono Guarantee: If you wait >10 minutes after scheduled seat, your service is 100% reimbursed.')}
            className="w-full py-2 px-4 rounded-xl text-xs text-slate-500 flex items-center justify-center gap-1.5 hover:text-slate-800 transition-colors"
          >
            <HelpCircle className="w-3.5 h-3.5" />
            <span>Need Help & Zero-Wait Guarantee?</span>
          </button>
        </div>
      </div>
    </div>
  );
};
