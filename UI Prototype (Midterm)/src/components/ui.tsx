import React, { ReactNode } from 'react';
import { PLATFORM_COLORS, PLATFORM_BG, Platform, getDiscount } from '../seed';

// --- Buttons ---

interface BtnProps {
  children: ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  loading?: boolean;
  className?: string;
  style?: React.CSSProperties;
}

export function PrimaryBtn({ children, onClick, disabled, loading, className = '', style }: BtnProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`flex items-center justify-center gap-2 font-semibold text-[16px] text-white rounded-[14px] h-[52px] px-6 transition-all active:scale-[0.97] ${className}`}
      style={{
        background: disabled ? '#E9E1FF' : 'linear-gradient(90deg, #5B2FD9 0%, #7C5CFF 100%)',
        color: disabled ? '#948FA8' : '#fff',
        boxShadow: disabled ? 'none' : '0 6px 16px rgba(91,47,217,0.25)',
        ...style,
      }}
    >
      {loading ? <Spinner /> : children}
    </button>
  );
}

export function SecondaryBtn({ children, onClick, className = '' }: BtnProps) {
  return (
    <button
      onClick={onClick}
      className={`flex items-center justify-center gap-2 font-semibold text-[16px] rounded-[14px] h-[52px] px-6 transition-all active:scale-[0.97] border-[1.5px] ${className}`}
      style={{ color: '#5B2FD9', borderColor: '#5B2FD9', background: '#fff' }}
    >
      {children}
    </button>
  );
}

export function GhostBtn({ children, onClick, className = '', danger }: BtnProps & { danger?: boolean }) {
  return (
    <button
      onClick={onClick}
      className={`flex items-center justify-center gap-1 font-medium text-[15px] h-[44px] px-3 transition-all active:opacity-70 ${className}`}
      style={{ color: danger ? '#E5484D' : '#5B2FD9' }}
    >
      {children}
    </button>
  );
}

export function SmallBtn({ children, onClick, outlined, className = '' }: BtnProps & { outlined?: boolean }) {
  return (
    <button
      onClick={onClick}
      className={`flex items-center justify-center h-9 px-4 rounded-[10px] text-[14px] font-semibold transition-all active:scale-[0.97] ${className}`}
      style={outlined
        ? { color: '#5B2FD9', border: '1.5px solid #5B2FD9', background: '#fff' }
        : { background: 'linear-gradient(90deg, #5B2FD9 0%, #7C5CFF 100%)', color: '#fff' }
      }
    >
      {children}
    </button>
  );
}

export function IconBtn({ children, onClick, size = 40, className = '' }: { children: ReactNode; onClick?: () => void; size?: number; className?: string }) {
  return (
    <button
      onClick={onClick}
      className={`flex items-center justify-center rounded-full transition-all active:scale-[0.93] ${className}`}
      style={{ width: size, height: size, background: 'rgba(255,255,255,0.92)', boxShadow: '0 2px 8px rgba(30,22,51,0.10)' }}
    >
      {children}
    </button>
  );
}

// --- Chips & Tags ---

export function FilterChip({ label, selected, onClick, icon }: { label: string; selected?: boolean; onClick?: () => void; icon?: ReactNode }) {
  return (
    <button
      onClick={onClick}
      className="flex items-center gap-1.5 h-9 px-4 rounded-full text-[13px] font-medium whitespace-nowrap transition-all active:scale-[0.97]"
      style={selected
        ? { background: '#5B2FD9', color: '#fff', border: 'none' }
        : { background: '#fff', color: '#3A3350', border: '1px solid #E9E6F0' }
      }
    >
      {selected && <CheckIcon size={12} color="#fff" />}
      {icon}
      {label}
    </button>
  );
}

export function ConditionChip({ condition }: { condition: string }) {
  return (
    <span
      className="inline-flex items-center h-6 px-2 rounded-[8px] text-[11px] font-medium"
      style={{ background: '#E9E1FF', color: '#45239E' }}
    >
      {condition}
    </span>
  );
}

export function PlatformTag({ platform }: { platform: Platform }) {
  return (
    <span
      className="inline-flex items-center h-5 px-1.5 rounded-[6px] text-[10px] font-bold uppercase"
      style={{ background: PLATFORM_BG[platform], color: PLATFORM_COLORS[platform] }}
    >
      {platform}
    </span>
  );
}

