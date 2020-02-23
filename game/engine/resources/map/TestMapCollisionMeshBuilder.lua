local MapCollisionChainData = require("engine/resources/map/MapCollisionChainData");

local tests = {};

tests[#tests + 1] = {name = "Load Diamond library"};
tests[#tests].body = function()
	local FFI = require("ffi");
	local Diamond = FFI.load("diamond");
end

tests[#tests + 1] = {name = "Diamond hello world"};
tests[#tests].body = function()
	local FFI = require("ffi");
	local Diamond = FFI.load("diamond");
	local q = Diamond.hello_rust();
	print(FFI.string(q));
end

return tests;
