require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");
local InputListener = require("engine/mapscene/behavior/InputListener");

local Dialog = Class("Dialog", Component);

Dialog.init = function(self, dialogBox)
	Dialog.super.init(self);
	assert(dialogBox);
	self._dialogBox = dialogBox;
	self._inputListener = nil;
	self._inputContext = nil;
end

Dialog.beginDialog = function(self, thread, player)
	assert(thread);
	assert(player);
	assert(player:isInstanceOf(Entity));
	assert(player:getComponent(InputListener));

	assert(not self._inputListener);
	assert(not self._inputContext);
	self._inputListener = player:getComponent(InputListener);
	self._inputContext = self._inputListener:pushContext(thread);

	return self._dialogBox:open();
end

Dialog.sayLine = function(self, text)
	assert(text);
	local inputListener = self._inputListener;
	local inputContext = self._inputContext;
	local dialogBox = self._dialogBox;
	local context = inputContext:getContext();

	dialogBox:sayLine(text);

	local waitForInput = function(self)
		if inputListener:isCommandActive("advanceDialog", inputContext) then
			self:waitFor("-advanceDialog");
		end
		self:waitFor("+advanceDialog");
	end

	local fastForward = context:thread(function(self)
		waitForInput(self);
		dialogBox:fastForward(text);
	end);

	local waitForLineCompletion = context:thread(function(self)
		while not dialogBox:isLineFullyPrinted() do
			self:waitFrame();
		end
		waitForInput(self);
		if not fastForward:isDead() then
			fastForward:stop();
		end
	end);

	context:join(waitForLineCompletion);
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
