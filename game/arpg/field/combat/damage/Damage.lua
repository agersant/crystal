require("engine/utils/OOP");
local Damage = Class("Damage");

Damage.init = function(self)
	self._amounts = {};
end

Damage.addAmount = function(self, amount, damageType, element)
	assert(amount);
	assert(damageType);
	assert(element);
	if not self._amounts[damageType] then
		self._amounts[damageType] = {};
	end
	if not self._amounts[damageType][element] then
		self._amounts[damageType][element] = 0;
	end
	self._amounts[damageType][element] = self._amounts[damageType][element] + amount;
end

Damage.getAmount = function(self, damageType, element)
	assert(damageType);
	assert(element);
	if not self._amounts[damageType] then
		return 0;
	end
	if not self._amounts[damageType][element] then
		return 0;
	end
	return self._amounts[damageType][element];
end

Damage.getTotal = function(self)
	local total = 0;
	for _, elements in pairs(self._amounts) do
		for _, amount in pairs(elements) do
			total = total + amount;
		end
	end
	return total;
end

return Damage;
