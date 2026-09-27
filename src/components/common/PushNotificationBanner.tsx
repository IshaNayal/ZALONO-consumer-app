import React from 'react';
import { Bell, Navigation, X } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const PushNotificationBanner: React.FC = () => {
  const { activeNotification, clearNotification } = useZalono();

  if (!activeNotification) return null;

  return (
    <div className="absolute top-12 left-3 right-3 z-50 animate-in slide-in-from-top-4 duration-300">
      <div className="bg-slate-900/95 backdrop-blur-md text-white p-3.5 rounded-2xl shadow-xl border border-white/10 flex items-start gap-3">
        <div className="w-8 h-8 rounded-xl bg-[#80142B] flex items-center justify-center shrink-0 shadow-sm mt-0.5">
          <Bell className="w-4 h-4 text-white" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-200 tracking-tight">{activeNotification.title}</span>
            <button 
              onClick={clearNotification}
              className="text-slate-400 hover:text-white transition-colors"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
          <p className="text-[11px] text-slate-300 mt-0.5 line-clamp-2 leading-relaxed">
            {activeNotification.message}
          </p>
          {activeNotification.actionText && (
            <button
              onClick={() => {
                if (activeNotification.onAction) activeNotification.onAction();
                clearNotification();
              }}
              className="mt-2 text-[11px] font-semibold text-[#f8a5b5] hover:text-white flex items-center gap-1 transition-colors"
            >
              <Navigation className="w-3 h-3" />
              <span>{activeNotification.actionText}</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
