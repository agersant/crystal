string.trim = function(s)
	return s:match("^%s*(.-)%s*$");
end

string.remove_whitespace = function(s)
	return s:gsub("%s+", "");
end

string.split = function(str, sep)
	local out = {};
	local pattern = string.format("([^%s]+)", sep);
	str:gsub(pattern, function(c)
		table.insert(out, c);
	end);
	return out;
end

string.file_extension = function(path)
	return path:match("%.([%a%d]+)$");
end

string.strip_file_extension = function(path)
	return path:match("^(.*)%.[%a%d]+$");
end

string.strip_file_from_path = function(path)
	local path_split = path:split("\\/");
	table.remove(path_split);
	local out = "";
	for i, p in ipairs(path_split) do
		if #out > 0 then
			out = out .. "/";
		end
		out = out .. p;
	end
	return out;
end

string.merge_paths = function(a, b)
	local a_split = a:split("\\/");
	local b_split = b:split("\\/");

	while #b_split > 0 and b_split[1] == ".." do
		table.remove(a_split);
		table.remove(b_split, 1);
	end

	local out = "";
	for i, p in ipairs(a_split) do
		if #out > 0 then
			out = out .. "/";
		end
		out = out .. p;
	end
	for i, p in ipairs(b_split) do
		if #out > 0 then
			out = out .. "/";
		end
		out = out .. p;
	end

	return out;
end

--#region Tests

crystal.test.add("Trim before", function()
	assert("oink" == (" 	 	  	oink"):trim());
end);

crystal.test.add("Trim after", function()
	assert("oink" == ("oink  	 	"):trim());
end);

crystal.test.add("Trim preserves spaces in the middle", function()
	assert("oink 	gruik" == (" 	oink 	gruik	 "):trim());
end);

crystal.test.add("Remove whitespace removes spaces", function()
	assert(("  oink  gruik  "):remove_whitespace() == "oinkgruik");
end);

crystal.test.add("Remove whitespace removes tabs", function()
	assert(("	oink	gruik	"):remove_whitespace() == "oinkgruik");
end);

crystal.test.add("Valid file extension", function()
	assert("png" == ("gruik.png"):file_extension());
end);

crystal.test.add("Valid file extension relative path", function()
	assert("png" == ("../gruik.png"):file_extension());
end);

crystal.test.add("Bad file extension", function()
	assert(nil == ("gruikpng"):file_extension());
end);

crystal.test.add("Strip file extension", function()
	assert("gruik" == ("gruik.png"):strip_file_extension());
end);

crystal.test.add("Strip file extension relative path", function()
	assert("../gruik" == ("../gruik.png"):strip_file_extension());
end);

crystal.test.add("Strip file from path", function()
	assert("aa/b/c" == ("aa/b\\c/gruik.png"):strip_file_from_path());
end);

crystal.test.add("Strip file from path without extension", function()
	assert("aa/b/c" == ("aa/b\\c/gruikpng"):strip_file_from_path());
end);

crystal.test.add("Merge with empty", function()
	assert("a/b/c" == string.merge_paths("a/b/c", ""));
end);

crystal.test.add("Merge from empty", function()
	assert("a/b/c" == string.merge_paths("", "a/b/c"));
end);

crystal.test.add("Merge simple", function()
	assert("a/b/c" == string.merge_paths("a/b", "c"));
end);

crystal.test.add("Merge with parent directory", function()
	assert("a/c" == string.merge_paths("a/b", "../c"));
end);

--#endregion

return {};
