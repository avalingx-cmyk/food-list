# FoodList App

A mobile app that allows users to:
- Add restaurants with details (name, city)
- Add food items with price, photos, and reviews
- Search/filter foods by price, review, and nearby restaurants
- OCR menu images to extract text data
- Explore sorted food lists in the Explore tab

## Current Status

✅ **Phase 1: Setup & Authentication** - COMPLETED
- Flutter project initialized with Android/iOS support
- Supabase service and configuration created
- Login and signup screens with form validation implemented
- Project structure organized for scalability
- Authentication flow working (sign up, sign in, sign out)

✅ **Phase 2: Restaurant Management** - COMPLETED
- Restaurant model created with Supabase integration
- Restaurant service for CRUD operations (add, edit, delete, list)
- Restaurant listing screen with edit/delete functionality
- Restaurant form screen for adding/editing restaurants
- State management using Flutter Riverpod
- City-based filtering implemented

🟡 **Phase 3: Food Items & Reviews** - IN PROGRESS
- Food item model created with Supabase integration
- Food item service for CRUD operations (add, edit, delete, list)
- State management using Flutter Riverpod for food items
- Food listing screen (for a specific restaurant)
- Food item form screen (for adding/editing)

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL database, storage, auth)
- **State Management**: Flutter Riverpod
- **Navigation**: GoRouter
- **OCR**: Google ML Kit (planned for Phase 5)

## Project Structure
```
lib/
├── core/
│   ├── services/
│   │   └── supabase_service.dart     # Supabase client wrapper
│   └── config/
│       └── supabase_config.dart      # Supabase initialization
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart     # Login screen with validation
│   │   │   └── signup_screen.dart    # Signup screen with validation
│   │   └── widgets/
│   │       └── auth_form_field.dart  # Reusable form field widget
│   ├── restaurant/
│   │   ├── models/
│   │   │   └── restaurant_model.dart
│   │   ├── services/
│   │   │   └── restaurant_service.dart
│   │   ├── providers/
│   │   │   └── restaurant_provider.dart
│   │   └── screens/
│   │       ├── restaurant_list_screen.dart
│   │       └── restaurant_form_screen.dart
│   └── food_item/
│       ├── models/
│       │   └── food_item_model.dart
│       ├── services/
│       │   └── food_item_service.dart
│       ├── providers/
│       │   └── food_item_provider.dart
│       └── screens/
│           ├── food_list_screen.dart
│           └── food_item_form_screen.dart
├── main.dart                         # App entry point with auth wrapper
```

## Next Steps

1. **Phase 3: Food Items & Reviews** (continued)
   - Implement sorting for food items (by price, review score)
   - Implement reviews functionality (add, list, delete reviews for a food item)
   - Link food items to restaurants (already done in model and service)

2. **Phase 4: Search & Filter** (2-3 days)
   - Search by food name
   - Filter by price range, review score
   - Nearby restaurant detection (geolocation)

3. **Phase 5: OCR Menu Scanning** (2-3 days)
   - Integrate Google ML Kit for OCR
   - Extract text from menu images
   - Auto-fill food item details

4. **Phase 6: Explore Tab & Polish** (2-3 days)
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

## Getting Started

1. Set up Supabase project and get URL/anon key
2. Update `lib/core/config/supabase_config.dart` with your Supabase credentials
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Planning Documents

- `PLAN.md` - Detailed project plan and architecture
- `research.md` - Tech stack analysis and decision rationale
- `design.md` - Recommended design system and UI patterns
