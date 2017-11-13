assert( gConf.unitTesting );
local Widget = require( "src/ui/Widget" );

local tests = {};


tests[#tests + 1] = { name = "Offset preserves size" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignTopLeft( 10, 20 );
	widget:offset( 30, 5 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Set padding" };
tests[#tests].body = function()
	local parent = Widget:new();
	parent:alignTopLeft( 100, 100 );
	local widget = Widget:new();
	parent:addChild( widget );
	widget:setPadding( 10 );
	parent:update( 0 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 80 );
	assert( h == 80 );
end

tests[#tests + 1] = { name = "Align top left" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignTopLeft( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align top center" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignTopCenter( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align top right" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignTopRight( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align middle left" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignMiddleRight( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align middle center" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignMiddleRight( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align middle right" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignMiddleRight( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align bottom left" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignBottomLeft( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align bottom center" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignBottomCenter( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end

tests[#tests + 1] = { name = "Align bottom right" };
tests[#tests].body = function()
	local widget = Widget:new();
	widget:alignBottomRight( 10, 20 );
	widget:update( 0 );
	local w, h = widget:getSize();
	assert( w == 10 );
	assert( h == 20 );
end


return tests;
