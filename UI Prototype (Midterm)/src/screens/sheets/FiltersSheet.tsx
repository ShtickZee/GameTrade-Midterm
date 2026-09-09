import React, { useState } from 'react';
import { PrimaryBtn, GhostBtn, FilterChip, Toggle } from '../../components/ui';

interface Props {
  onClose: () => void;
  onApply: () => void;
  showToast: (msg: string) => void;
}

export default function FiltersSheet({ onClose, onApply, showToast }: Props) {
  const [platforms, setPlatforms] = useState<string[]>([]);
  const [conditions, setConditions] = useState<string[]>([]);
  const [nearMe, setNearMe] = useState(true);
  const [acceptsTrades, setAcceptsTrades] = useState(false);
  const [bundlesOnly, setBundlesOnly] = useState(false);
  const [verifiedOnly, setVerifiedOnly] = useState(true);
  const [sortBy, setSortBy] = useState('recent');
  const [priceMin, setPriceMin] = useState(120);
  const [priceMax, setPriceMax] = useState(650);

  const toggleArr = (arr: string[], set: (v: string[]) => void, val: string) => {
    if (arr.includes(val)) set(arr.filter(x => x !== val));
    else set([...arr, val]);
  };

  const activeCount = platforms.length + conditions.length
    + (nearMe ? 1 : 0) + (acceptsTrades ? 1 : 0) + (bundlesOnly ? 1 : 0) + (verifiedOnly ? 1 : 0);

  return (
    <div className="flex flex-col rounded-t-[24px] bg-white sheet-enter" style={{ maxHeight: '85vh' }}>
      {/* Handle */}
      <div className="flex justify-center pt-3 pb-1">
        <div className="w-9 h-1 rounded-full" style={{ background: '#E9E6F0' }} />
      </div>

      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b" style={{ borderColor: '#E9E6F0' }}>
        <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>Filters</span>
        <button
          onClick={() => { setPlatforms([]); setConditions([]); setNearMe(false); setAcceptsTrades(false); setBundlesOnly(false); setVerifiedOnly(false); setSortBy('recent'); }}
          className="text-[14px] font-medium"
          style={{ color: activeCount > 0 ? '#E5484D' : '#6E6884' }}
        >
          Reset all
        </button>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll px-4 py-4 flex flex-col gap-6">
        {/* Platform */}
        <div>
          <p className="text-[15px] font-semibold mb-3" style={{ color: '#1E1633' }}>Platform</p>
          <div className="flex gap-2 flex-wrap">
            {['PlayStation', 'Xbox', 'Switch'].map(p => (
              <FilterChip key={p} label={p} selected={platforms.includes(p)} onClick={() => toggleArr(platforms, setPlatforms, p)} />
            ))}
          </div>
        </div>

        {/* Condition */}
        <div>
          <p className="text-[15px] font-semibold mb-3" style={{ color: '#1E1633' }}>Condition</p>
          <div className="flex gap-2 flex-wrap">
            {['Like New', 'Good', 'Fair', 'For Parts'].map(c => (
              <FilterChip key={c} label={c} selected={conditions.includes(c)} onClick={() => toggleArr(conditions, setConditions, c)} />
            ))}
          </div>
        </div>

        {/* Price range */}
        <div>
          <p className="text-[15px] font-semibold mb-3" style={{ color: '#1E1633' }}>Price range</p>
          <div className="flex items-center gap-3 mb-3">
            <div className="flex-1 h-12 rounded-[12px] flex items-center px-3 text-[15px] font-medium"
              style={{ background: '#F5F1FF', color: '#5B2FD9' }}>
              ${priceMin}
            </div>
            <span style={{ color: '#948FA8' }}>—</span>
            <div className="flex-1 h-12 rounded-[12px] flex items-center px-3 text-[15px] font-medium"
              style={{ background: '#F5F1FF', color: '#5B2FD9' }}>
              ${priceMax}
            </div>
          </div>
          {/* Track */}
          <div className="relative h-1.5 rounded-full" style={{ background: '#E9E6F0' }}>
            <div className="absolute h-full rounded-full"
              style={{
                left: `${(priceMin - 50) / 950 * 100}%`,
                right: `${100 - (priceMax - 50) / 950 * 100}%`,
                background: '#5B2FD9',
              }} />
          </div>
          <div className="flex gap-2 mt-3">
            {['Under $200', '$200–$400', '$400+'].map(p => (
              <button
                key={p}
                onClick={() => {
                  if (p === 'Under $200') { setPriceMin(50); setPriceMax(200); }
                  else if (p === '$200–$400') { setPriceMin(200); setPriceMax(400); }
                  else { setPriceMin(400); setPriceMax(1000); }
                }}
                className="flex-1 py-1.5 rounded-full text-[12px] font-medium"
                style={{ background: '#F5F1FF', color: '#5B2FD9' }}
              >
                {p}
              </button>
            ))}
          </div>
        </div>

        {/* Toggles */}
        <div className="rounded-[16px] overflow-hidden" style={{ border: '1px solid #E9E6F0' }}>
          {[
            { label: 'Near me (25 km)', value: nearMe, set: setNearMe },
            { label: 'Accepts trades only', value: acceptsTrades, set: setAcceptsTrades },
            { label: 'Bundles only', value: bundlesOnly, set: setBundlesOnly },
            { label: 'Verified sellers only', value: verifiedOnly, set: setVerifiedOnly },
          ].map((row, i) => (
            <div key={i} className="flex items-center justify-between px-4 h-14"
              style={{ borderTop: i > 0 ? '1px solid #E9E6F0' : 'none' }}>
              <span className="text-[15px] font-medium" style={{ color: '#1E1633' }}>{row.label}</span>
              <Toggle on={row.value} onChange={row.set} />
            </div>
          ))}
        </div>

        {/* Sort by */}
        <div>
          <p className="text-[15px] font-semibold mb-3" style={{ color: '#1E1633' }}>Sort by</p>
          <div className="flex flex-col gap-2">
            {[
              { value: 'recent', label: 'Most recent' },
              { value: 'price-low', label: 'Price: Low to High' },
              { value: 'price-high', label: 'Price: High to Low' },
              { value: 'best-match', label: 'Best match' },
            ].map(opt => (
              <button
                key={opt.value}
                onClick={() => setSortBy(opt.value)}
                className="flex items-center justify-between h-12 px-4 rounded-[12px]"
                style={{ background: sortBy === opt.value ? '#F5F1FF' : 'transparent', border: '1px solid #E9E6F0' }}
              >
                <span className="text-[15px] font-medium" style={{ color: '#1E1633' }}>{opt.label}</span>
                <div
                  className="w-5 h-5 rounded-full border-2 flex items-center justify-center"
                  style={{ borderColor: sortBy === opt.value ? '#5B2FD9' : '#E9E6F0' }}
                >
                  {sortBy === opt.value && (
                    <div className="w-2.5 h-2.5 rounded-full" style={{ background: '#5B2FD9' }} />
                  )}
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Sticky footer */}
      <div className="flex items-center gap-3 px-4 pb-8 pt-3" style={{ borderTop: '1px solid #E9E6F0' }}>
        <button
          onClick={onClose}
          className="text-[15px] font-medium"
          style={{ color: '#5B2FD9' }}
        >
          Show {248 - activeCount * 10} results
        </button>
        <PrimaryBtn onClick={() => { onApply(); showToast(`${activeCount} filters applied`); }} className="flex-1">
          Apply filters
        </PrimaryBtn>
      </div>
    </div>
  );
}
