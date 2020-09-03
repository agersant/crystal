local Element = require("engine/ui/bricks/core/Element");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalAlignment = require("engine/ui/bricks/core/VerticalAlignment");
local Overlay = require("engine/ui/bricks/elements/Overlay");
local TableUtils = require("engine/utils/TableUtils");

local tests = {};

tests[#tests + 1] = {name = "Respects alignment"};
tests[#tests].body = function()

	local testCases = {
		{HorizontalAlignment.LEFT, VerticalAlignment.TOP, {0, 60, 0, 40}},
		{HorizontalAlignment.LEFT, VerticalAlignment.CENTER, {0, 60, 30, 70}},
		{HorizontalAlignment.LEFT, VerticalAlignment.BOTTOM, {0, 60, 60, 100}},
		{HorizontalAlignment.LEFT, VerticalAlignment.STRETCH, {0, 60, 0, 100}},
		{HorizontalAlignment.CENTER, VerticalAlignment.TOP, {20, 80, 0, 40}},
		{HorizontalAlignment.CENTER, VerticalAlignment.CENTER, {20, 80, 30, 70}},
		{HorizontalAlignment.CENTER, VerticalAlignment.BOTTOM, {20, 80, 60, 100}},
		{HorizontalAlignment.CENTER, VerticalAlignment.STRETCH, {20, 80, 0, 100}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.TOP, {40, 100, 0, 40}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.CENTER, {40, 100, 30, 70}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.BOTTOM, {40, 100, 60, 100}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.STRETCH, {40, 100, 0, 100}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.TOP, {0, 100, 0, 40}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.CENTER, {0, 100, 30, 70}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.BOTTOM, {0, 100, 60, 100}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.STRETCH, {0, 100, 0, 100}},
	};

	for _, testCase in ipairs(testCases) do
		local overlay = Overlay:new();
		overlay:setLocalPosition(0, 100, 0, 100);

		local element = Element:new();
		element.getDesiredSize = function()
			return 60, 40;
		end

		overlay:addChild(element);
		element:setHorizontalAlignment(testCase[1]);
		element:setVerticalAlignment(testCase[2]);

		overlay:layout();
		assert(TableUtils.equals({element:getLocalPosition()}, testCase[3]));
	end
end

tests[#tests + 1] = {name = "Respects padding"};
tests[#tests].body = function()

	local testCases = {
		{HorizontalAlignment.LEFT, VerticalAlignment.TOP, {2, 62, 6, 46}},
		{HorizontalAlignment.LEFT, VerticalAlignment.CENTER, {2, 62, 28, 68}},
		{HorizontalAlignment.LEFT, VerticalAlignment.BOTTOM, {2, 62, 52, 92}},
		{HorizontalAlignment.LEFT, VerticalAlignment.STRETCH, {2, 62, 6, 92}},
		{HorizontalAlignment.CENTER, VerticalAlignment.TOP, {18, 78, 6, 46}},
		{HorizontalAlignment.CENTER, VerticalAlignment.CENTER, {18, 78, 28, 68}},
		{HorizontalAlignment.CENTER, VerticalAlignment.BOTTOM, {18, 78, 52, 92}},
		{HorizontalAlignment.CENTER, VerticalAlignment.STRETCH, {18, 78, 6, 92}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.TOP, {36, 96, 6, 46}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.CENTER, {36, 96, 28, 68}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.BOTTOM, {36, 96, 52, 92}},
		{HorizontalAlignment.RIGHT, VerticalAlignment.STRETCH, {36, 96, 6, 92}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.TOP, {2, 96, 6, 46}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.CENTER, {2, 96, 28, 68}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.BOTTOM, {2, 96, 52, 92}},
		{HorizontalAlignment.STRETCH, VerticalAlignment.STRETCH, {2, 96, 6, 92}},
	};

	for _, testCase in ipairs(testCases) do
		local overlay = Overlay:new();
		overlay:setLocalPosition(0, 100, 0, 100);

		local element = Element:new();
		element.getDesiredSize = function()
			return 60, 40;
		end

		overlay:addChild(element);
		element:setHorizontalAlignment(testCase[1]);
		element:setVerticalAlignment(testCase[2]);
		element:setEachPadding(2, 4, 6, 8);

		overlay:layout();
		assert(TableUtils.equals({element:getLocalPosition()}, testCase[3]));
	end
end

return tests;
