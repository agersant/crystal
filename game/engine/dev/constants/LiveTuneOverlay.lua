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
	title = Colors.greyD,
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

	-- Title
	local titleFontSize = 16;
	local prefixLineLength = 16;
	local titlePaddingX = 6;
	local titlePaddingY = 12;
	local titleFont = Fonts:get("devCondensed", titleFontSize);
	local deviceName = LiveTune:getCurrentDevice();
	local title = "LIVETUNE";
	if deviceName then
		title = title .. " / " .. deviceName;
	end

	-- Help
	local helpFontSize = 14;
	local helpFont = Fonts:get("dev", helpFontSize);

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
	local spacing = 10;

	-- Draw device name
	local y = titleFontSize / 2 + 0.5 + 4;
	love.graphics.setColor(colors.title);
	love.graphics.setLineWidth(1);
	love.graphics.setLineStyle("rough");
	love.graphics.line(0, y, prefixLineLength, y);
	local x = prefixLineLength + titleFont:getWidth(title) + 2 * titlePaddingX;
	love.graphics.line(x, y, love.graphics.getWidth() - 2 * padding, y);
	love.graphics.setFont(titleFont);
	love.graphics.printf(title, prefixLineLength + titlePaddingX, 0, love.graphics.getWidth(), "left");
	love.graphics.translate(0, titleFontSize + titlePaddingY);

	local mappedKnobs = Constants.instance:getMappedKnobs();

	if not deviceName then
		love.graphics.setFont(helpFont);
		local deviceList = LiveTune:listDevices();

		if #deviceList == 0 then
			love.graphics.printf("No MIDI devices were detected, please plug in a MIDI device.", 0, 0, love.graphics.getWidth(),
                     			"left");
		else
			love.graphics.printf("Not connected to a MIDI device. Use the `connectToMIDIDevice` command to select a device.", 0,
                     			0, love.graphics.getWidth(), "left");
			love.graphics.translate(0, 2 * helpFontSize);
			love.graphics.printf("MIDI devices detected:", 0, 0, love.graphics.getWidth(), "left");
			love.graphics.translate(10, 0);
			for i, deviceName in ipairs(deviceList) do
				love.graphics.translate(0, helpFontSize);
				love.graphics.printf("#" .. i .. " " .. deviceName, 0, 0, love.graphics.getWidth(), "left");
			end
		end

	elseif #mappedKnobs == 0 then
		love.graphics.setFont(helpFont);
		love.graphics.printf("Connected. Use the `liveTune` command to map a Constant to a knob on your " .. deviceName ..
                     						" device.", 0, 0, love.graphics.getWidth(), "left");
	else

		for _, mappedKnob in ipairs(mappedKnobs) do
			love.graphics.push();

			local rawValue = Constants:get(mappedKnob.constantName);
			local value = (rawValue - mappedKnob.minValue) / (mappedKnob.maxValue - mappedKnob.minValue);

			local headerText = mappedKnob.constantName;
			local width = math.max(130, headerFont:getWidth(headerText) + headerPaddingLeft + headerPaddingRight);

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
			love.graphics.printf(mappedKnob.knobIndex, arcRadius - width / 2, 2 * arcRadius + arcThickness / 2 + 2, width,
                     			"center");

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
			love.graphics.print(string.format("%.2f", rawValue), valuePadding, valuePadding - 2);

			love.graphics.pop();

			-- Move to next
			love.graphics.translate(width + spacing, 0);
		end
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
