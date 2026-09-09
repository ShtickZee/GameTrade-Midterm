# GameTrade! — Complete UI/UX Prototype Specification
**Version:** 1.0 (Midterm Prototype)
**Deliverable:** 100% high-fidelity, fully clickable Figma prototype
**Platform:** iOS — iPhone 15 frame (390 × 844 pt)
**Theme:** Light mode only — "Purple PlayStation" design language
**Font:** SF Pro (fallback: Inter). Iconography: SF Symbols style line icons, 24pt grid.

---

## 1. PRODUCT OVERVIEW

**GameTrade!** is a peer-to-peer marketplace for buying, selling, and trading used game consoles — **PlayStation, Xbox, and Nintendo Switch only**. No PC parts, no random electronics.

**Core promise:** A trustworthy console-only marketplace where users browse deals from official stores, buy/sell consoles, make cash offers, and propose trades — wrapped in a clean, premium, PlayStation-inspired UI with a purple identity.

**Primary user:** Both buyers and sellers equally. Casual gamers selling old consoles and buyers hunting deals.

**Prototype scope (100% clickable):**
- Onboarding (4 screens)
- Deals home screen (main tab) — official store deals, flash sales, seasonal banners (Shopee/Amazon-style commerce home)
- Marketplace (browse, search, filter)
- Listing detail with bundle support
- Make Offer + Propose Trade flows
- 4-step Sell flow with success state
- Offers inbox (incoming/sent, accept/decline)
- Profile system (own profile + other users' profiles)
- Notifications, Saved/Wishlist, Edit Profile
- All empty, loading (skeleton), and success states

**Explicitly OUT of prototype (button exists but shows a toast "Coming in v1.0"):**
- Chat/messaging screens
- Payments/billing/checkout
- Sign up / login flows (demo user is always signed in)

---

## 2. DESIGN SYSTEM — COLOR TOKENS

### 2.1 Brand Purple Scale
| Token | Hex | Usage |
|---|---|---|
| Purple/900 | #241049 | Onboarding headline text, deepest accents |
| Purple/800 | #33156B | Display text on light gradient areas |
| Purple/700 | #45239E | Strong text accents, active underline |
| Purple/600 (Primary) | #5B2FD9 | Primary brand color, active tab icon, links, primary buttons |
| Purple/500 | #7C5CFF | Gradient end color, bright accents |
| Purple/400 | #9B7BFF | Badges on dark gradient, progress fills |
| Purple/300 | #BDA6FF | Dividers on gradient, inactive dots |
| Purple/100 | #E9E1FF | Chip fills, selected chip background, tag backgrounds |
| Purple/50 | #F5F1FF | Card surface tints, section backgrounds, search field fill |

### 2.2 Accent Colors (purple-complementing)
| Token | Hex | Usage |
|---|---|---|
| Mint/500 | #23C997 | Success, stock progress bars, "Saved" confirmations |
| Mint/100 | #DFF7EF | Success chip background |
| Amber/500 | #FFB020 | Sale/discount highlights, warning |
| Amber/100 | #FFF3D6 | Discount badge background |
| Coral/500 | #FF6B5E | Flash deal urgency, countdown timer |
| Coral/100 | #FFE7E4 | Urgency chip background |
| Pink/500 | #FF7BD5 | Seasonal gradient end |
| Info Blue | #3E7BFA | Informational tags |

### 2.3 Semantic Colors
| Token | Hex | Usage |
|---|---|---|
| Success | #16A06A | Accepted status, verified badges, confirmed prices |
| Warning | #E8A200 | Pending status |
| Danger | #E5484D | Declined status, destructive buttons, error text |
| Info | #3E7BFA | Neutral info states |

### 2.4 Neutrals (purple-tinted grays)
| Token | Hex | Usage |
|---|---|---|
| Ink/900 | #1E1633 | Headline text |
| Ink/700 | #3A3350 | Body text |
| Ink/500 | #6E6884 | Secondary text |
| Ink/400 | #948FA8 | Tertiary text, timestamps |
| Line/200 | #E9E6F0 | Borders, dividers |
| Surface/100 | #F6F5FA | App background |
| Surface/0 | #FFFFFF | Cards, sheets, nav bars, tab bar |

### 2.5 Platform Colors (used ONLY inside small platform badges/icons)
| Platform | Hex |
|---|---|
| PlayStation | #0070D1 |
| Xbox | #107C10 |
| Nintendo Switch | #E60012 |

### 2.6 Gradients (exact specs)
| Name | Definition | Usage |
|---|---|---|
| Brand Gradient | Linear 135° · #5B2FD9 0% → #7C5CFF 55% → #A78BFA 100% | Primary CTAs, onboarding hero, tab center button, avatar rings |
| Hero Banner Gradient | Linear 160° · #241049 0% → #5B2FD9 60% → #7C5CFF 100% | Deals hero carousel banners, sale section headers |
| Seasonal Gradient | Linear 135° · #7C5CFF 0% → #FF7BD5 100% | Seasonal sale banner ("Spring Reset Sale") |
| Mint Gradient | Linear 135° · #23C997 0% → #4BE3B2 100% | Savings badges, success checkmark circle |
| CTA Gradient | Linear 90° · #5B2FD9 0% → #7C5CFF 100% | "Make Offer", "Publish Listing", "Get Started" buttons |
| Soft Card Gradient | Linear 180° · #FFFFFF 0% → #F5F1FF 100% | Info cards, offer cards, profile stat cards |
| Onboarding Fade | Linear 180° · #F5F1FF 0% → #E9E1FF 100% | Onboarding screen background |
| Flash Deal Gradient | Linear 135° · #FF6B5E 0% → #FF9F68 100% | Flash sale section header pill |
| Skeleton Shimmer | Linear 90° · #EFEDF5 0% → #F8F7FC 50% → #EFEDF5 100% (animated 1.4s loop) | All loading skeletons |

---

## 3. TYPOGRAPHY

Font: SF Pro (Inter fallback). All text color defaults to Ink/900 unless noted.

| Style | Size / Line Height / Weight / Tracking | Usage |
|---|---|---|
| Display LG | 32 / 40 / Bold / −0.5 | Onboarding headlines, profile name |
| Display MD | 28 / 34 / Bold / −0.4 | Section hero titles ("Mega Console Sale") |
| Title 1 | 22 / 28 / Bold / −0.2 | Screen titles, listing detail title |
| Title 2 | 18 / 24 / SemiBold | Section headers, card titles |
| Body LG | 16 / 24 / Regular | Descriptions, inputs |
| Body MD | 15 / 22 / Medium | Listing card titles, list rows |
| Body SM | 13 / 18 / Regular | Secondary text, seller/location rows |
| Caption | 11 / 14 / Medium | Badges, chips, timestamps, tab labels |
| Price LG | 26 / 32 / Bold | Listing detail price |
| Price MD | 17 / 22 / Bold | Listing card price, offer amounts |
| Price SM | 13 / 18 / SemiBold | Deal card prices |
| Mono Digits | SF Mono or tabular figures, 20 / 24 / Bold | Countdown timers, stat numbers |

Strikethrough original prices: Body SM, Ink/400, strikethrough on.

---

## 4. SPACING, RADIUS, ELEVATION, MOTION

**Spacing grid:** 4pt base — 4, 8, 12, 16, 20, 24, 32, 48. Screen side padding: 16pt. Section vertical gap: 24pt. Card inner padding: 12–16pt.

**Radius scale:** XS 8 (inputs, small chips) · SM 12 (buttons, chips) · MD 16 (cards, sheets) · LG 20 (listing cards, banners) · XL 24 (hero banners, bottom sheets top corners) · Full 999 (pills, avatars, icon buttons).

**Elevation:**
- Card resting: shadow 0 2 8 rgba(30,22,51,0.06)
- Card hover/press: shadow 0 6 16 rgba(91,47,217,0.12), scale 0.97
- Floating (tab bar, bottom sheets, sticky bars): shadow 0 −4 24 rgba(30,22,51,0.10)
- Center Sell button: shadow 0 8 20 rgba(91,47,217,0.35)

**Motion language (industry-standard easing):**
- Standard: 300ms cubic-bezier(0.2, 0.0, 0.0, 1.0)
- Emphasized (sheet present, hero transition): 450ms cubic-bezier(0.2, 0.8, 0.2, 1.0)
- Spring (tab switch, card press, success pop): damping 0.75, stiffness 400
- Micro-interactions: 150–200ms ease-out

---

## 5. COMPONENT LIBRARY (build as Figma components with variants)

### 5.1 Buttons
| Component | Variants | Spec |
|---|---|---|
| Button/Primary | Default, Pressed, Disabled, Loading | H 52, radius 14, CTA Gradient fill, white text 16/SemiBold, shadow 0 6 16 rgba(91,47,217,0.25). Pressed: scale 0.97 + brightness 95%. Disabled: fill Purple/100, text Ink/400, no shadow. Loading: white spinner replaces label. |
| Button/Secondary | Default, Pressed, Disabled | H 52, radius 14, fill White, border 1.5 Purple/600, text Purple/600 16/SemiBold. |
| Button/Ghost | Default, Pressed | H 44, no fill, text Purple/600 15/Medium. |
| Button/Danger-Ghost | Default | H 52, radius 14, fill #FDECEC, text Danger 16/SemiBold. |
| Button/Icon | 40px circle, 48px circle | White fill 92% opacity, shadow, icon 20 Ink/700. Used on image overlays (back, share, save). |
| Button/Small | Default | H 36, radius 10, padding 0 16, text 14/SemiBold. Primary and outlined variants. Used in brand strips ("Visit"), seller card ("Follow"). |

### 5.2 Chips & Tags
| Component | Spec |
|---|---|
| Chip/Filter | H 36, radius 999, padding 0 16. Unselected: fill White, border 1 Line/200, text Ink/700 13/Medium. Selected: fill Purple/600, text White, checkmark icon 12 leading. Optional icon slot (platform glyph). |
| Chip/Condition | H 24, radius 8, fill Purple/100, text Purple/700, 11/Medium. Values: "Like New", "Good", "Fair", "For Parts". |
| Tag/Platform | H 20, radius 6, platform color at 12% opacity fill, platform color text 10/Bold, uppercase. Values: PS5, PS4, XBOX, SWITCH. Sits overlaid top-left of listing card images (on white pill for legibility). |
| Badge/Discount | H 22, radius 6, Amber/500 fill, White text 11/Bold. Format: "−24%". |
| Badge/Deal | H 22, radius 999, Coral/500 fill, white text 11/Bold, lightning icon. "FLASH DEAL". |
| Badge/Verified | H 20, pill, Success fill, white checkmark 10 + "Verified" 10/Bold. |
| Badge/Bundle | H 24, radius 8, fill Purple/600, white text 11/SemiBold, box icon. "Bundle · 4 items". |
| Badge/Official | H 20, pill, Purple/600 fill, white text 10/Bold. "Official Store". |
| Badge/PriceDrop | H 22, radius 6, Mint Gradient fill, white text 11/Bold, down-arrow icon. "Price dropped 8%". |

### 5.3 Cards
| Component | Spec |
|---|---|
| Card/Listing | W 171 (2-col grid, 16 side padding, 12 gutter). Radius 20, White fill, Card shadow. Image area 171×128 (4:3), fill Surface/100, placeholder console image, radius top 20. Platform tag overlaid top-left (8pt inset). Heart/save icon button overlaid top-right (28px circle, white 90%, heart 14 Ink/500; saved state: heart fill Purple/600, scale-bounce animation). Content padding 12: Title Body MD 2-line clamp; Price row: Price MD Purple/900 + strikethrough original (if deal) + Badge/Discount; Meta row (8pt below): Condition chip + "· " + seller avatar 16 circle + seller name Body SM Ink/500; Location row: pin icon 12 + city Body SM Ink/400. **No timestamp. No trade badge on card.** |
| Card/Deal | W 160. Radius 16 White. Image 160×120 placeholder. Badge/Discount top-left overlay. Price SM row: sale price (Ink/900 Bold) + original strikethrough Ink/400. Sold progress bar (see 5.6). "Add to cart" not applicable — tap goes to Listing Detail. |
| Card/Offer | Full width − 32. Radius 16, Soft Card Gradient fill, border 1 Line/200. Layout: left listing thumb 56×56 radius 12; middle: counterparty avatar 24 + name Body MD, offer line "offered $380" (amount in Purple/600 SemiBold) or "wants to trade: Switch OLED + $50", Caption timestamp Ink/400 ("2h ago" — allowed inside offers only); right: Status Badge. Expanded actions zone (incoming + pending): two buttons side by side — Decline (Danger-Ghost style, H 40, flex 1) and Accept (Primary gradient, H 40, flex 1). Status Badge variants: Pending (Amber/100 bg, Warning text), Accepted (Mint/100 bg, Success text), Declined (#FDECEC bg, Danger text). |
| Card/Seller | Full width − 32. Radius 16 White. Avatar 48 circle with gradient ring (2pt), name Body MD + Badge/Verified inline, rating row: star icon 12 Amber/500 + "4.9 (127)" Body SM, response time "Replies within ~1 hr" Caption Ink/400. Right side: Button/Small "Follow". Tap card → Other User Profile. |
| Card/Info | Full width − 32, radius 16, Soft Card Gradient, padding 16. Contains listing title + price + platform tag. Used as the generic info box on Listing Detail (overlapping the gallery). |

### 5.4 Navigation
| Component | Spec |
|---|---|
| NavBar/Top | H 56 + status bar. Transparent or Surface/100 with blur. Leading: back chevron icon button (contextual). Center/left: Title 2. Trailing: icon buttons (bell, search). Bottom hairline 1 Line/200 only on scroll. |
| TabBar/Bottom | H 56 + home indicator area. White fill, top hairline Line/200, floating shadow. 5 slots: Deals (tag icon), Market (storefront icon), **Sell (center)**, Offers (exchange icon, with badge dot), Profile (person icon). Active state: icon Purple/600 filled + label Caption Purple/600 + 4px dot indicator above label that scales in (spring). Inactive: Ink/400 outline icons, label Caption. |
| SellButton/Center | 60px circle, Brand Gradient, white plus icon 26 (weight medium), elevated 12px above tab bar, glow shadow. Pressed: plus rotates 90° into an ×, scale 0.92. Tap → presents Sell flow as full-screen sheet sliding up. Label "Sell" Caption below, always Purple/600. |
| SegmentedControl | H 40, radius 12, fill Purple/50, padding 4. Two thumbs ("Incoming"/"Sent", "Listings"/"Sellers", "All"/"Offers"/"Deals"). Selected thumb: White fill, radius 10, shadow, text 13/SemiBold Ink/900. Unselected text 13/Medium Ink/500. Thumb slides with 300ms spring. |

### 5.5 Inputs
| Component | Spec |
|---|---|
| Field/Text | H 52, radius 12, fill Purple/50, no border default; focus: border 1.5 Purple/600 + white fill. Label above Body SM Ink/500. Placeholder Body LG Ink/400. Error state: border Danger, error text Caption Danger below. Char counter optional trailing Caption Ink/400. |
| Field/Search | H 44, radius 999, fill Purple/50, leading magnifier icon 16 Ink/500, placeholder "Search consoles, games, bundles…", trailing mic/x icon when typing. |
| Field/Price | H 56, radius 12, leading "$" Body LG Ink/500, digits Price LG, Purple/50 fill. Stepper presets below (see sheets). |
| Toggle/Switch | 51×31 standard iOS. On: Purple/600 track, white knob. Off: #D9D5E3 track. Knob slides spring 250ms. |
| Radio/Select | 22 circle, border 2 Line/200; selected: Purple/600 border + inner 10px dot fill. |
| PhotoUploadTile | 100×100, radius 16, dashed border 1.5 Purple/300, fill Purple/50, center plus icon 24 Purple/600 + Caption "Add photo" Purple/600. Filled state: image placeholder + small × remove button top-right (20 circle, Ink/700 80% fill, white ×) + cover badge on first ("COVER" 9/Bold white on Ink/900 60% pill bottom-left). |
| RangeSlider | Dual-thumb, track 4 radius 2, Line/200 base, Purple/600 active range, thumbs 24 white circle with Purple/600 border 2 + shadow. Min/max value bubbles above thumbs (Price SM on Purple/600 pill). |

### 5.6 Data Display
| Component | Spec |
|---|---|
| Avatar | Sizes 16/24/40/48/88. Circle, image placeholder fill Purple/100, initials fallback Purple/700 SemiBold on Purple/100. Variant "ring": 2pt Brand Gradient stroke offset 2pt. |
| RatingStars | 5 stars 12–16, fill Amber/500, partial fill supported, numeric label trailing Body SM. |
| CountdownTimer | Inline pill H 28 radius 8 Ink/900 fill; three digit boxes 22×26 radius 6 White fill, Mono Digits Ink/900 16/Bold, ":" separators White. Variant "on-dark": boxes White, digits Coral/500. Ticks every second (prototype: static "02 : 14 : 36"). |
| StockProgress | H 6 radius 3, track #FFE3DE, fill Flash Deal Gradient, width = % sold. Label above: "38 sold" Caption Ink/500; right label "72% claimed" Caption Coral/500 SemiBold. Animated fill 800ms ease-out on appear. |
| StatCell | Vertical, W flex. Number Title 1 Ink/900 (count-up animation on load). Label Caption Ink/500. Used in profile stats rows (3 cells). |
| ListRow/Menu | H 56, White fill, leading icon 22 in 36px rounded square tinted Purple/50 (icon Purple/600), label Body MD, trailing chevron 16 Ink/400, optional trailing value Caption Ink/400, bottom hairline Line/200 inset 54. |
| Toast | Bottom floating, H 48+, radius 14, Ink/900 92% fill, white text Body SM, leading icon 18 (Success check / Info / Warning), auto-dismiss 2.5s, slide-up + fade. |
| Skeleton | Shapes in #EFEDF5 radius matched to target component, shimmer overlay gradient sweeping left→right 1.4s infinite. |
| EmptyState | Centered: illustration placeholder 160×160 (line-art style, Purple/300 strokes), headline Title 2 Ink/900, subcopy Body SM Ink/500 (2-line max, centered), optional Button/Primary or Ghost. |

---

## 6. NAVIGATION ARCHITECTURE

### 6.1 Tab structure (bottom nav, Instagram-2026 style)
| Slot | Tab | Screen | Swipeable |
|---|---|---|---|
| 1 | Deals | Deals Home | Yes ↔ |
| 2 | Market | Marketplace | Yes ↔ |
| 3 | Sell | Sell Step 1 (modal, not a page) | Excluded |
| 4 | Offers | Offers | Yes ↔ |
| 5 | Profile | Profile (Me) | Yes ↔ |

**Swipe navigation:** Horizontal swipe left/right moves between Deals → Market → Offers → Profile as a continuous pager. During swipe: pages translate 1:1 with finger, adjacent page visible at edge; tab bar stays fixed; active tab icon swaps at the 50% crossover point with a spring pop (scale 1 → 1.15 → 1, 300ms). Sell (center) is never part of the pager.

**Sell button:** Tap → full-screen sheet slides up (450ms emphasized ease), presenting Sell Step 1 over a dimmed backdrop. Sheet has grabber handle (36×4, Line/200, radius 2) and swipe-down-to-dismiss.

### 6.2 Full screen inventory & frame naming
| # | Frame Name | Notes |
|---|---|---|
| 01 | Onboarding — Welcome | |
| 02 | Onboarding — Buy | |
| 03 | Onboarding — Sell | |
| 04 | Onboarding — Trade | Final slide, CTA |
| 10 | Deals — Home | Main tab, default landing after onboarding |
| 11 | Deals — Loading (Skeleton) | |
| 20 | Marketplace — All | |
| 21 | Marketplace — PlayStation | Filtered state |
| 22 | Marketplace — Loading (Skeleton) | |
| 30 | Search — Default | Recents + trending |
| 31 | Search — Results | Segmented Listings/Sellers |
| 32 | Search — Empty | |
| 35 | Filters — Sheet | Bottom sheet over Marketplace |
| 40 | Listing Detail — Default | PS5 Disc Edition |
| 41 | Listing Detail — Bundle | Xbox bundle, bundle section expanded |
| 42 | Offer Sheet — Make Offer | Bottom sheet over 40 |
| 43 | Offer Sheet — Propose Trade | Bottom sheet over 40 |
| 44 | Offer Sent — Success | Confetti + toast state |
| 50 | Sell — Step 1 Photos | |
| 51 | Sell — Step 2 Details | |
| 52 | Sell — Step 2 Error | Validation state |
| 53 | Sell — Step 3 Price & Trade | |
| 54 | Sell — Step 4 Review | |
| 55 | Sell — Success | |
| 60 | Offers — Incoming | |
| 61 | Offers — Sent | |
| 62 | Offers — Empty | Incoming empty state |
| 70 | Profile — Me | |
| 71 | Profile — Edit | |
| 75 | Profile — Other User | Jordan Lee |
| 76 | Notifications | |
| 77 | Saved — Wishlist | |

All frames: iPhone 15 (390×844), light status bar content (dark icons), home indicator always visible (Ink/900).

---

## 7. SCREEN SPECIFICATIONS

### FRAME 01–04 — ONBOARDING

**Layout (all four slides identical skeleton):**
- Background: Onboarding Fade gradient.
- Top-right: "Skip" Button/Ghost (Ink/500), hidden on slide 04.
- Hero zone (y≈120, centered, 300×300): rounded illustration placeholder, radius 32.
- Slide 01 hero: three overlapping console silhouettes (PS5 white/black, Xbox black, Switch neon) on a Brand Gradient blob; small floating cards around it: "A+", "$420", "Trade ✓" (decor chips, Purple/600 12% fill).
- Slide 02 hero: shopping-bag + price tag illustration, Amber/500 accents, "−30%" floating badge.
- Slide 03 hero: hand holding console into a camera frame, Purple/400 accents.
- Slide 04 hero: two consoles exchanging with circular arrows between them, Mint + Purple accents.
- Title: Display LG, centered, Purple/900.
- Subtitle: Body LG, centered, Ink/500, max 2 lines, side padding 32.
- Page dots: 4 dots, 8px inactive Purple/300, active dot is a 24×8 pill Purple/600, animates width with 300ms spring as user swipes.
- Bottom (y≈740): Button/Primary full width − 64.
  - Slides 01–03: label "Next".
  - Slide 04: label "Get Started" — CTA Gradient, glow shadow.

**Exact copy:**
| Slide | Title | Subtitle |
|---|---|---|
| 01 | Welcome to GameTrade! | Buy, sell, and trade PlayStation, Xbox, and Nintendo Switch consoles — all in one place. |
| 02 | Real Deals, Every Day | Official store discounts, flash sales, and seasonal drops on the consoles you want. |
| 03 | Sell in Minutes | Snap a few photos, set your price, and reach thousands of local gamers. |
| 04 | Trade, Not Just Buy | Propose console-for-console trades and close the deal your way. |

**Interactions:** Swipe left between slides (smart animate, dots update). Skip (any slide) → Frame 10. Next → next slide. Get Started → Frame 10 with a fade + scale-in (content springs up staggered 60ms).

---

### FRAME 10 — DEALS (HOME) ★ MAIN SCREEN
The commerce heart of the app. Shopee/Amazon-style vertical scroll. Status bar area white.

**Zone A — Header (sticky on scroll, collapses):**
- Row 1 (H 44): Wordmark left: "GameTrade!" 22/Bold, "Game" in Ink/900, "Trade!" in Purple/600, small purple bolt icon trailing the wordmark. Right: NotificationBell icon button (40 circle, Purple/50 fill, bell 20 Ink/700, unread red dot 8 top-right) → Frame 76.
- Row 2 (H 44, 8pt below): Field/Search full width, placeholder "Search PS5, Xbox Series X, Switch…". Tap → Frame 30.
- On scroll: rows collapse into a single compact bar (wordmark shrinks to 18, search field shrinks to icon+pill) — represent the collapsed state by duplicating content with sticky header variant if needed; otherwise keep expanded.

**Zone B — Hero banner carousel (H 180, side padding 16, radius XL 24):**
- 3 banners, horizontal pager, auto-advance every 4s, parallax on banner image (image moves at 0.8× speed of the swipe).
- Banner structure: Hero Banner Gradient background; left text block (padding 20): eyebrow Caption White 70% uppercase letter-spacing 0.8; title Display MD White 2-line; sub Body SM White 80%; small Button/Small inverted (White fill, Purple/600 text, "Shop now" H 32). Right: floating console image placeholder 140×140 with soft purple glow, slight −6° rotation.
- Banner 1 copy: eyebrow "MEGA CONSOLE SALE" · title "Up to 30% off certified pre-owned consoles" · sub "PlayStation · Xbox · Switch" · CTA "Shop now".
- Banner 2: Seasonal Gradient bg · eyebrow "SPRING RESET SALE" · title "Trade in your old console, level up" · sub "Extra 10% trade-in credit this week" · CTA "Start trading".
- Banner 3: Flash Deal Gradient bg · eyebrow "48 HOURS ONLY" · title "Official Store Flash Drop" · sub "While stocks last" · CTA "See deals".
- Page dots: 3, bottom-center over banner, 6px, White 40% inactive / White active pill 16×6.

**Zone C — Category quick grid (24pt below):**
- Section header row: "Browse by category" Title 2 left; "See all" Ghost Purple/600 right → Frame 20.
- 2 rows × 4 columns, 8 items, each 76 wide: icon tile 56×56 radius 16 pastel fill + line icon 24, label Caption Ink/700 centered below (2-line clamp).
- Items (tile fill / icon): PlayStation #EAF3FD controller · Xbox #E8F5E8 console · Switch #FDECEC joycon · Controllers Purple/50 gamepad · Bundles Amber/100 box · Deals of the Day Coral/100 lightning · Official Stores Mint/100 storefront · Accessories #EDEBFA headphones.
- Tap any tile → Frame 20 (Marketplace, pre-filtered).

**Zone D — Flash Deals (H ≈ 240):**
- Section header bar: full width − 32, radius 16, Flash Deal Gradient fill, H 48, padding 16: left "⚡ Flash Deals" 17/Bold White; center-right CountdownTimer (on-dark variant) reading "02 : 14 : 36"; trailing chevron-circle (28, White 20% fill, white chevron) → Frame 20.
- Horizontal scroll row of 4 Card/Deal components (gap 12, side padding 16, first/last snap).
- Deal card contents (image placeholder + overlay + text):
  1. "PS5 Slim — 1TB Disc" · $449 · ~~$549~~ · Badge/Discount "−18%" · progress 72% claimed, "38 sold".
  2. "Xbox Series X — 1TB" · $389 · ~~$499~~ · "−22%" · progress 54%, "27 sold".
  3. "Switch OLED — White" · $279 · ~~$349~~ · "−20%" · progress 83%, "41 sold".
  4. "DualSense Controller — Midnight" · $54 · ~~$69~~ · "−21%" · progress 31%, "12 sold".
- Tap card → Frame 40.

**Zone E — Official Store strip (H ≈ 120):**
- Section header: "Official stores" Title 2 + Ghost "See all".
- Horizontal row of 3 store cards (W 240, radius 16, White, card shadow, padding 12, layout: left logo tile 40×40 radius 10 platform-tinted fill + platform glyph; middle: store name Body MD + Badge/Official + Caption "4.8 ★ · 1.2k items"; right Button/Small "Visit").
- Stores: "PlayStation Direct" (PS blue tile) · "Xbox Official Store" (green tile) · "Nintendo Authorized Hub" (red tile).
- Tap Visit/card → Frame 20.

**Zone F — Seasonal collection ("Spring Reset Sale"):**
- Full width − 32 card, Seasonal Gradient bg, radius LG, padding 16, H ≈ 150: left text: eyebrow Caption White 80% "SEASONAL EVENT · ENDS APR 30"; title "Spring Reset Sale" Display MD White; sub "Consoles, bundles & trade-in bonuses" Body SM White 80%; inline pill link "Explore the sale →" White pill, Pink/500 text, H 32. Right: decorative collage of 3 small tilted image placeholders (64×64, radius 12, rotations −8°/+4°/−3°).
- Tap → Frame 20.

**Zone G — Deals for You (2-col grid continuation):**
- Section header: "Deals for you" Title 2 + Ghost "See all".
- 2 columns of Card/Deal (same as Flash row but wrapped grid, 4 items):
  1. "PS5 Disc Edition (Certified Pre-Owned)" $419 ~~$499~~ −16%
  2. "Xbox Series S Starter Bundle" $259 ~~$329~~ −21%
  3. "Switch + Mario Kart 8 Bundle" $309 ~~$379~~ −18%
  4. "PS4 Pro 1TB — Refurbished" $179 ~~$229~~ −22%
- Infinite scroll hint: at bottom, a spinner row (24pt, Purple/600 arc) suggesting more content.

**Pull-to-refresh:** standard iOS, Purple/600 spinner on Surface/100.

**FRAME 11 — Deals Loading:** identical layout, all imagery/cards replaced by Skeleton blocks with shimmer; hero banner skeleton is one big rounded block; countdown replaced by gray pill.

---

### FRAME 20/21/22 — MARKETPLACE (TAB 2)

**Zone A — Header (sticky):**
- Row 1: Title "Marketplace" Title 1 left; right: search icon button (40 circle Purple/50) → Frame 30, and filter icon button with active-count dot → Frame 35 (sheet).
- Row 2 (12pt below): Platform segmented chips (horizontal scroll, gap 8, side padding 16): "All" (selected by default), "PlayStation", "Xbox", "Switch". Chip/Filter style with mini platform glyph. Selected chip animates (fill morph + checkmark slide-in, spring 300ms).
- Row 3: secondary filter chips row (scrollable): "Price ▾", "Condition ▾", "Accepts trades", "Bundles", "Near me". Tapping any opens Frame 35.
- A sliding underline indicator (3px, Purple/600, radius 2) under the selected platform chip group — moves with spring.

**Zone B — Featured carousel (H ≈ 190):**
- Section label row: "Featured — verified sellers" Body SM Ink/500 left; "Why verified?" Ghost right (tap → Toast "Verification info coming in v1.0").
- Horizontal pager of 2 wide cards (W 320, radius LG, Hero Banner Gradient, padding 16): left: console image placeholder 120×120 radius 12 tilted −4°; right: Badge/Verified, title "PS5 Disc Edition" 17/Bold White, price "$430" Price MD White, seller row: avatar 20 + "Jordan Lee" + "★ 4.9" Caption White 80%, small Button/Small White "View" bottom-right.
- Second card: "Xbox Series X Bundle" $520, seller "Mia Torres ★ 5.0".

**Zone C — Results header row:**
- Left: "248 listings" Body SM Ink/500 (count animates 0→248 on filter change).
- Right: sort dropdown pill "Sort: Most recent ▾" (Caption, Purple/600 text, Purple/50 fill, radius 999, H 28) → opens Frame 35 scrolled to Sort section.

**Zone D — Listings grid (2 columns, gap 12, side padding 16):**
Card/Listing components. Frame 20 ("All") shows 8 cards in this exact order (content = Section 14 seed data): L1, L2, L3, L4, L5, L6, L7, L8. Two cards (L2, L6) show the saved-heart state (filled purple heart).
Frame 21 ("PlayStation"): only PS listings remain (L1, L3, L5, L7) with a smooth relayout animation (cards fly/fade into new positions, 350ms staggered 40ms).
Frame 22: grid of 6 Skeleton listing cards (image block + 2 text bars + chip bar), shimmer active; platform chips real (interactive), header real.

**Interactions:** Card tap → Frame 40 (hero image morph). Heart tap → toggle with pop animation (scale 1→1.3→1, 250ms) + haptic-style micro toast "Saved to wishlist". Scroll to bottom → infinite spinner row.

---

### FRAME 30/31/32 — SEARCH

**Frame 30 — Default:**
- Top: Field/Search auto-focused (keyboard shown as iOS light keyboard block), leading back chevron → previous tab.
- "Recent searches" section: header Body SM Ink/500 + "Clear" Ghost Danger right; chips: "PS5 disc edition", "Xbox series x", "Switch oled", "controller drift free" (Chip/Filter neutral, tap = fills search field).
- "Trending near you" section: 5 numbered rows (rank number Title 2 Purple/300 w40, mini thumb 40×40 radius 10, term Body MD, trailing trend arrow + count Caption: ↑ Mint or ↓ Danger):
  1. PS5 Disc Edition — ↑ 1.2k searches
  2. Xbox Series X — ↑ 890
  3. Switch OLED — ↑ 760
  4. PS4 Pro — ↓ 210
  5. Switch Lite — ↑ 180
- Tap any row → Frame 31.

**Frame 31 — Results ("ps5"):**
- Search bar filled "ps5" + clear ×.
- SegmentedControl: "Listings" (active) | "Sellers".
- Listings state: results count "32 results for 'ps5'" + 2-col grid of 4 cards (L1, L3, L5, L7) with staggered fade-up entrance (60ms).
- Sellers state (variant): 3 Card/Seller stacked: Jordan Lee (4.9★, 127 sales, Verified, 9 listings); GameHaven Store (4.8★, Official); Mia Torres (5.0★, Verified, 14 listings). Tap → Frame 75.

**Frame 32 — Empty ("ps58"):**
- Search bar filled, results area = EmptyState: illustration (magnifier over empty box, Purple/300 line art), headline "No results for 'ps58'", sub "Try a different spelling or browse all consoles.", Button/Primary "Browse marketplace" → Frame 20. Ghost below "Create a wanted alert" → Toast "Coming in v1.0".

---

### FRAME 35 — FILTERS SHEET (over Marketplace, backdrop Ink/900 40%)
Bottom sheet, top radius XL, White, floating shadow, grabber handle, H ≈ 640, scrollable, sticky footer.

- Header row: "Filters" Title 2 + trailing Ghost "Reset all" (Danger on active filters, Ink/500 otherwise).
- **Platform** (multi-select chips): PlayStation · Xbox · Switch. Selected = Purple/600 fill.
- **Condition** (multi-select chips): Like New · Good · Fair · For Parts.
- **Price range**: RangeSlider $50–$1,000; bubbles show "$120" and "$650"; quick preset chips below: "Under $200", "$200–$400", "$400+".
- **Location**: Toggle row "Near me (25 km)" — Toggle/Switch ON.
- **Trade options**: Toggle row "Accepts trades only" — OFF. Toggle row "Bundles only" — OFF.
- **Seller**: Toggle row "Verified sellers only" — ON.
- **Sort by** (Radio/Select list): Most recent (selected) · Price: Low to High · Price: High to Low · Best match.
- Sticky footer (H 84, White, top hairline, padding 16): left Ghost "Show 248 results" (count updates live in Purple/600), right Button/Primary flex 1.5 "Apply filters". Apply → sheet slides down (300ms) + marketplace relayout animation + Toast "3 filters applied".

---

### FRAME 40 — LISTING DETAIL (Default: PS5 Disc Edition)

**Zone A — Image gallery (full-bleed 390 × 420, top of screen, extends under status bar):**
- 4 image placeholders (console photos, labeled "Photo 1–4"), horizontal pager with snap; active dot White pill 16×6, inactive White 50% 6px, bottom-center over image; counter pill top-right under icons "1/4" (Caption Bold White on Ink/900 50% blur pill).
- Parallax: image block translates 0.5× while sheet content scrolls over it; on scroll-up past gallery, NavBar fades in (White, back chevron left, share + more icons right) and a compact title/price bar slides down into the nav (Title 2 + "$430" Purple/600 Bold).
- Floating controls over gallery: back chevron Button/Icon top-left → Frame 20; share icon Button/Icon top-right (tap → Toast "Share link coming in v1.0"); heart icon Button/Icon below share (toggle save, pop animation).

**Zone B — Info card (Card/Info, pulled up −24 over gallery, radius LG, padding 16):** the single generic info box pairing title + imagery (no grading system anywhere in the app):
- Row 1: Tag/Platform "PS5" + Badge/Deal if deal price applies (not on this listing) .
- Row 2: Title "PlayStation 5 Disc Edition — 1TB" Title 1 (2-line max).
- Row 3: Price row: "$430" Price LG Ink/900; right side: strikethrough "$499" + Badge/Discount "−14%" (only when the listing carries a deal price — show on Frame 41 instead to demonstrate).
- Row 4: meta row: Condition chip "Like New" + "·" + pin icon + "Quezon City" Body SM Ink/500.

**Zone C — Includes section:**
- Header "What's included" Body MD SemiBold; chips wrap: "Original box ✓", "1× DualSense controller", "HDMI cable", "Power cable", "2 games included". Chips: Purple/50 fill, Purple/700 text, check icon Mint/500.

**Zone D — Seller card (Card/Seller):**
- Avatar 48 gradient ring, "Jordan Lee" + Badge/Verified, "★ 4.9 (127 sales)" + "Replies within ~1 hr". Right Button/Small "Follow" (tap toggles to "Following ✓" with fill swap animation). Tap card → Frame 75.

**Zone E — Description:**
- Header "Description". Body LG Ink/700 text (4 lines) + Ghost "Read more" (expands full text with height animation 300ms):
  "Barely used PS5 Disc Edition, bought last December. Always kept in a ventilated shelf, no scratches on the disc drive, controllers have zero drift. Selling because I switched to handheld. Open to reasonable trades — see my trade list."
- Safety row (Purple/50 fill, radius 12, padding 12): shield icon Purple/600 + "Meet in public places. Never pay in advance." Body SM Ink/500.

**Zone F — Sticky bottom action bar (H 84 + home area, White, floating shadow, padding 12/16):**
- Left: Button/Icon 48 circle outline "chat bubble" (Message) → Toast "Chat coming in v1.0".
- Right pair: Button/Secondary "Trade" (flex 1, exchange icon, swaps to solid Purple when tapped → opens Frame 43) + Button/Primary "Make Offer $430" (flex 1.4, CTA Gradient) → opens Frame 42.

**FRAME 41 — Listing Detail (Bundle variant):** Same layout with: gallery 5 photos; Info card shows Badge/Bundle "Bundle · 4 items", title "Xbox Series X + 2 Controllers + 5 Games", price "$520" + strikethrough "$610" + Badge/Discount "−15%"; a **Bundle contents** section (seamless, this is the bundle requirement): Card/Info-styled list, header row "Bundle contents (4)" Body MD SemiBold + total value right "Value $610" Caption Ink/400 strikethrough; 4 rows each: thumb 48×48 radius 10 + item name Body MD + individual value Caption Ink/500 right:
1. Xbox Series X 1TB console — $380
2. Wireless Controller (Carbon Black) — $55
3. Wireless Controller (Robot White) — $55
4. Game pass bundle (Forza, Halo, Starfield, Sea of Stars, Ori) — $120
Rows have hairline dividers; expand/collapse chevron animates 180° with height transition. Seller: "Mia Torres ★ 5.0 Verified". Location "Makati".

---

### FRAME 42 — MAKE OFFER SHEET (over Frame 40, backdrop 40%)
Bottom sheet radius XL, H ≈ 480, grabber, padding 16.
- Header: "Make an offer" Title 2; right × icon button → dismiss (slide down 300ms).
- Mini listing row: thumb 48 radius 10 + title Body MD 1-line + "Listed at $430" Caption Ink/500.
- Quick-preset chips row: "−5% · $409" · "−10% · $387" (pre-selected, Purple/600) · "−15% · $366". Tap swaps Field/Price value with a digit-roll animation.
- Field/Price large, centered digits, label "Your offer".
- Optional note Field/Text (2-line, placeholder "Add a note for the seller…", 120 char counter).
- Footer: Button/Primary full width "Send offer" → Frame 44.
- Validation variant: empty/absurd offer (< 50% of price) → Danger border + Caption "Offers below $215 usually get declined." (show as a state).

### FRAME 43 — PROPOSE TRADE SHEET (over Frame 40)
- Header: "Propose a trade" + ×.
- Info line: Body SM Ink/500 "Pick one of your consoles to offer. Jordan accepts trades on this listing."
- Horizontal card picker (H 150): 2 cards W 130 radius 16 from my listings ("Switch OLED — $280", "PS4 Pro — $150") with radio-check overlay; selected card: Purple/600 border 2 + check badge top-right scale-in. Third tile = dashed "Add console" PhotoUploadTile style → Toast "Post it from the Sell tab" (deep-link hint).
- "+ Add cash" row: Toggle/Switch + Field/Price small ($50 preset) — enabling slides the field open (height animation 300ms).
- Balance meter row (nice, cheap to build): "Your offer value: $330 · Listing: $430" with a thin progress bar Purple/600 at 77% + Caption Mint "Fair trade range ✓".
- Footer: Button/Primary "Send proposal" → Frame 44.

### FRAME 44 — OFFER SENT SUCCESS (overlay over detail)
- Backdrop Ink/900 55%; centered success card (W 300, radius XL, White, padding 24, spring scale-in 0.8→1, 450ms emphasized): Mint Gradient circle 72 with white checkmark (stroke-draw animation 400ms); confetti burst (12 particles, purple/mint/amber, 700ms fall); headline "Offer sent! 🎉" Title 2; sub "Jordan Lee will review your offer of $387." Body SM Ink/500 centered; Button/Primary "View my offers" → Frame 61; Ghost "Keep browsing" → Frame 20.

---

### FRAMES 50–55 — SELL FLOW (full-screen sheet, 4 steps)

**Persistent chrome (all steps):** top bar H 56: × close left (dismiss with "Draft saved" toast), "Sell a console" Title 2 center, step counter "1/4" Caption Ink/500 right. Below: ProgressStepper — 4 segments H 4 radius 2, completed + current Purple/600 (current animates width-grow 350ms), upcoming Line/200. Sticky footer per step: back Ghost (steps 2–4) + Button/Primary (label changes per step).

**Frame 50 — Step 1 · Photos:**
- Headline "Show it off" Title 1 + sub "Up to 8 photos. First one is the cover. Good light = faster sale." Body SM Ink/500.
- PhotoUploadTile grid 3-col: tile 1 filled (console photo placeholder + "COVER" badge), tiles 2–3 filled, tile 4 = dashed add tile, tiles 5–8 = faint disabled placeholders. Filled tiles pop in with staggered scale animation (80ms).
- Tip card (Amber/100 fill, radius 12): "💡 Include the ports, screen, and serial number for buyer trust."
- Footer CTA: "Next: Details" (disabled until ≥1 photo; show enabled state).

**Frame 51 — Step 2 · Details:**
- Fields (Field/Text style, labels above):
  - "Title" — prefilled "Nintendo Switch OLED — White, boxed" (56/80 counter).
  - "Platform" — 3 large selectable tiles side by side (flex, H 72, radius 12): PlayStation / Xbox / Switch glyph + name; Switch selected (Purple/600 border + Purple/50 fill + check badge).
  - "Model" — dropdown row (chevron): value "Switch OLED (2023)".
  - "Storage" — chips (only if applicable): "32GB" selected, "64GB", "1TB", "2TB".
  - "Condition" — 4 Chip/Filter single-select: "Like New" (selected) · "Good" · "Fair" · "For Parts".
  - "Bundle items" — dynamic list: 2 filled rows (thumb 40 + name field "Pro Controller" + value field "$55" + remove − icon) + dashed "＋ Add bundle item" row (seamless bundle building).
  - "Description" — multiline field 120pt, placeholder "Describe usage, defects, why you're selling…".
- Footer: back "Photos" Ghost + "Next: Pricing" Primary.

**Frame 52 — Step 2 Error variant:** Title field empty with Danger border + error Caption "Give your listing a title"; platform unselected with shake-annotation; CTA disabled. (One frame showing validation.)

**Frame 53 — Step 3 · Price & Trade:**
- "Your price" Field/Price large, value "$280".
- Suggestion card (Purple/50, radius 12, padding 12): "Similar consoles near you sell for $265–$295" + 3 preset chips "Sell fast $260" · "Fair $280" (selected) · "Aim high $300". Tapping chips rolls the digits (number tween 300ms).
- Divider "or".
- Trade section: Toggle row "I'm open to trades" (ON) → reveals (slide-down 300ms): "What would you trade for?" Field/Text placeholder "e.g. PS5, Xbox Series S + cash…" + chip suggestions "PS5", "Xbox Series S", "Switch OLED".
- Footer: "Next: Review".

**Frame 54 — Step 4 · Review:**
- "Preview" label + live Card/Listing replica of the new listing (Switch OLED, $280, Like New, Makati, bundle badge "Bundle · 2 items") on Surface/100 backdrop with subtle drop shadow — this card is what buyers will see.
- Checklist rows (icon + label + trailing Ghost "Edit" → jumps to that step): Photos (3) ✓ · Details ✓ · Price & trade ✓ · Location "Makati" ✓.
- Footer: "Publish listing" Button/Primary full width, CTA Gradient + glow.

**Frame 55 — Success:**
- Centered: Mint Gradient circle 96 + white check (draw animation) + soft confetti; "It's live! 🚀" Display MD; sub "Your listing is now visible to 2,140 gamers near Makati." Body SM Ink/500.
- Mini stats row: 3 StatCells — "Views 0" · "Saves 0" · "Offers 0" (will count up later).
- Buttons: Primary "View my listing" → Frame 40; Ghost "Back to Deals" → Frame 10.
- Also publishes into user's Offers/Profile counts (Profile listings 14 → 15 in subsequent frames if you want continuity; keep 14 for simplicity and note it).

---

### FRAMES 60/61/62 — OFFERS (TAB 4)

**Chrome:** NavBar "Offers" Title 1 + trailing check-circle icon "Mark all read" (tap → unread dots fade out, Toast "All caught up"). SegmentedControl below: "Incoming (2)" | "Sent (3)" — thumb slides with spring; content cross-fades + 8pt horizontal slide in swipe direction.

**Frame 60 — Incoming:** 2 Card/Offer (pending):
1. Jordan-style reversed: buyer avatar "kai_gamer" · on your "Switch OLED — White" · **offered $265** · "2h ago" · Badge Pending · actions: Decline + Accept.
2. "mia.trades" · on your "PS4 Pro 1TB" · **wants to trade: Xbox Series S + $40** · "1d ago" · Badge Pending · actions Decline + Accept.
- Tap Accept → card animates: buttons collapse, status badge flips to Accepted (Mint) with a check-pop, row background flashes Mint/100 once, Toast "Offer accepted — arrange meetup details in chat (v1.0)". Tap Decline → badge flips to Declined, card dims to 60% and drops to bottom of list (300ms).

**Frame 61 — Sent:** 3 Card/Offer (no action buttons, status badges only):
1. On "PS5 Disc Edition — 1TB" (Jordan Lee) · you offered $387 · "10m ago" · Pending.
2. On "Xbox Series X Bundle" (Mia Torres) · you proposed: Switch OLED + $50 · "Yesterday" · Accepted (Mint).
3. On "Switch OLED — White" (GameHaven) · you offered $240 · "3d ago" · Declined.

**Frame 62 — Empty (variant of Incoming with 0 items):** EmptyState: illustration two consoles with an exchange arrow, headline "No offers yet", sub "When someone offers on your consoles, it shows up here.", Button/Primary "Browse deals" → Frame 10.

Tab bar Offers icon carries a red dot (8px, Danger) in all other frames; disappears on Frames 60/61 visit.

---

### FRAME 70 — PROFILE (ME, TAB 5)

**Zone A — Cover + identity:**
- Cover band H 120: Hero Banner Gradient with subtle controller-pattern overlay at 6% white; top-right gear icon button (40, White 20% fill, white gear) → Toast "Settings coming in v1.0".
- Avatar 88 circle centered, overlapping cover by −44, gradient ring 3pt (slow 8s rotate animation), image placeholder.
- Name "Alex Reyes" Display LG centered + Badge/Verified inline; handle "@alextrades" Body SM Ink/500; joined line Caption Ink/400 "Member since Mar 2025 · Makati".

**Zone B — Stats row (card, Soft Card Gradient, radius LG, padding 16, 3 StatCells + vertical hairline dividers):** "14 Listings" · "38 Saved" · "6 Sold". Numbers count up 600ms on appear.

**Zone C — Bio:** Body SM Ink/700 centered: "Collector clearing shelf space. All consoles tested, no surprises. Open to trades 🎮".

**Zone D — Action row:** Button/Secondary flex 1 "Edit profile" → Frame 71; Button/Primary flex 1 "Share profile" → Toast "Share link coming in v1.0".

**Zone E — Menu (ListRow/Menu stack in White rounded group, radius LG):**
1. 📦 My Listings — trailing "14"
2. ❤️ Saved Items — trailing "38" → Frame 77
3. 💰 Sold Items — trailing "6"
4. 📍 Meetup preferences — trailing "Makati"
5. 🔔 Notifications → Frame 76
6. ❓ Help Center
7. ⚙️ Settings
Rows 1, 3, 4, 6, 7 tap → Toast "Coming in v1.0" (midterm stubs); rows 2 and 5 navigate for real.
Footer Caption centered Ink/400: "GameTrade! v0.5 — Midterm Build".

**Frame 71 — Edit Profile:** NavBar "Edit profile" + × / "Save" (Purple/600 SemiBold, right). Centered avatar 88 + "Change photo" Caption Purple/600 with camera badge (24 circle, Purple/600 fill, white camera, bottom-right of avatar). Fields: Name "Alex Reyes", Username "alextrades", Bio multiline, Location "Makati", toggle row "Show my rating publicly" ON. Sticky footer Button/Primary "Save changes" → back to 70 + Toast "Profile updated".

---

### FRAME 75 — OTHER USER PROFILE (Jordan Lee)

- Cover band H 120 Hero Banner Gradient; back chevron Button/Icon over cover left; share icon right.
- Avatar 88 overlapping −44, left-aligned at 16 (not centered — distinguishes from own profile), gradient ring.
- "Jordan Lee" Title 1 + Badge/Verified + a gold "Top Seller" pill (Amber/100 bg, Amber/500 text, trophy icon 10).
- "@jordanlee · ★ 4.9 (127) · Replies in ~1 hr" Body SM/Caption rows.
- Stats card 3 StatCells: "9 Listings" · "47 Sold" · "4.9 Rating".
- Action row: Button/Primary flex 1.4 "Follow" (tap → "Following ✓" state, fill swaps to Purple/100 + text Purple/700, spring) + Button/Secondary flex 1 "Message" → Toast "Chat coming in v1.0".
- SegmentedControl: "Listings (9)" | "Sold (47)" | "Reviews (127)".
  - Listings: 2-col grid 4 cards (his seed items: PS5 $430 Like New Makati; PS4 Pro $150 Good Quezon City; PS5 Slim $489 Like New Makati; DualSense $55 Like New Makati).
  - Sold (variant): same grid, images desaturated + "SOLD" pill overlay Ink/900 70% White text centered.
  - Reviews (variant): 2 review rows (avatar 32 + name + stars 12 + review text Body SM + date Caption): "Sam P. ★★★★★ — 'PS5 exactly as described, smooth meetup.'" / "Ling C. ★★★★★ — 'Fast replies, fair trader.'" + Ghost "See all 127 reviews" → Toast.
- Tap his PS5 listing → Frame 40.

---

### FRAME 76 — NOTIFICATIONS

- NavBar "Notifications" Title 1 + trailing Ghost "Mark all read".
- SegmentedControl: "All" | "Offers" | "Deals".
- 5 rows (H ≈ 72, White group): leading icon circle 40 (tinted by type: Purple/100 offers, Amber/100 deals, Surface/100 system) + icon; title Body MD (unread = SemiBold + 8px Purple/600 dot right edge) + body Body SM Ink/500 1-line + time Caption Ink/400:
  1. 🤝 (unread) "New offer received" — "kai_gamer offered $265 on your Switch OLED." · 2h
  2. 🤝 (unread) "Trade proposal" — "mia.trades wants to trade for your PS4 Pro." · 1d
  3. ⚡ "Flash sale started" — "Up to 30% off certified pre-owned consoles — 48h only." · 2d
  4. ✅ "Offer accepted" — "Mia Torres accepted your Switch OLED + $50 trade." · 3d
  5. 🎉 "Welcome to GameTrade!" — "Set up your profile to start trading." · 1w
- Taps: rows 1–2 → Frame 60; row 3 → Frame 10; row 4 → Frame 61; row 5 → Frame 71.

---

### FRAME 77 — SAVED / WISHLIST

- NavBar "Saved items" Title 1 + trailing Ghost "Edit" (enter multiselect mode — show as label state only).
- Summary strip (Purple/50, radius 12, padding 12): "38 items · 2 price drops this week" with Mint down-arrow icon.
- 2-col grid, 6 Card/Listing from seed: L2 (with Badge/PriceDrop "−8%" overlay on image top-left), L4 (Badge/PriceDrop "−11%"), L1, L6, L8, L10. All hearts filled Purple/600.
- Heart tap → unfills with shrink animation, card fades + collapses out of grid (300ms), Toast "Removed from saved".

---

## 8. GLOBAL STATES & UTILITIES

- **Loading:** Skeleton versions of Deals (Frame 11) and Marketplace (Frame 22). Shimmer gradient sweeps 1.4s infinite. No spinners except pull-to-refresh and infinite-scroll row.
- **Empty states:** Offers (Frame 62), Search (Frame 32), plus reusable EmptyState component.
- **Toasts:** used for every v1.0-locked action (Chat, Share, Payments, Settings). Style per 5.6. Copy pattern: "[Feature] coming in v1.0".
- **Success moments:** confetti particles palette limited to Purple/600, Purple/400, Mint/500, Amber/500; used on offer-sent and publish-success only.
- **Backdrops:** sheets use Ink/900 40% scrim, tap-to-dismiss where a × exists.
- **Status bar:** dark content (black icons) on all light screens; white content on gradient covers during scroll (Deals banner area).
- **Safe areas:** content never hides under tab bar (bottom inset 56 + home indicator); sticky action bars sit above tab bar on tab screens, replace tab bar on pushed screens (Detail, Search, Sell).

---

## 9. ANIMATION & INTERACTION SPEC (summary table)

| Interaction | Animation |
|---|---|
| Tab switch (tap) | Content cross-fade + 12pt slide in tab direction, 300ms standard; icon spring pop (scale 1→1.15→1); label fade; dot indicator scale-in |
| Tab switch (swipe) | Pager drag 1:1, adjacent page parallax at 0.92× scale, tab bar indicator live-follows, crossover swap at 50% |
| Card press | scale 0.97, shadow lift, 150ms ease-out |
| Card → Detail | hero image matched-geometry morph into gallery, 450ms emphasized; info card slides up from bottom +24pt, fade in |
| Detail scroll | gallery parallax 0.5×; compact nav title/price fades in after 300pt scroll |
| Sheets (filters/offer/trade/sell) | slide up 450ms emphasized cubic-bezier(0.2,0.8,0.2,1); scrim fade 300ms; swipe-down dismiss with velocity |
| Banner carousel | auto 4s, parallax image 0.8×, dot pill morph 300ms spring |
| Countdown | digit tick: old digit slides up + fades, new slides in from below, 200ms |
| Stock progress | width 0→N% 800ms ease-out on first appear |
| Filter apply | grid relayout: removed cards fade+scale 0.9, remaining fly to new slots 350ms staggered 40ms |
| Heart/save | pop scale 1→1.3→1 250ms, fill color cross-fade |
| Offer accept | button row height collapses 300ms; status badge check-pop; row flash Mint/100 |
| Number counters | stats/count 0→N 600ms ease-out, tabular digits |
| Success | card scale-in 0.8→1 spring; check stroke-draw 400ms; confetti burst 700ms |
| Avatar ring | gradient ring rotation 8s linear infinite |
| Sell stepper | completed segment fill 350ms; check icon pop |
| Skeleton | shimmer sweep 1.4s linear infinite |
| Onboarding dots | active dot width 8→24 pill morph, spring 300ms |

---

## 10. PROTOTYPE FLOW MAP (wire these connections in Figma)

| From | Trigger | To | Transition |
|---|---|---|---|
| 01 | Swipe / tap Next | 02 → 03 → 04 | Slide left, smart animate dots |
| 01–03 | Tap Skip | 10 | Dissolve |
| 04 | Tap Get Started | 10 | Slide up + staggered content spring |
| 10 | Swipe left | 20 | Pager (see §9) |
| 20 | Swipe left | 60 | Pager |
| 60 | Swipe left | 70 | Pager |
| (reverse swipes navigate back through pager in order) | | | |
| 10 | Tap search field | 30 | Slide up + fade, keyboard in |
| 10 | Tap bell | 76 | Slide in from right |
| 10 | Tap banner CTA / deal card / category / store | 20 or 40 | Slide in right |
| 20 | Tap search icon | 30 | Slide up |
| 20 | Tap filter icon / sort pill | 35 | Sheet up |
| 20 | Tap listing card | 40 | Hero morph |
| 30 | Tap trending/recents | 31 | Slide left |
| 31 | Tap seller card | 75 | Slide in right |
| 31 | Empty query state | 32 | Swap content |
| 40 | Tap heart on card / back | 20 | Morph back |
| 40 | Tap Make Offer | 42 | Sheet up |
| 40 | Tap Trade | 43 | Sheet up |
| 40 | Tap seller card / Follow | 75 / toggle | Slide right / state swap |
| 42 | Tap Send offer | 44 | Success overlay spring |
| 43 | Tap Send proposal | 44 | Success overlay spring |
| 44 | View my offers | 61 | Slide in right |
| 44 | Keep browsing | 20 | Dissolve |
| Any tab | Tap center Sell | 50 | Sheet up (full screen) |
| 50 → 51 → 53 → 54 | Next CTAs | next step | Slide left + stepper fill |
| 54 | Publish listing | 55 | Success spring |
| 55 | View my listing | 40 | Slide in right |
| 55 | Back to Deals | 10 | Dissolve |
| 60 | Accept / Decline | in-place state | Badge flip + toast |
| 60/61 | Segment tap | swap | Thumb slide + cross-fade |
| 70 | Saved Items | 77 | Slide in right |
| 70 | Notifications | 76 | Slide in right |
| 70 | Edit profile | 71 | Slide up sheet-style |
| 70 | My Listings / stub rows | toast | — |
| 75 | Back / listing tap | 40 / 20 | Slide right / hero morph |
| 76 | Row taps | 60 / 10 / 61 / 71 | Slide in right |
| 77 | Card tap | 40 | Hero morph |

---

## 11. SEED CONTENT LIBRARY (use this exact data everywhere)

### Marketplace listings (L1–L12)
| ID | Title | Price | Was | Platform tag | Condition | Seller | Location | Saved? | Bundle? |
|---|---|---|---|---|---|---|---|---|---|
| L1 | PS5 Disc Edition — 1TB | $430 | $499 | PS5 | Like New | Jordan Lee | Quezon City | – | – |
| L2 | Xbox Series X — 1TB | $350 | – | XBOX | Good | Mia Torres | Makati | ❤ | – |
| L3 | Nintendo Switch OLED — White | $280 | – | SWITCH | Like New | GameHaven Store | BGC | – | – |
| L4 | PS4 Pro 1TB | $150 | $169 | PS4 | Fair | Alex Reyes | Pasig | – | – |
| L5 | Xbox Series S — 512GB | $220 | – | XBOX | Good | Kyle Tan | Ortigas | – | – |
| L6 | Switch Lite — Turquoise | $120 | – | SWITCH | Fair | Sam Rivera | Alabang | ❤ | – |
| L7 | PS5 Slim Digital — 1TB | $385 | – | PS5 | Like New | Jordan Lee | Quezon City | – | – |
| L8 | Xbox Series X + 2 Controllers + 5 Games | $520 | $610 | XBOX | Good | Mia Torres | Makati | – | Bundle · 4 |
| L9 | Switch + Mario Kart 8 + Carry Case | $300 | – | SWITCH | Good | GameHaven Store | BGC | – | Bundle · 3 |
| L10 | PS4 Slim 1TB + 3 Games | $140 | – | PS4 | Fair | Sam Rivera | Alabang | – | Bundle · 4 |
| L11 | DualSense Controller — Midnight Black | $55 | – | PS5 | Like New | Jordan Lee | Quezon City | – | – |
| L12 | Xbox Elite Controller Series 2 | $95 | $120 | XBOX | Good | Kyle Tan | Ortigas | – | – |

### Demo user (always signed in)
Alex Reyes · @alextrades · Makati · Member since Mar 2025 · 14 listings · 38 saved · 6 sold · Bio: "Collector clearing shelf space. All consoles tested, no surprises. Open to trades 🎮"

### Sellers
Jordan Lee (Verified, ★4.9/127, replies ~1h, Top Seller, 9 listings / 47 sold) · Mia Torres (Verified, ★5.0/84) · GameHaven Store (Official Store, ★4.8/312) · Kyle Tan (★4.7/45) · Sam Rivera (★4.6/23) · kai_gamer (buyer) · mia.trades (trader)

### Banners, deals, notifications, offers, reviews
Use the exact copy already embedded in Frames 10, 42–44, 60–61, 75–76.

---

## 12. ACCESSIBILITY & QUALITY RULES

- All tap targets ≥ 44×44pt.
- Body text contrast ≥ 4.5:1 on its background (Ink/700 on White = pass; White on Purple/600 = pass; avoid White on Purple/300).
- Badges never rely on color alone — always pair with icon or text.
- Dynamic Type: design at default size; keep labels 2-line clamped so growth degrades gracefully.
- Every image placeholder gets descriptive alt text ("PS5 Disc Edition console photo 1").
- Light mode only. Do not generate dark variants.

---

## 13. INSTRUCTIONS FOR FIGMA MAKE (build order & rules)

1. Create the Design System first: all color styles, text styles, gradients (§2–4), then every component in §5 with its variants (Default/Pressed/Selected/Disabled/Error where specified).
2. Build frames in this order: Onboarding 01–04 → Deals 10/11 → Marketplace 20/21/22 → Search 30–32 → Filters 35 → Detail 40/41 → Sheets 42–44 → Sell 50–55 → Offers 60–62 → Profiles 70/71/75 → Notifications 76 → Saved 77.
3. Use Auto Layout everywhere; 4pt spacing grid; consistent 16pt side padding.
4. Populate with the exact seed content in §11 — no lorem ipsum anywhere.
5. Wire every connection in §10 with the specified transition; set the pager swipes (Deals ↔ Market ↔ Offers ↔ Profile) as horizontal drag interactions in both directions.
6. Include one variant frame for each interactive state explicitly listed (saved hearts, accepted/declined offers, following, segment switches, filter-selected chips, validation error).
7. Name every frame exactly as in §6.2.
8. Style reference anchors: PlayStation Store (layout rhythm, card polish), Shopee/Lazada (Deals commerce density: banners, flash rows, category grid), Instagram 2026 (bottom nav + swipe pager feel). Reinterpret all of it in the purple/white system from §2 — do not copy their colors.