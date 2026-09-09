import React, { useState } from 'react';
import { PrimaryBtn, Toggle } from '../components/ui';

interface Props {
  onBack: () => void;
  showToast: (msg: string) => void;
}

export default function EditProfile({ onBack, showToast }: Props) {
  const [name, setName] = useState('Alex Reyes');
  const [username, setUsername] = useState('alextrades');
  const [bio, setBio] = useState("Collector clearing shelf space. All consoles tested, no surprises. Open to trades 🎮");
  const [location, setLocation] = useState('Makati');
  const [showRating, setShowRating] = useState(true);

  const save = () => {
    showToast('Profile updated');
    onBack();
  };

  return (
    <div className="flex flex-col h-full bg-white">
      {/* Header */}
      <div className="shrink-0 flex items-center justify-between px-4 py-4 border-b" style={{ borderColor: '#E9E6F0' }}>
        <button onClick={onBack} className="text-[22px]" style={{ color: '#6E6884' }}>×</button>
        <span className="text-[18px] font-semibold" style={{ color: '#1E1633' }}>Edit profile</span>
        <button onClick={save} className="text-[16px] font-semibold" style={{ color: '#5B2FD9' }}>Save</button>
      </div>

      <div className="flex-1 overflow-y-auto no-scroll px-4 py-6">
        {/* Avatar */}
        <div className="flex flex-col items-center mb-6">
          <div className="relative">
            <div className="w-20 h-20 rounded-full flex items-center justify-center text-3xl font-bold"
              style={{ background: '#E9E1FF', color: '#45239E' }}>A</div>
            <div className="absolute bottom-0 right-0 w-6 h-6 rounded-full flex items-center justify-center text-sm"
              style={{ background: '#5B2FD9', color: '#fff' }}>📷</div>
          </div>
          <button className="text-[14px] font-medium mt-2" style={{ color: '#5B2FD9' }}>Change photo</button>
        </div>

        <div className="flex flex-col gap-4">
          {[
            { label: 'Name', value: name, onChange: setName },
            { label: 'Username', value: username, onChange: setUsername },
            { label: 'Location', value: location, onChange: setLocation },
          ].map(f => (
            <div key={f.label}>
              <label className="text-[13px] font-medium block mb-1.5" style={{ color: '#6E6884' }}>{f.label}</label>
              <input
                className="w-full h-14 px-4 rounded-[12px] text-[16px] outline-none"
                style={{ background: '#F5F1FF', color: '#1E1633' }}
                value={f.value}
                onChange={e => f.onChange(e.target.value)}
              />
            </div>
          ))}

          <div>
            <label className="text-[13px] font-medium block mb-1.5" style={{ color: '#6E6884' }}>Bio</label>
            <textarea
              className="w-full px-4 py-3 rounded-[12px] text-[15px] outline-none resize-none"
              style={{ background: '#F5F1FF', color: '#1E1633', height: 100 }}
              value={bio}
              onChange={e => setBio(e.target.value)}
            />
          </div>

          <div className="flex items-center justify-between h-14 px-4 rounded-[12px] bg-white"
            style={{ border: '1px solid #E9E6F0' }}>
            <span className="text-[15px] font-medium" style={{ color: '#1E1633' }}>Show my rating publicly</span>
            <Toggle on={showRating} onChange={setShowRating} />
          </div>
        </div>
      </div>

      <div className="px-4 pb-8 pt-3" style={{ borderTop: '1px solid #E9E6F0' }}>
        <PrimaryBtn onClick={save} className="w-full">Save changes</PrimaryBtn>
      </div>
    </div>
  );
}
