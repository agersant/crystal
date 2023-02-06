local Element = require("ui/bricks/core/Element");
local Overlay = require("ui/bricks/elements/Overlay");
local TableUtils = require("utils/TableUtils");

local tests = {};

tests[#tests + 1] = { name = "Respects alignment" };
tests[#tests].body = function()

	local testCases = {
		{ "left", "top", { 0, 60, 0, 40 } },
		{ "left", "center", { 0, 60, 30, 70 } },
		{ "left", "bottom", { 0, 60, 60, 100 } },
		{ "left", "stretch", { 0, 60, 0, 100 } },
		{ "center", "top", { 20, 80, 0, 40 } },
		{ "center", "center", { 20, 80, 30, 70 } },
		{ "center", "bottom", { 20, 80, 60, 100 } },
		{ "center", "stretch", { 20, 80, 0, 100 } },
		{ "right", "top", { 40, 100, 0, 40 } },
		{ "right", "center", { 40, 100, 30, 70 } },
		{ "right", "bottom", { 40, 100, 60, 100 } },
		{ "right", "stretch", { 40, 100, 0, 100 } },
		{ "stretch", "top", { 0, 100, 0, 40 } },
		{ "stretch", "center", { 0, 100, 30, 70 } },
		{ "stretch", "bottom", { 0, 100, 60, 100 } },
		{ "stretch", "stretch", { 0, 100, 0, 100 } },
	};

	for _, testCase in ipairs(testCases) do
		local overlay = Overlay:new();

		local element = Element:new();
		element.computeDesiredSize = function()
			return 60, 40;
		end

		overlay:addChild(element);
		element:setHorizontalAlignment(testCase[1]);
		element:setVerticalAlignment(testCase[2]);

		overlay:updateTree(0, 100, 100);
		assert(TableUtils.equals({ element:getLocalPosition() }, testCase[3]));
	end
end

tests[#tests + 1] = { name = "Respects padding" };
tests[#tests].body = function()

	local testCases = {
		{ "left", "top", { 2, 62, 6, 46 } },
		{ "left", "center", { 2, 62, 28, 68 } },
		{ "left", "bottom", { 2, 62, 52, 92 } },
		{ "left", "stretch", { 2, 62, 6, 92 } },
		{ "center", "top", { 18, 78, 6, 46 } },
		{ "center", "center", { 18, 78, 28, 68 } },
		{ "center", "bottom", { 18, 78, 52, 92 } },
		{ "center", "stretch", { 18, 78, 6, 92 } },
		{ "right", "top", { 36, 96, 6, 46 } },
		{ "right", "center", { 36, 96, 28, 68 } },
		{ "right", "bottom", { 36, 96, 52, 92 } },
		{ "right", "stretch", { 36, 96, 6, 92 } },
		{ "stretch", "top", { 2, 96, 6, 46 } },
		{ "stretch", "center", { 2, 96, 28, 68 } },
		{ "stretch", "bottom", { 2, 96, 52, 92 } },
		{ "stretch", "stretch", { 2, 96, 6, 92 } },
	};

	for _, testCase in ipairs(testCases) do
		local overlay = Overlay:new();

		local element = Element:new();
		element.computeDesiredSize = function()
			return 60, 40;
		end

		overlay:addChild(element);
		element:setHorizontalAlignment(testCase[1]);
		element:setVerticalAlignment(testCase[2]);
		element:setEachPadding(2, 4, 6, 8);

		overlay:updateTree(0, 100, 100);
		assert(TableUtils.equals({ element:getLocalPosition() }, testCase[3]));
	end
end

return tests;
