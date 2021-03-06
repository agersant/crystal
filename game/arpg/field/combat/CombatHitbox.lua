require("engine/utils/OOP");
local HitEvent = require("arpg/field/combat/HitEvent");
local Hitbox = require("engine/mapscene/physics/Hitbox");

local CombatHitbox = Class("CombatHitbox", Hitbox);

CombatHitbox.init = function(self, physicsBody)
	CombatHitbox.super.init(self, physicsBody);
	self._targetsHit = {};
end

CombatHitbox.resetMultiHitTracking = function(self)
	self._targetsHit = {};
end

CombatHitbox.onBeginTouch = function(self, weakbox)
	CombatHitbox.super.onBeginTouch(self, weakbox);
	local target = weakbox:getEntity();
	if not self._targetsHit[target] then
		self._targetsHit[target] = true;
		self:getEntity():createEvent(HitEvent, target);
	end
end

return CombatHitbox;
