local Constants = require("dev/constants/Constants");
local LiveTune = require("dev/constants/LiveTune");
local Features = require("dev/Features");
local Colors = require("resources/Colors");
local Element = require("ui/bricks/core/Element");
local Border = require("ui/bricks/elements/Border");
local Image = require("ui/bricks/elements/Image");
local List = require("ui/bricks/elements/List");
local Overlay = require("ui/bricks/elements/Overlay");
local RoundedCorners = require("ui/bricks/elements/RoundedCorners");
local Switcher = require("ui/bricks/elements/switcher/Switcher");
local Text = require("ui/bricks/elements/Text");
local Widget = require("ui/bricks/elements/Widget");

local LiveTuneOverlay = Class("LiveTuneOverlay");

if not Features.liveTune then
	Features.stub(LiveTuneOverlay);
end

local drawOverlay = false;

local colors = {
	title = Colors.greyD,
	help = Colors.greyD,
	headerBackground = Colors.greyA,
	headerText = Colors.greyD,
	background = Colors.greyB,
	knobInactive = Colors.greyC,
	knobActive = Colors.cyan,
	knobIndex = Colors.greyD,
	valueOutline = Colors.greyC,
	valueText = Colors.greyD,
};

local KnobDonut = Class("KnobDonut", Element);

KnobDonut.init = function(self)
	KnobDonut.super.init(self);
	self._radius = 10;
	self._thickness = 4;
	self._arcStart = 2 * math.pi * (1 + 40 / 360);
	self._arcEnd = 2 * math.pi * (140 / 360);
	self._numSegments = 64;
	self.value = 0.5;
end

KnobDonut.computeDesiredSize = function(self)
	local size = 2 * self._radius + self._thickness;
	return size, size;
end

KnobDonut.draw = function(self)
	local width, height = self:getSize();
	love.graphics.setLineWidth(self._thickness);
	love.graphics.setColor(colors.knobInactive);
	love.graphics.arc("line", "open", width / 2, height / 2, self._radius, self._arcStart, self._arcEnd, self._numSegments);
	love.graphics.setColor(colors.knobActive);
	love.graphics.arc("line", "open", width / 2, height / 2, self._radius,
		self._arcEnd + self.value * (self._arcStart - self._arcEnd), self._arcEnd, self._numSegments);
end

local KnobInfo = Class("KnobInfo", Widget);

KnobInfo.init = function(self)
	KnobInfo.super.init(self);

	local roundedCorners = self:setRoot(RoundedCorners:new());
	local topLevelList = roundedCorners:setChild(List.Vertical:new());

	local header = topLevelList:addChild(Overlay:new());
	header:setHorizontalAlignment("stretch");
	local headerBackground = header:addChild(Image:new());
	headerBackground:setColor(colors.headerBackground);
	headerBackground:setAlignment("stretch", "stretch");
	self._headerText = header:addChild(Text:new());
	self._headerText:setFont(FONTS:get("devCondensed", 14));
	self._headerText:setColor(colors.headerText);
	self._headerText:setHorizontalPadding(8);
	self._headerText:setVerticalPadding(2);
	self._headerText:setVerticalAlignment("center");

	local content = topLevelList:addChild(Overlay:new());
	content:setHorizontalAlignment("stretch");
	local contentBackground = content:addChild(Image:new());
	contentBackground:setColor(colors.background);
	contentBackground:setAlignment("stretch", "stretch");
	local data = content:addChild(List.Horizontal:new());
	data:setAllPadding(10);

	local donutContainer = data:addChild(Overlay:new());
	donutContainer:setRightPadding(10);
	self._donut = donutContainer:addChild(KnobDonut:new());
	self._knobIndexText = donutContainer:addChild(Text:new());
	self._knobIndexText:setAlignment("center", "bottom");
	self._knobIndexText:setBottomPadding(-6);
	self._knobIndexText:setColor(colors.knobIndex);
	self._knobIndexText:setFont(FONTS:get("devBold", 12));

	local valueContainer = data:addChild(Overlay:new());
	local border = valueContainer:addChild(Border:new());
	border:setAlignment("stretch", "stretch");
	border:setRounding(2);
	border:setColor(colors.valueOutline);

	self._knobValueText = valueContainer:addChild(Text:new());
	self._knobValueText:setVerticalPadding(4);
	self._knobValueText:setHorizontalPadding(10);
	self._knobValueText:setColor(colors.valueText);
	self._knobValueText:setFont(FONTS:get("devBold", 14));
end

KnobInfo.setTitle = function(self, title)
	self._headerText:setContent(title);
end

KnobInfo.setKnobIndex = function(self, knobIndex)
	self._knobIndexText:setContent(knobIndex);
