import React, { useState } from 'react';
import {
  ListingCard, SkeletonCard, FilterChip, SegmentedControl,
  NavBar, GhostBtn, SectionHeader,
} from '../components/ui';
import { LISTINGS, Platform } from '../seed';

interface Props {
  onListing: (id: string) => void;
  onSearch: () => void;
  onFilters: () => void;
  showToast: (msg: string) => void;
  initialFilter?: string;
}

const PLATFORMS: Array<{ label: string; value: string | null }> = [
  { label: 'All', value: null },
  { label: 'PlayStation', value: 'PS5' },
  { label: 'Xbox', value: 'XBOX' },
  { label: 'Switch', value: 'SWITCH' },
];

const SECONDARY_FILTERS = ['Price ▾', 'Condition ▾', 'Accepts trades', 'Bundles', 'Near me'];

const FEATURED = [
  { id: 'F1', title: 'PS5 Disc Edition — 1TB', price: 430, seller: 'Jordan Lee', rating: '★ 4.9', listingId: 'L1' },
  { id: 'F2', title: 'Xbox Series X Bundle', price: 520, seller: 'Mia Torres', rating: '★ 5.0', listingId: 'L8' },
];

export default function Marketplace({ onListing, onSearch, onFilters, showToast, initialFilter }: Props) {
  const [platformFilter, setPlatformFilter] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [savedListings, setSavedListings] = useState<Set<string>>(new Set(['L2', 'L6']));

  const filtered = platformFilter
    ? LISTINGS.filter(l => l.platform === platformFilter || (platformFilter === 'PS5' && l.platform === 'PS4'))
    : LISTINGS.slice(0, 8);

  const switchPlatform = (val: string | null) => {
    setLoading(true);
    setPlatformFilter(val);
    setTimeout(() => setLoading(false), 600);
  };

  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      {/* Header */}
      <div className="shrink-0 bg-white px-4 pt-2 pb-3" style={{ borderBottom: '1px solid #E9E6F0' }}>
        <div className="flex items-center justify-between mb-3">
          <span className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Marketplace</span>
          <div className="flex items-center gap-2">
            <button
              onClick={onSearch}
              className="flex items-center justify-center w-10 h-10 rounded-full text-lg"
              style={{ background: '#F5F1FF' }}
            >
              🔍
            </button>
            <button
              onClick={onFilters}
              className="relative flex items-center justify-center w-10 h-10 rounded-full text-lg"
              style={{ background: '#F5F1FF' }}
            >
              ⚙️
              <div className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full" style={{ background: '#5B2FD9' }} />
            </button>
          </div>
        </div>

        {/* Platform chips */}
        <div className="flex gap-2 overflow-x-auto no-scroll pb-1">
          {PLATFORMS.map(p => (
            <FilterChip
              key={p.label}
              label={p.label}
              selected={platformFilter === p.value}
              onClick={() => switchPlatform(p.value)}
            />
          ))}
        </div>

        {/* Secondary filters */}
        <div className="flex gap-2 overflow-x-auto no-scroll pb-1 mt-2">
          {SECONDARY_FILTERS.map(f => (
            <FilterChip key={f} label={f} onClick={onFilters} />
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto no-scroll">
        {/* Featured */}
        <div className="mt-4">
          <div className="px-4 mb-2">
            <div className="flex items-center justify-between">
              <span className="text-[13px]" style={{ color: '#6E6884' }}>Featured — verified sellers</span>
              <GhostBtn onClick={() => showToast('Verification info coming in v1.0')}>Why verified?</GhostBtn>
            </div>
          </div>
          <div className="flex gap-3 px-4 overflow-x-auto no-scroll pb-1">
            {FEATURED.map(f => (
              <div
                key={f.id}
                onClick={() => onListing(f.listingId)}
                className="flex rounded-[20px] overflow-hidden cursor-pointer shrink-0"
                style={{
                  width: 320, height: 140,
                  background: 'linear-gradient(160deg, #241049 0%, #5B2FD9 60%, #7C5CFF 100%)',
                }}
              >
                <div className="flex-1 p-4 flex flex-col justify-between">
                  <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold text-white self-start"
                    style={{ background: '#16A06A' }}>
                    ✓ Verified
                  </div>
                  <div>
                    <p className="text-[17px] font-bold text-white leading-tight">{f.title}</p>
                    <p className="text-[20px] font-bold text-white">${f.price}</p>
                    <p className="text-[11px] text-white/80">{f.seller} · {f.rating}</p>
                  </div>
                </div>
                <div className="w-28 flex items-center justify-center text-6xl -rotate-6">🎮</div>
              </div>
            ))}
          </div>
        </div>

        {/* Results header */}
        <div className="flex items-center justify-between px-4 mt-4 mb-3">
          <span className="text-[13px]" style={{ color: '#6E6884' }}>
            {filtered.length * 31} listings
          </span>
          <button
            className="flex items-center h-7 px-3 rounded-full text-[12px] font-medium"
            style={{ background: '#F5F1FF', color: '#5B2FD9' }}
            onClick={onFilters}
          >
            Sort: Most recent ▾
          </button>
        </div>

        {/* Grid */}
        {loading ? (
          <div className="grid grid-cols-2 gap-3 px-4">
            {Array.from({ length: 6 }).map((_, i) => <SkeletonCard key={i} />)}
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3 px-4">
            {filtered.map(listing => (
              <ListingCard
                key={listing.id}
                listing={listing}
                saved={savedListings.has(listing.id)}
                onPress={() => onListing(listing.id)}
                onSave={() => {
                  const ns = new Set(savedListings);
                  if (ns.has(listing.id)) ns.delete(listing.id);
                  else ns.add(listing.id);
                  setSavedListings(ns);
                }}
              />
            ))}
          </div>
        )}

        {/* Infinite scroll hint */}
        <div className="flex items-center justify-center py-6">
          <div className="w-6 h-6 rounded-full border-2 border-[#5B2FD9] border-t-transparent animate-spin" />
        </div>
      </div>
    </div>
  );
}