export function DiscountBadge({ pct }: { pct: number }) {
  return (
    <span className="inline-flex items-center h-[22px] px-2 rounded-[6px] text-[11px] font-bold text-white"
      style={{ background: '#FFB020' }}>
      −{pct}%
    </span>
  );
}

export function FlashBadge() {
  return (
    <span className="inline-flex items-center gap-1 h-[22px] px-2 rounded-full text-[11px] font-bold text-white"
      style={{ background: '#FF6B5E' }}>
      ⚡ FLASH
    </span>
  );
}

export function VerifiedBadge() {
  return (
    <span className="inline-flex items-center gap-1 h-5 px-2 rounded-full text-[10px] font-bold text-white"
      style={{ background: '#16A06A' }}>
      ✓ Verified
    </span>
  );
}

export function OfficialBadge() {
  return (
    <span className="inline-flex items-center h-5 px-2 rounded-full text-[10px] font-bold text-white"
      style={{ background: '#5B2FD9' }}>
      Official Store
    </span>
  );
}

export function BundleBadge({ label }: { label: string }) {
  return (
    <span className="inline-flex items-center gap-1 h-6 px-2 rounded-[8px] text-[11px] font-semibold text-white"
      style={{ background: '#5B2FD9' }}>
      📦 {label}
    </span>
  );
}

export function PriceDropBadge({ pct }: { pct: number }) {
  return (
    <span className="inline-flex items-center gap-1 h-[22px] px-2 rounded-[6px] text-[11px] font-bold text-white"
      style={{ background: 'linear-gradient(135deg, #23C997 0%, #4BE3B2 100%)' }}>
      ↓ Price dropped {pct}%
    </span>
  );
}

export function TopSellerBadge() {
  return (
    <span className="inline-flex items-center gap-1 h-5 px-2 rounded-full text-[10px] font-bold"
      style={{ background: '#FFF3D6', color: '#FFB020' }}>
      🏆 Top Seller
    </span>
  );
}

export function StatusBadge({ status }: { status: 'Pending' | 'Accepted' | 'Declined' }) {
  const styles = {
    Pending: { bg: '#FFF3D6', color: '#E8A200' },
    Accepted: { bg: '#DFF7EF', color: '#16A06A' },
    Declined: { bg: '#FDECEC', color: '#E5484D' },
  };
  return (
    <span className="inline-flex items-center h-6 px-2 rounded-[6px] text-[11px] font-semibold"
      style={{ background: styles[status].bg, color: styles[status].color }}>
      {status}
    </span>
  );
}

// --- Avatar ---

export function Avatar({ size = 40, ring = false, initial = '?', className = '' }: {
  size?: number; ring?: boolean; initial?: string; className?: string;
}) {
  const inner = (
    <div
      className={`flex items-center justify-center rounded-full font-semibold ${className}`}
      style={{
        width: ring ? size - 6 : size,
        height: ring ? size - 6 : size,
        background: '#E9E1FF',
        color: '#45239E',
        fontSize: size * 0.35,
      }}
    >
      {initial}
    </div>
  );
  if (!ring) return inner;
  return (
    <div
      className="flex items-center justify-center rounded-full avatar-ring"
      style={{ width: size, height: size, padding: 3 }}
    >
      {inner}
    </div>
  );
}

// --- Rating ---

export function Stars({ rating, size = 12 }: { rating: number; size?: number }) {
  return (
    <span className="flex items-center gap-0.5" style={{ fontSize: size }}>
      {[1,2,3,4,5].map(i => (
        <span key={i} style={{ color: i <= Math.round(rating) ? '#FFB020' : '#E9E6F0' }}>★</span>
      ))}
    </span>
  );
}

// --- Search Field ---

