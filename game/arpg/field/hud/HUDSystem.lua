require("engine/utils/OOP");
local System = require("engine/ecs/System");
local HUD = require("arpg/field/hud/HUD");

local HUDSystem = Class("HUDSystem", System);

HUDSystem.init = function(self, ecs)
	HUDSystem.super.init(self, ecs);
	self._hud = HUD:new();
end

HUDSystem.getHUD = function(self)
	return self._hud;
end

HUDSystem.afterScripts = function(self, dt)
	self._hud:update(dt);
end

HUDSystem.afterDraw = function(self)
	self._hud:draw();
end

return HUDSystem;
