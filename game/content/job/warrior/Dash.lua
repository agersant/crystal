require("engine/utils/OOP");
local DamageUnit = require("arpg/field/combat/damage/DamageUnit");
local Skill = require("arpg/field/combat/skill/Skill");

local Dash = Class("Dash", Skill);

local action = function(self)
	local buildupDuration = 0.36;
	local buildupPeakSpeed = 90;
	local dashDuration = 0.2;
	local peakSpeed = 1200;
	local recoveryBeginSpeed = 60;
	local recoveryDuration = 0.2;

	self:scope(self:disableLocomotion());

	self:resetMultiHitTracking();
	self:setDamagePayload({DamageUnit:new(10)});

	self:setAnimation("dash_" .. self:getDirection4());

	local angle = self:getAngle();
	local dx = math.cos(angle);
	local dy = math.sin(angle);

	self:tween(buildupPeakSpeed, 0, buildupDuration, "outCubic", function(speed)
		self:setLinearVelocity(-dx * speed, -dy * speed);
	end);

	self:tween(peakSpeed, recoveryBeginSpeed, dashDuration, "outQuartic", function(speed)
		self:setLinearVelocity(dx * speed, dy * speed);
	end);
	self:tween(recoveryBeginSpeed, 0, recoveryDuration, "outQuadratic", function(speed)
		self:setLinearVelocity(dx * speed, dy * speed);
	end);
end

local dashScript = function(self)
	while true do
		self:waitFor("+useSkill");
		if self:isIdle() then
			self:doAction(action);
		end
	end
end

Dash.init = function(self, skillSlot)
	Dash.super.init(self, skillSlot, dashScript);
end

return Dash;
