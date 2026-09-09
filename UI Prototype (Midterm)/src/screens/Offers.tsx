import React, { useState } from 'react';
import { SegmentedControl, EmptyState, PrimaryBtn } from '../components/ui';

interface Props {
  onDeals: () => void;
  showToast: (msg: string) => void;
}

interface OfferItem {
  id: string;
  title: string;
  counterparty: string;
  offerText: string;
  time: string;
  status: 'Pending' | 'Accepted' | 'Declined';
}

const INITIAL_INCOMING: OfferItem[] = [
  { id: 'O1', title: 'Switch OLED — White', counterparty: 'kai_gamer', offerText: 'offered $265', time: '2h ago', status: 'Pending' },
  { id: 'O2', title: 'PS4 Pro 1TB', counterparty: 'mia.trades', offerText: 'wants to trade: Xbox Series S + $40', time: '1d ago', status: 'Pending' },
];

const SENT_OFFERS: OfferItem[] = [
  { id: 'S1', title: 'PS5 Disc Edition — 1TB', counterparty: 'Jordan Lee', offerText: 'offered $387', time: '10m ago', status: 'Pending' },
  { id: 'S2', title: 'Xbox Series X Bundle', counterparty: 'Mia Torres', offerText: 'proposed: Switch OLED + $50', time: 'Yesterday', status: 'Accepted' },
  { id: 'S3', title: 'Switch OLED — White', counterparty: 'GameHaven Store', offerText: 'offered $240', time: '3d ago', status: 'Declined' },
];

const STATUS_STYLES = {
  Pending: { bg: '#FFF3D6', color: '#E8A200' },
  Accepted: { bg: '#DFF7EF', color: '#16A06A' },
  Declined: { bg: '#FDECEC', color: '#E5484D' },
};

