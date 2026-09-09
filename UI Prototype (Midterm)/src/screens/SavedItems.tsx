import React, { useState } from 'react';
import { NavBar, PriceDropBadge } from '../components/ui';
import { LISTINGS } from '../seed';

interface Props {
  onBack: () => void;
  onListing: (id: string) => void;
  showToast: (msg: string) => void;
}

const SAVED_IDS = ['L2', 'L4', 'L1', 'L6', 'L8', 'L10'];
const PRICE_DROPS: Record<string, number> = { L2: 8, L4: 11 };

export default function SavedItems({ onBack, onListing, showToast }: Props) {
  const [savedIds, setSavedIds] = useState(new Set(SAVED_IDS));
  const visibleListings = LISTINGS.filter(l => savedIds.has(l.id));

  const unsave = (id: string) => {
    setSavedIds(s => { const n = new Set(s); n.delete(id); return n; });
    showToast('Removed from saved');
  };

  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      {/* Header */}
      <div className="shrink-0 flex items-center justify-between px-4 py-4 bg-white border-b" style={{ borderColor: '#E9E6F0' }}>
        <div className="flex items-center gap-3">
          <button onClick={onBack} className="text-2xl" style={{ color: '#6E6884' }}>←</button>
          <span className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Saved items</span>
        </div>
        <button className="text-[14px] font-medium" style={{ color: '#5B2FD9' }}>Edit</button>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll">
        {/* Summary strip */}
        <div className="mx-4 mt-4 flex items-center gap-2 px-3 py-2.5 rounded-[12px]"
          style={{ background: '#F5F1FF' }}>
          <span style={{ color: '#23C997', fontSize: 16 }}>↓</span>
          <span className="text-[13px]" style={{ color: '#6E6884' }}>
            <span className="font-semibold" style={{ color: '#1E1633' }}>{savedIds.size} items</span>
            {' · '}2 price drops this week
          </span>
        </div>

        <div className="grid grid-cols-2 gap-3 px-4 mt-4 pb-8">
          {visibleListings.map(listing => {
            const priceDrop = PRICE_DROPS[listing.id];
            return (
              <div
                key={listing.id}
                onClick={() => onListing(listing.id)}
                className="flex flex-col rounded-[20px] overflow-hidden bg-white cursor-pointer"
                style={{ boxShadow: '0 2px 8px rgba(30,22,51,0.06)' }}
              >
                {/* Image */}
                <div className="relative flex items-center justify-center text-4xl"
                  style={{ height: 128, background: '#F6F5FA' }}>
                  <span className="text-5xl">🎮</span>
                  {priceDrop && (
                    <div className="absolute top-2 left-2">
                      <PriceDropBadge pct={priceDrop} />
                    </div>
                  )}
                  {/* Heart (filled, always saved here) */}
                  <button
                    className="absolute top-2 right-2 w-7 h-7 rounded-full flex items-center justify-center"
                    style={{ background: 'rgba(255,255,255,0.90)' }}
                    onClick={e => { e.stopPropagation(); unsave(listing.id); }}
                  >
                    <span style={{ fontSize: 14, color: '#5B2FD9' }}>♥</span>
                  </button>
                </div>
                <div className="p-3">
                  <p className="text-[14px] font-medium line-clamp-2 leading-tight mb-1" style={{ color: '#1E1633' }}>
                    {listing.title}
                  </p>
                  <span className="text-[17px] font-bold" style={{ color: '#1E1633' }}>${listing.price}</span>
                  {listing.was && (
                    <span className="text-[12px] ml-1.5 line-through" style={{ color: '#948FA8' }}>${listing.was}</span>
                  )}
                  <div className="text-[12px] mt-1" style={{ color: '#948FA8' }}>📍 {listing.location}</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
