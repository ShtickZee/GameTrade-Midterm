import React, { useState } from 'react';
import { SegmentedControl, NavBar } from '../components/ui';

interface Props {
  onBack: () => void;
  onOffers: () => void;
  onDeals: () => void;
  showToast: (msg: string) => void;
}

const NOTIFS = [
  { icon: '🤝', title: 'New offer received', body: "kai_gamer offered $265 on your Switch OLED.", time: '2h', unread: true, tab: 'offers' },
  { icon: '🤝', title: 'Trade proposal', body: "mia.trades wants to trade for your PS4 Pro.", time: '1d', unread: true, tab: 'offers' },
  { icon: '⚡', title: 'Flash sale started', body: "Up to 30% off certified pre-owned consoles — 48h only.", time: '2d', unread: false, tab: 'deals' },
  { icon: '✅', title: 'Offer accepted', body: "Mia Torres accepted your Switch OLED + $50 trade.", time: '3d', unread: false, tab: 'sent' },
  { icon: '🎉', title: 'Welcome to GameTrade!', body: "Set up your profile to start trading.", time: '1w', unread: false, tab: 'profile' },
];

const TAB_COLORS: Record<string, string> = {
  offers: '#F5F1FF',
  deals: '#FFF3D6',
  sent: '#DFF7EF',
  profile: '#F6F5FA',
};

export default function Notifications({ onBack, onOffers, onDeals, showToast }: Props) {
  const [tab, setTab] = useState(0);
  const [read, setRead] = useState<Set<number>>(new Set());

  const markAllRead = () => setRead(new Set(NOTIFS.map((_, i) => i)));

  const handleRow = (n: typeof NOTIFS[0], i: number) => {
    setRead(r => { const s = new Set(r); s.add(i); return s; });
    if (n.tab === 'offers' || n.tab === 'sent') onOffers();
    else if (n.tab === 'deals') onDeals();
    else showToast('Coming in v1.0');
  };

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Header */}
      <div className="shrink-0 flex items-center justify-between px-4 py-4 border-b" style={{ borderColor: '#E9E6F0' }}>
        <div className="flex items-center gap-3">
          <button onClick={onBack} className="text-2xl" style={{ color: '#6E6884' }}>←</button>
          <span className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Notifications</span>
        </div>
        <button onClick={markAllRead} className="text-[13px] font-medium" style={{ color: '#5B2FD9' }}>
          Mark all read
        </button>
      </div>

      <div className="px-4 pt-3 shrink-0">
        <SegmentedControl options={['All', 'Offers', 'Deals']} selected={tab} onChange={setTab} />
      </div>

      <div className="flex-1 overflow-y-auto no-scroll px-4 py-3">
        {NOTIFS
          .filter(n => tab === 0 || (tab === 1 && (n.tab === 'offers' || n.tab === 'sent')) || (tab === 2 && n.tab === 'deals'))
          .map((n, i) => {
            const isUnread = n.unread && !read.has(i);
            return (
              <button
                key={i}
                onClick={() => handleRow(n, i)}
                className="flex items-start gap-3 w-full py-3 border-b text-left"
                style={{ borderColor: '#E9E6F0' }}
              >
                <div
                  className="flex items-center justify-center w-10 h-10 rounded-full text-xl shrink-0"
                  style={{ background: TAB_COLORS[n.tab] ?? '#F5F1FF' }}
                >
                  {n.icon}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <span className="text-[14px]" style={{ color: '#1E1633', fontWeight: isUnread ? 600 : 400 }}>
                      {n.title}
                    </span>
                    <div className="flex items-center gap-1.5 shrink-0">
                      <span className="text-[11px]" style={{ color: '#948FA8' }}>{n.time}</span>
                      {isUnread && <div className="w-2 h-2 rounded-full" style={{ background: '#5B2FD9' }} />}
                    </div>
                  </div>
                  <p className="text-[13px] mt-0.5 line-clamp-1" style={{ color: '#6E6884' }}>{n.body}</p>
                </div>
              </button>
            );
          })}
      </div>
    </div>
  );
}
