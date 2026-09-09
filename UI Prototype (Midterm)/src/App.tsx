import React, { useState, useCallback, useRef, useEffect } from 'react';
import Onboarding from './screens/Onboarding';
import DealsHome from './screens/DealsHome';
import Marketplace from './screens/Marketplace';
import ListingDetail from './screens/ListingDetail';
import Offers from './screens/Offers';
import Profile from './screens/Profile';
import OtherProfile from './screens/OtherProfile';
import Search from './screens/Search';
import Notifications from './screens/Notifications';
import SavedItems from './screens/SavedItems';
import EditProfile from './screens/EditProfile';
import SellFlow from './screens/SellFlow';
import MakeOffer from './screens/sheets/MakeOffer';
import ProposeTrade from './screens/sheets/ProposeTrade';
import FiltersSheet from './screens/sheets/FiltersSheet';
import OfferSuccess from './screens/OfferSuccess';

type Tab = 'deals' | 'market' | 'offers' | 'profile';
const PAGER_TABS: Tab[] = ['deals', 'market', 'offers', 'profile'];

type StackScreen =
  | { screen: 'listing'; listingId: string }
  | { screen: 'other-profile'; userId: string }
  | { screen: 'search' }
  | { screen: 'notifications' }
  | { screen: 'saved' }
  | { screen: 'edit-profile' };

type Sheet = 'make-offer' | 'propose-trade' | 'filters' | 'sell' | null;

