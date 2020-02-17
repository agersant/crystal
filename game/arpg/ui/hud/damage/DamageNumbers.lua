require("engine/utils/OOP");
local Widget = require("engine/ui/Widget");
local DamageEvent = require("arpg/combat/damage/DamageEvent");
local Hit = require("arpg/ui/hud/damage/Hit");

local DamageNumbers = Class("DamageNumbers", Widget);

DamageNumbers.init = function(self, hud)
	assert(hud);
	DamageNumbers.super.init(self);
	self._hud = hud;
end

DamageNumbers.update = function(self, dt)
	local field = self._hud:getField();
	local ecs = field:getECS();
	for _, event in pairs(ecs:getEvents(DamageEvent)) do
		local victim = event:getEntity();
		assert(victim);
		local amount = event:getDamage():getTotal();
		assert(amount);
		local hit = Hit:new(field, victim, amount);
		self:addChild(hit);
	end
	DamageNumbers.super.update(self, dt);
end

return DamageNumbers;