export function SearchField({ placeholder, value, onChange, onClick, readonly }: {
  placeholder?: string; value?: string; onChange?: (v: string) => void; onClick?: () => void; readonly?: boolean;
}) {
  return (
    <div
      className="flex items-center gap-2 h-11 px-4 rounded-full"
      style={{ background: '#F5F1FF' }}
      onClick={onClick}
    >
      <span style={{ color: '#6E6884', fontSize: 16 }}>🔍</span>
      {readonly ? (
        <span className="flex-1 text-[16px]" style={{ color: '#948FA8' }}>
          {placeholder}
        </span>
      ) : (
        <input
          className="flex-1 bg-transparent outline-none text-[16px]"
          style={{ color: '#1E1633' }}
          placeholder={placeholder}
          value={value}
          onChange={e => onChange?.(e.target.value)}
        />
      )}
    </div>
  );
}

// --- Segmented Control ---

export function SegmentedControl({ options, selected, onChange }: {
  options: string[]; selected: number; onChange: (i: number) => void;
}) {
  return (
    <div
      className="flex items-center p-1 rounded-xl"
      style={{ background: '#F5F1FF', height: 40 }}
    >
      {options.map((opt, i) => (
        <button
          key={i}
          onClick={() => onChange(i)}
          className="flex-1 h-8 rounded-[10px] text-[13px] transition-all"
          style={selected === i
            ? { background: '#fff', color: '#1E1633', fontWeight: 600, boxShadow: '0 1px 4px rgba(30,22,51,0.10)' }
            : { color: '#6E6884', fontWeight: 500 }
          }
        >
          {opt}
        </button>
      ))}
    </div>
  );
}

// --- Nav Bar ---

export function NavBar({ title, onBack, right, transparent }: {
  title?: string; onBack?: () => void; right?: ReactNode; transparent?: boolean;
}) {
  return (
    <div
      className="flex items-center px-4 h-14 gap-2 shrink-0"
      style={{
        background: transparent ? 'transparent' : '#fff',
        borderBottom: transparent ? 'none' : '1px solid #E9E6F0',
      }}
    >
      {onBack && (
        <button onClick={onBack} className="flex items-center justify-center w-10 h-10 rounded-full transition-all active:bg-[#F5F1FF]">
          <ChevronLeft />
        </button>
      )}
      {title && (
        <span className="flex-1 text-[18px] font-semibold" style={{ color: '#1E1633' }}>{title}</span>
      )}
      {right && <div className="flex items-center gap-2 ml-auto">{right}</div>}
    </div>
  );
}

// --- Toast ---

let toastTimer: ReturnType<typeof setTimeout>;
export function Toast({ message, visible }: { message: string; visible: boolean }) {
  if (!visible) return null;
  return (
    <div
      className="fixed bottom-[100px] left-1/2 -translate-x-1/2 flex items-center gap-2 px-4 py-3 rounded-[14px] text-[14px] text-white font-medium z-[200] fade-enter"
      style={{ background: 'rgba(30,22,51,0.92)', maxWidth: 320, width: 'max-content' }}
    >
      ℹ️ {message}
    </div>
  );
}

// --- Stock Progress ---

export function StockProgress({ pct, sold }: { pct: number; sold: number }) {
  return (
    <div className="flex flex-col gap-1">
      <div className="flex justify-between">
        <span className="text-[11px]" style={{ color: '#6E6884' }}>{sold} sold</span>
        <span className="text-[11px] font-semibold" style={{ color: '#FF6B5E' }}>{pct}% claimed</span>
      </div>
      <div className="h-1.5 rounded-full" style={{ background: '#FFE3DE' }}>
        <div
          className="h-full rounded-full"
          style={{ width: `${pct}%`, background: 'linear-gradient(135deg, #FF6B5E 0%, #FF9F68 100%)', transition: 'width 0.8s ease-out' }}
        />
      </div>
    </div>
  );
}

// --- Listing Card ---

import { Listing, SELLERS } from '../seed';

interface ListingCardProps {
  listing: Listing;
  onPress?: () => void;
  saved?: boolean;
  onSave?: () => void;
}

export const CONSOLE_EMOJIS: Record<Platform, string> = {
  PS5: '🎮', PS4: '🎮', XBOX: '🎮', SWITCH: '🕹️',
};
export const CONSOLE_COLORS: Record<Platform, string[]> = {
  PS5: ['#003087', '#0070D1'],
  PS4: ['#003087', '#0050A0'],
  XBOX: ['#052a00', '#107C10'],
  SWITCH: ['#8b0000', '#E60012'],
};

