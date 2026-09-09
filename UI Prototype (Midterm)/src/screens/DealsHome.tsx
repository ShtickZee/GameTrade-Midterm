import React, { useState, useEffect, useCallback } from 'react';
import { SectionHeader, BellIcon, GhostBtn, SmallBtn } from '../components/ui';

interface Props {
  onSearch: () => void;
  onBell: () => void;
  onListing: (id: string) => void;
  onMarket: () => void;
  showToast: (msg: string) => void;
}

const BANNERS = [
  {
    bg: 'linear-gradient(160deg, #241049 0%, #5B2FD9 60%, #7C5CFF 100%)',
    eyebrow: 'MEGA CONSOLE SALE',
    title: 'Up to 30% off certified pre-owned consoles',
    sub: 'PlayStation · Xbox · Switch',
    cta: 'Shop now',
    emoji: '🎮',
  },
  {
    bg: 'linear-gradient(135deg, #7C5CFF 0%, #FF7BD5 100%)',
    eyebrow: 'SPRING RESET SALE',
    title: 'Trade in your old console, level up',
    sub: 'Extra 10% trade-in credit this week',
    cta: 'Start trading',
    emoji: '🔄',
  },
  {
    bg: 'linear-gradient(135deg, #FF6B5E 0%, #FF9F68 100%)',
    eyebrow: '48 HOURS ONLY',
    title: 'Official Store Flash Drop',
    sub: 'While stocks last',
    cta: 'See deals',
    emoji: '⚡',
  },
];

const CATEGORIES = [
  { icon: '🎮', label: 'PlayStation', bg: '#EAF3FD' },
  { icon: '🟩', label: 'Xbox', bg: '#E8F5E8' },
  { icon: '🔴', label: 'Switch', bg: '#FDECEC' },
  { icon: '🕹️', label: 'Controllers', bg: '#F5F1FF' },
  { icon: '📦', label: 'Bundles', bg: '#FFF3D6' },
  { icon: '⚡', label: 'Deals of Day', bg: '#FFE7E4' },
  { icon: '🏪', label: 'Official Stores', bg: '#DFF7EF' },
  { icon: '🎧', label: 'Accessories', bg: '#EDEBFA' },
];

const FLASH_DEALS = [
  { id: 'L1', title: 'PS5 Slim — 1TB Disc', price: 449, was: 549, pct: 18, prog: 72, sold: 38, colors: ['#003087','#0070D1'] },
  { id: 'L2', title: 'Xbox Series X — 1TB', price: 389, was: 499, pct: 22, prog: 54, sold: 27, colors: ['#052a00','#107C10'] },
  { id: 'L3', title: 'Switch OLED — White', price: 279, was: 349, pct: 20, prog: 83, sold: 41, colors: ['#8b0000','#E60012'] },
  { id: 'L11', title: 'DualSense — Midnight', price: 54, was: 69, pct: 21, prog: 31, sold: 12, colors: ['#003087','#0070D1'] },
];

const STORES = [
  { icon: '🟦', name: 'PlayStation Direct', rating: '4.8 ★', items: '1.2k items', bg: '#EAF3FD' },
  { icon: '🟩', name: 'Xbox Official Store', rating: '4.7 ★', items: '890 items', bg: '#E8F5E8' },
  { icon: '🟥', name: 'Nintendo Auth Hub', rating: '4.9 ★', items: '650 items', bg: '#FDECEC' },
];

const DEALS_FOR_YOU = [
  { id: 'L1', title: 'PS5 Disc Edition (Certified Pre-Owned)', price: 419, was: 499, pct: 16, emoji: '🎮', colors: ['#003087','#0070D1'] },
  { id: 'L5', title: 'Xbox Series S Starter Bundle', price: 259, was: 329, pct: 21, emoji: '🟩', colors: ['#052a00','#107C10'] },
  { id: 'L9', title: 'Switch + Mario Kart 8 Bundle', price: 309, was: 379, pct: 18, emoji: '🔴', colors: ['#8b0000','#E60012'] },
  { id: 'L4', title: 'PS4 Pro 1TB — Refurbished', price: 179, was: 229, pct: 22, emoji: '🎮', colors: ['#003087','#0050A0'] },
];

