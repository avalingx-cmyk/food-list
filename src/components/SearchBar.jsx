import { useState } from 'react'

function SearchBar({ onSearch }) {
  const [query, setQuery] = useState('')

  const handleSubmit = (e) => {
    e.preventDefault()
    onSearch(query)
  }

  return (
    <form onSubmit={handleSubmit} className="w-full max-w-2xl">
      <div className="flex gap-2">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search restaurants, cuisine, or city..."
          className="flex-1 px-4 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-ring bg-white"
        />
        <button
          type="submit"
          className="px-6 py-2 bg-primary text-on-primary rounded-lg hover:opacity-90 transition-opacity cursor-pointer"
        >
          Search
        </button>
        {query && (
          <button
            type="button"
            onClick={() => { setQuery(''); onSearch('') }}
            className="px-4 py-2 bg-muted text-foreground rounded-lg hover:opacity-90 transition-opacity cursor-pointer"
          >
            Clear
          </button>
        )}
      </div>
    </form>
  )
}

export default SearchBar
