import React from 'react';
import { ArrowLeft, MapPin, Check, Navigation, Compass } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';
import { PilotLocation } from '../../types';

export const LocationPickerModal: React.FC = () => {
  const { 
    setConsumerScreen, 
    locationsList, 
    currentLocation, 
    setCurrentLocation 
  } = useZalono();

  const handleSelect = (loc: PilotLocation) => {
    setCurrentLocation(loc);
    setConsumerScreen('home');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6]">
      {/* Top Bar */}
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setConsumerScreen('home')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900">Select Pilot Location</h1>
        <div className="w-7"></div>
      </div>

      <div className="p-4 space-y-4">
        <div className="p-3 bg-blue-50 border border-blue-200 rounded-2xl flex items-start gap-2.5">
          <Compass className="w-4 h-4 text-blue-600 mt-0.5 shrink-0" />
          <p className="text-xs text-blue-900 leading-relaxed">
            <strong>Bhubaneswar Beta Pilot:</strong> Selecting your locality recalculates live transit times and slot recommendation buffers (travel + 5m buffer) dynamically.
          </p>
        </div>

        <div className="space-y-2.5">
          {locationsList.map((loc) => {
            const isSelected = currentLocation.id === loc.id;
            return (
              <div
                key={loc.id}
                onClick={() => handleSelect(loc)}
                className={`p-3.5 rounded-2xl border transition-all cursor-pointer flex items-center justify-between ${
                  isSelected
                    ? 'bg-[#F9E8EC] border-[#80142B] shadow-xs'
                    : 'bg-white border-slate-200 hover:border-slate-300'
                }`}
              >
                <div className="flex items-start gap-3">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
                    isSelected ? 'bg-[#80142B] text-white' : 'bg-slate-100 text-slate-600'
                  }`}>
                    <MapPin className="w-4 h-4" />
                  </div>
                  <div>
                    <h3 className={`text-sm font-bold ${isSelected ? 'text-[#80142B]' : 'text-slate-900'}`}>
                      {loc.name}
                    </h3>
                    <p className="text-xs text-slate-500 mt-0.5">{loc.landmark}</p>
                  </div>
                </div>

                {isSelected && (
                  <div className="w-6 h-6 rounded-full bg-[#80142B] text-white flex items-center justify-center">
                    <Check className="w-3.5 h-3.5 stroke-[3]" />
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
