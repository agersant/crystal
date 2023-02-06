local TableUtils = require("utils/TableUtils");

local tests = {};

tests[#tests + 1] = { name = "Count keys" };
tests[#tests].body = function()
	assert(TableUtils.countKeys({}) == 0);
	assert(TableUtils.countKeys({ a = 0, b = 2 }) == 2);
	assert(TableUtils.countKeys({ 1, 2, 3 }) == 3);
end

tests[#tests + 1] = { name = "Contains" };
tests[#tests].body = function()
	assert(TableUtils.contains({ 2 }, 2));
	assert(TableUtils.contains({ a = 2 }, 2));
	assert(not TableUtils.contains({ 2 }, 3));
	assert(not TableUtils.contains({ [3] = 2 }, 3));
end

tests[#tests + 1] = { name = "Shallow copy" };
tests[#tests].body = function()
	local original = { a = { 1, 2, 3 } };
	local copy = TableUtils.shallowCopy(original);
	assert(copy ~= original);
	assert(copy.a == original.a);
end

tests[#tests + 1] = { name = "Serialize empty table" };
tests[#tests].body = function()
	local original = {};
	local copy = TableUtils.unserialize(TableUtils.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(TableUtils.countKeys(copy) == 0);
end

tests[#tests + 1] = { name = "Serialize trivial table" };
tests[#tests].body = function()
	local original = { a = 0, b = "oink" };
	local copy = TableUtils.unserialize(TableUtils.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(copy.a == 0);
	assert(copy.b == "oink");
end

tests[#tests + 1] = { name = "Serialize simple table" };
tests[#tests].body = function()
	local original = { a = 0, b = "oink", c = { 1, 2, 3 }, d = { b = "gruik" } };
	local copy = TableUtils.unserialize(TableUtils.serialize(original));
	assert(type(copy) == "table");
	assert(copy ~= original);
	assert(copy.a == 0);
	assert(copy.b == "oink");
	assert(copy.c[1] == 1);
	assert(copy.c[2] == 2);
	assert(copy.c[3] == 3);
	assert(copy.d.b == "gruik");
end

tests[#tests + 1] = { name = "Equality" };
tests[#tests].body = function()
	assert(TableUtils.equals({}, {}));
	assert(TableUtils.equals({ 1, 2, 3 }, { 1, 2, 3 }));
	assert(not TableUtils.equals({ 1, 2 }, { 1, 2, 3 }));
	assert(not TableUtils.equals({ 1, 3, 2 }, { 1, 2, 3 }));
	assert(TableUtils.equals({ a = 0, b = 1 }, { a = 0, b = 1 }));
	assert(not TableUtils.equals({ a = 0, b = 1 }, { a = 1, b = 0 }));
	assert(not TableUtils.equals({ a = 0 }, { a = 1 }));
end

return tests;
