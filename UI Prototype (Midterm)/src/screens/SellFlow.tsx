import React, { useState } from 'react';
import { PrimaryBtn, GhostBtn, SuccessCircle, Confetti, Toggle } from '../components/ui';

interface Props {
  onClose: () => void;
  onViewListing: () => void;
  onBackToDeals: () => void;
}

type Step = 1 | 2 | 3 | 4 | 5;

const PLATFORMS_SELL = [
  { label: 'PlayStation', emoji: '🎮' },
  { label: 'Xbox', emoji: '🟢' },
  { label: 'Switch', emoji: '🕹️' },
];

export default function SellFlow({ onClose, onViewListing, onBackToDeals }: Props) {
  const [step, setStep] = useState<Step>(1);
  const [selectedPlatform, setSelectedPlatform] = useState(2); // Switch selected
  const [condition, setCondition] = useState('Like New');
  const [title, setTitle] = useState('Nintendo Switch OLED — White, boxed');
  const [price, setPrice] = useState(280);
  const [openToTrades, setOpenToTrades] = useState(true);
  const [tradeFor, setTradeFor] = useState('PS5, Xbox Series S + cash');
  const [pricePreset, setPricePreset] = useState(1);
  const PRICE_PRESETS = [
    { label: 'Sell fast', price: 260 },
    { label: 'Fair', price: 280 },
    { label: 'Aim high', price: 300 },
  ];

  const pct = step === 5 ? 4 : step;
  const totalSteps = 4;

  const nextStep = () => setStep((step < 5 ? step + 1 : 5) as Step);
  const prevStep = () => setStep((step > 1 ? step - 1 : 1) as Step);

  return (
    <div className="flex flex-col h-full bg-white rounded-t-[24px] sheet-enter">
      {/* Handle */}
      <div className="flex justify-center pt-3 pb-1">
        <div className="w-9 h-1 rounded-full" style={{ background: '#E9E6F0' }} />
      </div>

      {/* Top bar */}
      <div className="flex items-center justify-between px-4 py-3">
        <button onClick={() => { onClose(); }} className="w-8 h-8 flex items-center justify-center text-[22px]"
          style={{ color: '#6E6884' }}>×</button>
        <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>Sell a console</span>
        {step < 5 ? (
          <span className="text-[13px]" style={{ color: '#6E6884' }}>{Math.min(step, 4)}/{totalSteps}</span>
        ) : <div className="w-8" />}
      </div>

      {/* Progress */}
      {step < 5 && (
        <div className="flex items-center gap-1 px-4 mb-2">
          {[1,2,3,4].map(s => (
            <div
              key={s}
              className="flex-1 h-1 rounded-full"
              style={{ background: s <= step ? '#5B2FD9' : '#E9E6F0', transition: 'background 0.35s' }}
            />
          ))}
        </div>
      )}

      {/* Content */}
      <div className="flex-1 overflow-y-auto no-scroll px-4 py-4">
        {step === 1 && <StepPhotos />}
        {step === 2 && (
          <StepDetails
            title={title} setTitle={setTitle}
            platform={selectedPlatform} setPlatform={setSelectedPlatform}
            condition={condition} setCondition={setCondition}
          />
        )}
        {step === 3 && (
          <StepPricing
            price={price} setPrice={setPrice}
            preset={pricePreset} setPreset={(i: number) => { setPricePreset(i); setPrice(PRICE_PRESETS[i].price); }}
            presets={PRICE_PRESETS}
            openToTrades={openToTrades} setOpenToTrades={setOpenToTrades}
            tradeFor={tradeFor} setTradeFor={setTradeFor}
          />
        )}
        {step === 4 && <StepReview title={title} price={price} condition={condition} onEdit={(s: number) => setStep(s as Step)} />}
        {step === 5 && <StepSuccess onViewListing={onViewListing} onBackToDeals={onBackToDeals} />}
      </div>

      {/* Footer */}
      {step < 5 && (
        <div className="flex items-center gap-3 px-4 pb-8 pt-3" style={{ borderTop: '1px solid #E9E6F0' }}>
          {step > 1 && (
            <GhostBtn onClick={prevStep}>{['', '', 'Photos', 'Details', 'Pricing'][step]}</GhostBtn>
          )}
          <PrimaryBtn onClick={nextStep} className="flex-1">
            {['', 'Next: Details', 'Next: Pricing', 'Next: Review', 'Publish listing'][step]}
          </PrimaryBtn>
        </div>
      )}
    </div>
  );
}

