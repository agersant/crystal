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

tests[#tests + 1] = {name = "Errors on ambiguous call"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local ToA = Class("ToA");
	local ToB = Class("ToB");
	ToA.example = function()
	end
	ToB.example = function()
	end
	local from = From:new();
	local toA = ToA:new();
	local toB = ToB:new();
	Alias:add(from, toA);
	Alias:add(from, toB);

	local success, errorMessage = pcall(function()
		from:example();
	end);
	assert(not success);
	assert(#errorMessage > 1);
end

tests[#tests + 1] = {name = "Shared base methods are not ambiguous"};
tests[#tests].body = function()
	Class:resetIndex();
	local From = Class("From");
	local Base = Class("Base");
	local DerivedA = Class("DerivedA", Base);
	local DerivedB = Class("DerivedB", Base);
	Base.example = function()
	end
	local from = From:new();
	local derivedA = DerivedA:new();
	local derivedB = DerivedB:new();
	Alias:add(from, derivedA);
	Alias:add(from, derivedB);

	local success = pcall(function()
		from:example();
	end);
	assert(success);
end

return tests;
