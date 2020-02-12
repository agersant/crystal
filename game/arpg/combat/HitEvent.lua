require("engine/utils/OOP");
local Event = require("engine/ecs/Event");

local HitEvent = Class("HitEvent", Event);

HitEvent.init = function(self, entity, damageIntent, targetEntity)
	HitEvent.super.init(self, entity);
	assert(damageIntent);
	assert(targetEntity);
	self._damageIntent = damageIntent;
	self._targetEntity = targetEntity;
end

HitEvent.getDamageIntent = function(self)
	return self._damageIntent;
end

HitEvent.getTargetEntity = function(self)
	return self._targetEntity;
end

return HitEvent;
