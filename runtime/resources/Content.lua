local StringUtils = require("utils/StringUtils");

local Content = Class("Content");

local forEachLuaFile;
forEachLuaFile = function(path, action)
	for _, item in ipairs(love.filesystem.getDirectoryItems(path)) do
		local file = StringUtils.mergePaths(path, item);
		local info = love.filesystem.getInfo(file);
		if info.type == "file" then
			if StringUtils.fileExtension(file) == "lua" then
				local stripped = StringUtils.stripFileExtension(file);
				action(stripped);
			end
		elseif info.type == "directory" then
			forEachLuaFile(file, action);
		end
	end
end

Content.requireAll = function(self, path)
	forEachLuaFile(path, require)
end

Content.unrequireAll = function(self, path)
	forEachLuaFile(path, function(fileName)
		package.loaded[fileName] = nil;
	end)
end

return Content;
