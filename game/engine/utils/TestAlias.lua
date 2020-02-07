local Alias = require("engine/utils/Alias");

local tests = {};

tests[#tests + 1] = {name = "Basic usage"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local To = Class("To");
	To.method = function()
		return true;
	end
	local from = From:new();
	local to = To:new();
	assert(not from.method);
	Alias:add(from, to);
	assert(from.method());
end

tests[#tests + 1] = {name = "Transitive"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local Middle = Class("Middle");
	local To = Class("To");
	To.method = function()
		return true;
	end
	local from = From:new();
	local middle = Middle:new();
	local to = To:new();
	Alias:add(from, middle);
	Alias:add(middle, to);
	assert(from.method());
end

tests[#tests + 1] = {name = "Works for inherited methods"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local Base = Class("Base");
	local To = Class("To", Base);
	Base.method = function()
		return true;
	end
	local from = From:new();
	local to = To:new();
	assert(not from.method);
	Alias:add(from, to);
	assert(from.method());
end

tests[#tests + 1] = {name = "Does not alias variables"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local To = Class("To");
	local from = From:new();
	local to = To:new();
	to.member = true;
	Alias:add(from, to);
	assert(not from.member);
end

tests[#tests + 1] = {name = "Overrides self parameter"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local To = Class("To");
	To.getMyClass = function(self)
		return self:getClass();
	end
	local from = From:new();
	local to = To:new();
	Alias:add(from, to);
	assert(from:getMyClass() == To);
end

return tests;
