require("engine/utils/OOP");
local DialogBeginEvent = require("arpg/field/hud/dialog/DialogBeginEvent");
local Dialog = require("arpg/field/hud/dialog/Dialog");
local DialogEndEvent = require("arpg/field/hud/dialog/DialogEndEvent");
local DialogLineEvent = require("arpg/field/hud/dialog/DialogLineEvent");
local Log = require("engine/dev/Log");
local InputDevice = require("engine/input/InputDevice");
local Colors = require("engine/resources/Colors");
local Script = require("engine/script/Script");
local Image = require("engine/ui/core/Image");
local Text = require("engine/ui/core/Text");
local Widget = require("engine/ui/Widget");
local Alias = require("engine/utils/Alias");

local DialogBox = Class("DialogBox", Widget);

local script = function(self)
	local waitForInput = function()
		if self:isCommandActive("advanceDialog") then
			self:waitFor("-" .. "advanceDialog");
		end
		self:waitFor("+" .. "advanceDialog");
	end

	while true do
		self:waitFor("beginLine");
		waitForInput();
		if not self:advance() then
			waitForInput();
		end
		self:endLine();
	end
end

DialogBox.init = function(self, field)
	DialogBox.super.init(self);
	assert(field);
	self._field = field;
	self._textSpeed = 25;
	self._owner = nil;
	self._player = nil;
	self._targetText = nil;
	self._currentText = nil;
	self._currentGlyphCount = nil;
	self._revealAll = false;

	self._script = Script:new(script);
	Alias:add(self._script, self);

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

DialogBox.update = function(self, dt)

	if self._inputDevice then
		for _, commandEvent in self._inputDevice:pollEvents() do
			self._script:signal(commandEvent);
		end
	end
	self._script:update(dt);

	local endDialogEvents = self._field:getECS():getEvents(DialogEndEvent);
	if #endDialogEvents > 0 then
		self:close();
	end

	local beginDialogEvents = self._field:getECS():getEvents(DialogBeginEvent);
	assert(#beginDialogEvents <= 1);
	for _, event in ipairs(beginDialogEvents) do
		self:open(event:getDialogComponent(), event:getInputDevice());
		break
	end

	local dialogLineEvents = self._field:getECS():getEvents(DialogLineEvent);
	assert(#dialogLineEvents <= 1);
	for _, event in ipairs(dialogLineEvents) do
		self:beginLine(event:getText());
		break
	end

	self:tickText(dt);

	DialogBox.super.update(self, dt);
end

DialogBox.tickText = function(self, dt)
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

DialogBox.open = function(self, dialogComponent, inputDevice)
	assert(dialogComponent:isInstanceOf(Dialog));
	assert(inputDevice:isInstanceOf(InputDevice));
	assert(self._inputDevice == nil);
	assert(self._dialogComponent == nil);
	self._dialogComponent = dialogComponent;
	self._inputDevice = inputDevice;
	Alias:add(self._script, self._inputDevice);
	self:setAlpha(1);

	self._dialogComponent:beganDialog();
end

DialogBox.beginLine = function(self, text)
	assert(self._dialogComponent ~= nil);
	assert(self._inputDevice ~= nil);

	Log:info("Displaying dialogbox: " .. text);
	self._targetText = text;
	self._currentText = "";
	self._revealAll = false;
	self._currentGlyphCount = 0;

	self._script:signal("beginLine");
end

DialogBox.endLine = function(self)
	assert(self._dialogComponent ~= nil);
	self._dialogComponent:saidLine();
end

DialogBox.advance = function(self)
	self._revealAll = true;
	return self._currentText == self._targetText;
end

DialogBox.close = function(self)
	assert(self._dialogComponent);
	assert(self._inputDevice);

	Alias:remove(self._script, self._inputDevice);
	self._inputDevice = nil;
	self._dialogComponent = nil;

	self._targetText = nil;
	self._currentText = nil;
	self:setAlpha(0);
end

return DialogBox;
