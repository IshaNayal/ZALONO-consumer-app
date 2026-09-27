import React, { useState } from 'react';
import { 
  Smartphone, 
  Columns, 
  Code2, 
  RotateCcw, 
  Sparkles, 
  Store, 
  User, 
  Layers, 
  ChevronRight,
  ExternalLink,
  Volume2,
  RefreshCw,
  MapPin
} from 'lucide-react';
import { ZalonoProvider, useZalono } from './context/ZalonoContext';
import { DeviceShell } from './components/common/DeviceShell';
import { PushNotificationBanner } from './components/common/PushNotificationBanner';

// Consumer screens
import { ConsumerHome } from './components/consumer/ConsumerHome';
import { ServiceTimeSelection } from './components/consumer/ServiceTimeSelection';
import { AvailableSalonsList } from './components/consumer/AvailableSalonsList';
import { SalonDetail } from './components/consumer/SalonDetail';
import { BookingConfirmationModal } from './components/consumer/BookingConfirmationModal';
import { LiveAppointmentTracker } from './components/consumer/LiveAppointmentTracker';
import { BookingsScreen } from './components/consumer/BookingsScreen';
import { BookByTimeScreen } from './components/consumer/BookByTimeScreen';
import { LastMinuteSlotsModal } from './components/consumer/LastMinuteSlotsModal';
import { LocationPickerModal } from './components/consumer/LocationPickerModal';
import { PaymentFeedbackModal } from './components/consumer/PaymentFeedbackModal';

// Partner screens
import { PartnerDashboard } from './components/partner/PartnerDashboard';
import { ManageSlotsScreen } from './components/partner/ManageSlotsScreen';
import { StaffManagementModal } from './components/partner/StaffManagementModal';
import { AddWalkInModal } from './components/partner/AddWalkInModal';
import { IncomingBookingModal } from './components/partner/IncomingBookingModal';
import { DuringServiceScreen } from './components/partner/DuringServiceScreen';
import { CustomerCRMModal } from './components/partner/CustomerCRMModal';
import { PartnerAnalyticsModal } from './components/partner/PartnerAnalyticsModal';

// Flutter Code Viewer
import { FlutterCodeViewer } from './components/flutter_export/FlutterCodeViewer';

type ViewMode = 'single_mobile' | 'dual_sync' | 'flutter_code';