export default function App() {
  const [onboarded, setOnboarded] = useState(false);
  const [activeTab, setActiveTab] = useState<Tab>('deals');
  const [prevTab, setPrevTab] = useState<Tab>('deals');
  const [stack, setStack] = useState<StackScreen[]>([]);
  const [sheet, setSheet] = useState<Sheet>(null);
  const [offerListingId, setOfferListingId] = useState<string>('L1');
  const [showOfferSuccess, setShowOfferSuccess] = useState(false);
  const [toast, setToast] = useState<string | null>(null);
  const [offersBadge, setOffersBadge] = useState(true);
  const [sellPressed, setSellPressed] = useState(false);

  // Swipe pager state
  const dragStartX = useRef(0);
  const dragStartY = useRef(0);
  const [dragOffset, setDragOffset] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const isHorizSwipe = useRef(false);

  const showToast = useCallback((msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 2500);
  }, []);

  const navigate = (s: StackScreen) => setStack(prev => [...prev, s]);
  const goBack = () => setStack(prev => prev.slice(0, -1));

  const switchTab = useCallback((tab: Tab) => {
    setPrevTab(activeTab);
    setActiveTab(tab);
    setStack([]);
    if (tab === 'offers') setOffersBadge(false);
  }, [activeTab]);

  const openSheet = (s: Exclude<Sheet, null>) => setSheet(s);
  const closeSheet = () => setSheet(null);

  const openMakeOffer = (listingId: string) => {
    setOfferListingId(listingId);
    openSheet('make-offer');
  };
  const openProposeTrade = (listingId: string) => {
    setOfferListingId(listingId);
    openSheet('propose-trade');
  };

  const topScreen = stack[stack.length - 1] ?? null;
  const tabIndex = PAGER_TABS.indexOf(activeTab);

  // Touch handlers for swipe-between-tabs pager
  const handleTouchStart = (e: React.TouchEvent) => {
    if (topScreen || sheet) return;
    dragStartX.current = e.touches[0].clientX;
    dragStartY.current = e.touches[0].clientY;
    isHorizSwipe.current = false;
    setIsDragging(false);
    setDragOffset(0);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (topScreen || sheet) return;
    const dx = e.touches[0].clientX - dragStartX.current;
    const dy = e.touches[0].clientY - dragStartY.current;

    if (!isDragging) {
      // Determine swipe direction on first significant movement
      if (Math.abs(dx) < 8 && Math.abs(dy) < 8) return;
      if (Math.abs(dx) > Math.abs(dy)) {
        isHorizSwipe.current = true;
        setIsDragging(true);
      } else {
        return; // vertical scroll takes priority
      }
    }

    if (!isHorizSwipe.current) return;

    // Clamp: can't swipe left past last tab or right past first
    const canSwipeLeft = tabIndex < PAGER_TABS.length - 1;
    const canSwipeRight = tabIndex > 0;
    if (dx < 0 && !canSwipeLeft) return;
    if (dx > 0 && !canSwipeRight) return;

    setDragOffset(dx);
  };

  const handleTouchEnd = () => {
    if (!isHorizSwipe.current) return;
    setIsDragging(false);
    isHorizSwipe.current = false;

    if (dragOffset < -60 && tabIndex < PAGER_TABS.length - 1) {
      switchTab(PAGER_TABS[tabIndex + 1]);
    } else if (dragOffset > 60 && tabIndex > 0) {
      switchTab(PAGER_TABS[tabIndex - 1]);
    }
    setDragOffset(0);
  };

  if (!onboarded) {
    return (
      <PhoneFrame>
        <Onboarding onComplete={() => setOnboarded(true)} />
      </PhoneFrame>
    );
  }

  const renderTab = (tab: Tab) => {
    if (tab === 'deals') return (
      <DealsHome
        onSearch={() => navigate({ screen: 'search' })}
        onBell={() => navigate({ screen: 'notifications' })}
        onListing={id => navigate({ screen: 'listing', listingId: id })}
        onMarket={() => switchTab('market')}
        showToast={showToast}
      />
    );
    if (tab === 'market') return (
      <Marketplace
        onListing={id => navigate({ screen: 'listing', listingId: id })}
        onSearch={() => navigate({ screen: 'search' })}
        onFilters={() => openSheet('filters')}
        showToast={showToast}
      />
    );
    if (tab === 'offers') return (
      <Offers onDeals={() => switchTab('deals')} showToast={showToast} />
    );
    if (tab === 'profile') return (
      <Profile
        onSaved={() => navigate({ screen: 'saved' })}
        onNotifications={() => navigate({ screen: 'notifications' })}
        onEditProfile={() => navigate({ screen: 'edit-profile' })}
        showToast={showToast}
      />
    );
  };

  const renderStack = () => {
    if (!topScreen) return null;
    if (topScreen.screen === 'listing') return (
      <ListingDetail
        listingId={topScreen.listingId}
        onBack={goBack}
        onMakeOffer={openMakeOffer}
        onProposeTrade={openProposeTrade}
        onSellerProfile={id => navigate({ screen: 'other-profile', userId: id })}
        showToast={showToast}
      />
    );
    if (topScreen.screen === 'other-profile') return (
      <OtherProfile
        userId={topScreen.userId}
        onBack={goBack}
        onListing={id => navigate({ screen: 'listing', listingId: id })}
        showToast={showToast}
      />
    );
    if (topScreen.screen === 'search') return (
      <Search
        onBack={goBack}
        onListing={id => navigate({ screen: 'listing', listingId: id })}
        onSeller={id => navigate({ screen: 'other-profile', userId: id })}
        showToast={showToast}
      />
    );
    if (topScreen.screen === 'notifications') return (
      <Notifications
        onBack={goBack}
        onOffers={() => { goBack(); switchTab('offers'); }}
        onDeals={() => { goBack(); switchTab('deals'); }}
        showToast={showToast}
      />
    );
    if (topScreen.screen === 'saved') return (
      <SavedItems
        onBack={goBack}
        onListing={id => navigate({ screen: 'listing', listingId: id })}
        showToast={showToast}
      />
    );
    if (topScreen.screen === 'edit-profile') return (
      <EditProfile onBack={goBack} showToast={showToast} />
    );
  };

  return (
    <PhoneFrame>
      <StatusBar />

      {/* Main content area */}
      <div
        className="flex-1 overflow-hidden relative"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        {/* Pager: render active tab, with drag offset applied */}
        <div
          className="absolute inset-0"
          style={{
            transform: isDragging ? `translateX(${dragOffset * 0.35}px)` : 'translateX(0)',
            transition: isDragging ? 'none' : 'transform 0.3s cubic-bezier(0.2,0,0,1)',
          }}
        >
          {renderTab(activeTab)}
        </div>

        {/* Stack screen (pushed on top) */}
        {topScreen && (
          <div
            className="absolute inset-0"
            style={{
              zIndex: 10,
              animation: 'slide-in-right 0.3s cubic-bezier(0.2,0,0,1) both',
            }}
          >
            {renderStack()}
          </div>
        )}

        {/* Offer Success overlay */}
        {showOfferSuccess && (
          <OfferSuccess
            offerAmt={387}
            sellerName="Jordan Lee"
            onViewOffers={() => {
              setShowOfferSuccess(false);
              closeSheet();
              setStack([]);
              switchTab('offers');
            }}
            onKeepBrowsing={() => {
              setShowOfferSuccess(false);
              closeSheet();
              switchTab('market');
            }}
          />
        )}
      </div>

      {/* Tab bar — hidden when stack is showing */}
      {!topScreen && (
        <TabBar
          active={activeTab}
          onTab={switchTab}
          onSell={() => { setSellPressed(true); openSheet('sell'); }}
          sellPressed={sheet === 'sell'}
          offersBadge={offersBadge}
        />
      )}

      {/* Home indicator */}
      <div className="flex justify-center py-2 shrink-0 bg-white">
        <div className="w-32 h-1 rounded-full" style={{ background: '#1E1633', opacity: 0.2 }} />
      </div>

      {/* Sheets */}
      {sheet && (
        <SheetBackdrop onClose={closeSheet}>
          {sheet === 'make-offer' && (
            <MakeOffer
              listingId={offerListingId}
              onClose={closeSheet}
              onSuccess={() => { closeSheet(); setShowOfferSuccess(true); }}
            />
          )}
          {sheet === 'propose-trade' && (
            <ProposeTrade
              listingId={offerListingId}
              onClose={closeSheet}
              onSuccess={() => { closeSheet(); setShowOfferSuccess(true); }}
              showToast={showToast}
            />
          )}
          {sheet === 'filters' && (
            <FiltersSheet
              onClose={closeSheet}
              onApply={closeSheet}
              showToast={showToast}
            />
          )}
          {sheet === 'sell' && (
            <SellFlow
              onClose={() => { closeSheet(); showToast('Draft saved'); }}
              onViewListing={() => {
                closeSheet();
                navigate({ screen: 'listing', listingId: 'L7' });
              }}
              onBackToDeals={() => { closeSheet(); switchTab('deals'); }}
            />
          )}
        </SheetBackdrop>
      )}

      {toast && <ToastNotif message={toast} />}
    </PhoneFrame>
  );
}

