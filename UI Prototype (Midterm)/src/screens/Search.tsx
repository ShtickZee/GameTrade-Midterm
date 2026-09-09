import React, { useState } from 'react';
import { ListingCard, SellerCard, SegmentedControl, EmptyState, GhostBtn, NavBar } from '../components/ui';
import { LISTINGS, SELLERS } from '../seed';

interface Props {
  onBack: () => void;
  onListing: (id: string) => void;
  onSeller: (id: string) => void;
  showToast: (msg: string) => void;
}

const RECENTS = ['PS5 disc edition', 'Xbox series x', 'Switch oled', 'controller drift free'];
const TRENDING = [
  { term: 'PS5 Disc Edition', count: '1.2k', up: true },
  { term: 'Xbox Series X', count: '890', up: true },
  { term: 'Switch OLED', count: '760', up: true },
  { term: 'PS4 Pro', count: '210', up: false },
  { term: 'Switch Lite', count: '180', up: true },
];

export default function Search({ onBack, onListing, onSeller, showToast }: Props) {
  const [query, setQuery] = useState('');
  const [tab, setTab] = useState(0);

  const isEmpty = query === 'ps58';
  const hasResults = query.length > 0 && !isEmpty;

  const sellers = Object.values(SELLERS).filter(s => s.id !== 'alex').slice(0, 3);
  const resultListings = LISTINGS.filter(l => l.platform === 'PS5' || l.platform === 'PS4').slice(0, 4);

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Search bar */}
      <div className="shrink-0 px-4 pt-3 pb-3" style={{ background: '#fff', borderBottom: '1px solid #E9E6F0' }}>
        <div className="flex items-center gap-3">
          <button onClick={onBack} className="text-[22px]" style={{ color: '#6E6884' }}>←</button>
          <div className="flex-1 flex items-center gap-2 h-11 px-4 rounded-full"
            style={{ background: '#F5F1FF' }}>
            <span style={{ color: '#6E6884' }}>🔍</span>
            <input
              autoFocus
              className="flex-1 bg-transparent outline-none text-[16px]"
              style={{ color: '#1E1633' }}
              placeholder="Search consoles, games, bundles…"
              value={query}
              onChange={e => setQuery(e.target.value)}
            />
            {query && (
              <button onClick={() => setQuery('')} style={{ color: '#6E6884' }}>×</button>
            )}
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll">
        {!hasResults && !isEmpty && (
          <div className="px-4 py-4">
            {/* Recent searches */}
            <div className="flex items-center justify-between mb-3">
              <span className="text-[13px]" style={{ color: '#6E6884' }}>Recent searches</span>
              <button className="text-[13px] font-medium" style={{ color: '#E5484D' }}>Clear</button>
            </div>
            <div className="flex flex-wrap gap-2 mb-6">
              {RECENTS.map(r => (
                <button
                  key={r}
                  onClick={() => setQuery(r)}
                  className="h-9 px-4 rounded-full text-[13px] font-medium"
                  style={{ background: '#fff', border: '1px solid #E9E6F0', color: '#3A3350' }}
                >
                  {r}
                </button>
              ))}
            </div>

            {/* Trending */}
            <span className="text-[13px] block mb-3" style={{ color: '#6E6884' }}>Trending near you</span>
            <div className="flex flex-col gap-0">
              {TRENDING.map((t, i) => (
                <button
                  key={i}
                  onClick={() => setQuery(t.term.toLowerCase())}
                  className="flex items-center gap-3 h-14"
                  style={{ borderBottom: '1px solid #E9E6F0' }}
                >
                  <span className="text-[24px] font-bold w-10 text-left" style={{ color: '#BDA6FF' }}>
                    {i + 1}
                  </span>
                  <div className="w-10 h-10 rounded-[10px] flex items-center justify-center text-xl"
                    style={{ background: '#F5F1FF' }}>🎮</div>
                  <span className="flex-1 text-[15px] font-medium" style={{ color: '#1E1633' }}>{t.term}</span>
                  <span className="text-[12px] font-medium"
                    style={{ color: t.up ? '#23C997' : '#E5484D' }}>
                    {t.up ? '↑' : '↓'} {t.count}
                  </span>
                </button>
              ))}
            </div>
          </div>
        )}

        {isEmpty && (
          <EmptyState
            icon="🔍"
            title={`No results for '${query}'`}
            sub="Try a different spelling or browse all consoles."
            cta="Browse marketplace"
            onCta={onBack}
          />
        )}

        {hasResults && (
          <div className="px-4 py-3">
            <div className="mb-3">
              <SegmentedControl
                options={['Listings', 'Sellers']}
                selected={tab}
                onChange={setTab}
              />
            </div>

            {tab === 0 && (
              <>
                <p className="text-[13px] mb-3" style={{ color: '#6E6884' }}>
                  32 results for '{query}'
                </p>
                <div className="grid grid-cols-2 gap-3">
                  {resultListings.map(l => (
                    <ListingCard key={l.id} listing={l} onPress={() => onListing(l.id)} />
                  ))}
                </div>
              </>
            )}

            {tab === 1 && (
              <div className="flex flex-col gap-3">
                {sellers.map(s => (
                  <SellerCard key={s.id} seller={s} onPress={() => onSeller(s.id)} />
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
