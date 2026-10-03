import React, { useEffect, useRef, useState } from 'react';
import {
  ArrowLeft,
  Calendar,
  Check,
  CheckCircle2,
  Heart,
  Info,
  Loader2,
  QrCode,
  Share2,
  Star,
  Store,
  Wallet
} from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

/**
 * Mirrors the Flutter `PaymentVerificationScreen` stage machine: the mobile
 * number and its OTP are confirmed before any service detail is shown, then
 * payment. The website-only UPI, feedback and receipt steps follow on.
 */
type PayStep = 'mobile' | 'otp' | 'payment' | 'upi_qr' | 'feedback' | 'success';

interface SummaryLine {
  name: string;
  price: number;
}

/** Same `+91 XXXXX XXXXX` shape the profile already stores. */
const formatPhone = (digits: string) => {
  const local = digits.length > 10 ? digits.slice(-10) : digits;
  return `+91 ${local.slice(0, 5)} ${local.slice(5)}`.trim();
};

export const PaymentFeedbackModal: React.FC = () => {
  const {
    activeBooking,
    userProfile,
    setUserProfile,
    setConsumerScreen,
    completeService,
    submitFeedback,
    getWhatsAppShareUrl
  } = useZalono();

  const [step, setStep] = useState<PayStep>('mobile');
  const [selectedMethod, setSelectedMethod] = useState<'cash' | 'upi'>('upi');

  // Verification stage state, same shape as the app's screen. The number is
  // kept as bare digits because the +91 prefix is rendered by the field.
  const [phone, setPhone] = useState<string>(
    (activeBooking?.customerPhone || userProfile.phone).replace(/\D/g, '')
  );
  const [otp, setOtp] = useState('');
  const [expectedOtp, setExpectedOtp] = useState<string | null>(null);
  const [errorText, setErrorText] = useState<string | null>(null);
  const [isWorking, setIsWorking] = useState(false);
  const workTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Feedback states
  const [rating, setRating] = useState(5);
  const [startedOnTime, setStartedOnTime] = useState<'yes' | 'almost' | 'no'>('yes');
  const [wouldBookAgain, setWouldBookAgain] = useState<'yes' | 'maybe' | 'no'>('yes');
  const [reviewNote, setReviewNote] = useState('');
  const [isSavedUsual, setIsSavedUsual] = useState(true);

  useEffect(
    () => () => {
      if (workTimer.current) clearTimeout(workTimer.current);
    },
    []
  );

  if (!activeBooking) {
    return (
      <div className="flex-1 p-6 text-center">
        <p className="text-xs text-slate-500">No active appointment.</p>
        <button onClick={() => setConsumerScreen('home')} className="mt-3 text-xs text-[#80142B] font-bold">Go Home</button>
      </div>
    );
  }

  const totalPrice = activeBooking.servicePrice;
  const summaryLines: SummaryLine[] = [
    { name: activeBooking.serviceName, price: activeBooking.servicePrice }
  ];
  const isPhoneValid = phone.replace(/\D/g, '').length >= 10;

  /** Stands in for the API calls the app marks as pending integration. */
  const runBusy = (work: () => void, delay = 600) => {
    setIsWorking(true);
    workTimer.current = setTimeout(() => {
      setIsWorking(false);
      work();
    }, delay);
  };

  const handleRequestOtp = () =>
    runBusy(() => {
      setExpectedOtp(String(100000 + (Date.now() % 900000)));
      setOtp('');
      setErrorText(null);
      setStep('otp');
    });

  const handleVerifyOtp = () => {
    const entered = otp.trim();
    if (entered.length !== 6) {
      setErrorText('Enter the 6-digit code.');
      return;
    }
    if (entered !== expectedOtp) {
      setErrorText('That code is not correct. Try again.');
      return;
    }
    runBusy(() => {
      setErrorText(null);
      setUserProfile((prev) => ({
        ...prev,
        phone: formatPhone(phone),
        isOtpVerified: true
      }));
      setStep('payment');
    }, 400);
  };

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

  const handleBack = () => {
    if (step === 'otp') {
      setOtp('');
      setErrorText(null);
      setStep('mobile');
      return;
    }
    if (step === 'upi_qr') {
      setStep('payment');
      return;
    }
    setConsumerScreen('live_appointment');
  };

  const title =
    step === 'mobile' || step === 'otp'
      ? 'Verify Your Number'
      : step === 'payment' || step === 'upi_qr'
        ? 'Service & Payment'
        : step === 'feedback'
          ? 'Feedback & Rating'
          : 'Payment Receipt';

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={handleBack}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">{title}</h1>
        <div className="w-7"></div>
      </div>

      <div className="w-full max-w-xl mx-auto p-4 sm:px-6 space-y-6">
        {/* Services stay hidden until the number is verified: showing the
            basket before the user is identified is a spoiler for anyone
            picking up the phone. */}
        {step === 'payment' && (
          <SummaryCard
            salonName={activeBooking.salonName}
            services={summaryLines}
            total={totalPrice}
          />
        )}

        {/* Stage 1 — mobile number */}
        {step === 'mobile' && (
          <div className="space-y-4">
            <StageHeading
              title="Verify your mobile number"
              subtitle="We will send a one-time code to confirm it is you."
            />
            <Field
              label="Mobile number"
              prefix="+91  "
              value={phone}
              inputMode="tel"
              maxLength={15}
              onChange={(value) => {
                setPhone(value);
                setErrorText(null);
              }}
            />
            <ErrorText message={errorText} />
            <PrimaryButton
              label="Send OTP"
              busy={isWorking}
              disabled={!isPhoneValid}
              onClick={handleRequestOtp}
            />
          </div>
        )}

        {/* Stage 2 — OTP */}
        {step === 'otp' && (
          <div className="space-y-4">
            <StageHeading
              title="Enter the OTP"
              subtitle="Check your messages for the 6-digit code."
            />
            {/* No SMS provider is wired up, so the code is shown rather than
                pretending it was delivered. */}
            <div className="flex items-start gap-2 px-3 py-2.5 rounded-[10px] bg-[#F9E8EC] border border-[#F3D3DC]">
              <Info className="w-4 h-4 text-[#80142B] shrink-0 mt-px" />
              <p className="text-xs font-semibold text-[#80142B]">
                Demo build: your code is {expectedOtp ?? '------'}
              </p>
            </div>
            <Field
              label="6-digit OTP"
              value={otp}
              inputMode="numeric"
              maxLength={6}
              autoFocus
              onChange={(value) => {
                setOtp(value);
                setErrorText(null);
              }}
            />
            <ErrorText message={errorText} />
            <PrimaryButton
              label="Verify & Continue"
              busy={isWorking}
              onClick={handleVerifyOtp}
            />
            <div className="text-center">
              <button
                type="button"
                onClick={handleRequestOtp}
                className="text-[13px] font-semibold text-[#80142B]"
              >
                Resend OTP
              </button>
            </div>
          </div>
        )}

        {/* Stage 3 — payment */}
        {step === 'payment' && (
          <div className="space-y-4">
            <StageHeading
              title="Payment"
              subtitle="Pay now to confirm your appointment."
            />
            <div className="space-y-2.5">
              <MethodTile
                icon={<Wallet className="w-5 h-5" />}
                label="UPI"
                subtitle="Pay using any UPI app"
                selected={selectedMethod === 'upi'}
                onClick={() => setSelectedMethod('upi')}
              />
              <MethodTile
                icon={<Store className="w-5 h-5" />}
                label="Pay at salon"
                subtitle="Cash, UPI or card at the counter"
                selected={selectedMethod === 'cash'}
                onClick={() => setSelectedMethod('cash')}
              />
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-slate-500">Amount to pay</span>
              <span className="text-lg font-bold text-slate-900">
                ₹{totalPrice}
              </span>
            </div>
            <PrimaryButton
              label={`Pay ₹${totalPrice} & Confirm`}
              onClick={handlePayNow}
            />
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
              <p className="text-lg font-bold text-slate-900 font-mono">₹{totalPrice}.00</p>
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
                <span className="text-[#80142B] font-mono">₹{totalPrice}</span>
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
                  `Zalono Receipt #${activeBooking.invoiceId}: Paid ₹${totalPrice} at ${activeBooking.salonName}. Zero-wait guarantee fulfilled!`
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

/** Salon, selected services and the combined total, as on the app's screen. */
const SummaryCard: React.FC<{
  salonName: string;
  services: SummaryLine[];
  total: number;
}> = ({ salonName, services, total }) => (
  <div className="bg-white p-3.5 rounded-[14px] border border-slate-200 shadow-xs">
    <div className="flex items-center justify-between gap-2.5">
      <span className="text-sm font-bold text-slate-900 truncate">{salonName}</span>
      <span className="text-base font-bold text-[#80142B] shrink-0">₹{total}</span>
    </div>

    <div className="mt-2 space-y-0.5">
      {services.map((service) => (
        <div key={service.name} className="flex items-center gap-1.5">
          <Check className="w-[13px] h-[13px] text-emerald-600 shrink-0" />
          <span className="flex-1 min-w-0 text-[12.5px] text-slate-500 truncate">
            {service.name}
          </span>
          <span className="text-[12.5px] text-slate-500">₹{service.price}</span>
        </div>
      ))}
    </div>

    <div className="mt-2.5 pt-2.5 border-t border-slate-100 space-y-1">
      <div className="flex items-center justify-between text-xs text-slate-500">
        <span>Stylist Service Fee:</span>
        <span>Included</span>
      </div>
      <div className="flex items-center justify-between text-xs text-slate-500">
        <span>Zero-Wait Guarantee Discount:</span>
        <span className="text-emerald-700 font-semibold">Applied (₹0 wait fee)</span>
      </div>
    </div>
  </div>
);

const StageHeading: React.FC<{ title: string; subtitle: string }> = ({
  title,
  subtitle
}) => (
  <div className="space-y-1">
    <h2 className="text-[19px] font-bold text-slate-900">{title}</h2>
    <p className="text-[13px] leading-[1.4] text-slate-500">{subtitle}</p>
  </div>
);

const Field: React.FC<{
  label: string;
  value: string;
  onChange: (value: string) => void;
  prefix?: string;
  inputMode?: 'text' | 'tel' | 'numeric';
  maxLength?: number;
  autoFocus?: boolean;
}> = ({ label, value, onChange, prefix, inputMode = 'text', maxLength, autoFocus }) => (
  <div className="space-y-1.5">
    <label className="block text-[13px] font-semibold text-slate-700">{label}</label>
    <div className="flex items-center gap-1 px-3 rounded-xl border border-slate-300 bg-white focus-within:border-[#80142B]">
      {prefix && <span className="text-sm text-slate-500 select-none">{prefix}</span>}
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        inputMode={inputMode}
        maxLength={maxLength}
        autoFocus={autoFocus}
        className="w-full bg-transparent py-3 text-sm text-slate-900 tracking-wide outline-none"
      />
    </div>
  </div>
);

const ErrorText: React.FC<{ message: string | null }> = ({ message }) =>
  message ? <p className="text-xs text-red-600">{message}</p> : null;

const PrimaryButton: React.FC<{
  label: string;
  onClick: () => void;
  busy?: boolean;
  disabled?: boolean;
}> = ({ label, onClick, busy, disabled }) => (
  <button
    type="button"
    onClick={onClick}
    disabled={busy || disabled}
    className="w-full h-[52px] bg-[#80142B] text-white rounded-[14px] text-[15px] font-bold shadow-md transition-colors hover:bg-[#681023] disabled:bg-[#80142B]/40 disabled:shadow-none flex items-center justify-center"
  >
    {busy ? <Loader2 className="w-5 h-5 animate-spin" /> : label}
  </button>
);

const MethodTile: React.FC<{
  icon: React.ReactNode;
  label: string;
  subtitle: string;
  selected: boolean;
  onClick: () => void;
}> = ({ icon, label, subtitle, selected, onClick }) => (
  <button
    type="button"
    onClick={onClick}
    className={`w-full text-left p-3.5 rounded-xl border transition-colors ${
      selected ? 'bg-[#F9E8EC] border-[#80142B]' : 'bg-white border-slate-200'
    }`}
  >
    <div className="flex items-center gap-3">
      <span className="text-[#80142B] shrink-0">{icon}</span>
      <span className="flex-1 min-w-0">
        <span className="block text-sm font-semibold text-slate-900 truncate">
          {label}
        </span>
        <span className="block text-xs text-slate-500 truncate">{subtitle}</span>
      </span>
      {selected && <CheckCircle2 className="w-[18px] h-[18px] text-[#80142B] shrink-0" />}
    </div>
  </button>
);