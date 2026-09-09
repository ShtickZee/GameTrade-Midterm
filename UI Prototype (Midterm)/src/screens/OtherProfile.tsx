import React, { useState } from 'react';
import {
  Avatar, VerifiedBadge, TopSellerBadge, Stars, ListingCard, SegmentedControl,
  PrimaryBtn, SecondaryBtn, IconBtn, ChevronLeft, ShareIcon,
} from '../components/ui';
import { LISTINGS, SELLERS } from '../seed';

interface Props {
  userId: string;
  onBack: () => void;
  onListing: (id: string) => void;
  showToast: (msg: string) => void;
}

const REVIEWS = [
  { name: 'Sam P.', rating: 5, text: 'PS5 exactly as described, smooth meetup.', date: '2 weeks ago' },
  { name: 'Ling C.', rating: 5, text: 'Fast replies, fair trader.', date: '1 month ago' },
];

export default function OtherProfile({ userId, onBack, onListing, showToast }: Props) {
  const seller = SELLERS[userId] ?? SELLERS.jordan;
  const [following, setFollowing] = useState(false);
  const [tab, setTab] = useState(0);

  const sellerListings = LISTINGS.filter(l => l.sellerId === userId).slice(0, 4);

  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      {/* Cover */}
      <div className="relative shrink-0" style={{ height: 120, background: 'linear-gradient(160deg, #241049 0%, #5B2FD9 60%, #7C5CFF 100%)' }}>
        <div className="absolute top-10 left-4 right-4 flex justify-between">
          <IconBtn onClick={onBack}><ChevronLeft size={18} color="#1E1633" /></IconBtn>
          <IconBtn onClick={() => showToast('Share link coming in v1.0')}><ShareIcon size={16} /></IconBtn>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll">
        {/* Identity - left aligned (distinguishes from own profile) */}
        <div className="px-4 -mt-11 pb-4">
          <Avatar size={88} ring initial={seller.name[0]} />
          <div className="flex items-center gap-2 mt-2 flex-wrap">
            <span className="text-[20px] font-bold" style={{ color: '#1E1633' }}>{seller.name}</span>
            {seller.verified && <VerifiedBadge />}
            {seller.topSeller && <TopSellerBadge />}
          </div>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-[14px]" style={{ color: '#6E6884' }}>{seller.handle}</span>
            <Stars rating={seller.rating} size={11} />
            <span className="text-[13px]" style={{ color: '#6E6884' }}>{seller.rating} ({seller.reviews})</span>
          </div>
          <span className="text-[12px]" style={{ color: '#948FA8' }}>Replies in {seller.responseTime}</span>

          {/* Stats */}
          <div className="flex rounded-[16px] overflow-hidden mt-3"
            style={{ background: 'linear-gradient(180deg, #fff 0%, #F5F1FF 100%)', border: '1px solid #E9E6F0' }}>
            {[
              { label: 'Listings', value: seller.listings },
              { label: 'Sold', value: seller.sold },
              { label: 'Rating', value: seller.rating },
            ].map((s, i) => (
              <div key={i} className={`flex-1 flex flex-col items-center py-4 ${i > 0 ? 'border-l' : ''}`}
                style={{ borderColor: '#E9E6F0' }}>
                <span className="text-[22px] font-bold" style={{ color: '#1E1633' }}>{s.value}</span>
                <span className="text-[12px]" style={{ color: '#6E6884' }}>{s.label}</span>
              </div>
            ))}
          </div>

          {/* Actions */}
          <div className="flex gap-3 mt-4">
            <PrimaryBtn
              onClick={() => setFollowing(!following)}
              className="flex-[1.4]"
              style={following ? { background: '#E9E1FF', color: '#45239E', boxShadow: 'none' } : {}}
            >
              {following ? 'Following ✓' : 'Follow'}
            </PrimaryBtn>
            <SecondaryBtn onClick={() => showToast('Chat coming in v1.0')} className="flex-1">
              Message
            </SecondaryBtn>
          </div>
        </div>

        {/* Tabs */}
        <div className="px-4 mb-3">
          <SegmentedControl
            options={[`Listings (${seller.listings})`, `Sold (${seller.sold})`, `Reviews (${seller.reviews})`]}
            selected={tab}
            onChange={setTab}
          />
        </div>

        {tab === 0 && (
          <div className="grid grid-cols-2 gap-3 px-4 pb-8">
            {sellerListings.map(l => (
              <ListingCard key={l.id} listing={l} onPress={() => onListing(l.id)} />
            ))}
          </div>
        )}

        {tab === 1 && (
          <div className="grid grid-cols-2 gap-3 px-4 pb-8">
            {sellerListings.map(l => (
              <div key={l.id} className="relative">
                <ListingCard listing={l} />
                <div className="absolute inset-0 flex items-center justify-center rounded-[20px]"
                  style={{ background: 'rgba(30,22,51,0.60)' }}>
                  <span className="text-white font-bold text-[14px] tracking-widest">SOLD</span>
                </div>
              </div>
            ))}
          </div>
        )}

        {tab === 2 && (
          <div className="flex flex-col gap-3 px-4 pb-8">
            {REVIEWS.map((r, i) => (
              <div key={i} className="bg-white rounded-[16px] p-4"
                style={{ border: '1px solid #E9E6F0' }}>
                <div className="flex items-center gap-2 mb-2">
                  <Avatar size={32} initial={r.name[0]} />
                  <div>
                    <span className="text-[14px] font-medium" style={{ color: '#1E1633' }}>{r.name}</span>
                    <div className="flex items-center gap-1">
                      <Stars rating={r.rating} size={11} />
                    </div>
                  </div>
                  <span className="ml-auto text-[12px]" style={{ color: '#948FA8' }}>{r.date}</span>
                </div>
                <p className="text-[14px]" style={{ color: '#3A3350' }}>{r.text}</p>
              </div>
            ))}
            <button onClick={() => showToast('Reviews coming in v1.0')}
              className="text-[14px] font-medium text-center py-3" style={{ color: '#5B2FD9' }}>
              See all {seller.reviews} reviews
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
