local Element = require("ui/bricks/core/Element");
local List = require("ui/bricks/elements/List");
local TableUtils = require("utils/TableUtils");

local tests = {};

tests[#tests + 1] = { name = "Horizontal list aligns children" };
tests[#tests].body = function()
	local box = List.Horizontal:new();
	local a = box:addChild(Element:new());
	a:setGrow(1);
	local b = box:addChild(Element:new());
	b:setGrow(1);
	local c = box:addChild(Element:new());
	c:setGrow(1);
	box:updateTree(0, 90, 40);
	assert(TableUtils.equals({ 0, 30, 0, 0 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 30, 60, 0, 0 }, { b:getLocalPosition() }));
	assert(TableUtils.equals({ 60, 90, 0, 0 }, { c:getLocalPosition() }));
end

tests[#tests + 1] = { name = "Vertical list aligns children" };
tests[#tests].body = function()
	local box = List.Vertical:new();
	local a = box:addChild(Element:new());
	a:setGrow(1);
	local b = box:addChild(Element:new());
	b:setGrow(1);
	local c = box:addChild(Element:new());
	c:setGrow(1);
	box:updateTree(0, 40, 90);
	assert(TableUtils.equals({ 0, 0, 0, 30 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 0, 30, 60 }, { b:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 0, 60, 90 }, { c:getLocalPosition() }));
end

tests[#tests + 1] = { name = "Horizontal list respects vertical alignment" };
tests[#tests].body = function()
	local box = List.Horizontal:new();

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
	assert(TableUtils.equals({ 0, 25, 0, 10 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 25, 50, 15, 25 }, { b:getLocalPosition() }));
	assert(TableUtils.equals({ 50, 75, 30, 40 }, { c:getLocalPosition() }));
	assert(TableUtils.equals({ 75, 100, 0, 40 }, { d:getLocalPosition() }));
end

tests[#tests + 1] = { name = "Vertical list respects horizontal alignment" };
tests[#tests].body = function()
	local box = List.Vertical:new();

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
	assert(TableUtils.equals({ 0, 10, 0, 25 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 15, 25, 25, 50 }, { b:getLocalPosition() }));
	assert(TableUtils.equals({ 30, 40, 50, 75 }, { c:getLocalPosition() }));
	assert(TableUtils.equals({ 0, 40, 75, 100 }, { d:getLocalPosition() }));
end

tests[#tests + 1] = { name = "Horizontal list respects padding" };
tests[#tests].body = function()
	local box = List.Horizontal:new();

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
	assert(TableUtils.equals({ 5, 30, 0, 10 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 30, 55, 16, 26 }, { b:getLocalPosition() }));
	assert(TableUtils.equals({ 55, 80, 30, 40 }, { c:getLocalPosition() }));
	assert(TableUtils.equals({ 100, 125, 10, 30 }, { d:getLocalPosition() }));
end

tests[#tests + 1] = { name = "Vertical list respects padding" };
tests[#tests].body = function()
	local box = List.Vertical:new();

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
	assert(TableUtils.equals({ 0, 10, 5, 30 }, { a:getLocalPosition() }));
	assert(TableUtils.equals({ 16, 26, 30, 55 }, { b:getLocalPosition() }));
	assert(TableUtils.equals({ 30, 40, 55, 80 }, { c:getLocalPosition() }));
	assert(TableUtils.equals({ 10, 30, 100, 125 }, { d:getLocalPosition() }));
end

return tests;
