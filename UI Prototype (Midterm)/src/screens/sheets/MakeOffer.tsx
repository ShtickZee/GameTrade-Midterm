import React, { useState } from 'react';
import { PrimaryBtn, GhostBtn } from '../../components/ui';
import { LISTINGS } from '../../seed';

interface Props {
  listingId: string;
  onClose: () => void;
  onSuccess: () => void;
}

const PRESETS = [
  { label: '−5%', pct: 5 },
  { label: '−10%', pct: 10 },
  { label: '−15%', pct: 15 },
];

export default function MakeOffer({ listingId, onClose, onSuccess }: Props) {
  const listing = LISTINGS.find(l => l.id === listingId) ?? LISTINGS[0];
  const [offerAmt, setOfferAmt] = useState(Math.round(listing.price * 0.9));
  const [note, setNote] = useState('');
  const [selectedPreset, setSelectedPreset] = useState(1);
  const tooLow = offerAmt < listing.price * 0.5;

  const applyPreset = (pct: number, idx: number) => {
    setSelectedPreset(idx);
    setOfferAmt(Math.round(listing.price * (1 - pct / 100)));
  };

  return (
    <div
      className="flex flex-col rounded-t-[24px] bg-white sheet-enter"
      style={{ maxHeight: '80vh' }}
    >
      {/* Handle */}
      <div className="flex justify-center pt-3 pb-1">
        <div className="w-9 h-1 rounded-full" style={{ background: '#E9E6F0' }} />
      </div>

      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b" style={{ borderColor: '#E9E6F0' }}>
        <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>Make an offer</span>
        <button onClick={onClose} className="text-[22px] w-8 h-8 flex items-center justify-center rounded-full"
          style={{ color: '#6E6884' }}>×</button>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll px-4 py-4 flex flex-col gap-4">
        {/* Listing mini row */}
        <div className="flex items-center gap-3 p-3 rounded-[12px]" style={{ background: '#F5F1FF' }}>
          <div className="w-12 h-12 rounded-[10px] flex items-center justify-center text-2xl"
            style={{ background: '#E9E1FF' }}>🎮</div>
          <div>
            <p className="text-[14px] font-medium line-clamp-1" style={{ color: '#1E1633' }}>{listing.title}</p>
            <p className="text-[12px]" style={{ color: '#6E6884' }}>Listed at ${listing.price}</p>
          </div>
        </div>

        {/* Presets */}
        <div className="flex gap-2">
          {PRESETS.map((p, i) => (
            <button
              key={i}
              onClick={() => applyPreset(p.pct, i)}
              className="flex-1 py-2 rounded-[10px] text-[13px] font-medium transition-all"
              style={selectedPreset === i
                ? { background: '#5B2FD9', color: '#fff' }
                : { background: '#F5F1FF', color: '#3A3350' }
              }
            >
              {p.label} · ${Math.round(listing.price * (1 - p.pct / 100))}
            </button>
          ))}
        </div>

        {/* Price field */}
        <div>
          <label className="text-[13px] font-medium block mb-1.5" style={{ color: '#6E6884' }}>Your offer</label>
          <div
            className="flex items-center h-14 rounded-[12px] px-4 gap-1"
            style={{ background: tooLow ? '#fff0f0' : '#F5F1FF', border: tooLow ? '1.5px solid #E5484D' : 'none' }}
          >
            <span className="text-[16px]" style={{ color: '#6E6884' }}>$</span>
            <input
              type="number"
              className="flex-1 bg-transparent outline-none text-[26px] font-bold"
              style={{ color: '#1E1633' }}
              value={offerAmt}
              onChange={e => { setSelectedPreset(-1); setOfferAmt(Number(e.target.value)); }}
            />
          </div>
          {tooLow && (
            <p className="text-[12px] mt-1" style={{ color: '#E5484D' }}>
              Offers below ${Math.round(listing.price * 0.5)} usually get declined.
            </p>
          )}
        </div>

        {/* Note */}
        <div>
          <div className="flex justify-between mb-1.5">
            <label className="text-[13px] font-medium" style={{ color: '#6E6884' }}>Note (optional)</label>
            <span className="text-[12px]" style={{ color: '#948FA8' }}>{note.length}/120</span>
          </div>
          <textarea
            className="w-full rounded-[12px] px-4 py-3 text-[15px] outline-none resize-none"
            style={{ background: '#F5F1FF', color: '#1E1633', height: 80, border: 'none' }}
            placeholder="Add a note for the seller…"
            maxLength={120}
            value={note}
            onChange={e => setNote(e.target.value)}
          />
        </div>
      </div>

      {/* Footer */}
      <div className="px-4 pb-8 pt-3" style={{ borderTop: '1px solid #E9E6F0' }}>
        <PrimaryBtn onClick={onSuccess} className="w-full" disabled={tooLow}>
          Send offer ${offerAmt}
        </PrimaryBtn>
      </div>
    </div>
  );
}
