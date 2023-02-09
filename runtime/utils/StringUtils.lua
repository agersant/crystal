local StringUtils = {};

StringUtils.trim = function(s)
	return s:match("^%s*(.-)%s*$");
end

StringUtils.removeWhitespace = function(s)
	return s:gsub("%s+", "");
end

StringUtils.split = function(str, sep)
	local out = {};
	local pattern = string.format("([^%s]+)", sep);
	str:gsub(pattern, function(c)
		table.insert(out, c);
	end);
	return out;
end

StringUtils.fileExtension = function(path)
	return path:match("%.([%a%d]+)$");
end

StringUtils.stripFileExtension = function(path)
	return path:match("^(.*)%.[%a%d]+$");
end

StringUtils.stripFileFromPath = function(path)
	local pathSplit = StringUtils.split(path, "\\/");
	table.remove(pathSplit);
	local out = "";
	for i, p in ipairs(pathSplit) do
		if #out > 0 then
			out = out .. "/";
		end
		out = out .. p;
	end
	return out;
end

StringUtils.mergePaths = function(a, b)
	local aSplit = StringUtils.split(a, "\\/");
	local bSplit = StringUtils.split(b, "\\/");

	while #bSplit > 0 and bSplit[1] == ".." do
		table.remove(aSplit);
		table.remove(bSplit, 1);
	end

	local out = "";
	for i, p in ipairs(aSplit) do
		if #out > 0 then
			out = out .. "/";
		end
		out = out .. p;
	end
	for i, p in ipairs(bSplit) do
		if #out > 0 then
			out = out .. "/";
		end
		out = out .. p;
	end

	return out;
end

--#region Tests


crystal.test.add("Trim before", function()
	assert("oink" == StringUtils.trim(" 	 	  	oink"));
end);

crystal.test.add("Trim after", function()
	assert("oink" == StringUtils.trim("oink  	 	"));
end);

crystal.test.add("Trim preserves spaces in the middle", function()
	assert("oink 	gruik" == StringUtils.trim(" 	oink 	gruik	 "));
end);

crystal.test.add("Remove whitespace removes spaces", function()
	assert(StringUtils.removeWhitespace("  oink  gruik  ") == "oinkgruik");
end);

crystal.test.add("Remove whitespace removes tabs", function()
	assert(StringUtils.removeWhitespace("	oink	gruik	") == "oinkgruik");
end);

crystal.test.add("Valid file extension", function()
	assert("png" == StringUtils.fileExtension("gruik.png"));
end);

crystal.test.add("Valid file extension relative path", function()
	assert("png" == StringUtils.fileExtension("../gruik.png"));
end);

crystal.test.add("Bad file extension", function()
	assert(nil == StringUtils.fileExtension("gruikpng"));
end);

crystal.test.add("Strip file extension", function()
	assert("gruik" == StringUtils.stripFileExtension("gruik.png"));
end);

crystal.test.add("Strip file extension relative path", function()
	assert("../gruik" == StringUtils.stripFileExtension("../gruik.png"));
end);

crystal.test.add("Strip file from path", function()
	assert("aa/b/c" == StringUtils.stripFileFromPath("aa/b\\c/gruik.png"));
end);

crystal.test.add("Strip file from path without extension", function()
	assert("aa/b/c" == StringUtils.stripFileFromPath("aa/b\\c/gruikpng"));
end);

crystal.test.add("Merge with empty", function()
	assert("a/b/c" == StringUtils.mergePaths("a/b/c", ""));
end);

crystal.test.add("Merge from empty", function()
	assert("a/b/c" == StringUtils.mergePaths("", "a/b/c"));
end);

crystal.test.add("Merge simple", function()
	assert("a/b/c" == StringUtils.mergePaths("a/b", "c"));
end);

crystal.test.add("Merge with parent directory", function()
	assert("a/c" == StringUtils.mergePaths("a/b", "../c"));
end);

--#endregion

return StringUtils;
