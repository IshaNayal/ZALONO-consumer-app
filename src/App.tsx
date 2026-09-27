import React from 'react';
import { ZalonoProvider, useZalono } from './context/ZalonoContext';
import { DeviceShell } from './components/common/DeviceShell';
import { PushNotificationBanner } from './components/common/PushNotificationBanner';

// Consumer Screens
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

// Partner Screens
import { PartnerDashboard } from './components/partner/PartnerDashboard';
import { ManageSlotsScreen } from './components/partner/ManageSlotsScreen';

const AppScreenRouter: React.FC = () => {
  const { 
    role,
    consumerScreen, 
    partnerScreen,
  } = useZalono();

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
      default:
        return <PartnerDashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-[#F0EDE6] flex items-center justify-center p-0 sm:p-4 select-none">
      <DeviceShell deviceLabel={role === 'consumer' ? 'Zalono' : 'Zalono Partner'}>
        <PushNotificationBanner />
        {role === 'consumer' ? renderConsumerScreen() : renderPartnerScreen()}
      </DeviceShell>
    </div>
  );
};

export default function App() {
  return (
    <ZalonoProvider>
      <AppScreenRouter />
    </ZalonoProvider>
  );
}
