import { useState } from 'react'
import { Link } from 'react-router-dom'
import { getCities, searchRestaurants } from '../api/restaurantApi'
import SearchBar from '../components/SearchBar'

function Home() {
  const [searchQuery, setSearchQuery] = useState('')
  const cities = getCities()

  const handleSearch = (query) => {
    setSearchQuery(query)
  }

  const searchResults = searchQuery ? searchRestaurants(searchQuery) : null

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-primary text-on-primary p-4 shadow-md">
        <div className="max-w-6xl mx-auto">
          <h1 className="text-2xl font-bold">FoodList</h1>
          <p className="text-sm opacity-90">Discover restaurants across Sri Lanka</p>
        </div>
      </header>

      <main className="max-w-6xl mx-auto p-4">
        <section className="mb-8">
          <h2 className="text-xl font-semibold mb-4 text-foreground">Search All Restaurants</h2>
          <SearchBar onSearch={handleSearch} />
        </section>

        {searchResults ? (
          <section>
            <h2 className="text-xl font-semibold mb-4 text-foreground">
              Search Results ({searchResults.length})
            </h2>
            {searchResults.length === 0 ? (
              <p className="text-muted-foreground">No restaurants found.</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {searchResults.map(restaurant => (
                  <Link
                    key={restaurant.id}
                    to={`/city/${restaurant.city.toLowerCase()}`}
                    className="block bg-white p-4 rounded-lg shadow hover:shadow-md transition-shadow border border-border"
                  >
                    <h3 className="font-semibold text-foreground">{restaurant.name}</h3>
                    <p className="text-sm text-muted-foreground">{restaurant.cuisine} • {restaurant.city}</p>
                    <p className="text-sm text-accent font-medium">{restaurant.priceRange}</p>
                  </Link>
                ))}
              </div>
            )}
          </section>
        ) : (
          <section>
            <h2 className="text-xl font-semibold mb-4 text-foreground">Cities</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {cities.map(city => (
                <Link
                  key={city.name}
                  to={`/city/${city.name.toLowerCase()}`}
                  className="block bg-white p-6 rounded-lg shadow hover:shadow-md transition-shadow border border-border text-center"
                >
                  <h3 className="text-lg font-semibold text-foreground capitalize">{city.name}</h3>
                  <p className="text-3xl font-bold text-primary mt-2">{city.count}</}</p>
                  <p className="text-sm text-muted-foreground">restaurants</p>
                </Link>
              ))}
            </div>
          </section>
        )}
      </main>
    </div>
  )
}

export default Home
