local Element = require("engine/ui/bricks/core/Element");
local HorizontalBox = require("engine/ui/bricks/elements/HorizontalBox");
local TableUtils = require("engine/utils/TableUtils");

local tests = {};

tests[#tests + 1] = {name = "Aligns children"};
tests[#tests].body = function()
	local box = HorizontalBox:new();

	local a = box:addChild(Element:new());
	a:setGrow(1);

	local b = box:addChild(Element:new());
	b:setGrow(1);

	local c = box:addChild(Element:new());
	c:setGrow(1);

	box:updateTree(0, 90, 40);
	assert(TableUtils.equals({0, 30, 0, 0}, {a:getLocalPosition()}));
	assert(TableUtils.equals({30, 60, 0, 0}, {b:getLocalPosition()}));
	assert(TableUtils.equals({60, 90, 0, 0}, {c:getLocalPosition()}));
end

tests[#tests + 1] = {name = "Respects vertical alignment"};
tests[#tests].body = function()
	local box = HorizontalBox:new();

	local a = box:addChild(Element:new());
	a:setVerticalAlignment("top");

	local b = box:addChild(Element:new());
	b:setVerticalAlignment("center");

	local c = box:addChild(Element:new());
	c:setVerticalAlignment("bottom");

	local d = box:addChild(Element:new());
	d:setVerticalAlignment("stretch");

	a.computeDesiredSize = function()
		return 25, 10;
	end
	b.computeDesiredSize = function()
		return 25, 10;
	end
	c.computeDesiredSize = function()
		return 25, 10;
	end
	d.computeDesiredSize = function()
		return 25, 10;
	end

	box:updateTree(0, nil, 40);
	assert(TableUtils.equals({0, 25, 0, 10}, {a:getLocalPosition()}));
	assert(TableUtils.equals({25, 50, 15, 25}, {b:getLocalPosition()}));
	assert(TableUtils.equals({50, 75, 30, 40}, {c:getLocalPosition()}));
	assert(TableUtils.equals({75, 100, 0, 40}, {d:getLocalPosition()}));
end

tests[#tests + 1] = {name = "Respects padding"};
tests[#tests].body = function()
	local box = HorizontalBox:new();

	local a = box:addChild(Element:new());
	a:setVerticalAlignment("top");
	a:setLeftPadding(5);

	local b = box:addChild(Element:new());
	b:setVerticalAlignment("center");
	b:setTopPadding(5);
	b:setBottomPadding(4);

	local c = box:addChild(Element:new());
	c:setVerticalAlignment("bottom");
	c:setRightPadding(10);

	local d = box:addChild(Element:new());
	d:setVerticalAlignment("stretch");
	d:setAllPadding(10);

	a.computeDesiredSize = function()
		return 25, 10;
	end
	b.computeDesiredSize = function()
		return 25, 10;
	end
	c.computeDesiredSize = function()
		return 25, 10;
	end
	d.computeDesiredSize = function()
		return 25, 20;
	end

	box:updateTree(0);
	assert(TableUtils.equals({5, 30, 0, 10}, {a:getLocalPosition()}));
	assert(TableUtils.equals({30, 55, 16, 26}, {b:getLocalPosition()}));
	assert(TableUtils.equals({55, 80, 30, 40}, {c:getLocalPosition()}));
	assert(TableUtils.equals({100, 125, 10, 30}, {d:getLocalPosition()}));
end

return tests;
