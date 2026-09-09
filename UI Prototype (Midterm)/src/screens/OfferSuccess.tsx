import React from 'react';
import { SuccessCircle, Confetti, PrimaryBtn, GhostBtn } from '../components/ui';

interface Props {
  offerAmt?: number;
  sellerName?: string;
  onViewOffers: () => void;
  onKeepBrowsing: () => void;
}

export default function OfferSuccess({ offerAmt = 387, sellerName = 'Jordan Lee', onViewOffers, onKeepBrowsing }: Props) {
  return (
    <div
      className="absolute inset-0 flex items-center justify-center z-50"
      style={{ background: 'rgba(30,22,51,0.55)' }}
    >
      <div
        className="relative flex flex-col items-center text-center p-6 rounded-[24px] bg-white mx-6 scale-enter overflow-hidden"
        style={{ boxShadow: '0 20px 60px rgba(30,22,51,0.25)', minWidth: 300 }}
      >
        <Confetti />
        <SuccessCircle size={72} />
        <h2 className="text-[20px] font-bold mt-4 mb-2" style={{ color: '#1E1633' }}>
          Offer sent! 🎉
        </h2>
        <p className="text-[14px] mb-6" style={{ color: '#6E6884' }}>
          {sellerName} will review your offer of ${offerAmt}.
        </p>
        <PrimaryBtn onClick={onViewOffers} className="w-full mb-3">
          View my offers
        </PrimaryBtn>
        <GhostBtn onClick={onKeepBrowsing}>Keep browsing</GhostBtn>
      </div>
    </div>
  );
}
