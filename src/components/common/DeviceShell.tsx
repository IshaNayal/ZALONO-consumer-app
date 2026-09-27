import React, { useState, useEffect } from 'react';
import { Wifi, Battery, Signal } from 'lucide-react';

interface DeviceShellProps {
  children: React.ReactNode;
  title?: string;
  theme?: 'light' | 'dark';
  deviceLabel?: string;
}

export const DeviceShell: React.FC<DeviceShellProps> = ({
  children,
  deviceLabel = 'iPhone 16 Pro'
}) => {
  const [time, setTime] = useState('9:41');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      const hours = now.getHours() % 12 || 12;
      const minutes = now.getMinutes().toString().padStart(2, '0');
      setTime(`${hours}:${minutes}`);
    };
    updateTime();
    const interval = setInterval(updateTime, 30000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex flex-col items-center">
      {/* Device Label */}
      {deviceLabel && (
        <div className="mb-2 flex items-center gap-2 text-xs font-medium text-slate-500">
          <span className="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          <span>{deviceLabel}</span>
        </div>
      )}

      {/* Phone Body with Titanium Frame */}
      <div className="relative w-[390px] h-[844px] bg-slate-900 rounded-[50px] p-[10px] shadow-2xl border-4 border-slate-700/80 ring-1 ring-white/10 flex flex-col overflow-hidden select-none">
        
        {/* Screen Bezel and Inner Glass */}
        <div className="relative w-full h-full bg-[#FAFAF9] rounded-[40px] overflow-hidden flex flex-col text-slate-900">
          
          {/* iOS Status Bar */}
          <div className="h-11 px-7 pt-2.5 flex items-center justify-between text-xs font-semibold tracking-tight text-slate-900 z-30 shrink-0 select-none bg-transparent">
            <span>{time}</span>
            
            {/* Dynamic Island Pill */}
            <div className="w-28 h-6 bg-black rounded-full flex items-center justify-center gap-2 px-2 shadow-sm">
              <div className="w-2.5 h-2.5 rounded-full bg-[#1c1c1e] ring-1 ring-white/10"></div>
              <div className="w-2 h-2 rounded-full bg-[#0a84ff]/30"></div>
            </div>

            <div className="flex items-center gap-1.5 text-slate-800">
              <Signal className="w-3.5 h-3.5 stroke-[2.5]" />
              <Wifi className="w-3.5 h-3.5 stroke-[2.5]" />
              <Battery className="w-4 h-4 stroke-[2.5]" />
            </div>
          </div>

          {/* App Viewport Content */}
          <div className="flex-1 overflow-y-auto overflow-x-hidden relative flex flex-col no-scrollbar">
            {children}
          </div>

          {/* iOS Home Indicator Bar */}
          <div className="h-5 shrink-0 flex items-center justify-center pb-1 z-30 pointer-events-none">
            <div className="w-32 h-1 bg-slate-900/30 rounded-full"></div>
          </div>
        </div>
      </div>
    </div>
  );
};