export function ListingCard({ listing, onPress, saved, onSave }: ListingCardProps) {
  const [isSaved, setIsSaved] = React.useState(saved ?? listing.saved ?? false);
  const [heartAnim, setHeartAnim] = React.useState(false);
  const [pressed, setPressed] = React.useState(false);
  const discount = listing.was ? getDiscount(listing.price, listing.was) : null;
  const seller = SELLERS[listing.sellerId];
  const sellerInitial = seller?.name?.[0] ?? '?';
  const sellerName = seller?.name ?? listing.sellerId;
  const colors = CONSOLE_COLORS[listing.platform];

  const toggleSave = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsSaved(!isSaved);
    setHeartAnim(true);
    setTimeout(() => setHeartAnim(false), 300);
    onSave?.();
  };

  return (
    <div
      onClick={onPress}
      onMouseDown={() => setPressed(true)}
      onMouseUp={() => setPressed(false)}
      onMouseLeave={() => setPressed(false)}
      onTouchStart={() => setPressed(true)}
      onTouchEnd={() => setPressed(false)}
      className="flex flex-col rounded-[20px] overflow-hidden bg-white cursor-pointer"
      style={{
        boxShadow: pressed ? '0 6px 16px rgba(91,47,217,0.12)' : '0 2px 8px rgba(30,22,51,0.06)',
        transform: pressed ? 'scale(0.97)' : 'scale(1)',
        transition: 'transform 0.15s ease-out, box-shadow 0.15s ease-out',
      }}
    >
      {/* Image area */}
      <div className="relative" style={{ aspectRatio: '171/128', background: '#F6F5FA' }}>
        {/* Gradient tint */}
        <div className="absolute inset-0"
          style={{ background: `linear-gradient(135deg, ${colors[0]} 0%, ${colors[1]} 100%)`, opacity: 0.14 }}
        />
        <div className="absolute inset-0 flex items-center justify-center text-5xl">
          {CONSOLE_EMOJIS[listing.platform]}
        </div>
        {/* Platform tag */}
        <div className="absolute top-2 left-2">
          <PlatformTag platform={listing.platform} />
        </div>
        {/* Heart */}
        <button
          onClick={toggleSave}
          className="absolute top-2 right-2 flex items-center justify-center w-7 h-7 rounded-full"
          style={{ background: 'rgba(255,255,255,0.90)' }}
        >
          <span
            style={{
              fontSize: 14,
              color: isSaved ? '#5B2FD9' : '#6E6884',
              display: 'block',
              animation: heartAnim ? 'heart-pop 0.25s ease' : 'none',
            }}
          >
            {isSaved ? '♥' : '♡'}
          </span>
        </button>
        {/* Bundle badge */}
        {listing.bundle && (
          <div className="absolute bottom-2 left-2">
            <BundleBadge label={listing.bundle} />
          </div>
        )}
      </div>

      {/* Content */}
      <div className="flex flex-col gap-1 p-3">
        <p className="text-[14px] font-medium leading-[1.3] line-clamp-2" style={{ color: '#1E1633' }}>
          {listing.title}
        </p>
        <div className="flex items-center gap-2 mt-0.5">
          <span className="text-[17px] font-bold" style={{ color: '#1E1633' }}>${listing.price}</span>
          {listing.was && (
            <>
              <span className="text-[12px] line-through" style={{ color: '#948FA8' }}>${listing.was}</span>
              {discount && <DiscountBadge pct={discount} />}
            </>
          )}
        </div>
        {/* Meta row: condition chip + seller */}
        <div className="flex items-center gap-1.5 mt-0.5 flex-wrap">
          <ConditionChip condition={listing.condition} />
          <span style={{ color: '#948FA8', fontSize: 10 }}>·</span>
          {/* Seller avatar + name */}
          <div className="flex items-center gap-1">
            <div
              className="flex items-center justify-center rounded-full text-[8px] font-bold shrink-0"
              style={{ width: 16, height: 16, background: '#E9E1FF', color: '#45239E' }}
            >
              {sellerInitial}
            </div>
            <span className="text-[12px]" style={{ color: '#6E6884' }}>{sellerName}</span>
          </div>
        </div>
        {/* Location */}
        <div className="flex items-center gap-1 mt-0.5">
          <span style={{ fontSize: 10, color: '#948FA8' }}>📍</span>
          <span className="text-[12px]" style={{ color: '#948FA8' }}>{listing.location}</span>
        </div>
      </div>
    </div>
  );
}

