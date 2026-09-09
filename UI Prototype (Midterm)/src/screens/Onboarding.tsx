import React, { useState } from 'react';
import { PrimaryBtn, GhostBtn } from '../components/ui';

interface Props {
  onComplete: () => void;
}

const SLIDES = [
  {
    emoji: '🎮',
    bg: 'linear-gradient(135deg, #5B2FD9 0%, #7C5CFF 55%, #A78BFA 100%)',
    title: 'Welcome to GameTrade!',
    sub: 'Buy, sell, and trade PlayStation, Xbox, and Nintendo Switch consoles — all in one place.',
    decor: [
      { label: 'A+', x: 20, y: 30 },
      { label: '$420', x: 65, y: 20 },
      { label: 'Trade ✓', x: 72, y: 65 },
    ],
  },
  {
    emoji: '🛍️',
    bg: 'linear-gradient(135deg, #FFB020 0%, #FF9F68 100%)',
    title: 'Real Deals, Every Day',
    sub: 'Official store discounts, flash sales, and seasonal drops on the consoles you want.',
    decor: [{ label: '−30%', x: 65, y: 25 }],
  },
  {
    emoji: '📸',
    bg: 'linear-gradient(135deg, #9B7BFF 0%, #5B2FD9 100%)',
    title: 'Sell in Minutes',
    sub: 'Snap a few photos, set your price, and reach thousands of local gamers.',
    decor: [],
  },
  {
    emoji: '🔄',
    bg: 'linear-gradient(135deg, #23C997 0%, #7C5CFF 100%)',
    title: 'Trade, Not Just Buy',
    sub: 'Propose console-for-console trades and close the deal your way.',
    decor: [],
  },
];

export default function Onboarding({ onComplete }: Props) {
  const [slide, setSlide] = useState(0);
  const s = SLIDES[slide];
  const isLast = slide === SLIDES.length - 1;

  const next = () => {
    if (isLast) onComplete();
    else setSlide(slide + 1);
  };

  return (
    <div
      className="flex flex-col h-full select-none"
      style={{ background: 'linear-gradient(180deg, #F5F1FF 0%, #E9E1FF 100%)' }}
    >
      {/* Skip */}
      <div className="flex justify-end px-4 pt-4 h-12">
        {!isLast && (
          <GhostBtn onClick={onComplete}>
            Skip
          </GhostBtn>
        )}
      </div>

      {/* Hero zone */}
      <div className="flex-1 flex flex-col items-center justify-center px-8">
        {/* Illustration */}
        <div className="relative mb-10" style={{ width: 280, height: 280 }}>
          {/* Main circle */}
          <div
            className="absolute inset-0 rounded-[40px] flex items-center justify-center"
            style={{ background: s.bg, boxShadow: '0 20px 60px rgba(91,47,217,0.25)' }}
          >
            <span style={{ fontSize: 100 }}>{s.emoji}</span>
          </div>
          {/* Decor chips */}
          {s.decor.map((d, i) => (
            <div
              key={i}
              className="absolute px-3 py-1 rounded-full text-[12px] font-semibold"
              style={{
                background: 'rgba(91,47,217,0.12)',
                color: '#5B2FD9',
                left: `${d.x}%`,
                top: `${d.y}%`,
                backdropFilter: 'blur(8px)',
                border: '1px solid rgba(91,47,217,0.2)',
              }}
            >
              {d.label}
            </div>
          ))}
        </div>

        {/* Title */}
        <h1
          className="text-[32px] font-bold text-center leading-tight mb-3"
          style={{ color: '#241049', letterSpacing: -0.5 }}
        >
          {s.title}
        </h1>
        <p className="text-[16px] text-center leading-relaxed" style={{ color: '#6E6884' }}>
          {s.sub}
        </p>
      </div>

      {/* Dots */}
      <div className="flex items-center justify-center gap-2 py-6">
        {SLIDES.map((_, i) => (
          <div
            key={i}
            onClick={() => setSlide(i)}
            className="rounded-full cursor-pointer"
            style={{
              height: 8,
              width: i === slide ? 24 : 8,
              background: i === slide ? '#5B2FD9' : '#BDA6FF',
              transition: 'width 0.3s cubic-bezier(0.2,0.8,0.2,1), background 0.3s',
            }}
          />
        ))}
      </div>

      {/* CTA */}
      <div className="px-8 pb-8">
        <PrimaryBtn
          onClick={next}
          className="w-full"
          style={isLast ? {
            background: 'linear-gradient(90deg, #5B2FD9 0%, #7C5CFF 100%)',
            boxShadow: '0 8px 24px rgba(91,47,217,0.35)',
          } : {}}
        >
          {isLast ? 'Get Started 🚀' : 'Next'}
        </PrimaryBtn>
      </div>
    </div>
  );
}
