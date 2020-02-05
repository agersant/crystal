require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");
local InputDrivenController = require("engine/scene/controller/InputDrivenController");
local Actions = require("engine/scene/Actions");
local Script = require("engine/script/Script");
local Widget = require("engine/ui/Widget");
local Image = require("engine/ui/core/Image");
local Text = require("engine/ui/core/Text");

local Dialog = Class("Dialog", Widget);

-- IMPLEMENTATION

local getInputDevice = function(self)
	if self._player then
		local controller = self._player:getController();
		if controller:isInstanceOf(InputDrivenController) then
			return controller:getInputDevice();
		end
	end
end

local sendCommandSignals = function(self)
	local device = getInputDevice(self);
	if device then
		for _, commandEvent in device:pollEvents() do
			self:signal(commandEvent);
		end
	end
end

local waitForCommandPress = function(self, command)
	local device = getInputDevice(self);
	if device:isCommandActive(command) then
		self:waitFor("-" .. command);
	end
	self:waitFor("+" .. command);
end

-- PUBLIC API

Dialog.init = function(self)
	Dialog.super.init(self);
	self._textSpeed = 25;
	self._owner = nil;
	self._player = nil;
	self._targetText = nil;
	self._currentText = nil;
	self._currentGlyphCount = nil;
	self._revealAll = false;

	self:setAlpha(0);
	self:alignBottomCenter(424, 80);
	self:offset(0, -8);

	local box = Image:new();
	box:setColor(Colors.black6C);
	box:setAlpha(.8);
	self:addChild(box);

	self._textWidget = Text:new("body", 16);
	self._textWidget:setPadding(8);
	self._textWidget:setLeftOffset(80);
	self:addChild(self._textWidget);
end

Dialog.update = function(self, dt)
	sendCommandSignals(self);
	Dialog.super.update(self, dt);

	if self._targetText and self._currentText ~= self._targetText then
		if self._revealAll then
			self._currentText = self._targetText;
		else
			self._currentGlyphCount = self._currentGlyphCount + dt * self._textSpeed;
			self._currentGlyphCount = math.min(self._currentGlyphCount, #self._targetText);
			if math.floor(self._currentGlyphCount) > 1 then
				-- TODO: This assumes each glyph is one byte, not UTF-8 aware
				self._currentText = string.sub(self._targetText, 1, self._currentGlyphCount);
			else
				self._currentText = "";
			end
		end
		self._textWidget:setText(self._currentText);
	end
end

Dialog.setPortait = function(self, portait)
end

Dialog.open = function(self, owner, player)
	assert(owner:isInstanceOf(Script));
	assert(self._owner == nil);
	assert(self._player == nil);
	self._owner = owner;
	self._player = player;
	self:setAlpha(1);

	local controller = self._player:getController();
	assert(controller:isIdle());
	controller:doAction(Actions.idle);
	if controller:isInstanceOf(InputDrivenController) then
		controller:disable();
	end
end

Dialog.say = function(self, text)

	assert(self._owner ~= nil);
	assert(self._player ~= nil);

	Log:info("Displaying dialog: " .. text);
	self._targetText = text;
	self._currentText = "";
	self._revealAll = false;
	self._currentGlyphCount = 0;

	local controller = self._player:getController();
	if controller:isInstanceOf(InputDrivenController) then
		local dialog = self;
		self:thread(function()
			waitForCommandPress(self, "advanceDialog");
			if self._currentText ~= self._targetText then
				self._revealAll = true;
				waitForCommandPress(self, "advanceDialog");
			end
			dialog._owner:signal("advanceDialog");
		end);
	end

	self._owner:waitFor("advanceDialog");
end

Dialog.close = function(self)
	assert(self._owner ~= nil);
	assert(self._player ~= nil);

	local controller = self._player:getController();
	if controller:isInstanceOf(InputDrivenController) then
		controller:enable();
	end

	self._targetText = nil;
	self._currentText = nil;
	self._owner = nil;
	self._player = nil;
	self:setAlpha(0);
end

return Dialog;