// --- Deal Card ---

export function DealCard({ listing, onPress }: { listing: Listing; onPress?: () => void }) {
  const discount = listing.was ? getDiscount(listing.price, listing.was) : null;
  return (
    <div
      onClick={onPress}
      className="flex flex-col rounded-[16px] overflow-hidden bg-white cursor-pointer shrink-0"
      style={{ width: 160, boxShadow: '0 2px 8px rgba(30,22,51,0.06)' }}
    >
      <div className="relative flex items-center justify-center text-4xl"
        style={{ height: 120, background: '#F6F5FA' }}>
        <div className="absolute inset-0"
          style={{ background: `linear-gradient(135deg, ${CONSOLE_COLORS[listing.platform][0]} 0%, ${CONSOLE_COLORS[listing.platform][1]} 100%)`, opacity: 0.12 }} />
        <span className="text-4xl">{CONSOLE_EMOJIS[listing.platform]}</span>
        {discount && (
          <div className="absolute top-2 left-2"><DiscountBadge pct={discount} /></div>
        )}
      </div>
      <div className="p-3 flex flex-col gap-1">
        <p className="text-[13px] font-medium line-clamp-2 leading-tight" style={{ color: '#1E1633' }}>
          {listing.title}
        </p>
        <div className="flex items-center gap-1.5">
          <span className="text-[13px] font-bold" style={{ color: '#1E1633' }}>${listing.price}</span>
          {listing.was && <span className="text-[11px] line-through" style={{ color: '#948FA8' }}>${listing.was}</span>}
        </div>
      </div>
    </div>
  );
}

// --- Seller Card ---

export function SellerCard({ seller, onPress, onFollow }: {
  seller: import('../seed').Seller; onPress?: () => void; onFollow?: () => void;
}) {
  const [following, setFollowing] = React.useState(false);
  return (
    <div
      onClick={onPress}
      className="flex items-center gap-3 p-4 rounded-[16px] bg-white cursor-pointer"
      style={{ boxShadow: '0 2px 8px rgba(30,22,51,0.06)', border: '1px solid #E9E6F0' }}
    >
      <Avatar size={48} ring initial={seller.name[0]} />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-1.5 flex-wrap">
          <span className="font-medium text-[15px]" style={{ color: '#1E1633' }}>{seller.name}</span>
          {seller.verified && <VerifiedBadge />}
          {seller.topSeller && <TopSellerBadge />}
        </div>
        <div className="flex items-center gap-1 mt-0.5">
          <Stars rating={seller.rating} size={11} />
          <span className="text-[13px]" style={{ color: '#6E6884' }}>{seller.rating} ({seller.reviews})</span>
        </div>
        {seller.responseTime && (
          <span className="text-[11px]" style={{ color: '#948FA8' }}>Replies within {seller.responseTime}</span>
        )}
      </div>
      <SmallBtn outlined onClick={() => { setFollowing(!following); }}>
        {following ? 'Following ✓' : 'Follow'}
      </SmallBtn>
    </div>
  );
}

// --- Offer Card ---

