import data from '../data/restaurants.json';

const restaurants = data.restaurants || [];

export function getAllRestaurants() {
  return restaurants;
}

export function getRestaurantsByCity(city) {
  return restaurants.filter(r => r.city.toLowerCase() === city.toLowerCase());
}

export function getCities() {
  const cities = [...new Set(restaurants.map(r => r.city))];
  return cities.map(city => ({
    name: city,
    count: getRestaurantsByCity(city).length
  }));
}

export function searchRestaurants(query) {
  if (!query) return restaurants;
  const q = query.toLowerCase();
  return restaurants.filter(r =>
    r.name.toLowerCase().includes(q) ||
    (r.cuisine && r.cuisine.toLowerCase().includes(q)) ||
    r.city.toLowerCase().includes(q)
  );
}

export function filterRestaurants({ city, cuisine, priceRange }) {
  let result = restaurants;
  if (city) result = result.filter(r => r.city.toLowerCase() === city.toLowerCase());
  if (cuisine) result = result.filter(r => r.cuisine && r.cuisine.toLowerCase() === cuisine.toLowerCase());
  if (priceRange) result = result.filter(r => r.priceRange === priceRange);
  return result;
}

export function getCuisines() {
  const cuisines = [...new Set(restaurants.map(r => r.cuisine).filter(Boolean))];
  return cuisines.sort();
}
