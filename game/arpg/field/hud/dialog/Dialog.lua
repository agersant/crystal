require("engine/utils/OOP");
local Entity = require("engine/ecs/Entity");
local Behavior = require("engine/mapscene/behavior/Behavior");
local InputListener = require("engine/mapscene/behavior/InputListener");

local Dialog = Class("Dialog", Behavior);

Dialog.init = function(self, dialogBox)
	Dialog.super.init(self);
	assert(dialogBox);
	self._dialogBox = dialogBox;
	self._inputListener = nil;
	self._inputContext = nil;

	local dialog = self;
	self._script:addThread(function(self)
		self:scope(function()
			dialog:cleanup();
		end);
		self:hang();
	end);
end

Dialog.beginDialog = function(self, player)
	assert(player);
	assert(player:isInstanceOf(Entity));
	assert(player:getComponent(InputListener));
	assert(not self._inputListener);
	assert(not self._inputContext);
	if self._dialogBox:open() then
		self._inputListener = player:getComponent(InputListener);
		self._inputContext = self._inputListener:pushContext(self._script);
		return true;
	end
	return false;
end

Dialog.sayLine = function(self, text)
	assert(text);
	assert(self._inputListener);
	assert(self._inputContext);

	local inputListener = self._inputListener;
	local inputContext = self._inputContext;
	local dialogBox = self._dialogBox;

	local waitForInput = function(self)
		if inputListener:isCommandActive("advanceDialog", inputContext) then
			self:waitFor("-advanceDialog");
		end
		self:waitFor("+advanceDialog");
	end

	local lineDelivery = self._script:addThreadAndRun(function(self)
		self:thread(function()
			waitForInput(self);
			dialogBox:fastForward(text);
		end);

		self:join(dialogBox:sayLine(text));
		waitForInput(self);
	end);

	return lineDelivery;
end

Dialog.cleanup = function(self)
	if self._inputListener or self._inputContext then
		self:endDialog();
	end
end

Dialog.endDialog = function(self)
	assert(self._inputListener);
	assert(self._inputContext);
	self._dialogBox:close();
	self._inputListener:popContext(self._inputContext);
	self._inputListener = nil;
	self._inputContext = nil;
end

return Dialog;
