local Element = require("engine/ui/bricks/core/Element");
local HorizontalAlignment = require("engine/ui/bricks/core/HorizontalAlignment");
local VerticalBox = require("engine/ui/bricks/elements/VerticalBox");
local TableUtils = require("engine/utils/TableUtils");

local tests = {};

tests[#tests + 1] = {name = "Aligns children"};
tests[#tests].body = function()
	local box = VerticalBox:new();
	box:setLocalPosition(0, 40, 0, 90);

	local a = box:addChild(Element:new());
	a:setGrow(1);

	local b = box:addChild(Element:new());
	b:setGrow(1);

	local c = box:addChild(Element:new());
	c:setGrow(1);

	box:layout();
	assert(TableUtils.equals({0, 0, 0, 30}, {a:getLocalPosition()}));
	assert(TableUtils.equals({0, 0, 30, 60}, {b:getLocalPosition()}));
	assert(TableUtils.equals({0, 0, 60, 90}, {c:getLocalPosition()}));
end

tests[#tests + 1] = {name = "Respects horizontal alignment"};
tests[#tests].body = function()
	local box = VerticalBox:new();

	local a = box:addChild(Element:new());
	a:setHorizontalAlignment(HorizontalAlignment.LEFT);

	local b = box:addChild(Element:new());
	b:setHorizontalAlignment(HorizontalAlignment.CENTER);

	local c = box:addChild(Element:new());
	c:setHorizontalAlignment(HorizontalAlignment.RIGHT);

	local d = box:addChild(Element:new());
	d:setHorizontalAlignment(HorizontalAlignment.STRETCH);

	a.getDesiredSize = function()
		return 10, 25;
	end
	b.getDesiredSize = function()
		return 10, 25;
	end
	c.getDesiredSize = function()
		return 10, 25;
	end
	d.getDesiredSize = function()
		return 10, 25;
	end

	local _, h = box:getDesiredSize();
	box:setLocalPosition(0, 40, 0, h);
	box:layout();
	assert(TableUtils.equals({0, 10, 0, 25}, {a:getLocalPosition()}));
	assert(TableUtils.equals({15, 25, 25, 50}, {b:getLocalPosition()}));
	assert(TableUtils.equals({30, 40, 50, 75}, {c:getLocalPosition()}));
	assert(TableUtils.equals({0, 40, 75, 100}, {d:getLocalPosition()}));
end

tests[#tests + 1] = {name = "Respects padding"};
tests[#tests].body = function()
	local box = VerticalBox:new();

	local a = box:addChild(Element:new());
	a:setHorizontalAlignment(HorizontalAlignment.LEFT);
	a:setTopPadding(5);

	local b = box:addChild(Element:new());
	b:setHorizontalAlignment(HorizontalAlignment.CENTER);
	b:setLeftPadding(5);
	b:setRightPadding(4);

	local c = box:addChild(Element:new());
	c:setHorizontalAlignment(HorizontalAlignment.RIGHT);
	c:setBottomPadding(10);

	local d = box:addChild(Element:new());
	d:setHorizontalAlignment(HorizontalAlignment.STRETCH);
	d:setAllPadding(10);

	a.getDesiredSize = function()
		return 10, 25;
	end
	b.getDesiredSize = function()
		return 10, 25;
	end
	c.getDesiredSize = function()
		return 10, 25;
	end
	d.getDesiredSize = function()
		return 20, 25;
	end

	local w, h = box:getDesiredSize();
	box:setLocalPosition(0, w, 0, h);
	box:layout();
	assert(TableUtils.equals({0, 10, 5, 30}, {a:getLocalPosition()}));
	assert(TableUtils.equals({16, 26, 30, 55}, {b:getLocalPosition()}));
	assert(TableUtils.equals({30, 40, 55, 80}, {c:getLocalPosition()}));
	assert(TableUtils.equals({10, 30, 100, 125}, {d:getLocalPosition()}));
end

return tests;
