require("engine/utils/OOP");
local DamageEvent = require("arpg/field/combat/damage/DamageEvent");
local HitWidgetEntity = require("arpg/field/hud/damage/HitWidgetEntity");
local System = require("engine/ecs/System");

local DamageNumbersSystem = Class("DamageNumbersSystem", System);

DamageNumbersSystem.init = function(self, ecs)
	DamageNumbersSystem.super.init(self, ecs);
end

DamageNumbersSystem.afterScripts = function(self, dt)
	for _, event in pairs(self:getECS():getEvents(DamageEvent)) do
		local victim = event:getEntity();
		assert(victim);
		local amount = event:getDamage():getTotal();
		assert(amount);
		self:getECS():spawn(HitWidgetEntity, victim, amount);
	end
end

return DamageNumbersSystem;
