import React from 'react';
import { ArrowLeft, Flame, Clock } from 'lucide-react';
import { useZalono } from '../../context/ZalonoContext';

export const LastMinuteSlotsModal: React.FC = () => {
  const { setConsumerScreen, salons, setSelectedSalon, bookSlot } = useZalono();

  const lastMinuteItems = [
    {
      id: 'lm-1',
      service: 'Haircut',
      price: 399,
      salon: salons[0],
      time: '11:20 AM',
      inTime: 'In 15 min',
      distance: '0.8 km'
    },
    {
      id: 'lm-2',
      service: 'Facial Glow',
      price: 699,
      salon: salons[1],
      time: '11:45 AM',
      inTime: 'In 40 min',
      distance: '1.1 km'
    },
    {
      id: 'lm-3',
      service: 'Beard Trim & Shape',
      price: 299,
      salon: salons[2],
      time: '12:00 PM',
      inTime: 'In 55 min',
      distance: '1.4 km'
    },
  ];

  const handleBook = (item: any) => {
    setSelectedSalon(item.salon);
    bookSlot(item.salon.id, item.salon.slots[0].id, item.salon.services[0].id);
    setConsumerScreen('confirmation');
  };

  return (
    <div className="flex-1 flex flex-col bg-[#FAF9F6] pb-10">
      <div className="px-4 py-3 bg-white border-b border-slate-100 flex items-center justify-between sticky top-0 z-20">
        <button
          onClick={() => setConsumerScreen('home')}
          className="p-1.5 rounded-full hover:bg-slate-100 text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-base font-bold text-slate-900 flex items-center gap-1.5">
          <Flame className="w-4 h-4 text-amber-500 fill-amber-500" />
          <span>Last Minute Slots</span>
        </h1>
        <div className="w-7"></div>
      </div>

      <div className="p-4 space-y-3">
        <p className="text-xs text-slate-600 bg-amber-50 border border-amber-200 p-2.5 rounded-xl">
          ⚡ <strong>Cancellations & Live Openings:</strong> Grab these slots in the next 90 minutes before someone else snaps them up!
        </p>

        {lastMinuteItems.map((item) => (
          <div key={item.id} className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
            <div className="flex items-center gap-3">
              <img
                src={item.salon.image}
                alt={item.salon.name}
                className="w-14 h-14 rounded-xl object-cover border shrink-0"
              />
              <div>
                <span className="text-[10px] font-bold text-rose-700 bg-rose-50 border border-rose-200 px-1.5 py-0.2 rounded-full">
                  {item.inTime}
                </span>
                <h3 className="text-sm font-bold text-slate-900 mt-1">{item.service} · ₹{item.price}</h3>
                <p className="text-xs text-slate-600">{item.salon.name} · {item.distance}</p>
                <div className="flex items-center gap-1 text-[11px] text-slate-500 mt-0.5">
                  <Clock className="w-3 h-3 text-[#80142B]" />
                  <span className="font-semibold text-slate-800">{item.time} slot</span>
                </div>
              </div>
            </div>

            <button
              onClick={() => handleBook(item)}
              className="px-4 py-2 bg-[#80142B] text-white text-xs font-bold rounded-xl hover:bg-[#681023] shadow-xs shrink-0"
            >
              Book
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