// ─── Phone Frame ──────────────────────────────────────────────────────────────

function PhoneFrame({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="min-h-screen flex items-center justify-center"
      style={{ background: 'linear-gradient(135deg, #0f0a1e 0%, #1a0f3c 50%, #0f0a1e 100%)', padding: '12px' }}
    >
      <div
        className="relative flex flex-col overflow-hidden"
        style={{
          width: 390,
          height: 844,
          borderRadius: 50,
          background: '#fff',
          boxShadow:
            '0 40px 80px rgba(0,0,0,0.65), 0 0 0 2px rgba(255,255,255,0.12), inset 0 0 0 1px rgba(255,255,255,0.06)',
        }}
      >
        {/* Dynamic Island */}
        <div
          className="absolute top-3 left-1/2 -translate-x-1/2 z-50 rounded-full flex items-center justify-center gap-3"
          style={{ width: 126, height: 37, background: '#0a0a0a' }}
        >
          {/* Camera dot */}
          <div className="w-3 h-3 rounded-full" style={{ background: '#1a1a1a', border: '1px solid #2a2a2a' }} />
        </div>
        {children}
      </div>
    </div>
  );
}

// ─── Status Bar ───────────────────────────────────────────────────────────────

function StatusBar() {
  const [time, setTime] = useState('9:41');

  return (
    <div
      className="shrink-0 flex items-end justify-between px-7 pb-1"
      style={{ height: 54, background: 'white' }}
    >
      <span className="text-[15px] font-semibold" style={{ color: '#1E1633' }}>9:41</span>
      <div className="flex items-center gap-1.5">
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
          <rect x="0" y="6" width="3" height="6" rx="1" fill="#1E1633" />
          <rect x="4.5" y="4" width="3" height="8" rx="1" fill="#1E1633" />
          <rect x="9" y="2" width="3" height="10" rx="1" fill="#1E1633" />
          <rect x="13.5" y="0" width="2.5" height="12" rx="1" fill="#1E1633" opacity="0.3" />
        </svg>
        <svg width="16" height="12" viewBox="0 0 16 12" fill="#1E1633">
          <path d="M8 2.4C10.4 2.4 12.6 3.5 14 5.3L15.5 3.5C13.6 1.3 10.9 0 8 0C5.1 0 2.4 1.3.5 3.5L2 5.3C3.4 3.5 5.6 2.4 8 2.4Z"/>
          <path d="M8 5.6C9.6 5.6 11 6.3 12 7.4L13.5 5.6C12.1 4.1 10.2 3.2 8 3.2C5.8 3.2 3.9 4.1 2.5 5.6L4 7.4C5 6.3 6.4 5.6 8 5.6Z" opacity="0.7"/>
          <circle cx="8" cy="10" r="2"/>
        </svg>
        <svg width="25" height="12" viewBox="0 0 25 12" fill="none">
          <rect x="0.5" y="0.5" width="21" height="11" rx="3.5" stroke="#1E1633" strokeOpacity="0.35"/>
          <rect x="2" y="2" width="17" height="8" rx="2" fill="#1E1633"/>
          <path d="M23 4.5V7.5C23.8 7.2 24.5 6.5 24.5 6C24.5 5.5 23.8 4.8 23 4.5Z" fill="#1E1633" fillOpacity="0.4"/>
        </svg>
      </div>
    </div>
  );
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

const TAB_DEFS: { id: Tab; label: string; icon: (active: boolean) => React.ReactNode }[] = [
  {
    id: 'deals', label: 'Deals',
    icon: (active) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={active ? '#5B2FD9' : '#948FA8'} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/>
        <line x1="7" y1="7" x2="7.01" y2="7"/>
      </svg>
    ),
  },
  {
    id: 'market', label: 'Market',
    icon: (active) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={active ? '#5B2FD9' : '#948FA8'} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
        <polyline points="9 22 9 12 15 12 15 22"/>
      </svg>
    ),
  },
  {
    id: 'offers', label: 'Offers',
    icon: (active) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={active ? '#5B2FD9' : '#948FA8'} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="17 1 21 5 17 9"/>
        <path d="M3 11V9a4 4 0 0 1 4-4h14"/>
        <polyline points="7 23 3 19 7 15"/>
        <path d="M21 13v2a4 4 0 0 1-4 4H3"/>
      </svg>
    ),
  },
  {
    id: 'profile', label: 'Profile',
    icon: (active) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={active ? '#5B2FD9' : '#948FA8'} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
        <circle cx="12" cy="7" r="4"/>
      </svg>
    ),
  },
];

