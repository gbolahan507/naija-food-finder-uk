# UI/UX Design

*Last updated: December 24, 2025*

## Design System

### Color Palette

**Primary Colors:**
- Nigerian Green: `#008751` (from flag)
- White: `#FFFFFF` (from flag)
- Accent: `#FFD700` (Gold - for highlights)

**Secondary Colors:**
- Dark Gray: `#2C3E50` (Text)
- Light Gray: `#ECF0F1` (Backgrounds)
- Success Green: `#27AE60`
- Warning Red: `#E74C3C`

### Typography

**Font Family:** Inter / SF Pro (iOS) / Roboto (Android)

**Font Sizes:**
- H1 (Screen Titles): 24px, Bold
- H2 (Section Headers): 20px, SemiBold
- Body: 16px, Regular
- Caption: 14px, Regular
- Small: 12px, Regular

### Spacing

- XS: 4px
- S: 8px
- M: 16px
- L: 24px
- XL: 32px

---

## Screen Designs

### 1. Home / Restaurant List Screen

**Purpose:** Browse Nigerian restaurants

**Layout:**
- App Bar (Search + Logo)
- Filter chips (All, Nigerian, Ghanaian, etc.)
- Scrollable list of restaurant cards
- Bottom navigation

**Restaurant Card Components:**
- Restaurant image (thumbnail)
- Name (H2)
- Rating + review count
- Cuisine type + distance
- Delivery/Takeaway badges

**Actions:**
- Tap card → Restaurant Details
- Pull to refresh
- Infinite scroll

---

### 2. Restaurant Details Screen

**Purpose:** View restaurant info and reviews

**Layout:**
- Back button + Restaurant name
- Hero image (full width)
- Info section:
  - Rating
  - Address
  - Phone
  - Hours
- Action buttons (Delivery/Takeaway)
- Favorite button
- Reviews list

**Actions:**
- Call restaurant
- Get directions (opens Maps)
- Add to favorites
- View all reviews

---

### 3. Search & Filters Screen

**Purpose:** Find specific restaurants

**Layout:**
- Search input
- Filter categories (checkboxes)
- Distance slider
- Feature toggles
- Apply button

**Filters:**
- Cuisine type
- Distance range
- Delivery/Takeaway
- Open now
- Price range

---

### 4. Map View Screen

**Purpose:** See restaurants on map

**Layout:**
- Full-screen map
- Restaurant markers (clustered)
- Current location marker
- Toggle to List View
- Search box overlay

**Actions:**
- Tap marker → Show info card
- Tap info card → Restaurant Details
- Recenter on user location

---

### 5. User Profile Screen

**Purpose:** Manage account and preferences

**Layout:**
- User avatar + name
- Email
- Menu items:
  - Favorites
  - My Reviews
  - Settings
  - Log Out

---

## Navigation Flow
```
Home ⟷ Details ⟷ Reviews
 ↕       ↕
Search  Map
 ↕       ↕
Profile ⟷ Settings
```

---

## Wireframes

[Add sketches/screenshots here when ready]

---

## Next Steps

- [ ] Create high-fidelity mockups in Figma
- [ ] Design app icon and splash screen
- [ ] Create design assets (icons, illustrations)
- [ ] Get feedback from potential users