import { useState, useMemo } from 'react'
import { useParams, Link } from 'react-router-dom'
import { getRestaurantsByCity, getCuisines, filterRestaurants } from '../api/restaurantApi'
import RestaurantCard from '../components/RestaurantCard'
import FilterBar from '../components/FilterBar'

function CityView() {
  const { cityName } = useParams()
  const city = cityName?.charAt(0).toUpperCase() + cityName?.slice(1).toLowerCase()
  const [filters, setFilters] = useState({ city: cityName, cuisine: '', priceRange: '' })

  const restaurants = useMemo(() => filterRestaurants(filters), [filters])
  const cuisines = getCuisines()

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-primary text-on-primary p-4 shadow-md">
        <div className="max-w-6xl mx-auto flex items-center gap-4">
          <Link to="/" className="text-on-primary hover:opacity-80 cursor-pointer">←</Link>
          <div>
            <h1 className="text-2xl font-bold">{city}</h1>
            <p className="text-sm opacity-90">{restaurants.length} restaurants</p>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto p-4">
        <FilterBar
          cuisines={cuisines}
          filters={filters}
          onFilterChange={setFilters}
        />

        {restaurants.length === 0 ? (
          <p className="text-muted-foreground text-center py-8">No restaurants match your filters.</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {restaurants.map(restaurant => (
              <RestaurantCard key={restaurant.id} restaurant={restaurant} />
            ))}
          </div>
        )}
      </main>
    </div>
  )
}

export default CityView
