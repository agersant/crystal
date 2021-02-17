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

return StringUtils;