export function OfferCard({
  type, title, listingThumb, counterparty, offerText, time, status, onAccept, onDecline,
}: {
  type: 'incoming' | 'sent';
  title: string;
  listingThumb?: string;
  counterparty: string;
  offerText: string;
  time: string;
  status: 'Pending' | 'Accepted' | 'Declined';
  onAccept?: () => void;
  onDecline?: () => void;
}) {
  const [st, setSt] = React.useState(status);
  return (
    <div
      className="rounded-[16px] overflow-hidden"
      style={{
        background: 'linear-gradient(180deg, #FFFFFF 0%, #F5F1FF 100%)',
        border: '1px solid #E9E6F0',
        opacity: st === 'Declined' ? 0.6 : 1,
        transition: 'opacity 0.3s',
      }}
    >
      <div className="flex items-start gap-3 p-4">
        {/* Listing thumb */}
        <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0"
          style={{ background: '#F5F1FF' }}>🎮</div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <Avatar size={24} initial={counterparty[0]} />
            <span className="text-[15px] font-medium" style={{ color: '#1E1633' }}>{counterparty}</span>
          </div>
          <p className="text-[15px] mt-0.5" style={{ color: '#3A3350' }}>
            <span style={{ color: '#5B2FD9', fontWeight: 600 }}>{offerText}</span>
            {' on '}
            <span className="font-medium">{title}</span>
          </p>
          <p className="text-[11px] mt-0.5" style={{ color: '#948FA8' }}>{time}</p>
        </div>
        <StatusBadge status={st} />
      </div>
      {type === 'incoming' && st === 'Pending' && (
        <div className="flex gap-2 px-4 pb-4">
          <button
            onClick={() => setSt('Declined')}
            className="flex-1 h-10 rounded-[10px] text-[14px] font-semibold"
            style={{ background: '#FDECEC', color: '#E5484D' }}
          >
            Decline
          </button>
          <button
            onClick={() => setSt('Accepted')}
            className="flex-1 h-10 rounded-[10px] text-[14px] font-semibold text-white"
            style={{ background: 'linear-gradient(90deg, #5B2FD9 0%, #7C5CFF 100%)' }}
          >
            Accept
          </button>
        </div>
      )}
    </div>
  );
}

// --- Countdown Timer ---

export function CountdownTimer({ dark }: { dark?: boolean }) {
  return (
    <div className="flex items-center gap-1 px-2 py-1 rounded-[8px]"
      style={{ background: dark ? 'transparent' : '#1E1633' }}>
      {['02', '14', '36'].map((v, i) => (
        <React.Fragment key={i}>
          <div className="flex items-center justify-center rounded-[6px] w-[26px] h-[26px]"
            style={{ background: dark ? 'rgba(255,255,255,0.2)' : '#fff' }}>
            <span className="font-bold text-[14px]" style={{ color: dark ? '#FF6B5E' : '#1E1633', fontVariantNumeric: 'tabular-nums' }}>
              {v}
            </span>
          </div>
          {i < 2 && <span className="font-bold text-[14px] text-white">:</span>}
        </React.Fragment>
      ))}
    </div>
  );
}

// --- Skeleton ---

export function SkeletonCard() {
  return (
    <div className="flex flex-col rounded-[20px] overflow-hidden bg-white" style={{ boxShadow: '0 2px 8px rgba(30,22,51,0.06)' }}>
      <div className="shimmer-block" style={{ height: 128 }} />
      <div className="p-3 flex flex-col gap-2">
        <div className="shimmer-block h-4 rounded" style={{ width: '80%' }} />
        <div className="shimmer-block h-3 rounded" style={{ width: '50%' }} />
        <div className="shimmer-block h-5 rounded" style={{ width: '60%' }} />
      </div>
    </div>
  );
}

// --- Empty State ---

export function EmptyState({ icon, title, sub, cta, onCta }: {
  icon?: string; title: string; sub: string; cta?: string; onCta?: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center gap-4 py-16 px-8">
      {icon && <div className="text-[80px]">{icon}</div>}
      <div className="flex flex-col items-center gap-2 text-center">
        <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>{title}</span>
        <span className="text-[13px] leading-relaxed" style={{ color: '#6E6884' }}>{sub}</span>
      </div>
      {cta && <PrimaryBtn onClick={onCta}>{cta}</PrimaryBtn>}
    </div>
  );
}

// --- List Row ---

export function ListRow({ icon, label, trailing, value, onPress }: {
  icon: string; label: string; trailing?: boolean; value?: string; onPress?: () => void;
}) {
  return (
    <button
      onClick={onPress}
      className="flex items-center gap-3 h-14 px-4 w-full text-left"
      style={{ borderBottom: '1px solid #E9E6F0' }}
    >
      <div className="flex items-center justify-center w-9 h-9 rounded-[10px] text-[18px]"
        style={{ background: '#F5F1FF' }}>
        {icon}
      </div>
      <span className="flex-1 text-[15px] font-medium" style={{ color: '#1E1633' }}>{label}</span>
      {value && <span className="text-[13px]" style={{ color: '#948FA8' }}>{value}</span>}
      {trailing && <ChevronRight />}
    </button>
  );
}

