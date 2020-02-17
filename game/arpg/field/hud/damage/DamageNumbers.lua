require("engine/utils/OOP");
local DamageEvent = require("arpg/field/combat/damage/DamageEvent");
local Hit = require("arpg/field/hud/damage/Hit");
local Widget = require("engine/ui/Widget");

local DamageNumbers = Class("DamageNumbers", Widget);

DamageNumbers.init = function(self, field)
	DamageNumbers.super.init(self);
	assert(field);
	self._field = field;
end

DamageNumbers.update = function(self, dt)
	local ecs = self._field:getECS();
	for _, event in pairs(ecs:getEvents(DamageEvent)) do
		local victim = event:getEntity();
		assert(victim);
		local amount = event:getDamage():getTotal();
		assert(amount);
		local hit = Hit:new(self._field, victim, amount);
		self:addChild(hit);
	end
	DamageNumbers.super.update(self, dt);
end

return DamageNumbers;
