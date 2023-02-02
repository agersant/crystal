local tests = {};

tests[#tests + 1] = { name = "To string" };
tests[#tests].body = function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local Bird = Class:test("Bird");
	assert(tostring(Fruit));
	assert(#tostring(Fruit) > 0);
	assert(tostring(Fruit) ~= tostring(Bird));
	assert(tostring(Fruit) ~= tostring(Peach));
end

tests[#tests + 1] = { name = "Get class" };
tests[#tests].body = function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local myFruit = Fruit:new();
	local myPeach = Peach:new();
	assert(myFruit:getClass() == Fruit);
	assert(myPeach:getClass() == Peach);
end

tests[#tests + 1] = { name = "Get class name" };
tests[#tests].body = function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local myFruit = Fruit:new();
	local myPeach = Peach:new();
	assert(myFruit:getClassName() == "Fruit");
	assert(myPeach:getClassName() == "Peach");
end

tests[#tests + 1] = { name = "Is instance of" };
tests[#tests].body = function()
	local Fruit = Class:test("Fruit");
	local myFruit = Fruit:new();
	assert(myFruit:isInstanceOf(Fruit));

	local Bird = Class:test("Bird");
	assert(not myFruit:isInstanceOf(Bird));
end

tests[#tests + 1] = { name = "Is instance of inheritance" };
tests[#tests].body = function()
	local Fruit = Class:test("Fruit");
	local Peach = Class:test("Peach", Fruit);
	local Apple = Class:test("Apple", Fruit);

	local myPeach = Peach:new();
	assert(myPeach:isInstanceOf(Fruit));
	assert(myPeach:isInstanceOf(Peach));
	assert(not myPeach:isInstanceOf(Apple));

	local myFruit = Fruit:new();
	assert(myFruit:isInstanceOf(Fruit));
	assert(not myFruit:isInstanceOf(Peach));
end

tests[#tests + 1] = { name = "Get by name" };
tests[#tests].body = function()
	local Fruit = Class("MostUniqueFruit");
	local Peach = Class("VeryUniqueDerivedPeach", Fruit);
	assert(Class:getByName("MostUniqueFruit") == Fruit);
	assert(Class:getByName("VeryUniqueDerivedPeach") == Peach);
	assert(Class:getByName("Berry") == nil);
end

tests[#tests + 1] = { name = "Placement new" };
tests[#tests].body = function()
	local Fruit = Class:test("Fruit");
	local fruit = {};
	Fruit:placementNew(fruit);
	assert(fruit:getClass() == Fruit);
end

return tests;
