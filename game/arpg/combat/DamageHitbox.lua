require("engine/utils/OOP");
local HitEvent = require("arpg/combat/HitEvent");
local Hitbox = require("engine/mapscene/physics/Hitbox");

local CombatHitbox = Class("CombatHitbox", Hitbox);

CombatHitbox.init = function(self)
	CombatHitbox.super.init(self);
	self._damageIntent = nil;
	self._targetsHit = {};
end

CombatHitbox.setDamageIntent = function(self, damageIntent)
	assert(damageIntent);
	self._damageIntent = damageIntent;
	self._targetsHit = {};
end

CombatHitbox.onBeginTouch = function(self, weakbox)
	CombatHitbox.super.onBeginTouch(self, weakbox);
	if self._damageIntent then
		local target = weakbox:getEntity();
		if not self._targetsHit[target] then
			self._targetsHit[target] = true;
			self:getEntity():createEvent(HitEvent, self._damageIntent, target);
		end
	end
end

return CombatHitbox;