// --- Icons ---

export function ChevronLeft({ size = 20, color = '#1E1633' }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none">
      <path d="M13 4l-6 6 6 6" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function ChevronRight({ size = 20, color = '#948FA8' }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill="none">
      <path d="M7 4l6 6-6 6" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function CheckIcon({ size = 14, color = '#5B2FD9' }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none">
      <path d="M2 7l3.5 3.5L12 4" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function HeartIcon({ filled, size = 14 }: { filled?: boolean; size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? '#5B2FD9' : 'none'} stroke={filled ? '#5B2FD9' : '#6E6884'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
    </svg>
  );
}

export function BellIcon({ size = 20 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
      <path d="M13.73 21a2 2 0 0 1-3.46 0" />
    </svg>
  );
}

export function ShareIcon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="18" cy="5" r="3" />
      <circle cx="6" cy="12" r="3" />
      <circle cx="18" cy="19" r="3" />
      <line x1="8.59" y1="13.51" x2="15.42" y2="17.49" />
      <line x1="15.41" y1="6.51" x2="8.59" y2="10.49" />
    </svg>
  );
}

export function Spinner({ size = 18, color = '#fff' }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" className="animate-spin">
      <path d="M12 2a10 10 0 0 1 10 10" />
    </svg>
  );
}

export function SuccessCircle({ size = 72 }: { size?: number }) {
  return (
    <div className="flex items-center justify-center rounded-full"
      style={{ width: size, height: size, background: 'linear-gradient(135deg, #23C997 0%, #4BE3B2 100%)' }}>
      <svg width={size * 0.5} height={size * 0.5} viewBox="0 0 36 36" fill="none">
        <path
          d="M8 18l6 6 14-14"
          stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"
          strokeDasharray="60" strokeDashoffset="0"
          style={{ animation: 'check-draw 0.4s ease both' }}
        />
      </svg>
    </div>
  );
}

export function Confetti() {
  const particles = [
    { color: '#5B2FD9', x: 30, delay: 0 },
    { color: '#7C5CFF', x: 60, delay: 0.1 },
    { color: '#23C997', x: 90, delay: 0.05 },
    { color: '#FFB020', x: 120, delay: 0.15 },
    { color: '#FF6B5E', x: 50, delay: 0.2 },
    { color: '#9B7BFF', x: 80, delay: 0.08 },
    { color: '#5B2FD9', x: 110, delay: 0.12 },
    { color: '#23C997', x: 40, delay: 0.18 },
    { color: '#FFB020', x: 100, delay: 0.03 },
    { color: '#FF6B5E', x: 70, delay: 0.22 },
    { color: '#7C5CFF', x: 20, delay: 0.07 },
    { color: '#9B7BFF', x: 140, delay: 0.14 },
  ];
  return (
    <div className="absolute inset-0 pointer-events-none overflow-hidden">
      {particles.map((p, i) => (
        <div
          key={i}
          className="absolute w-2 h-2 rounded-sm"
          style={{
            background: p.color,
            left: `${p.x / 1.6}%`,
            top: 0,
            animation: `confetti-fall 0.7s ease-out ${p.delay}s both`,
          }}
        />
      ))}
    </div>
  );
}

// Toggle Switch
export function Toggle({ on, onChange }: { on: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      onClick={() => onChange(!on)}
      className="relative rounded-full transition-all"
      style={{
        width: 51, height: 31,
        background: on ? '#5B2FD9' : '#D9D5E3',
        transition: 'background 0.25s',
      }}
    >
      <div
        className="absolute top-0.5 rounded-full bg-white"
        style={{
          width: 27, height: 27,
          left: on ? 22 : 2,
          transition: 'left 0.25s cubic-bezier(0.2,0.8,0.2,1)',
          boxShadow: '0 1px 4px rgba(0,0,0,0.2)',
        }}
      />
    </button>
  );
}

// Section Header
export function SectionHeader({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return (
    <div className="flex items-center justify-between px-4">
      <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>{title}</span>
      {action && <GhostBtn onClick={onAction}>{action}</GhostBtn>}
    </div>
  );
}