const AppContent: React.FC = () => {
  const { 
    role, 
    setRole, 
    consumerScreen, 
    setConsumerScreen, 
    partnerScreen, 
    setPartnerScreen,
    currentLocation,
    resetDemoData,
    playBookingChime
  } = useZalono();

  const [viewMode, setViewMode] = useState<ViewMode>('single_mobile');

  // Consumer screen router
  const renderConsumerScreen = () => {
    switch (consumerScreen) {
      case 'home':
        return <ConsumerHome />;
      case 'service_time':
        return <ServiceTimeSelection />;
      case 'salon_list':
        return <AvailableSalonsList />;
      case 'salon_detail':
        return <SalonDetail />;
      case 'confirmation':
        return <BookingConfirmationModal />;
      case 'live_appointment':
        return <LiveAppointmentTracker />;
      case 'bookings':
        return <BookingsScreen />;
      case 'book_by_time':
        return <BookByTimeScreen />;
      case 'last_minute':
        return <LastMinuteSlotsModal />;
      case 'location_picker':
        return <LocationPickerModal />;
      case 'upi_payment':
      case 'receipt':
        return <PaymentFeedbackModal />;
      case 'profile':
        return <BookingsScreen />;
      default:
        return <ConsumerHome />;
    }
  };

  // Partner screen router
  const renderPartnerScreen = () => {
    switch (partnerScreen) {
      case 'dashboard':
        return <PartnerDashboard />;
      case 'manage_slots':
        return <ManageSlotsScreen />;
      case 'staff':
        return <StaffManagementModal />;
      case 'walk_in':
        return <AddWalkInModal />;
      case 'incoming_bookings':
        return <IncomingBookingModal />;
      case 'during_service':
        return <DuringServiceScreen />;
      case 'crm':
        return <CustomerCRMModal />;
      case 'analytics':
        return <PartnerAnalyticsModal />;
      default:
        return <PartnerDashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col font-sans select-none">
      {/* Studio Top Bar */}
      <header className="px-6 py-3 bg-slate-950/90 border-b border-slate-800 flex items-center justify-between z-30 shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-[#80142B] flex items-center justify-center font-zalono text-lg font-bold text-white shadow-md">
            Z
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-zalono text-lg font-bold text-white tracking-wide">Zalono</span>
              <span className="text-[10px] font-semibold uppercase tracking-wider text-rose-300 bg-[#80142B]/40 px-2 py-0.5 rounded-full border border-rose-500/20">
                Pilot Release · Bhubaneswar Beta
              </span>
              <span className="text-[10px] font-semibold text-emerald-400 bg-emerald-950/60 px-2 py-0.5 rounded-full border border-emerald-500/30 flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                <span>Zero-Wait Engine Active</span>
              </span>
            </div>
          </div>
        </div>

        {/* View Mode Switcher */}
        <div className="flex items-center gap-1 bg-slate-900 p-1 rounded-xl border border-slate-800 text-xs">
          <button
            onClick={() => setViewMode('single_mobile')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-semibold transition-all ${
              viewMode === 'single_mobile'
                ? 'bg-[#80142B] text-white shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Smartphone className="w-3.5 h-3.5" />
            <span>Pilot App Preview</span>
          </button>

          <button
            onClick={() => setViewMode('dual_sync')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-semibold transition-all ${
              viewMode === 'dual_sync'
                ? 'bg-[#80142B] text-white shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Columns className="w-3.5 h-3.5" />
            <span>Dual Sync (Consumer + Partner)</span>
          </button>

          <button
            onClick={() => setViewMode('flutter_code')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-semibold transition-all ${
              viewMode === 'flutter_code'
                ? 'bg-[#80142B] text-white shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            <Code2 className="w-3.5 h-3.5" />
            <span>Flutter & Dart Code</span>
          </button>
        </div>

        {/* Pilot Tools */}
        <div className="flex items-center gap-2">
          {viewMode === 'single_mobile' && (
            <div className="flex items-center bg-slate-800/80 p-0.5 rounded-xl border border-slate-700 text-xs">
              <button
                onClick={() => setRole('consumer')}
                className={`px-3 py-1 rounded-lg font-semibold transition-all ${
                  role === 'consumer'
                    ? 'bg-white text-slate-900 shadow-sm'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Customer App
              </button>
              <button
                onClick={() => setRole('partner')}
                className={`px-3 py-1 rounded-lg font-semibold transition-all ${
                  role === 'partner'
                    ? 'bg-white text-slate-900 shadow-sm'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Partner App
              </button>
            </div>
          )}

          {/* Audio Chime tester */}
          <button
            onClick={playBookingChime}
            title="Test pilot audio chime"
            className="p-1.5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 rounded-lg border border-slate-700"
          >
            <Volume2 className="w-3.5 h-3.5" />
          </button>

          {/* Reset Demo Data */}
          <button
            onClick={resetDemoData}
            title="Reset pilot demo data to initial state"
            className="p-1.5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 rounded-lg border border-slate-700"
          >
            <RefreshCw className="w-3.5 h-3.5" />
          </button>
        </div>
      </header>

      {/* Quick Scenario Jump Ribbon */}
      <div className="px-6 py-2 bg-slate-950 border-b border-slate-800/80 flex items-center gap-2 text-xs overflow-x-auto no-scrollbar shrink-0">
        <span className="text-[10px] uppercase font-bold text-slate-500 shrink-0">Pilot Flows:</span>
        
        {/* Consumer Steps */}
        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('home'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'home' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          1. Home
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('location_picker'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'location_picker' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          📍 Location ({currentLocation.name})
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('service_time'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'service_time' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          2. Time Selection
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('salon_list'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'salon_list' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          3. Salons List (Smart Slots)
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('salon_detail'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'salon_detail' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          4. Detail & Live Slots
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('confirmation'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'confirmation' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          5. Confirmation
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('live_appointment'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'live_appointment' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          6. Live Queue Tracker
        </button>

        <button
          onClick={() => { setRole('consumer'); setConsumerScreen('upi_payment'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            consumerScreen === 'upi_payment' && role === 'consumer' && viewMode === 'single_mobile'
              ? 'bg-[#80142B] text-white font-bold'
              : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          7. UPI Payment & Feedback
        </button>

        <span className="text-slate-700">|</span>

        {/* Partner Steps */}
        <button
          onClick={() => { setRole('partner'); setPartnerScreen('dashboard'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            partnerScreen === 'dashboard' && role === 'partner' && viewMode === 'single_mobile'
              ? 'bg-amber-600 text-white font-bold'
              : 'bg-slate-900 text-amber-400 hover:text-amber-200'
          }`}
        >
          Partner Home
        </button>

        <button
          onClick={() => { setRole('partner'); setPartnerScreen('manage_slots'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            partnerScreen === 'manage_slots' && role === 'partner' && viewMode === 'single_mobile'
              ? 'bg-amber-600 text-white font-bold'
              : 'bg-slate-900 text-amber-400 hover:text-amber-200'
          }`}
        >
          Manage Slots
        </button>

        <button
          onClick={() => { setRole('partner'); setPartnerScreen('walk_in'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            partnerScreen === 'walk_in' && role === 'partner' && viewMode === 'single_mobile'
              ? 'bg-amber-600 text-white font-bold'
              : 'bg-slate-900 text-amber-400 hover:text-amber-200'
          }`}
        >
          Add Walk-in
        </button>

        <button
          onClick={() => { setRole('partner'); setPartnerScreen('during_service'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            partnerScreen === 'during_service' && role === 'partner' && viewMode === 'single_mobile'
              ? 'bg-amber-600 text-white font-bold'
              : 'bg-slate-900 text-amber-400 hover:text-amber-200'
          }`}
        >
          Live Service & Payment
        </button>

        <button
          onClick={() => { setRole('partner'); setPartnerScreen('crm'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            partnerScreen === 'crm' && role === 'partner' && viewMode === 'single_mobile'
              ? 'bg-amber-600 text-white font-bold'
              : 'bg-slate-900 text-amber-400 hover:text-amber-200'
          }`}
        >
          Customer CRM
        </button>

        <button
          onClick={() => { setRole('partner'); setPartnerScreen('analytics'); setViewMode('single_mobile'); }}
          className={`px-2.5 py-1 rounded-lg shrink-0 font-medium transition-colors ${
            partnerScreen === 'analytics' && role === 'partner' && viewMode === 'single_mobile'
              ? 'bg-amber-600 text-white font-bold'
              : 'bg-slate-900 text-amber-400 hover:text-amber-200'
          }`}
        >
          Analytics
        </button>
      </div>

      {/* Main View Area */}
      <main className="flex-1 flex items-center justify-center p-4 overflow-y-auto">
        {viewMode === 'flutter_code' ? (
          <div className="w-full h-[85vh] max-w-6xl rounded-2xl overflow-hidden border border-slate-800 shadow-2xl">
            <FlutterCodeViewer />
          </div>
        ) : viewMode === 'dual_sync' ? (
          /* Dual Phone Side-by-Side: Consumer on left, Partner on right */
          <div className="flex flex-wrap items-center justify-center gap-10 py-6">
            <DeviceShell deviceLabel="Zalono Consumer App (Client)">
              <PushNotificationBanner />
              {renderConsumerScreen()}
            </DeviceShell>

            <DeviceShell deviceLabel="Zalono Partner App (Salon Owner)">
              <PushNotificationBanner />
              {renderPartnerScreen()}
            </DeviceShell>
          </div>
        ) : (
          /* Single Mobile View */
          <div className="py-4">
            <DeviceShell deviceLabel={role === 'consumer' ? 'Zalono Consumer App' : 'Zalono Partner App'}>
              <PushNotificationBanner />
              {role === 'consumer' ? renderConsumerScreen() : renderPartnerScreen()}
            </DeviceShell>
          </div>
        )}
      </main>
    </div>
  );
};

export default function App() {
  return (
    <ZalonoProvider>
      <AppContent />
    </ZalonoProvider>
  );
}
