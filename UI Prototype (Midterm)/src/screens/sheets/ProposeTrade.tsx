import React, { useState } from 'react';
import { PrimaryBtn, Toggle } from '../../components/ui';
import { LISTINGS } from '../../seed';

interface Props {
  listingId: string;
  onClose: () => void;
  onSuccess: () => void;
  showToast: (msg: string) => void;
}

const MY_CONSOLES = [
  { id: 'MY1', title: 'Switch OLED', value: 280, emoji: '🕹️' },
  { id: 'MY2', title: 'PS4 Pro', value: 150, emoji: '🎮' },
];

export default function ProposeTrade({ listingId, onClose, onSuccess, showToast }: Props) {
  const listing = LISTINGS.find(l => l.id === listingId) ?? LISTINGS[0];
  const [selected, setSelected] = useState<string | null>('MY1');
  const [addCash, setAddCash] = useState(false);
  const [cash, setCash] = useState(50);

  const selectedConsole = MY_CONSOLES.find(c => c.id === selected);
  const offerValue = (selectedConsole?.value ?? 0) + (addCash ? cash : 0);
  const fairPct = Math.round((offerValue / listing.price) * 100);

  return (
    <div className="flex flex-col rounded-t-[24px] bg-white sheet-enter" style={{ maxHeight: '80vh' }}>
      {/* Handle */}
      <div className="flex justify-center pt-3 pb-1">
        <div className="w-9 h-1 rounded-full" style={{ background: '#E9E6F0' }} />
      </div>

      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b" style={{ borderColor: '#E9E6F0' }}>
        <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>Propose a trade</span>
        <button onClick={onClose} className="text-[22px] w-8 h-8 flex items-center justify-center rounded-full"
          style={{ color: '#6E6884' }}>×</button>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll px-4 py-4 flex flex-col gap-4">
        <p className="text-[14px]" style={{ color: '#6E6884' }}>
          Pick one of your consoles to offer. Jordan accepts trades on this listing.
        </p>

        {/* Console picker */}
        <div className="flex gap-3">
          {MY_CONSOLES.map(c => (
            <button
              key={c.id}
              onClick={() => setSelected(c.id)}
              className="flex-1 relative flex flex-col items-center justify-center gap-2 p-4 rounded-[16px] h-[150px]"
              style={{
                border: selected === c.id ? '2px solid #5B2FD9' : '1.5px solid #E9E6F0',
                background: selected === c.id ? '#F5F1FF' : '#fff',
              }}
            >
              {selected === c.id && (
                <div className="absolute top-2 right-2 w-5 h-5 rounded-full flex items-center justify-center text-white text-[11px] font-bold scale-enter"
                  style={{ background: '#5B2FD9' }}>✓</div>
              )}
              <span className="text-4xl">{c.emoji}</span>
              <span className="text-[13px] font-medium" style={{ color: '#1E1633' }}>{c.title}</span>
              <span className="text-[13px] font-bold" style={{ color: '#5B2FD9' }}>${c.value}</span>
            </button>
          ))}
          {/* Add console tile */}
          <button
            onClick={() => showToast('Post it from the Sell tab')}
            className="flex-1 flex flex-col items-center justify-center gap-2 p-4 rounded-[16px] h-[150px]"
            style={{ border: '1.5px dashed #BDA6FF', background: '#fff' }}
          >
            <span className="text-3xl" style={{ color: '#5B2FD9' }}>＋</span>
            <span className="text-[12px] text-center" style={{ color: '#5B2FD9' }}>Add console</span>
          </button>
        </div>

        {/* Add cash toggle */}
        <div className="flex items-center justify-between py-3 border-y" style={{ borderColor: '#E9E6F0' }}>
          <span className="text-[15px] font-medium" style={{ color: '#1E1633' }}>+ Add cash</span>
          <Toggle on={addCash} onChange={setAddCash} />
        </div>

        {addCash && (
          <div className="flex items-center h-12 rounded-[12px] px-4 gap-1"
            style={{ background: '#F5F1FF' }}>
            <span className="text-[15px]" style={{ color: '#6E6884' }}>$</span>
            <input
              type="number"
              className="flex-1 bg-transparent outline-none text-[20px] font-bold"
              style={{ color: '#1E1633' }}
              value={cash}
              onChange={e => setCash(Number(e.target.value))}
            />
          </div>
        )}

        {/* Balance meter */}
        <div className="p-3 rounded-[12px]" style={{ background: '#F5F1FF' }}>
          <div className="flex justify-between mb-2 text-[13px]">
            <span style={{ color: '#6E6884' }}>Your offer: <span className="font-semibold" style={{ color: '#1E1633' }}>${offerValue}</span></span>
            <span style={{ color: '#6E6884' }}>Listing: <span className="font-semibold" style={{ color: '#1E1633' }}>${listing.price}</span></span>
          </div>
          <div className="h-1.5 rounded-full" style={{ background: '#E9E6F0' }}>
            <div className="h-full rounded-full" style={{ width: `${Math.min(fairPct, 100)}%`, background: 'linear-gradient(90deg, #5B2FD9, #7C5CFF)', transition: 'width 0.3s' }} />
          </div>
          <p className="text-[12px] mt-1.5 font-medium" style={{ color: fairPct >= 70 ? '#23C997' : '#FFB020' }}>
            {fairPct >= 70 ? '✓ Fair trade range' : '⚠ Consider adding more'}
          </p>
        </div>
      </div>

      <div className="px-4 pb-8 pt-3" style={{ borderTop: '1px solid #E9E6F0' }}>
        <PrimaryBtn onClick={onSuccess} className="w-full" disabled={!selected}>
          Send proposal
        </PrimaryBtn>
      </div>
    </div>
  );
}
