import React, { useState } from 'react';
import { Avatar, VerifiedBadge, Stars, PrimaryBtn, SecondaryBtn, ListRow, GhostBtn } from '../components/ui';

interface Props {
  onSaved: () => void;
  onNotifications: () => void;
  onEditProfile: () => void;
  showToast: (msg: string) => void;
}

export default function Profile({ onSaved, onNotifications, onEditProfile, showToast }: Props) {
  return (
    <div className="flex flex-col h-full" style={{ background: '#F6F5FA' }}>
      <div className="flex-1 overflow-y-auto no-scroll">
        {/* Cover */}
        <div className="relative" style={{ height: 120, background: 'linear-gradient(160deg, #241049 0%, #5B2FD9 60%, #7C5CFF 100%)' }}>
          {/* Controller pattern overlay */}
          <div className="absolute inset-0 flex items-center justify-end pr-4 text-[60px] opacity-[0.06]">🎮</div>
          <button
            onClick={() => showToast('Settings coming in v1.0')}
            className="absolute top-4 right-4 w-10 h-10 rounded-full flex items-center justify-center text-xl"
            style={{ background: 'rgba(255,255,255,0.2)' }}
          >
            ⚙️
          </button>
        </div>

        {/* Avatar overlapping */}
        <div className="flex flex-col items-center -mt-11 pb-4 px-4">
          <Avatar size={88} ring initial="A" />
          <div className="flex items-center gap-2 mt-2">
            <span className="text-[28px] font-bold" style={{ color: '#1E1633' }}>Alex Reyes</span>
            <VerifiedBadge />
          </div>
          <span className="text-[15px]" style={{ color: '#6E6884' }}>@alextrades</span>
          <span className="text-[12px] mt-1" style={{ color: '#948FA8' }}>Member since Mar 2025 · Makati</span>

          {/* Stats */}
          <div
            className="flex w-full mt-4 rounded-[16px] overflow-hidden"
            style={{ background: 'linear-gradient(180deg, #fff 0%, #F5F1FF 100%)', border: '1px solid #E9E6F0' }}
          >
            {[
              { label: 'Listings', value: 14 },
              { label: 'Saved', value: 38 },
              { label: 'Sold', value: 6 },
            ].map((s, i) => (
              <div
                key={i}
                className={`flex-1 flex flex-col items-center py-4 ${i > 0 ? 'border-l' : ''}`}
                style={{ borderColor: '#E9E6F0' }}
              >
                <span className="text-[24px] font-bold" style={{ color: '#1E1633' }}>{s.value}</span>
                <span className="text-[12px]" style={{ color: '#6E6884' }}>{s.label}</span>
              </div>
            ))}
          </div>

          {/* Bio */}
          <p className="text-[14px] text-center mt-3" style={{ color: '#3A3350' }}>
            Collector clearing shelf space. All consoles tested, no surprises. Open to trades 🎮
          </p>

          {/* Action row */}
          <div className="flex gap-3 w-full mt-4">
            <SecondaryBtn onClick={onEditProfile} className="flex-1">Edit profile</SecondaryBtn>
            <PrimaryBtn onClick={() => showToast('Share link coming in v1.0')} className="flex-1">Share profile</PrimaryBtn>
          </div>
        </div>

        {/* Menu */}
        <div className="mx-4 mb-4 rounded-[16px] overflow-hidden bg-white"
          style={{ border: '1px solid #E9E6F0' }}>
          <ListRow icon="📦" label="My Listings" value="14" trailing onPress={() => showToast('Coming in v1.0')} />
          <ListRow icon="❤️" label="Saved Items" value="38" trailing onPress={onSaved} />
          <ListRow icon="💰" label="Sold Items" value="6" trailing onPress={() => showToast('Coming in v1.0')} />
          <ListRow icon="📍" label="Meetup preferences" value="Makati" trailing onPress={() => showToast('Coming in v1.0')} />
          <ListRow icon="🔔" label="Notifications" trailing onPress={onNotifications} />
          <ListRow icon="❓" label="Help Center" trailing onPress={() => showToast('Coming in v1.0')} />
          <ListRow icon="⚙️" label="Settings" trailing onPress={() => showToast('Coming in v1.0')} />
        </div>

        <p className="text-center text-[12px] pb-8" style={{ color: '#948FA8' }}>
          GameTrade! v0.5 — Midterm Build
        </p>
      </div>
    </div>
  );
}