function StepPhotos() {
  return (
    <div className="flex flex-col gap-4">
      <div>
        <h2 className="text-[22px] font-bold mb-1" style={{ color: '#1E1633' }}>Show it off</h2>
        <p className="text-[13px]" style={{ color: '#6E6884' }}>Up to 8 photos. First one is the cover. Good light = faster sale.</p>
      </div>
      <div className="grid grid-cols-3 gap-2">
        {[
          { filled: true, cover: true },
          { filled: true },
          { filled: true },
          { filled: false },
          { disabled: true },
          { disabled: true },
          { disabled: true },
          { disabled: true },
        ].map((tile, i) => (
          <div
            key={i}
            className="aspect-square rounded-[16px] flex items-center justify-center relative overflow-hidden"
            style={{
              border: tile.filled ? 'none' : tile.disabled ? '1.5px dashed #E9E6F0' : '1.5px dashed #BDA6FF',
              background: tile.filled ? '#F5F1FF' : tile.disabled ? '#FAFAFA' : '#fff',
              opacity: tile.disabled ? 0.5 : 1,
            }}
          >
            {tile.filled ? (
              <>
                <span className="text-4xl">🎮</span>
                {tile.cover && (
                  <div className="absolute bottom-2 left-2 px-1.5 py-0.5 rounded-full text-[9px] font-bold text-white"
                    style={{ background: 'rgba(30,22,51,0.6)' }}>COVER</div>
                )}
                <button className="absolute top-1.5 right-1.5 w-5 h-5 rounded-full flex items-center justify-center text-white text-[11px]"
                  style={{ background: 'rgba(30,22,51,0.6)' }}>×</button>
              </>
            ) : !tile.disabled ? (
              <div className="flex flex-col items-center gap-1">
                <span style={{ fontSize: 24, color: '#5B2FD9' }}>＋</span>
                <span className="text-[11px] font-medium" style={{ color: '#5B2FD9' }}>Add photo</span>
              </div>
            ) : null}
          </div>
        ))}
      </div>
      <div className="flex items-start gap-2 p-3 rounded-[12px]"
        style={{ background: '#FFF3D6' }}>
        <span>💡</span>
        <p className="text-[13px]" style={{ color: '#6E6884' }}>
          Include the ports, screen, and serial number for buyer trust.
        </p>
      </div>
    </div>
  );
}

