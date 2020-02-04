require("engine/utils/OOP");
local Damage = Class("Damage");

-- PUBLIC API

Damage.init = function(self, amount, origin)
	assert(amount);
	assert(origin);
	self._amount = amount;
	self._origin = origin;
end

Damage.getAmount = function(self)
	return self._amount;
end

Damage.getOrigin = function(self)
	return self._origin;
end

return Damage;