function TabBar({
  active, onTab, onSell, sellPressed, offersBadge,
}: {
  active: Tab; onTab: (t: Tab) => void; onSell: () => void; sellPressed: boolean; offersBadge: boolean;
}) {
  return (
    <div
      className="shrink-0 flex items-stretch"
      style={{
        height: 56,
        background: '#fff',
        borderTop: '1px solid #E9E6F0',
        boxShadow: '0 -4px 24px rgba(30,22,51,0.08)',
      }}
    >
      {/* Deals + Market */}
      {TAB_DEFS.slice(0, 2).map(def => (
        <TabItem
          key={def.id}
          def={def}
          active={active === def.id}
          onPress={() => onTab(def.id)}
        />
      ))}

      {/* Center Sell button */}
      <div className="flex-1 flex flex-col items-center justify-end pb-1">
        <div className="flex flex-col items-center" style={{ marginTop: -16 }}>
          <button
            onMouseDown={() => {}}
            onClick={onSell}
            className="flex items-center justify-center rounded-full text-white"
            style={{
              width: 60,
              height: 60,
              background: 'linear-gradient(135deg, #5B2FD9 0%, #7C5CFF 55%, #A78BFA 100%)',
              boxShadow: '0 8px 20px rgba(91,47,217,0.35)',
              transition: 'transform 0.15s ease',
              transform: sellPressed ? 'scale(0.92)' : 'scale(1)',
            }}
          >
            <svg
              width="26"
              height="26"
              viewBox="0 0 24 24"
              fill="none"
              stroke="white"
              strokeWidth="2.2"
              strokeLinecap="round"
              style={{
                transform: sellPressed ? 'rotate(90deg)' : 'rotate(0deg)',
                transition: 'transform 0.3s cubic-bezier(0.2,0.8,0.2,1)',
              }}
            >
              <line x1="12" y1="5" x2="12" y2="19" />
              <line x1="5" y1="12" x2="19" y2="12" />
            </svg>
          </button>
          <span className="text-[11px] font-medium mt-0.5" style={{ color: '#5B2FD9' }}>Sell</span>
        </div>
      </div>

      {/* Offers + Profile */}
      {TAB_DEFS.slice(2).map(def => (
        <TabItem
          key={def.id}
          def={def}
          active={active === def.id}
          onPress={() => onTab(def.id)}
          badge={def.id === 'offers' && offersBadge}
        />
      ))}
    </div>
  );
}

