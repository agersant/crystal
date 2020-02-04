require("engine/utils/OOP");
local Scene = require("engine/scene/Scene");
local DamageNumbers = require("engine/ui/hud/damage/DamageNumbers");
local Dialog = require("engine/ui/hud/Dialog");

local HUD = Class("HUD");

-- IMPLEMENTATION

local onSceneChanged = function(self)
	self:init();
end

-- PUBLIC API

HUD.init = function(self)
	self._widgets = {};
	self._damageNumbers = DamageNumbers:new();
	table.insert(self._widgets, self._damageNumbers);
	self._dialog = Dialog:new();
	table.insert(self._widgets, self._dialog);
end

HUD.update = function(self, dt)
	local currentScene = Scene:getCurrent();
	if self._scene ~= currentScene then
		self._scene = currentScene;
		onSceneChanged(self);
	end
	for _, widget in ipairs(self._widgets) do
		widget:update(dt);
	end
end

HUD.draw = function(self)
	for _, widget in ipairs(self._widgets) do
		widget:draw();
	end
end

HUD.getDialog = function(self)
	return self._dialog;
end

HUD.showDamage = function(self, victim, amount)
	assert(victim);
	assert(amount);
	self._damageNumbers:show(victim, amount);
end

local instance = HUD:new();
return instance;
