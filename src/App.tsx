import React from 'react';
import { ZalonoProvider, useZalono } from './context/ZalonoContext';
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
import { StaffManagementModal } from './components/partner/StaffManagementModal';
import { IncomingBookingModal } from './components/partner/IncomingBookingModal';
import { AddWalkInModal } from './components/partner/AddWalkInModal';
import { DuringServiceScreen } from './components/partner/DuringServiceScreen';
import { CustomerCRMModal } from './components/partner/CustomerCRMModal';
import { PartnerAnalyticsModal } from './components/partner/PartnerAnalyticsModal';

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
      case 'staff':
        return <StaffManagementModal />;
      case 'incoming_bookings':
        return <IncomingBookingModal />;
      case 'walk_in':
        return <AddWalkInModal />;
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
    <div className="min-h-screen w-full bg-[#FAF9F6] flex flex-col text-slate-900">
      <PushNotificationBanner />
      <div className="flex-1 flex flex-col min-h-0">
        {role === 'consumer' ? renderConsumerScreen() : renderPartnerScreen()}
      </div>
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
