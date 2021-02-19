local Element = require("engine/ui/bricks/core/Element");
local VerticalBox = require("engine/ui/bricks/elements/VerticalBox");
local TableUtils = require("engine/utils/TableUtils");

local tests = {};

tests[#tests + 1] = {name = "Aligns children"};
tests[#tests].body = function()
	local box = VerticalBox:new();

	local a = box:addChild(Element:new());
	a:setGrow(1);

	local b = box:addChild(Element:new());
	b:setGrow(1);

	local c = box:addChild(Element:new());
	c:setGrow(1);

	box:updateTree(0, 40, 90);
	assert(TableUtils.equals({0, 0, 0, 30}, {a:getLocalPosition()}));
	assert(TableUtils.equals({0, 0, 30, 60}, {b:getLocalPosition()}));
	assert(TableUtils.equals({0, 0, 60, 90}, {c:getLocalPosition()}));
end

tests[#tests + 1] = {name = "Respects horizontal alignment"};
tests[#tests].body = function()
	local box = VerticalBox:new();

	local a = box:addChild(Element:new());
	a:setHorizontalAlignment("left");

	local b = box:addChild(Element:new());
	b:setHorizontalAlignment("center");

	local c = box:addChild(Element:new());
	c:setHorizontalAlignment("right");

	local d = box:addChild(Element:new());
	d:setHorizontalAlignment("stretch");

	a.computeDesiredSize = function()
		return 10, 25;
	end
	b.computeDesiredSize = function()
		return 10, 25;
	end
	c.computeDesiredSize = function()
		return 10, 25;
	end
	d.computeDesiredSize = function()
		return 10, 25;
	end

	box:updateTree(0, 40);
	assert(TableUtils.equals({0, 10, 0, 25}, {a:getLocalPosition()}));
	assert(TableUtils.equals({15, 25, 25, 50}, {b:getLocalPosition()}));
	assert(TableUtils.equals({30, 40, 50, 75}, {c:getLocalPosition()}));
	assert(TableUtils.equals({0, 40, 75, 100}, {d:getLocalPosition()}));
end

tests[#tests + 1] = {name = "Respects padding"};
tests[#tests].body = function()
	local box = VerticalBox:new();

	local a = box:addChild(Element:new());
	a:setHorizontalAlignment("left");
	a:setTopPadding(5);

	local b = box:addChild(Element:new());
	b:setHorizontalAlignment("center");
	b:setLeftPadding(5);
	b:setRightPadding(4);

	local c = box:addChild(Element:new());
	c:setHorizontalAlignment("right");
	c:setBottomPadding(10);

	local d = box:addChild(Element:new());
	d:setHorizontalAlignment("stretch");
	d:setAllPadding(10);

	a.computeDesiredSize = function()
		return 10, 25;
	end
	b.computeDesiredSize = function()
		return 10, 25;
	end
	c.computeDesiredSize = function()
		return 10, 25;
	end
	d.computeDesiredSize = function()
		return 20, 25;
	end

	box:updateTree(0);
	assert(TableUtils.equals({0, 10, 5, 30}, {a:getLocalPosition()}));
	assert(TableUtils.equals({16, 26, 30, 55}, {b:getLocalPosition()}));
	assert(TableUtils.equals({30, 40, 55, 80}, {c:getLocalPosition()}));
	assert(TableUtils.equals({10, 30, 100, 125}, {d:getLocalPosition()}));
end

return tests;