function StepDetails({ title, setTitle, platform, setPlatform, condition, setCondition }: any) {
  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Details</h2>

      {/* Title */}
      <div>
        <div className="flex justify-between mb-1.5">
          <label className="text-[13px] font-medium" style={{ color: '#6E6884' }}>Title</label>
          <span className="text-[12px]" style={{ color: '#948FA8' }}>{title.length}/80</span>
        </div>
        <input
          className="w-full h-14 px-4 rounded-[12px] text-[16px] outline-none"
          style={{ background: '#F5F1FF', color: '#1E1633' }}
          value={title}
          onChange={e => setTitle(e.target.value.slice(0, 80))}
        />
      </div>

      {/* Platform */}
      <div>
        <label className="text-[13px] font-medium block mb-2" style={{ color: '#6E6884' }}>Platform</label>
        <div className="flex gap-2">
          {[{ label: 'PlayStation', emoji: '🎮' }, { label: 'Xbox', emoji: '🟢' }, { label: 'Switch', emoji: '🕹️' }].map((p, i) => (
            <button
              key={i}
              onClick={() => setPlatform(i)}
              className="flex-1 flex flex-col items-center gap-2 h-[72px] rounded-[12px] justify-center"
              style={{
                border: platform === i ? '2px solid #5B2FD9' : '1.5px solid #E9E6F0',
                background: platform === i ? '#F5F1FF' : '#fff',
              }}
            >
              <span className="text-2xl">{p.emoji}</span>
              <span className="text-[12px] font-medium" style={{ color: platform === i ? '#5B2FD9' : '#1E1633' }}>{p.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Condition */}
      <div>
        <label className="text-[13px] font-medium block mb-2" style={{ color: '#6E6884' }}>Condition</label>
        <div className="flex gap-2 flex-wrap">
          {['Like New', 'Good', 'Fair', 'For Parts'].map(c => (
            <button
              key={c}
              onClick={() => setCondition(c)}
              className="h-9 px-4 rounded-full text-[13px] font-medium"
              style={condition === c
                ? { background: '#5B2FD9', color: '#fff' }
                : { background: '#fff', color: '#3A3350', border: '1px solid #E9E6F0' }
              }
            >
              {condition === c && '✓ '}{c}
            </button>
          ))}
        </div>
      </div>

      {/* Bundle items */}
      <div>
        <label className="text-[13px] font-medium block mb-2" style={{ color: '#6E6884' }}>Bundle items (optional)</label>
        {[
          { name: 'Pro Controller', value: 55 },
          { name: 'Carry Case', value: 25 },
        ].map((item, i) => (
          <div key={i} className="flex items-center gap-2 mb-2">
            <div className="w-10 h-10 rounded-[10px] flex items-center justify-center text-xl"
              style={{ background: '#F5F1FF' }}>🎮</div>
            <input className="flex-1 h-10 px-3 rounded-[10px] text-[14px] outline-none"
              style={{ background: '#F5F1FF', color: '#1E1633' }} defaultValue={item.name} />
            <input className="w-20 h-10 px-3 rounded-[10px] text-[14px] outline-none"
              style={{ background: '#F5F1FF', color: '#1E1633' }} defaultValue={`$${item.value}`} />
            <button className="w-8 h-8 flex items-center justify-center text-xl" style={{ color: '#E5484D' }}>−</button>
          </div>
        ))}
        <button className="flex items-center gap-2 text-[14px] font-medium" style={{ color: '#5B2FD9' }}>
          ＋ Add bundle item
        </button>
      </div>

      {/* Description */}
      <div>
        <label className="text-[13px] font-medium block mb-1.5" style={{ color: '#6E6884' }}>Description</label>
        <textarea
          className="w-full px-4 py-3 rounded-[12px] text-[15px] outline-none resize-none"
          style={{ background: '#F5F1FF', color: '#1E1633', height: 100 }}
          placeholder="Describe usage, defects, why you're selling…"
        />
      </div>
    </div>
  );
}

function StepPricing({ price, setPrice, preset, setPreset, presets, openToTrades, setOpenToTrades, tradeFor, setTradeFor }: any) {
  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Price & Trade</h2>

      {/* Price field */}
      <div>
        <label className="text-[13px] font-medium block mb-1.5" style={{ color: '#6E6884' }}>Your price</label>
        <div className="flex items-center h-16 rounded-[12px] px-4 gap-1"
          style={{ background: '#F5F1FF' }}>
          <span className="text-[22px]" style={{ color: '#6E6884' }}>$</span>
          <input
            type="number"
            className="flex-1 bg-transparent outline-none text-[26px] font-bold"
            style={{ color: '#1E1633' }}
            value={price}
            onChange={e => setPrice(Number(e.target.value))}
          />
        </div>
      </div>

      {/* Suggestion card */}
      <div className="p-3 rounded-[12px]" style={{ background: '#F5F1FF' }}>
        <p className="text-[13px] mb-2" style={{ color: '#6E6884' }}>Similar consoles near you sell for $265–$295</p>
        <div className="flex gap-2">
          {presets.map((p: any, i: number) => (
            <button
              key={i}
              onClick={() => setPreset(i)}
              className="flex-1 py-2 rounded-[10px] text-[12px] font-medium"
              style={preset === i
                ? { background: '#5B2FD9', color: '#fff' }
                : { background: '#fff', color: '#3A3350', border: '1px solid #E9E6F0' }
              }
            >
              {p.label} ${p.price}
            </button>
          ))}
        </div>
      </div>

      <div className="flex items-center justify-center my-1">
        <div className="h-px flex-1" style={{ background: '#E9E6F0' }} />
        <span className="px-3 text-[13px]" style={{ color: '#6E6884' }}>or</span>
        <div className="h-px flex-1" style={{ background: '#E9E6F0' }} />
      </div>

      {/* Trade toggle */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <span className="text-[15px] font-medium" style={{ color: '#1E1633' }}>I'm open to trades</span>
          <Toggle on={openToTrades} onChange={setOpenToTrades} />
        </div>
        {openToTrades && (
          <div>
            <label className="text-[13px] font-medium block mb-1.5" style={{ color: '#6E6884' }}>What would you trade for?</label>
            <input
              className="w-full h-14 px-4 rounded-[12px] text-[15px] outline-none"
              style={{ background: '#F5F1FF', color: '#1E1633' }}
              value={tradeFor}
              onChange={e => setTradeFor(e.target.value)}
              placeholder="e.g. PS5, Xbox Series S + cash…"
            />
            <div className="flex gap-2 mt-2">
              {['PS5', 'Xbox Series S', 'Switch OLED'].map(s => (
                <button key={s} className="h-8 px-3 rounded-full text-[12px] font-medium"
                  style={{ background: '#F5F1FF', color: '#5B2FD9' }}>
                  {s}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function StepReview({ title, price, condition, onEdit }: any) {
  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-[22px] font-bold" style={{ color: '#1E1633' }}>Review</h2>

      {/* Preview card */}
      <div className="p-3 rounded-[20px]" style={{ background: '#F6F5FA', boxShadow: '0 2px 8px rgba(30,22,51,0.06)' }}>
        <p className="text-[12px] font-medium mb-2" style={{ color: '#6E6884' }}>Preview — what buyers will see</p>
        <div className="bg-white rounded-[16px] overflow-hidden">
          <div className="flex items-center justify-center h-[120px]" style={{ background: '#E9E1FF' }}>
            <span className="text-5xl">🕹️</span>
          </div>
          <div className="p-3">
            <p className="text-[14px] font-medium line-clamp-2" style={{ color: '#1E1633' }}>{title}</p>
            <p className="text-[17px] font-bold mt-1" style={{ color: '#1E1633' }}>${price}</p>
            <div className="flex items-center gap-2 mt-1">
              <span className="inline-flex h-5 px-2 rounded text-[10px] font-medium"
                style={{ background: '#E9E1FF', color: '#45239E' }}>{condition}</span>
              <span className="inline-flex h-5 px-2 rounded-full text-[10px] font-bold text-white"
                style={{ background: '#5B2FD9' }}>Bundle · 2 items</span>
            </div>
            <span className="text-[12px] mt-1 block" style={{ color: '#948FA8' }}>📍 Makati</span>
          </div>
        </div>
      </div>

      {/* Checklist */}
      <div className="flex flex-col gap-2">
        {[
          { icon: '📷', label: 'Photos (3)', step: 1 },
          { icon: '📝', label: 'Details', step: 2 },
          { icon: '💰', label: 'Price & trade', step: 3 },
          { icon: '📍', label: 'Location "Makati"', step: null },
        ].map((row, i) => (
          <div key={i} className="flex items-center gap-3 h-14 px-4 rounded-[12px] bg-white"
            style={{ border: '1px solid #E9E6F0' }}>
            <span className="text-xl">{row.icon}</span>
            <span className="flex-1 text-[14px] font-medium" style={{ color: '#1E1633' }}>
              {row.label} <span style={{ color: '#23C997' }}>✓</span>
            </span>
            {row.step && (
              <button className="text-[13px] font-medium" style={{ color: '#5B2FD9' }}
                onClick={() => onEdit(row.step)}>
                Edit
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function StepSuccess({ onViewListing, onBackToDeals }: any) {
  return (
    <div className="flex flex-col items-center text-center gap-4 py-8 relative">
      <Confetti />
      <SuccessCircle size={96} />
      <div>
        <h2 className="text-[26px] font-bold" style={{ color: '#1E1633' }}>It's live! 🚀</h2>
        <p className="text-[14px] mt-2" style={{ color: '#6E6884' }}>
          Your listing is now visible to 2,140 gamers near Makati.
        </p>
      </div>

      {/* Stats */}
      <div className="flex w-full">
        {[
          { label: 'Views', value: '0' },
          { label: 'Saves', value: '0' },
          { label: 'Offers', value: '0' },
        ].map((s, i) => (
          <div key={i} className={`flex-1 flex flex-col items-center gap-1 py-4 ${i > 0 ? 'border-l' : ''}`}
            style={{ borderColor: '#E9E6F0' }}>
            <span className="text-[28px] font-bold animate-count-up" style={{ color: '#1E1633' }}>{s.value}</span>
            <span className="text-[12px]" style={{ color: '#6E6884' }}>{s.label}</span>
          </div>
        ))}
      </div>

      <PrimaryBtn onClick={onViewListing} className="w-full">View my listing</PrimaryBtn>
      <GhostBtn onClick={onBackToDeals}>Back to Deals</GhostBtn>
    </div>
  );
}
