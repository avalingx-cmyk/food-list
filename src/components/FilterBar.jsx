import { useMemo } from 'react'
import { getCities } from '../api/restaurantApi'

function FilterBar({ cuisines, filters, onFilterChange }) {
  const cities = useMemo(() => getCities(), [])

  const handleChange = (key, value) => {
    onFilterChange({ ...filters, [key]: value })
  }

  return (
    <div className="bg-white p-4 rounded-lg shadow border border-border mb-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium text-foreground mb-1">City</label>
          <select
            value={filters.city}
            onChange={(e) => handleChange('city', e.target.value)}
            className="w-full px-3 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-ring bg-white cursor-pointer"
          >
            <option value="">All Cities</option>
            {cities.map(c => (
              <option key={c.name} value={c.name.toLowerCase()}>{c.name} ({c.count})</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-foreground mb-1">Cuisine</label>
          <select
            value={filters.cuisine}
            onChange={(e) => handleChange('cuisine', e.target.value)}
            className="w-full px-3 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-ring bg-white cursor-pointer"
          >
            <option value="">All Cuisines</option>
            {cuisines.map(c => (
              <option key={c} value={c.toLowerCase()}>{c}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-foreground mb-1">Price Range</label>
          <select
            value={filters.priceRange}
            onChange={(e) => handleChange('priceRange', e.target.value)}
            className="w-full px-3 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-ring bg-white cursor-pointer"
          >
            <option value="">All Prices</option>
            <option value="$">$ - Budget</option>
            <option value="$$">$$ - Moderate</option>
            <option value="$$$">$$$ - Upscale</option>
          </select>
        </div>
      </div>

      {(filters.city || filters.cuisine || filters.priceRange) && (
        <button
          onClick={() => onFilterChange({ city: '', cuisine: '', priceRange: '' })}
          className="mt-3 text-sm text-destructive hover:opacity-80 cursor-pointer"
        >
          Clear filters
        </button>
      )}
    </div>
  )
}

export default FilterBar
