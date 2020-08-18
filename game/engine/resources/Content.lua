require("engine/utils/OOP");
local StringUtils = require("engine/utils/StringUtils");

local Content = Class("Content");

Content.requireAll = function(self, path)
	for _, item in ipairs(love.filesystem.getDirectoryItems(path)) do
		local file = StringUtils.mergePaths(path, item);
		local info = love.filesystem.getInfo(file);
		if info.type == "file" then
			if StringUtils.fileExtension(file) == "lua" then
				local stripped = StringUtils.stripFileExtension(file);
				require(stripped);
			end
		elseif info.type == "directory" then
			self:requireAll(file);
		end
	end
end

return Content;
