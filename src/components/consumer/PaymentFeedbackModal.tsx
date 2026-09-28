import React, { useState } from 'react';
import { 
  ArrowLeft, 
  CheckCircle, 
  Star, 
  QrCode, 
  Smartphone, 
  IndianRupee, 
  Check, 
  Heart, 
  Receipt, 
  Share2,
  Calendar
} from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const PaymentFeedbackModal: React.FC = () => {
  const { 
    activeBooking, 
    setConsumerScreen, 
    completeService, 
    submitFeedback, 
    showNotification,
    getWhatsAppShareUrl 
  } = useZalono();

  const [step, setStep] = useState<'payment' | 'upi_qr' | 'feedback' | 'success'>('payment');
  const [selectedMethod, setSelectedMethod] = useState<'cash' | 'upi'>('upi');
  
  // Feedback states
  const [rating, setRating] = useState(5);
  const [startedOnTime, setStartedOnTime] = useState<'yes' | 'almost' | 'no'>('yes');
  const [wouldBookAgain, setWouldBookAgain] = useState<'yes' | 'maybe' | 'no'>('yes');
  const [reviewNote, setReviewNote] = useState('');
  const [isSavedUsual, setIsSavedUsual] = useState(true);

  if (!activeBooking) {
    return (
      <div className="flex-1 p-6 text-center">
        <p className="text-xs text-slate-500">No active appointment.</p>
        <button onClick={() => setConsumerScreen('home')} className="mt-3 text-xs text-[#80142B] font-bold">Go Home</button>
      </div>
    );
  }

  const handlePayNow = () => {
    if (selectedMethod === 'upi') {
      setStep('upi_qr');
    } else {
      completeService(activeBooking.id, 'paid_salon', { methodUsed: 'cash' });
      setStep('feedback');
    }
  };

  const handleUpiConfirmed = () => {
    completeService(activeBooking.id, 'paid_upi', { methodUsed: 'upi' });
    setStep('feedback');
  };

  const handleSubmitFeedback = () => {
    submitFeedback(activeBooking.id, rating, startedOnTime, wouldBookAgain, reviewNote);
    setStep('success');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setConsumerScreen('live_appointment')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">
          {step === 'payment' || step === 'upi_qr' ? 'Service & Payment' : step === 'feedback' ? 'Feedback & Rating' : 'Payment Receipt'}
        </h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-xl mx-auto p-4 sm:px-6 space-y-4">
        {step === 'payment' && (
          <div className="space-y-4">
            {/* Visit Summary Card */}
            <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs space-y-3">
              <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">Your Visit</span>
              <div className="flex items-center justify-between text-sm">
                <span className="font-semibold text-slate-800">{activeBooking.serviceName}</span>
                <span className="font-mono font-bold text-slate-900">₹{activeBooking.servicePrice}</span>
              </div>
              <div className="flex items-center justify-between text-sm text-slate-500 text-xs">
                <span>Stylist Service Fee:</span>
                <span>Included</span>
              </div>
              <div className="flex items-center justify-between text-sm text-slate-500 text-xs">
                <span>Zero-Wait Guarantee Discount:</span>
                <span className="text-emerald-700 font-semibold">Applied (₹0 wait fee)</span>
              </div>
              <div className="pt-2 border-t border-slate-100 flex items-center justify-between text-base font-bold text-slate-900">
                <span>Total Amount</span>
                <span className="text-[#80142B] font-mono">₹{activeBooking.servicePrice}</span>
              </div>
            </div>

            {/* Payment Mode Selection */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-700">Choose Payment Method</label>
              
              <div
                onClick={() => setSelectedMethod('upi')}
                className={`p-3.5 rounded-2xl border cursor-pointer flex items-center justify-between transition-all ${
                  selectedMethod === 'upi' ? 'bg-[#F9E8EC] border-[#80142B]' : 'bg-white border-slate-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-700 flex items-center justify-center font-bold text-xs">
                    UPI
                  </div>
                  <div>
                    <span className="text-sm font-bold text-slate-900">Pay with UPI (Instant)</span>
                    <p className="text-xs text-slate-500">GPay, PhonePe, Paytm or QR</p>
                  </div>
                </div>
                <input type="radio" checked={selectedMethod === 'upi'} onChange={() => setSelectedMethod('upi')} className="accent-[#80142B]" />
              </div>

              <div
                onClick={() => setSelectedMethod('cash')}
                className={`p-3.5 rounded-2xl border cursor-pointer flex items-center justify-between transition-all ${
                  selectedMethod === 'cash' ? 'bg-[#F9E8EC] border-[#80142B]' : 'bg-white border-slate-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center font-bold text-xs">
                    💵
                  </div>
                  <div>
                    <span className="text-sm font-bold text-slate-900">Pay at Salon (Cash / Card)</span>
                    <p className="text-xs text-slate-500">Pay directly at front desk after cut</p>
                  </div>
                </div>
                <input type="radio" checked={selectedMethod === 'cash'} onChange={() => setSelectedMethod('cash')} className="accent-[#80142B]" />
              </div>
            </div>

            <button
              onClick={handlePayNow}
              className="w-full py-3 bg-[#80142B] text-white rounded-xl font-bold text-xs hover:bg-[#681023] shadow-md transition-colors mt-2"
            >
              {selectedMethod === 'upi' ? 'Proceed to UPI Payment →' : 'Confirm Cash Payment →'}
            </button>
          </div>
        )}

        {/* UPI QR Simulation Step */}
        {step === 'upi_qr' && (
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs text-center space-y-4">
            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-widest block">
              Scan & Pay via any UPI App
            </span>

            {/* Generated UPI QR Code Mock */}
            <div className="mx-auto w-48 h-48 bg-slate-50 border-2 border-dashed border-slate-300 rounded-2xl flex flex-col items-center justify-center p-3 shadow-inner">
              <QrCode className="w-36 h-36 text-slate-800" />
              <span className="text-[10px] text-slate-500 font-mono mt-1">UPI ID: lookssalon.bbsr@icici</span>
            </div>

            <div className="space-y-1">
              <p className="text-lg font-bold text-slate-900 font-mono">₹{activeBooking.servicePrice}.00</p>
              <p className="text-xs text-slate-500">To: Looks Salon (Saheed Nagar)</p>
            </div>

            {/* Fast UPI App Simulator buttons */}
            <div className="grid grid-cols-3 gap-2 pt-1 text-xs">
              <button
                onClick={handleUpiConfirmed}
                className="py-2 bg-blue-50 hover:bg-blue-100 text-blue-700 font-bold rounded-xl border border-blue-200"
              >
                GPay
              </button>
              <button
                onClick={handleUpiConfirmed}
                className="py-2 bg-purple-50 hover:bg-purple-100 text-purple-700 font-bold rounded-xl border border-purple-200"
              >
                PhonePe
              </button>
              <button
                onClick={handleUpiConfirmed}
                className="py-2 bg-sky-50 hover:bg-sky-100 text-sky-700 font-bold rounded-xl border border-sky-200"
              >
                Paytm
              </button>
            </div>

            <button
              onClick={handleUpiConfirmed}
              className="w-full py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold text-xs shadow-md transition-colors"
            >
              ✓ Simulate Successful Payment
            </button>
          </div>
        )}

        {/* Feedback Screen (Wireframe Step 9 & 10) */}
        {step === 'feedback' && (
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs space-y-4">
            <div className="text-center space-y-1">
              <h2 className="text-base font-bold text-slate-900">How was your service?</h2>
              <p className="text-xs text-slate-500">{activeBooking.salonName} · Stylist {activeBooking.stylistName}</p>
              
              {/* Star Rating */}
              <div className="flex items-center justify-center gap-2 pt-2">
                {[1, 2, 3, 4, 5].map((s) => (
                  <button
                    key={s}
                    onClick={() => setRating(s)}
                    className="p-1 text-2xl transition-transform hover:scale-110"
                  >
                    <Star
                      className={`w-8 h-8 ${
                        s <= rating
                          ? 'text-amber-400 fill-amber-400'
                          : 'text-slate-200'
                      }`}
                    />
                  </button>
                ))}
              </div>
            </div>

            {/* Question 1: Did appointment start on time? */}
            <div className="pt-2 border-t border-slate-100 space-y-1.5">
              <label className="text-xs font-bold text-slate-700 block text-center">
                Did your appointment start on time?
              </label>
              <div className="grid grid-cols-3 gap-2">
                {(['yes', 'almost', 'no'] as const).map((ans) => (
                  <button
                    key={ans}
                    onClick={() => setStartedOnTime(ans)}
                    className={`py-2 text-xs font-bold rounded-xl border capitalize transition-all ${
                      startedOnTime === ans
                        ? 'bg-[#80142B] text-white border-[#80142B] shadow-xs'
                        : 'bg-slate-50 text-slate-700 border-slate-200'
                    }`}
                  >
                    {ans}
                  </button>
                ))}
              </div>
            </div>

            {/* Question 2: Would you book this salon again? */}
            <div className="pt-2 border-t border-slate-100 space-y-1.5">
              <label className="text-xs font-bold text-slate-700 block text-center">
                Would you book this salon again?
              </label>
              <div className="grid grid-cols-3 gap-2">
                {(['yes', 'maybe', 'no'] as const).map((ans) => (
                  <button
                    key={ans}
                    onClick={() => setWouldBookAgain(ans)}
                    className={`py-2 text-xs font-bold rounded-xl border capitalize transition-all ${
                      wouldBookAgain === ans
                        ? 'bg-[#80142B] text-white border-[#80142B] shadow-xs'
                        : 'bg-slate-50 text-slate-700 border-slate-200'
                    }`}
                  >
                    {ans}
                  </button>
                ))}
              </div>
            </div>

            {/* Review Note */}
            <div>
              <input
                type="text"
                value={reviewNote}
                onChange={(e) => setReviewNote(e.target.value)}
                placeholder="Optional review notes (e.g. Great scissor fade)..."
                className="w-full text-xs p-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none"
              />
            </div>

            {/* Save as my usual salon (Wireframe step 10) */}
            <div className="p-3 bg-rose-50/70 border border-rose-200 rounded-xl flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Heart className="w-4 h-4 text-[#80142B] fill-[#80142B]" />
                <div>
                  <p className="text-xs font-bold text-slate-900">Save as my usual salon</p>
                  <p className="text-[10px] text-slate-500">1-tap rebooking next time</p>
                </div>
              </div>
              <input
                type="checkbox"
                checked={isSavedUsual}
                onChange={(e) => setIsSavedUsual(e.target.checked)}
                className="accent-[#80142B] w-4 h-4"
              />
            </div>

            <button
              onClick={handleSubmitFeedback}
              className="w-full py-3 bg-[#80142B] text-white rounded-xl font-bold text-xs hover:bg-[#681023] shadow-md transition-colors"
            >
              Submit Feedback & View Receipt →
            </button>
          </div>
        )}

        {/* Final Receipt Card */}
        {step === 'success' && (
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-md space-y-4">
            <div className="text-center space-y-1">
              <div className="w-12 h-12 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto">
                <Check className="w-6 h-6 stroke-[3]" />
              </div>
              <h2 className="text-base font-bold text-slate-900">Service Completed & Paid!</h2>
              <p className="text-xs text-slate-500 font-mono">Invoice #{activeBooking.invoiceId || 'ZAL-2026-0927-101'}</p>
            </div>

            <div className="p-3.5 bg-slate-50 rounded-xl space-y-2 text-xs text-slate-700">
              <div className="flex justify-between">
                <span>Salon:</span>
                <strong className="text-slate-900">{activeBooking.salonName}</strong>
              </div>
              <div className="flex justify-between">
                <span>Service:</span>
                <strong className="text-slate-900">{activeBooking.serviceName}</strong>
              </div>
              <div className="flex justify-between">
                <span>Stylist:</span>
                <strong className="text-slate-900">{activeBooking.stylistName}</strong>
              </div>
              <div className="flex justify-between">
                <span>Paid via:</span>
                <strong className="text-emerald-700 uppercase">{selectedMethod}</strong>
              </div>
              <div className="flex justify-between border-t pt-1.5 font-bold text-slate-900">
                <span>Total Paid:</span>
                <span className="text-[#80142B] font-mono">₹{activeBooking.servicePrice}</span>
              </div>
            </div>

            {/* Smart Rebooking Reminder Box (Wireframe step 11) */}
            <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl text-xs text-amber-950 space-y-1">
              <p className="font-bold flex items-center gap-1">
                <Calendar className="w-3.5 h-3.5 text-amber-700" />
                <span>Smart Rebooking Active</span>
              </p>
              <p className="text-[11px] text-amber-800 leading-relaxed">
                We'll notify you in 25 days when your hair is ready for a fresh trim with Rahul!
              </p>
            </div>

            <div className="grid grid-cols-2 gap-2 pt-2">
              <a
                href={getWhatsAppShareUrl(
                  activeBooking.customerPhone,
                  `Zalono Receipt #${activeBooking.invoiceId}: Paid ₹${activeBooking.servicePrice} at ${activeBooking.salonName}. Zero-wait guarantee fulfilled!`
                )}
                target="_blank"
                rel="noreferrer"
                className="py-2.5 px-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-colors"
              >
                <Share2 className="w-3.5 h-3.5" />
                <span>Share Receipt</span>
              </a>

              <button
                onClick={() => setConsumerScreen('home')}
                className="py-2.5 px-3 bg-[#80142B] hover:bg-[#681023] text-white rounded-xl text-xs font-bold flex items-center justify-center transition-colors"
              >
                Done
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
