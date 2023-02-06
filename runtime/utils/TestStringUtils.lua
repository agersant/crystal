local StringUtils = require("utils/StringUtils");

local tests = {};

tests[#tests + 1] = { name = "Trim before" };
tests[#tests].body = function()
	assert("oink" == StringUtils.trim(" 	 	  	oink"));
end

tests[#tests + 1] = { name = "Trim after" };
tests[#tests].body = function()
	assert("oink" == StringUtils.trim("oink  	 	"));
end

tests[#tests + 1] = { name = "Trim preserves spaces in the middle" };
tests[#tests].body = function()
	assert("oink 	gruik" == StringUtils.trim(" 	oink 	gruik	 "));
end

tests[#tests + 1] = { name = "Remove whitespace removes spaces" };
tests[#tests].body = function()
	assert(StringUtils.removeWhitespace("  oink  gruik  ") == "oinkgruik");
end

tests[#tests + 1] = { name = "Remove whitespace removes tabs" };
tests[#tests].body = function()
	assert(StringUtils.removeWhitespace("	oink	gruik	") == "oinkgruik");
end

tests[#tests + 1] = { name = "Valid file extension" };
tests[#tests].body = function()
	assert("png" == StringUtils.fileExtension("gruik.png"));
end

tests[#tests + 1] = { name = "Valid file extension relative path" };
tests[#tests].body = function()
	assert("png" == StringUtils.fileExtension("../gruik.png"));
end

tests[#tests + 1] = { name = "Bad file extension" };
tests[#tests].body = function()
	assert(nil == StringUtils.fileExtension("gruikpng"));
end

tests[#tests + 1] = { name = "Strip file extension" };
tests[#tests].body = function()
	assert("gruik" == StringUtils.stripFileExtension("gruik.png"));
end

tests[#tests + 1] = { name = "Strip file extension relative path" };
tests[#tests].body = function()
	assert("../gruik" == StringUtils.stripFileExtension("../gruik.png"));
end

tests[#tests + 1] = { name = "Strip file from path" };
tests[#tests].body = function()
	assert("aa/b/c" == StringUtils.stripFileFromPath("aa/b\\c/gruik.png"));
end

tests[#tests + 1] = { name = "Strip file from path without extension" };
tests[#tests].body = function()
	assert("aa/b/c" == StringUtils.stripFileFromPath("aa/b\\c/gruikpng"));
end

tests[#tests + 1] = { name = "Merge with empty" };
tests[#tests].body = function()
	assert("a/b/c" == StringUtils.mergePaths("a/b/c", ""));
end

tests[#tests + 1] = { name = "Merge from empty" };
tests[#tests].body = function()
	assert("a/b/c" == StringUtils.mergePaths("", "a/b/c"));
end

tests[#tests + 1] = { name = "Merge simple" };
tests[#tests].body = function()
	assert("a/b/c" == StringUtils.mergePaths("a/b", "c"));
end

tests[#tests + 1] = { name = "Merge with parent directory" };
tests[#tests].body = function()
	assert("a/c" == StringUtils.mergePaths("a/b", "../c"));
end

return tests;