export default function Offers({ onDeals, showToast }: Props) {
  const [tab, setTab] = useState(0);
  const [incoming, setIncoming] = useState<OfferItem[]>(INITIAL_INCOMING);

  const accept = (id: string) => {
    setIncoming(prev => prev.map(o => o.id === id ? { ...o, status: 'Accepted' } : o));
    showToast('Offer accepted — arrange meetup details in chat (v1.0)');
  };

  const decline = (id: string) => {
    setIncoming(prev => prev.map(o => o.id === id ? { ...o, status: 'Declined' } : o));
  };

  const pendingCount = incoming.filter(o => o.status === 'Pending').length;
  const allResolved = incoming.every(o => o.status !== 'Pending');

  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      {/* Header */}
      <div className="shrink-0 px-4 pt-3 pb-3 bg-white" style={{ borderBottom: '1px solid #E9E6F0' }}>
        <div className="flex items-center justify-between mb-3">
          <span className="text-[22px] font-bold" style={{ color: '#1E1633', letterSpacing: -0.3 }}>Offers</span>
          <button
            onClick={() => showToast('All caught up')}
            className="flex items-center gap-1.5 text-[13px] font-medium"
            style={{ color: '#5B2FD9' }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#5B2FD9" strokeWidth="2" strokeLinecap="round">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
            Mark all read
          </button>
        </div>
        <SegmentedControl
          options={[`Incoming (${pendingCount})`, 'Sent (3)']}
          selected={tab}
          onChange={setTab}
        />
      </div>

      <div className="flex-1 overflow-y-auto no-scroll">
        {/* ── Incoming tab ── */}
        {tab === 0 && (
          <>
            {allResolved ? (
              /* Frame 62 — Empty state after all resolved */
              <EmptyState
                icon="🔁"
                title="No pending offers"
                sub="When someone offers on your consoles, it shows up here."
                cta="Browse deals"
                onCta={onDeals}
              />
            ) : (
              <div className="flex flex-col gap-3 p-4">
                {incoming.map(offer => (
                  <OfferCard key={offer.id} offer={offer} type="incoming" onAccept={() => accept(offer.id)} onDecline={() => decline(offer.id)} />
                ))}
              </div>
            )}
            {/* Resolved offers (dimmed, below) */}
            {incoming.some(o => o.status !== 'Pending') && (
              <div className="px-4 pb-4">
                <p className="text-[12px] font-medium mb-2" style={{ color: '#948FA8' }}>RESOLVED</p>
                <div className="flex flex-col gap-3">
                  {incoming.filter(o => o.status !== 'Pending').map(offer => (
                    <OfferCard key={offer.id} offer={offer} type="incoming" resolved />
                  ))}
                </div>
              </div>
            )}
          </>
        )}

        {/* ── Sent tab ── */}
        {tab === 1 && (
          <div className="flex flex-col gap-3 p-4">
            {SENT_OFFERS.map(offer => (
              <OfferCard key={offer.id} offer={offer} type="sent" />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function OfferCard({
  offer, type, onAccept, onDecline, resolved = false,
}: {
  offer: OfferItem;
  type: 'incoming' | 'sent';
  onAccept?: () => void;
  onDecline?: () => void;
  resolved?: boolean;
}) {
  const statusStyle = STATUS_STYLES[offer.status];
  const showActions = type === 'incoming' && offer.status === 'Pending' && !resolved;
  const isTrade = offer.offerText.includes('trade') || offer.offerText.includes('wants to');

  return (
    <div
      className="rounded-[16px] overflow-hidden"
      style={{
        background: 'linear-gradient(180deg, #FFFFFF 0%, #F5F1FF 100%)',
        border: '1px solid #E9E6F0',
        opacity: resolved ? 0.55 : 1,
        transition: 'opacity 0.3s',
      }}
    >
      <div className="flex items-start gap-3 p-4">
        {/* Listing thumb */}
        <div
          className="flex items-center justify-center rounded-[12px] shrink-0"
          style={{ width: 56, height: 56, background: '#F5F1FF', fontSize: 26 }}
        >
          {isTrade ? '🔄' : '🎮'}
        </div>

        <div className="flex-1 min-w-0">
          {/* Counterparty row */}
          <div className="flex items-center gap-2 mb-0.5">
            <div
              className="flex items-center justify-center rounded-full text-[9px] font-bold shrink-0"
              style={{ width: 22, height: 22, background: '#E9E1FF', color: '#45239E' }}
            >
              {offer.counterparty[0].toUpperCase()}
            </div>
            <span className="text-[14px] font-semibold" style={{ color: '#1E1633' }}>{offer.counterparty}</span>
          </div>
          {/* Offer text */}
          <p className="text-[14px]" style={{ color: '#3A3350' }}>
            <span className="font-semibold" style={{ color: '#5B2FD9' }}>{offer.offerText}</span>
            <span style={{ color: '#6E6884' }}> on </span>
            <span className="font-medium">{offer.title}</span>
          </p>
          {/* Timestamp */}
          <p className="text-[11px] mt-0.5" style={{ color: '#948FA8' }}>{offer.time}</p>
        </div>

        {/* Status badge */}
        <div
          className="shrink-0 flex items-center h-6 px-2 rounded-[6px] text-[11px] font-semibold"
          style={{ background: statusStyle.bg, color: statusStyle.color }}
        >
          {offer.status === 'Accepted' && '✓ '}
          {offer.status === 'Declined' && '✕ '}
          {offer.status}
        </div>
      </div>

      {/* Action buttons */}
      {showActions && (
        <div className="flex gap-2 px-4 pb-4">
          <button
            onClick={onDecline}
            className="flex-1 h-10 rounded-[10px] text-[14px] font-semibold"
            style={{ background: '#FDECEC', color: '#E5484D' }}
          >
            Decline
          </button>
          <button
            onClick={onAccept}
            className="flex-1 h-10 rounded-[10px] text-[14px] font-semibold text-white"
            style={{ background: 'linear-gradient(90deg, #5B2FD9 0%, #7C5CFF 100%)' }}
          >
            Accept ✓
          </button>
        </div>
      )}
    </div>
  );
}
