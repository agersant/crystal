local Content = Class("Content");

local browse;
browse = function(path, files, pattern)
	for _, item in ipairs(love.filesystem.getDirectoryItems(path)) do
		local file = string.merge_paths(path, item);
		local info = love.filesystem.getInfo(file);
		if info.type == "file" then
			if not pattern or file:match(pattern) then
				table.insert(files, file);
			end
		elseif info.type == "directory" then
			browse(file, files, pattern);
		end
	end
end

Content.listAllFiles = function(self, root, pattern)
	local files = {};
	browse(root, files, pattern);
	return files;
end

return Content;
