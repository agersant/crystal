require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local DamageEvent = Class("DamageEvent", Event);

DamageEvent.init = function(self, entity, damage)
	DamageEvent.super.init(self, entity);
	assert(damage);
	self._damage = damage;
end

DamageEvent.getDamage = function(self)
	return self._damage;
end

return DamageEvent;
