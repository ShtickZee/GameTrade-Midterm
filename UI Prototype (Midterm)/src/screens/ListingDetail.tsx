import React, { useState } from 'react';
import {
  PlatformTag, ConditionChip, DiscountBadge, VerifiedBadge, BundleBadge,
  Avatar, Stars, IconBtn, ChevronLeft, ShareIcon, GhostBtn, PrimaryBtn, SecondaryBtn,
  NavBar,
} from '../components/ui';
import { LISTINGS, SELLERS, getDiscount } from '../seed';

interface Props {
  listingId: string;
  onBack: () => void;
  onMakeOffer: (id: string) => void;
  onProposeTrade: (id: string) => void;
  onSellerProfile: (sellerId: string) => void;
  showToast: (msg: string) => void;
}

const INCLUDES = ['Original box ✓', '1× DualSense controller', 'HDMI cable', 'Power cable', '2 games included'];
const BUNDLE_ITEMS = [
  { name: 'Xbox Series X 1TB console', value: 380 },
  { name: 'Wireless Controller (Carbon Black)', value: 55 },
  { name: 'Wireless Controller (Robot White)', value: 55 },
  { name: 'Game pass bundle (Forza, Halo, Starfield, Sea of Stars, Ori)', value: 120 },
];

export default function ListingDetail({ listingId, onBack, onMakeOffer, onProposeTrade, onSellerProfile, showToast }: Props) {
  const listing = LISTINGS.find(l => l.id === listingId) ?? LISTINGS[0];
  const seller = SELLERS[listing.sellerId] ?? SELLERS.jordan;
  const [saved, setSaved] = useState(listing.saved ?? false);
  const [following, setFollowing] = useState(false);
  const [descExpanded, setDescExpanded] = useState(false);
  const [bundleExpanded, setBundleExpanded] = useState(true);
  const [imgIdx, setImgIdx] = useState(0);
  const isBundle = listing.id === 'L8';
  const discount = listing.was ? getDiscount(listing.price, listing.was) : null;
  const numImages = isBundle ? 5 : 4;

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Image Gallery */}
      <div className="relative shrink-0" style={{ height: 300, background: '#F6F5FA', overflow: 'hidden' }}>
        {/* Gradient bg */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="absolute inset-0"
            style={{
              background: listing.platform === 'XBOX'
                ? 'linear-gradient(135deg, #052a00 0%, #107C10 100%)'
                : 'linear-gradient(135deg, #003087 0%, #0070D1 100%)',
              opacity: 0.15,
            }}
          />
          <span style={{ fontSize: 120 }}>🎮</span>
        </div>

        {/* Photo counter */}
        <div className="absolute top-14 right-4 px-2 py-1 rounded-full text-[11px] font-bold text-white"
          style={{ background: 'rgba(30,22,51,0.5)' }}>
          {imgIdx + 1}/{numImages}
        </div>

        {/* Dots */}
        <div className="absolute bottom-3 left-0 right-0 flex items-center justify-center gap-1.5">
          {Array.from({ length: numImages }).map((_, i) => (
            <div
              key={i}
              onClick={() => setImgIdx(i)}
              className="rounded-full cursor-pointer"
              style={{
                height: 6,
                width: i === imgIdx ? 16 : 6,
                background: i === imgIdx ? '#fff' : 'rgba(255,255,255,0.5)',
                transition: 'width 0.3s',
              }}
            />
          ))}
        </div>

        {/* Controls */}
        <div className="absolute top-4 left-4 right-4 flex items-center justify-between" style={{ paddingTop: 20 }}>
          <IconBtn onClick={onBack}><ChevronLeft size={18} color="#1E1633" /></IconBtn>
          <div className="flex items-center gap-2">
            <IconBtn onClick={() => showToast('Share link coming in v1.0')}><ShareIcon size={16} /></IconBtn>
            <IconBtn onClick={() => setSaved(!saved)}>
              <span style={{ fontSize: 16, color: saved ? '#5B2FD9' : '#6E6884' }}>{saved ? '♥' : '♡'}</span>
            </IconBtn>
          </div>
        </div>
      </div>

      {/* Scrollable content */}
      <div className="flex-1 overflow-y-auto no-scroll">
        {/* Info card pulled up */}
        <div className="bg-white rounded-t-[24px] -mt-4 px-4 pt-5 pb-3" style={{ boxShadow: '0 -2px 12px rgba(30,22,51,0.06)' }}>
          <div className="flex items-center gap-2 mb-2">
            <PlatformTag platform={listing.platform} />
            {isBundle && <BundleBadge label="Bundle · 4 items" />}
          </div>
          <h1 className="text-[22px] font-bold leading-tight mb-2" style={{ color: '#1E1633' }}>
            {listing.title}
          </h1>
          <div className="flex items-center gap-3 mb-2">
            <span className="text-[26px] font-bold" style={{ color: '#1E1633' }}>${listing.price}</span>
            {listing.was && (
              <>
                <span className="text-[15px] line-through" style={{ color: '#948FA8' }}>${listing.was}</span>
                {discount && <DiscountBadge pct={discount} />}
              </>
            )}
          </div>
          <div className="flex items-center gap-2">
            <ConditionChip condition={listing.condition} />
            <span className="text-[13px]" style={{ color: '#6E6884' }}>📍 {listing.location}</span>
          </div>
        </div>

        {/* Bundle contents */}
        {isBundle && (
          <div className="mx-4 mt-3 rounded-[16px] overflow-hidden" style={{ border: '1px solid #E9E6F0' }}>
            <button
              onClick={() => setBundleExpanded(!bundleExpanded)}
              className="flex items-center justify-between w-full px-4 py-3"
            >
              <span className="text-[15px] font-semibold" style={{ color: '#1E1633' }}>Bundle contents (4)</span>
              <div className="flex items-center gap-2">
                <span className="text-[13px]" style={{ color: '#948FA8', textDecoration: 'line-through' }}>Value $610</span>
                <span style={{ transform: bundleExpanded ? 'rotate(180deg)' : 'rotate(0)', transition: 'transform 0.3s', fontSize: 14, color: '#6E6884' }}>▾</span>
              </div>
            </button>
            {bundleExpanded && (
              <div>
                {BUNDLE_ITEMS.map((item, i) => (
                  <div key={i} className="flex items-center gap-3 px-4 py-2.5"
                    style={{ borderTop: '1px solid #E9E6F0' }}>
                    <div className="w-12 h-12 rounded-[10px] flex items-center justify-center text-xl"
                      style={{ background: '#F5F1FF' }}>🎮</div>
                    <span className="flex-1 text-[14px] font-medium" style={{ color: '#1E1633' }}>{item.name}</span>
                    <span className="text-[13px]" style={{ color: '#6E6884' }}>${item.value}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* What's included (non-bundle) */}
        {!isBundle && (
          <div className="px-4 mt-4">
            <p className="text-[15px] font-semibold mb-2" style={{ color: '#1E1633' }}>What's included</p>
            <div className="flex flex-wrap gap-2">
              {INCLUDES.map((item, i) => (
                <span
                  key={i}
                  className="flex items-center gap-1 px-3 py-1 rounded-full text-[13px]"
                  style={{ background: '#F5F1FF', color: '#45239E' }}
                >
                  {item}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Seller */}
        <div className="mx-4 mt-4">
          <button
            onClick={() => onSellerProfile(seller.id)}
            className="flex items-center gap-3 p-4 rounded-[16px] w-full text-left"
            style={{ border: '1px solid #E9E6F0', background: 'linear-gradient(180deg, #fff 0%, #F5F1FF 100%)' }}
          >
            <Avatar size={48} ring initial={seller.name[0]} />
            <div className="flex-1">
              <div className="flex items-center gap-1.5">
                <span className="text-[15px] font-semibold" style={{ color: '#1E1633' }}>{seller.name}</span>
                <VerifiedBadge />
              </div>
              <div className="flex items-center gap-1 mt-0.5">
                <Stars rating={seller.rating} size={11} />
                <span className="text-[13px]" style={{ color: '#6E6884' }}>{seller.rating} ({seller.reviews})</span>
              </div>
              <span className="text-[11px]" style={{ color: '#948FA8' }}>Replies within {seller.responseTime}</span>
            </div>
            <button
              onClick={e => { e.stopPropagation(); setFollowing(!following); }}
              className="px-3 py-1.5 rounded-[10px] text-[13px] font-semibold"
              style={following
                ? { background: '#E9E1FF', color: '#45239E' }
                : { background: 'linear-gradient(90deg,#5B2FD9,#7C5CFF)', color: '#fff' }
              }
            >
              {following ? 'Following ✓' : 'Follow'}
            </button>
          </button>
        </div>

        {/* Description */}
        <div className="px-4 mt-4">
          <p className="text-[15px] font-semibold mb-2" style={{ color: '#1E1633' }}>Description</p>
          <p
            className="text-[15px] leading-relaxed"
            style={{ color: '#3A3350', WebkitLineClamp: descExpanded ? undefined : 4, display: '-webkit-box', WebkitBoxOrient: 'vertical', overflow: descExpanded ? 'visible' : 'hidden' }}
          >
            {listing.description ?? "Barely used console, bought last year. Always kept in a ventilated shelf, no scratches. Selling because I switched to a different platform. Open to reasonable trades."}
          </p>
          {!descExpanded && (
            <GhostBtn onClick={() => setDescExpanded(true)} className="mt-1 px-0">Read more</GhostBtn>
          )}
        </div>

        {/* Safety */}
        <div className="mx-4 mt-3 mb-28 flex items-center gap-2 px-3 py-2.5 rounded-[12px]"
          style={{ background: '#F5F1FF' }}>
          <span style={{ color: '#5B2FD9', fontSize: 16 }}>🛡️</span>
          <span className="text-[13px]" style={{ color: '#6E6884' }}>Meet in public places. Never pay in advance.</span>
        </div>
      </div>

      {/* Sticky bottom action bar */}
      <div
        className="shrink-0 flex items-center gap-2 px-4 pt-3 pb-5"
        style={{ background: '#fff', boxShadow: '0 -4px 24px rgba(30,22,51,0.10)' }}
      >
        <button
          onClick={() => showToast('Chat coming in v1.0')}
          className="flex items-center justify-center w-12 h-12 rounded-full border-[1.5px]"
          style={{ borderColor: '#5B2FD9', color: '#5B2FD9' }}
        >
          💬
        </button>
        <SecondaryBtn onClick={() => onProposeTrade(listing.id)} className="flex-1">
          🔄 Trade
        </SecondaryBtn>
        <PrimaryBtn onClick={() => onMakeOffer(listing.id)} className="flex-[1.4]">
          Make Offer ${listing.price}
        </PrimaryBtn>
      </div>
    </div>
  );
}