end

KnobInfo.setValue = function(self, current, min, max)
	self._donut.value = (current - min) / (max - min);
	self._knobValueText:setContent(string.format("%.2f", current));
end

LiveTuneOverlay.init = function(self, constants, liveTune)
	assert(constants);
	assert(liveTune);
	self._constants = constants;
	self._liveTune = liveTune;
	self._widget = Widget:new();

	local topLevelList = self._widget:setRoot(List.Vertical:new());
	topLevelList:setAllPadding(20);

	local titleBar = topLevelList:addChild(List.Horizontal:new());
	titleBar:setHorizontalAlignment("stretch");
	titleBar:setBottomPadding(12);

	local titleBarPrefix = titleBar:addChild(Image:new());
	self._titleText = titleBar:addChild(Text:new());
	local titleBarSuffix = titleBar:addChild(Image:new());

	self._titleText:setHorizontalPadding(6);
	self._titleText:setFont(FONTS:get("devCondensed", 16));
	self._titleText:setColor(colors.title);

	titleBarPrefix:setVerticalAlignment("center");
	titleBarPrefix:setWidth(16);
	titleBarPrefix:setHeight(1);
	titleBarPrefix:setColor(colors.title);
	titleBarPrefix:setTopPadding(1.5); -- TODO let image widget handle pixel snapping?

	titleBarSuffix:setVerticalAlignment("center");
	titleBarSuffix:setGrow(1);
	titleBarSuffix:setHeight(1);
	titleBarSuffix:setColor(colors.title);
	titleBarSuffix:setTopPadding(1.5); -- TODO let image widget handle pixel snapping?

	self._content = topLevelList:addChild(Switcher:new());
	self._content:setHorizontalAlignment("stretch");
	self._helpText = self._content:addChild(Text:new());
	self._helpText:setHorizontalAlignment("stretch");
	self._helpText:setColor(colors.help);
	self._knobInfos = self._content:addChild(List.Horizontal:new());
end

LiveTuneOverlay.update = function(self, dt)

	local mappedKnobs = self._constants:getMappedKnobs();
	if #mappedKnobs > 0 and self._previousNumMappedKnobs == 0 then
		drawOverlay = true;
	end
	self._previousNumMappedKnobs = #mappedKnobs;

	if not drawOverlay then
		return;
	end

	local title = "LIVETUNE";
	local deviceName = self._liveTune:getCurrentDevice();
	if deviceName then
		title = title .. " / " .. deviceName;
	end
	self._titleText:setContent(title);

	if not deviceName then
		self._content:jumpToChild(self._helpText);
		local deviceList = self._liveTune:listDevices();
		if #deviceList == 0 then
			self._helpText:setContent("No MIDI devices were detected, please plug in a MIDI device.");
		else
			local text = "Not connected to a MIDI device. Use the `connectToMIDIDevice` command to select a device.";
			text = text .. "\n\nMIDI devices detected:";
			for i, deviceName in ipairs(deviceList) do
				text = text .. "\n\t#" .. i .. " " .. deviceName;
			end
			self._helpText:setContent(text);
		end

	elseif #mappedKnobs == 0 then
		self._content:jumpToChild(self._helpText);
		self._helpText:setContent(
			"Connected. Use the `liveTune` command to map a Constant to a knob on your " .. deviceName .. " device.");
	else
		self._content:jumpToChild(self._knobInfos);
	end

	local children = self._knobInfos:getChildren();
	for i = 1 + #mappedKnobs, #children do
		self._knobInfos:removeChild(children[i]);
	end
	for i = 1 + #children, #mappedKnobs do
		local knobInfo = self._knobInfos:addChild(KnobInfo:new());
		knobInfo:setRightPadding(10);
	end

	for i, mappedKnob in ipairs(mappedKnobs) do
		local widget = self._knobInfos:getChild(i);
		assert(widget);
		widget:setTitle(mappedKnob.constantName);
		local currentValue = self._constants:get(mappedKnob.constantName);
		widget:setValue(currentValue, mappedKnob.minValue, mappedKnob.maxValue);
		widget:setKnobIndex(mappedKnob.knobIndex);
	end

	local width, height = love.graphics.getDimensions();
	self._widget:updateTree(dt, width, height);
end

LiveTuneOverlay.draw = function(self)
	if not drawOverlay then
		return;
	end
	self._widget:draw();
end

TERMINAL:addCommand("showLiveTuneOverlay", function()
	drawOverlay = true;
end);

TERMINAL:addCommand("hideLiveTuneOverlay", function()
	drawOverlay = false;
end);

return LiveTuneOverlay;
