require("engine/utils/OOP");
local Skill = require("arpg/combat/Skill");
local Actions = require("engine/scene/Actions");

local Dash = Class("Dash", Skill);

local dashScript = function(self)
	self:thread(function(self)
		while true do
			self:waitFor("+useSkill");
			if self:isIdle() then
				self:doAction(function(self)
					Actions.idle(self);
					local buildupDuration = 0.24;
					local dashDuration = 0.36;
					local peakSpeed = 300;
					self:setAnimation("dash_" .. self:getDirection4(), true);
					self:wait(buildupDuration);
					self:tween(peakSpeed, 0, dashDuration, "inCubic", function(speed)
						self:setSpeed(speed);
					end);
					Actions.idle(self);
				end);
			end
		end
	end);
end

Dash.init = function(self, skillSlot)
	Dash.super.init(self, skillSlot, dashScript);
end

return Dash;
