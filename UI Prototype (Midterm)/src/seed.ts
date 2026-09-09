export type Platform = 'PS5' | 'PS4' | 'XBOX' | 'SWITCH';
export type Condition = 'Like New' | 'Good' | 'Fair' | 'For Parts';

export interface Listing {
  id: string;
  title: string;
  price: number;
  was?: number;
  platform: Platform;
  condition: Condition;
  sellerId: string;
  location: string;
  saved?: boolean;
  bundle?: string;
  images?: string[];
  description?: string;
}

export interface Seller {
  id: string;
  name: string;
  handle?: string;
  rating: number;
  reviews: number;
  verified: boolean;
  officialStore?: boolean;
  topSeller?: boolean;
  listings: number;
  sold: number;
  responseTime?: string;
  avatar?: string;
}

export const SELLERS: Record<string, Seller> = {
  jordan: {
    id: 'jordan', name: 'Jordan Lee', handle: '@jordanlee',
    rating: 4.9, reviews: 127, verified: true, topSeller: true,
    listings: 9, sold: 47, responseTime: '~1 hr',
  },
  mia: {
    id: 'mia', name: 'Mia Torres', handle: '@mia.torres',
    rating: 5.0, reviews: 84, verified: true,
    listings: 5, sold: 84, responseTime: '~30 min',
  },
  gamehaven: {
    id: 'gamehaven', name: 'GameHaven Store', handle: '@gamehaven',
    rating: 4.8, reviews: 312, verified: true, officialStore: true,
    listings: 42, sold: 312, responseTime: '~2 hrs',
  },
  kyle: {
    id: 'kyle', name: 'Kyle Tan', handle: '@kyle.tan',
    rating: 4.7, reviews: 45, verified: false,
    listings: 3, sold: 45, responseTime: '~3 hrs',
  },
  sam: {
    id: 'sam', name: 'Sam Rivera', handle: '@sam.rivera',
    rating: 4.6, reviews: 23, verified: false,
    listings: 4, sold: 23, responseTime: '~4 hrs',
  },
  alex: {
    id: 'alex', name: 'Alex Reyes', handle: '@alextrades',
    rating: 4.8, reviews: 18, verified: true,
    listings: 14, sold: 6, responseTime: '~1 hr',
  },
};

export const LISTINGS: Listing[] = [
  {
    id: 'L1', title: 'PS5 Disc Edition — 1TB', price: 430, was: 499,
    platform: 'PS5', condition: 'Like New', sellerId: 'jordan', location: 'Quezon City',
    description: 'Barely used PS5 Disc Edition, bought last December. Always kept in a ventilated shelf, no scratches on the disc drive, controllers have zero drift. Selling because I switched to handheld. Open to reasonable trades — see my trade list.',
    images: ['ps5-1','ps5-2','ps5-3','ps5-4'],
  },
  {
    id: 'L2', title: 'Xbox Series X — 1TB', price: 350,
    platform: 'XBOX', condition: 'Good', sellerId: 'mia', location: 'Makati', saved: true,
  },
  {
    id: 'L3', title: 'Nintendo Switch OLED — White', price: 280,
    platform: 'SWITCH', condition: 'Like New', sellerId: 'gamehaven', location: 'BGC',
  },
  {
    id: 'L4', title: 'PS4 Pro 1TB', price: 150, was: 169,
    platform: 'PS4', condition: 'Fair', sellerId: 'alex', location: 'Pasig',
  },
  {
    id: 'L5', title: 'Xbox Series S — 512GB', price: 220,
    platform: 'XBOX', condition: 'Good', sellerId: 'kyle', location: 'Ortigas',
  },
  {
    id: 'L6', title: 'Switch Lite — Turquoise', price: 120,
    platform: 'SWITCH', condition: 'Fair', sellerId: 'sam', location: 'Alabang', saved: true,
  },
  {
    id: 'L7', title: 'PS5 Slim Digital — 1TB', price: 385,
    platform: 'PS5', condition: 'Like New', sellerId: 'jordan', location: 'Quezon City',
  },
  {
    id: 'L8', title: 'Xbox Series X + 2 Controllers + 5 Games', price: 520, was: 610,
    platform: 'XBOX', condition: 'Good', sellerId: 'mia', location: 'Makati',
    bundle: 'Bundle · 4 items',
  },
  {
    id: 'L9', title: 'Switch + Mario Kart 8 + Carry Case', price: 300,
    platform: 'SWITCH', condition: 'Good', sellerId: 'gamehaven', location: 'BGC',
    bundle: 'Bundle · 3 items',
  },
  {
    id: 'L10', title: 'PS4 Slim 1TB + 3 Games', price: 140,
    platform: 'PS4', condition: 'Fair', sellerId: 'sam', location: 'Alabang',
    bundle: 'Bundle · 4 items',
  },
  {
    id: 'L11', title: 'DualSense Controller — Midnight Black', price: 55,
    platform: 'PS5', condition: 'Like New', sellerId: 'jordan', location: 'Quezon City',
  },
  {
    id: 'L12', title: 'Xbox Elite Controller Series 2', price: 95, was: 120,
    platform: 'XBOX', condition: 'Good', sellerId: 'kyle', location: 'Ortigas',
  },
];

export const PLATFORM_COLORS: Record<Platform, string> = {
  PS5: '#0070D1',
  PS4: '#0070D1',
  XBOX: '#107C10',
  SWITCH: '#E60012',
};

export const PLATFORM_BG: Record<Platform, string> = {
  PS5: 'rgba(0,112,209,0.12)',
  PS4: 'rgba(0,112,209,0.12)',
  XBOX: 'rgba(16,124,16,0.12)',
  SWITCH: 'rgba(230,0,18,0.12)',
};

export function getDiscount(price: number, was: number) {
  return Math.round((1 - price / was) * 100);
}
