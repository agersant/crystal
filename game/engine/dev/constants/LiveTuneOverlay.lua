require("engine/utils/OOP");
local Terminal = require("engine/dev/cli/Terminal");
local Constants = require("engine/dev/constants/Constants");
local LiveTune = require("engine/dev/constants/LiveTune");
local Features = require("engine/dev/Features");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");

local LiveTuneOverlay = Class("LiveTuneOverlay");

if not Features.liveTune then
	Features.stub(LiveTuneOverlay);
end

local drawOverlay = false;

local colors = {
	deviceName = Colors.greyD,
	headerBackground = Colors.greyA,
	headerText = Colors.greyD,
	background = Colors.greyB,
	knobInactive = Colors.greyC,
	knobActive = Colors.cyan,
	knobIndex = Colors.greyD,
	valueOutline = Colors.greyC,
	valueText = Colors.greyD,
};

LiveTuneOverlay.init = function(self)
end

LiveTuneOverlay.draw = function(self)

	if not drawOverlay then
		return;
	end

	love.graphics.push();

	local padding = 20;
	love.graphics.translate(padding, padding);

	-- Device name
	local deviceNameFontSize = 16;
	local prefixLineLength = 16;
	local deviceNamePaddingX = 6;
	local deviceNamePaddingY = 12;
	local deviceNameFont = Fonts:get("devCondensed", deviceNameFontSize);
	local deviceName = LiveTune:getCurrentDevice() or "Not connected to a MIDI device";

	-- Headers
	local headerPaddingY = 8;
	local headerPaddingLeft = 8;
	local headerPaddingRight = 8;
	local headerFontSize = 14;
	local headerFont = Fonts:get("devCondensed", headerFontSize);
	local headerHeight = headerFontSize + 2 * headerPaddingY;
	local contentPadding = 10;

	-- Knob
	local p = 2 * math.pi;
	local numSegments = 64;
	local arcRadius = 10;
	local arcThickness = 4;
	local arcStart = 40 / 360 * p + p;
	local arcEnd = 140 / 360 * p;
	local knobIndexFontSize = 12;
	local knobIndexFont = Fonts:get("devBold", knobIndexFontSize);
	local knobMargin = 10;

	-- Value
	local valueFontSize = 14;
	local valuePadding = 4;

	-- Measurements
	local contentHeight = math.max(2 * arcRadius, valueFontSize + 2 * valuePadding) + 2 * contentPadding;
	local totalHeight = contentHeight + headerHeight;

	-- Draw device name
	local y = deviceNameFontSize / 2 + 0.5 + 4;
	love.graphics.setColor(colors.deviceName);
	love.graphics.setLineWidth(1);
	love.graphics.line(0, y, prefixLineLength, y);
	local x = prefixLineLength + deviceNameFont:getWidth(deviceName) + 2 * deviceNamePaddingX;
	love.graphics.line(x, y, love.graphics.getWidth() - 2 * padding, y);
	love.graphics.setFont(deviceNameFont);
	love.graphics.printf(deviceName, prefixLineLength + deviceNamePaddingX, 0, love.graphics.getWidth(), "left");
	love.graphics.translate(0, deviceNameFontSize + deviceNamePaddingY);

	-- TODO Real data + scale value for bounds
	for i = 1, 16 do

		love.graphics.push();

		local constantName = "Constant#" .. i;
		Constants:register(constantName, 0.5, {minValue = 0, maxValue = 1});
		Constants:liveTune(constantName, i);
		local value = Constants:get(constantName);

		local headerText = constantName;
		local width = math.max(130, headerFont:getWidth(headerText) + headerPaddingLeft + headerPaddingRight);

		local spacing = 10;

		-- Draw background
		love.graphics.setColor(colors.background);
		love.graphics.rectangle("fill", 0, headerHeight / 2, width, headerHeight / 2 + contentHeight, 2, 2);

		-- Draw header
		love.graphics.setColor(colors.headerBackground);
		love.graphics.rectangle("fill", 0, 0, width, headerHeight, 2, 2);
		love.graphics.rectangle("fill", 0, 2, width, headerHeight - 2, 0, 0);

		love.graphics.setFont(headerFont);
		love.graphics.setColor(colors.headerText);
		love.graphics.printf(headerText, headerPaddingLeft, headerPaddingY - 2, width, "left");

		love.graphics.translate(contentPadding + arcThickness / 2, headerHeight);

		-- Draw knob
		love.graphics.setColor(colors.knobInactive);
		love.graphics.setLineWidth(arcThickness);
		love.graphics.arc("line", "open", arcRadius, contentHeight / 2, arcRadius, arcStart, arcEnd, numSegments);
		love.graphics.setColor(colors.knobActive);
		love.graphics.setLineWidth(arcThickness);
		love.graphics.arc("line", "open", arcRadius, contentHeight / 2, arcRadius, arcEnd + value * (arcStart - arcEnd),
                  		arcEnd, numSegments);

		-- Draw knob index
		love.graphics.setColor(colors.knobIndex);
		love.graphics.setFont(knobIndexFont);
		love.graphics.printf(i, arcRadius - width / 2, 2 * arcRadius + arcThickness / 2 + 2, width, "center");

		love.graphics.translate(2 * arcRadius + knobMargin, (contentHeight - valueFontSize - 2 * valuePadding) / 2);

		-- Draw value background
		local r = 2;
		local w = width - 2 * contentPadding - 2 * arcRadius - knobMargin;
		love.graphics.setColor(colors.valueOutline);
		love.graphics.setLineWidth(1);
		love.graphics.rectangle("line", 0, 0, w, valueFontSize + 2 * valuePadding, r, r);

		-- Draw value
		love.graphics.setColor(colors.valueText);
		love.graphics.setFont(Fonts:get("devBold", valueFontSize));
		love.graphics.print(string.format("%.2f", value), valuePadding, valuePadding - 2);

		love.graphics.pop();

		-- Move to next
		love.graphics.translate(width + spacing, 0);
	end

	love.graphics.pop();

end

Terminal:registerCommand("showLiveTuneOverlay", function()
	drawOverlay = true;
end);

Terminal:registerCommand("hideLiveTuneOverlay", function()
	drawOverlay = false;
end);

return LiveTuneOverlay;
