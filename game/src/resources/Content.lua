require("src/utils/OOP");
local StringUtils = require("src/utils/StringUtils");

local Content = Class("Content");

Content.requireAll = function(self, path)
	for _, item in ipairs(love.filesystem.getDirectoryItems(path)) do
		local file = path .. "/" .. item;
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
