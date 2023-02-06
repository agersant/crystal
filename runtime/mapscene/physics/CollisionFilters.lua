CollisionFilters = {
	GEO = 1, -- Solid portions of the map
	SOLID = 2, -- Solid shapes
	HITBOX = 4, -- Damaging shapes in entities
	WEAKBOX = 8, -- Vulnerable shapes
	TRIGGER = 16, -- Touch triggers
};

return CollisionFilters;
