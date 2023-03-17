string.trim = function(s)
	return s:match("^%s*(.-)%s*$");
end

string.strip_whitespace = function(s)
	return s:gsub("%s+", "");
end

string.split = function(str, sep)
	assert(type(str) == "string");
	assert(type(sep) == "string");
	local out = {};
	local safe_separators = string.gsub(sep, "([^%w])", "%%%1");
	local pattern = string.format("([^%s]+)", safe_separators);
	str:gsub(pattern, function(c)
		table.push(out, c);
	end);
	return out;
end

string.file_extension = function(path)
	local path_split = path:split("\\/");
	if #path_split == 0 then
		return nil;
	end
	return path_split[#path_split]:match("%.([%a%d]+)$");
end

string.strip_file_extension = function(path)
	return path:match("^(.*)%.[%a%d]+$");
end

string.parent_directory = function(path)
	if path == "" then
		return nil;
	end
	local path_split = path:split("\\/");
	table.pop(path_split);
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
		table.pop(a_split);
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

return {
	init = function()
		--#region Tests

		crystal.test.add("Can trim string", function()
			assert("oink" == (" 	 	  	oink"):trim());
			assert("oink" == ("oink  	 	"):trim());
			assert("oink 	gruik" == (" 	oink 	gruik	 "):trim());
		end);

		crystal.test.add("Can strip whitespace", function()
			assert(("  oink  gruik  "):strip_whitespace() == "oinkgruik");
			assert(("	oink	gruik	"):strip_whitespace() == "oinkgruik");
		end);

		crystal.test.add("Can extract file extension", function()
			assert("png" == ("gruik.png"):file_extension());
			assert("png" == ("../gruik.png"):file_extension());
			assert(nil == ("a/b.c/gruik"):file_extension());
			assert(nil == ("gruikpng"):file_extension());
		end);

		crystal.test.add("Can strip file extension", function()
			assert("gruik" == ("gruik.png"):strip_file_extension());
			assert("../gruik" == ("../gruik.png"):strip_file_extension());
		end);

		crystal.test.add("Can strip file from path", function()
			assert(nil == (""):parent_directory());
			assert("" == ("aa"):parent_directory());
			assert("" == ("/"):parent_directory());
			assert("" == ("/a"):parent_directory());
			assert("aa/b/c" == ("aa/b\\c/gruik.png"):parent_directory());
			assert("aa/b/c" == ("aa/b\\c/gruikpng"):parent_directory());
		end);

		crystal.test.add("Can merge paths", function()
			assert("a/b/c" == string.merge_paths("a/b/c", ""));
			assert("a/b/c" == string.merge_paths("", "a/b/c"));
			assert("a/b/c" == string.merge_paths("a/b", "c"));
			assert("a/c" == string.merge_paths("a/b", "../c"));
			assert("a/b/c" == string.merge_paths("a/b/", "c/"));
		end);

		crystal.test.add("Can split with multiple separators", function()
			local split = string.split("ab.cde,fg  hij", " ,.");
			assert(split[1] == "ab");
			assert(split[2] == "cde");
			assert(split[3] == "fg");
			assert(split[4] == "hij");
		end);

		--#endregion
	end,
};
