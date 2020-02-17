require("engine/utils/OOP");
local DialogBeginEvent = require("arpg/field/hud/dialog/DialogBeginEvent");
local DialogEndEvent = require("arpg/field/hud/dialog/DialogEndEvent");
local DialogLineEvent = require("arpg/field/hud/dialog/DialogLineEvent");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");
local InputListener = require("engine/mapscene/behavior/InputListener");
local Script = require("engine/script/Script");

local Dialog = Class("Dialog", Component);

Dialog.init = function(self)
	Dialog.super.init(self);
	self._inputListener = nil;
	self._scriptContext = nil;
end

Dialog.beginDialog = function(self, scriptContext, player)
	assert(player);
	assert(player:isInstanceOf(Entity));
	assert(not self._inputListener);
	self._inputListener = player:getComponent(InputListener);
	assert(self._inputListener);
	self._inputListener:disable();

	local inputDevice = self._inputListener:getInputDevice();
	assert(inputDevice);
	self:getEntity():createEvent(DialogBeginEvent, self, inputDevice);

	assert(scriptContext);
	assert(scriptContext:isInstanceOf(Script));
	assert(not self._scriptContext);
	self._scriptContext = scriptContext;

	self._scriptContext:waitFor("beganDialog");
end

Dialog.beganDialog = function(self)
	assert(self._scriptContext);
	self._scriptContext:signal("beganDialog");
end

Dialog.sayLine = function(self, text)
	assert(text);
	assert(self._scriptContext);
	self:getEntity():createEvent(DialogLineEvent, text);
	self._scriptContext:waitFor("saidLine");
end

Dialog.saidLine = function(self)
	assert(self._scriptContext);
	self._scriptContext:signal("saidLine");
end

Dialog.endDialog = function(self)
	assert(self._inputListener);
	self._inputListener:enable();
	self:getEntity():createEvent(DialogEndEvent);
	self._inputListener = nil;
	self._scriptContext = nil;
end

return Dialog;
