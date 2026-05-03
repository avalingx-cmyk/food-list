function RestaurantCard({ restaurant }) {
  return (
    <div className="bg-white p-4 rounded-lg shadow hover:shadow-md transition-shadow border border-border">
      <h3 className="font-semibold text-foreground text-lg">{restaurant.name}</h3>
      <div className="mt-2 space-y-1 text-sm">
        {restaurant.cuisine && (
          <p className="text-muted-foreground">🍽️ {restaurant.cuisine}</p>
        )}
        {restaurant.priceRange && (
          <p className="text-accent font-medium">💰 {restaurant.priceRange}</p>
        )}
        {restaurant.address && (
          <p className="text-muted-foreground text-xs">📍 {restaurant.address}</p>
        )}
        {restaurant.rating && (
          <p className="text-sm">⭐ {restaurant.rating}/5</p>
        )}
      </div>
    </div>
  )
}

export default RestaurantCard