function TabItem({
  def, active, onPress, badge,
}: {
  def: typeof TAB_DEFS[0]; active: boolean; onPress: () => void; badge?: boolean;
}) {
  return (
    <button
      onClick={onPress}
      className="flex-1 flex flex-col items-center justify-end pb-1.5 gap-0.5 relative"
    >
      {/* Active dot indicator */}
      {active && (
        <div
          className="absolute top-0 left-1/2 -translate-x-1/2 rounded-full"
          style={{
            width: 4,
            height: 4,
            background: '#5B2FD9',
            animation: 'scale-in 0.2s cubic-bezier(0.2,0.8,0.2,1) both',
          }}
        />
      )}
      <div className="relative">
        {def.icon(active)}
        {badge && (
          <div
            className="absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full"
            style={{ background: '#E5484D', border: '1.5px solid #fff' }}
          />
        )}
      </div>
      <span
        className="text-[11px] font-medium"
        style={{
          color: active ? '#5B2FD9' : '#948FA8',
          transition: 'color 0.2s',
        }}
      >
        {def.label}
      </span>
    </button>
  );
}

// ─── Sheet Backdrop ───────────────────────────────────────────────────────────

function SheetBackdrop({ children, onClose }: { children: React.ReactNode; onClose: () => void }) {
  return (
    <div
      className="absolute inset-0 z-30 flex flex-col justify-end"
      style={{ background: 'rgba(30,22,51,0.4)', animation: 'fade-in 0.3s ease both' }}
      onClick={e => { if (e.target === e.currentTarget) onClose(); }}
    >
      {children}
    </div>
  );
}

// ─── Toast ────────────────────────────────────────────────────────────────────

function ToastNotif({ message }: { message: string }) {
  return (
    <div
      className="absolute left-4 right-4 z-50 flex items-center gap-2.5 px-4 py-3 rounded-[14px] text-[14px] text-white font-medium"
      style={{
        bottom: 80,
        background: 'rgba(30,22,51,0.92)',
        boxShadow: '0 4px 20px rgba(0,0,0,0.25)',
        animation: 'slide-up 0.3s cubic-bezier(0.2,0.8,0.2,1) both',
      }}
    >
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round">
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/>
        <line x1="12" y1="16" x2="12.01" y2="16"/>
      </svg>
      {message}
    </div>
  );
}
