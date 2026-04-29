# FoodList App - Project Plan

## Project Overview
FoodList is a mobile app that allows users to:
- Add restaurants with details (name, city)
- Add food items with price, photos, and reviews
- Search/filter foods by price, review, and nearby restaurants
- OCR menu images to extract text data
- Explore sorted food lists in the Explore tab

## Tech Stack Analysis

### Option 1: Flutter + Firebase
**Pros:**
- Cross-platform (iOS/Android)
- Fast development with hot reload
- Firebase provides auth, database, storage, and OCR (ML Kit)
- Real-time data sync

**Cons:**
- Dart language learning curve
- Firebase vendor lock-in

### Option 2: Flutter + Supabase
**Pros:**
- Cross-platform (iOS/Android)
- Fast development with hot reload
- Supabase (open-source Firebase alternative) with Postgres, storage, auth
- Real-time subscriptions
- Google ML Kit for OCR

**Cons:**
- Requires separate OCR solution (google_ml_kit or firebase_ml_vision)
- Learning curve for Dart/Supabase

### Selected Stack: Flutter + Supabase
**Reason:** Better alignment with existing skills (Dart/Flutter), open-source backend, and easier integration with google_ml_kit for OCR.

## Architecture
```
Frontend (Flutter)
  ├── Auth (Supabase Auth)
  ├── Restaurant Management
  ├── Food Item Management
  ├── OCR Module (google_ml_kit)
  ├── Search/Filter
  └── Explore Tab
Backend (Supabase)
  ├── Postgres Database
  ├── Storage (food photos, menu images)
  └── Realtime Subscriptions
```

## Core Features (Phases)

### Phase 1: Setup & Auth (1-2 days)
- Initialize Flutter project
- Setup Supabase project
- Implement user authentication (login/register)

### Phase 2: Restaurant Management (2-3 days)
- Add/edit/delete restaurants
- City-based filtering
- Restaurant listing screen

### Phase 3: Food Items & Reviews (3-4 days)
- Add food items with price, photos, reviews
- Link food items to restaurants
- Food listing with sorting

### Phase 4: Search & Filter (2-3 days)
- Search by food name
- Filter by price range, review score
- Nearby restaurant detection (geolocation)

### Phase 5: OCR Menu Scanning (2-3 days)
- Integrate google_ml_kit for OCR
- Extract text from menu images
- Auto-fill food item details

### Phase 6: Explore Tab & Polish (2-3 days)
- Sorted food lists (trending, top-rated)
- UI/UX polish
- Testing & deployment

## Database Schema (Supabase Postgres)
```sql
-- Restaurants
CREATE TABLE restaurants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Food Items
CREATE TABLE food_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(id),
  name TEXT NOT NULL,
  price DECIMAL NOT NULL,
  photo_url TEXT,
  review_score DECIMAL,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  food_item_id UUID REFERENCES food_items(id),
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Next Steps
1. Initialize Flutter project with Supabase
2. Setup Supabase project and database schema
3. Implement authentication flow
4. Start Phase 1 development