// Live countdown from spec: 02:14:36
function useCountdown() {
  const [secs, setSecs] = useState(2 * 3600 + 14 * 60 + 36);
  useEffect(() => {
    const id = setInterval(() => setSecs(s => Math.max(0, s - 1)), 1000);
    return () => clearInterval(id);
  }, []);
  const h = Math.floor(secs / 3600);
  const m = Math.floor((secs % 3600) / 60);
  const s = secs % 60;
  return [
    String(h).padStart(2, '0'),
    String(m).padStart(2, '0'),
    String(s).padStart(2, '0'),
  ];
}

function CountdownTimer() {
  const parts = useCountdown();
  return (
    <div className="flex items-center gap-1">
      {parts.map((v, i) => (
        <React.Fragment key={i}>
          <div
            className="flex items-center justify-center rounded-[6px]"
            style={{ width: 28, height: 28, background: 'rgba(255,255,255,0.2)' }}
          >
            <span
              className="font-bold text-[14px] text-white"
              style={{ fontVariantNumeric: 'tabular-nums', letterSpacing: -0.5 }}
            >
              {v}
            </span>
          </div>
          {i < 2 && <span className="text-[14px] font-bold text-white">:</span>}
        </React.Fragment>
      ))}
    </div>
  );
}

export default function DealsHome({ onSearch, onBell, onListing, onMarket, showToast }: Props) {
  const [bannerIdx, setBannerIdx] = useState(0);
  const [skeleton, setSkeleton] = useState(true);

  // Auto-advance banner every 4s
  useEffect(() => {
    const id = setInterval(() => {
      setBannerIdx(i => (i + 1) % BANNERS.length);
    }, 4000);
    return () => clearInterval(id);
  }, []);

  // Simulate initial skeleton load
  useEffect(() => {
    const id = setTimeout(() => setSkeleton(false), 1200);
    return () => clearTimeout(id);
  }, []);

  const banner = BANNERS[bannerIdx];

  if (skeleton) return <DealsHomeSkeleton />;

  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      {/* Sticky header */}
      <div className="shrink-0 bg-white px-4 pt-2 pb-3" style={{ borderBottom: '1px solid #E9E6F0' }}>
        <div className="flex items-center justify-between mb-2.5">
          <div className="flex items-center gap-0.5">
            <span className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Game</span>
            <span className="text-[22px] font-bold" style={{ color: '#5B2FD9' }}>Trade!</span>
            <span className="text-[18px] ml-0.5">⚡</span>
          </div>
          <button
            onClick={onBell}
            className="relative flex items-center justify-center w-10 h-10 rounded-full"
            style={{ background: '#F5F1FF', color: '#3A3350' }}
          >
            <BellIcon size={20} />
            <div className="absolute top-2 right-2 w-2 h-2 rounded-full" style={{ background: '#E5484D', border: '1.5px solid #fff' }} />
          </button>
        </div>
        {/* Search */}
        <button
          onClick={onSearch}
          className="flex items-center gap-2.5 w-full h-11 px-4 rounded-full text-left"
          style={{ background: '#F5F1FF' }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6E6884" strokeWidth="2" strokeLinecap="round">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
          </svg>
          <span className="text-[15px]" style={{ color: '#948FA8' }}>Search PS5, Xbox Series X, Switch…</span>
        </button>
      </div>

      {/* Scroll content */}
      <div className="flex-1 overflow-y-auto no-scroll">

        {/* ── Zone B: Hero Banner Carousel ── */}
        <div className="px-4 pt-4">
          <div
            className="relative overflow-hidden rounded-[24px]"
            style={{ height: 180, background: banner.bg, transition: 'background 0.5s ease' }}
          >
            <div className="absolute inset-0 flex">
              <div className="flex-1 p-5 flex flex-col justify-center gap-1">
                <span
                  className="text-[10px] font-bold uppercase text-white"
                  style={{ opacity: 0.7, letterSpacing: '0.8px' }}
                >
                  {banner.eyebrow}
                </span>
                <h2 className="text-[20px] font-bold text-white leading-[1.25] line-clamp-2">
                  {banner.title}
                </h2>
                <p className="text-[13px] text-white" style={{ opacity: 0.8 }}>{banner.sub}</p>
                <button
                  onClick={onMarket}
                  className="self-start mt-1 px-3 py-1.5 rounded-[8px] text-[13px] font-semibold"
                  style={{ background: '#fff', color: '#5B2FD9' }}
                >
                  {banner.cta}
                </button>
              </div>
              <div
                className="w-36 flex items-center justify-center"
                style={{ fontSize: 80, transform: 'rotate(-6deg) translateX(8px)' }}
              >
                {banner.emoji}
              </div>
            </div>
          </div>

          {/* Banner dots */}
          <div className="flex items-center justify-center gap-1.5 mt-3">
            {BANNERS.map((_, i) => (
              <button
                key={i}
                onClick={() => setBannerIdx(i)}
                className="rounded-full"
                style={{
                  height: 6,
                  width: i === bannerIdx ? 16 : 6,
                  background: i === bannerIdx ? '#5B2FD9' : '#BDA6FF',
                  transition: 'width 0.3s cubic-bezier(0.2,0.8,0.2,1), background 0.3s',
                }}
              />
            ))}
          </div>
        </div>

        {/* ── Zone C: Category Grid ── */}
        <div className="mt-6">
          <SectionHeader title="Browse by category" action="See all" onAction={onMarket} />
          <div className="grid grid-cols-4 gap-y-4 gap-x-3 px-4 mt-3">
            {CATEGORIES.map((cat, i) => (
              <button
                key={i}
                onClick={onMarket}
                className="flex flex-col items-center gap-1.5 active:scale-[0.93]"
                style={{ transition: 'transform 0.15s' }}
              >
                <div
                  className="flex items-center justify-center rounded-[16px] text-[24px]"
                  style={{ width: 56, height: 56, background: cat.bg }}
                >
                  {cat.icon}
                </div>
                <span
                  className="text-[11px] font-medium text-center leading-tight"
                  style={{ color: '#3A3350', maxWidth: 64 }}
                >
                  {cat.label}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* ── Zone D: Flash Deals ── */}
        <div className="mt-6">
          {/* Header bar */}
          <div
            className="mx-4 flex items-center justify-between px-4 rounded-[16px] mb-3"
            style={{ height: 52, background: 'linear-gradient(135deg, #FF6B5E 0%, #FF9F68 100%)' }}
          >
            <span className="text-[17px] font-bold text-white">⚡ Flash Deals</span>
            <CountdownTimer />
          </div>

          {/* Deal cards row */}
          <div className="flex gap-3 px-4 overflow-x-auto no-scroll pb-1">
            {FLASH_DEALS.map(fd => (
              <button
                key={fd.id}
                onClick={() => onListing(fd.id)}
                className="flex flex-col rounded-[16px] overflow-hidden bg-white shrink-0 active:scale-[0.97] text-left"
                style={{ width: 160, boxShadow: '0 2px 8px rgba(30,22,51,0.06)', transition: 'transform 0.15s, box-shadow 0.15s' }}
              >
                <div className="relative flex items-center justify-center" style={{ height: 110, background: '#F6F5FA' }}>
                  <div className="absolute inset-0" style={{ background: `linear-gradient(135deg, ${fd.colors[0]} 0%, ${fd.colors[1]} 100%)`, opacity: 0.13 }} />
                  <span className="text-5xl relative">🎮</span>
                  <div className="absolute top-2 left-2">
                    <span className="inline-flex items-center h-[22px] px-2 rounded-[6px] text-[11px] font-bold text-white" style={{ background: '#FFB020' }}>
                      −{fd.pct}%
                    </span>
                  </div>
                </div>
                <div className="p-3 flex flex-col gap-1.5">
                  <p className="text-[13px] font-medium leading-tight line-clamp-2" style={{ color: '#1E1633' }}>{fd.title}</p>
                  <div className="flex items-center gap-1.5">
                    <span className="text-[14px] font-bold" style={{ color: '#1E1633' }}>${fd.price}</span>
                    <span className="text-[12px] line-through" style={{ color: '#948FA8' }}>${fd.was}</span>
                  </div>
                  {/* Stock progress */}
                  <div>
                    <div className="flex justify-between mb-1">
                      <span className="text-[10px]" style={{ color: '#6E6884' }}>{fd.sold} sold</span>
                      <span className="text-[10px] font-semibold" style={{ color: '#FF6B5E' }}>{fd.prog}%</span>
                    </div>
                    <div className="h-1.5 rounded-full" style={{ background: '#FFE3DE' }}>
                      <div className="h-full rounded-full" style={{ width: `${fd.prog}%`, background: 'linear-gradient(135deg, #FF6B5E 0%, #FF9F68 100%)', transition: 'width 0.8s ease-out' }} />
                    </div>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* ── Zone E: Official Stores ── */}
        <div className="mt-6">
          <SectionHeader title="Official stores" action="See all" onAction={onMarket} />
          <div className="flex gap-3 px-4 mt-3 overflow-x-auto no-scroll pb-1">
            {STORES.map((store, i) => (
              <div
                key={i}
                onClick={onMarket}
                className="flex items-center gap-3 p-3 rounded-[16px] bg-white cursor-pointer shrink-0 active:scale-[0.97]"
                style={{ width: 240, boxShadow: '0 2px 8px rgba(30,22,51,0.06)', transition: 'transform 0.15s' }}
              >
                <div className="flex items-center justify-center w-10 h-10 rounded-[10px] text-xl shrink-0"
                  style={{ background: store.bg }}>
                  {store.icon}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-1.5 flex-wrap">
                    <span className="text-[13px] font-semibold" style={{ color: '#1E1633' }}>{store.name}</span>
                    <span className="inline-flex h-[18px] px-1.5 rounded-full text-[9px] font-bold text-white" style={{ background: '#5B2FD9', lineHeight: '18px' }}>
                      Official
                    </span>
                  </div>
                  <span className="text-[11px]" style={{ color: '#948FA8' }}>{store.rating} · {store.items}</span>
                </div>
                <button
                  onClick={e => { e.stopPropagation(); showToast('Coming in v1.0'); }}
                  className="shrink-0 h-8 px-3 rounded-[10px] text-[13px] font-semibold"
                  style={{ border: '1.5px solid #5B2FD9', color: '#5B2FD9', background: '#fff' }}
                >
                  Visit
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* ── Zone F: Seasonal Banner ── */}
        <div className="mt-6 mx-4">
          <div
            onClick={onMarket}
            className="relative rounded-[20px] overflow-hidden p-5 cursor-pointer active:scale-[0.98]"
            style={{ minHeight: 150, background: 'linear-gradient(135deg, #7C5CFF 0%, #FF7BD5 100%)', transition: 'transform 0.15s' }}
          >
            <div className="max-w-[55%]">
              <span className="text-[9px] font-bold uppercase tracking-[0.8px] text-white" style={{ opacity: 0.8 }}>
                SEASONAL EVENT · ENDS APR 30
              </span>
              <h3 className="text-[22px] font-bold text-white mt-1 leading-tight">Spring Reset Sale</h3>
              <p className="text-[13px] text-white mt-0.5 mb-3" style={{ opacity: 0.85 }}>
                Consoles, bundles & trade-in bonuses
              </p>
              <span
                className="inline-flex h-8 px-3 items-center rounded-full text-[12px] font-semibold"
                style={{ background: '#fff', color: '#FF7BD5' }}
              >
                Explore the sale →
              </span>
            </div>
            {/* Decorative tilted thumbnails */}
            <div className="absolute right-4 top-1/2 -translate-y-1/2 flex gap-1">
              {['🎮','🕹️','📦'].map((e, i) => (
                <div
                  key={i}
                  className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl"
                  style={{
                    background: 'rgba(255,255,255,0.2)',
                    backdropFilter: 'blur(4px)',
                    transform: `rotate(${[-8, 4, -3][i]}deg)`,
                  }}
                >
                  {e}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* ── Zone G: Deals for You ── */}
        <div className="mt-6">
          <SectionHeader title="Deals for you" action="See all" onAction={onMarket} />
          <div className="grid grid-cols-2 gap-3 px-4 mt-3">
            {DEALS_FOR_YOU.map(d => (
              <button
                key={d.id}
                onClick={() => onListing(d.id)}
                className="flex flex-col rounded-[16px] overflow-hidden bg-white active:scale-[0.97] text-left"
                style={{ boxShadow: '0 2px 8px rgba(30,22,51,0.06)', transition: 'transform 0.15s, box-shadow 0.15s' }}
              >
                <div className="relative flex items-center justify-center" style={{ height: 110, background: '#F6F5FA' }}>
                  <div className="absolute inset-0" style={{ background: `linear-gradient(135deg, ${d.colors[0]} 0%, ${d.colors[1]} 100%)`, opacity: 0.12 }} />
                  <span className="text-5xl relative">{d.emoji}</span>
                  <div className="absolute top-2 left-2">
                    <span className="inline-flex items-center h-[22px] px-2 rounded-[6px] text-[11px] font-bold text-white" style={{ background: '#FFB020' }}>
                      −{d.pct}%
                    </span>
                  </div>
                </div>
                <div className="p-3">
                  <p className="text-[13px] font-medium leading-tight line-clamp-2 mb-1" style={{ color: '#1E1633' }}>{d.title}</p>
                  <div className="flex items-center gap-1.5">
                    <span className="text-[14px] font-bold" style={{ color: '#1E1633' }}>${d.price}</span>
                    <span className="text-[12px] line-through" style={{ color: '#948FA8' }}>${d.was}</span>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Infinite scroll hint */}
        <div className="flex items-center justify-center py-8">
          <div className="w-6 h-6 rounded-full border-2 border-t-transparent animate-spin" style={{ borderColor: '#5B2FD9', borderTopColor: 'transparent' }} />
        </div>
      </div>
    </div>
  );
}

// ── Skeleton (Frame 11) ───────────────────────────────────────────────────────

function SkimBlock({ w = '100%', h = 16, r = 8, className = '' }: { w?: number | string; h?: number; r?: number; className?: string }) {
  return (
    <div
      className={`shimmer-block ${className}`}
      style={{ width: w, height: h, borderRadius: r }}
    />
  );
}

function DealsHomeSkeleton() {
  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      {/* Header */}
      <div className="shrink-0 bg-white px-4 pt-2 pb-3" style={{ borderBottom: '1px solid #E9E6F0' }}>
        <div className="flex items-center justify-between mb-2.5">
          <SkimBlock w={140} h={28} r={8} />
          <SkimBlock w={40} h={40} r={20} />
        </div>
        <SkimBlock w="100%" h={44} r={22} />
      </div>
      <div className="flex-1 overflow-y-auto no-scroll px-4 py-4 flex flex-col gap-6">
        {/* Banner */}
        <SkimBlock w="100%" h={180} r={24} />
        {/* Category row */}
        <div className="flex gap-4 justify-between">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="flex flex-col items-center gap-2">
              <SkimBlock w={56} h={56} r={16} />
              <SkimBlock w={48} h={11} r={4} />
            </div>
          ))}
        </div>
        {/* Flash row */}
        <SkimBlock w="100%" h={52} r={16} />
        <div className="flex gap-3">
          {Array.from({ length: 3 }).map((_, i) => <SkimBlock key={i} w={160} h={190} r={16} />)}
        </div>
        {/* Deals grid */}
        <div className="grid grid-cols-2 gap-3">
          {Array.from({ length: 4 }).map((_, i) => <SkimBlock key={i} h={180} r={16} />)}
        </div>
      </div>
    </div>
  );
}
