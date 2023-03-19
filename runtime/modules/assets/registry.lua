---@class Registry
---@field private assets { [string]: Asset }
---@field private contexts { [string]: { [string]: boolean } }
---@field private loaders { [string]: Loader }
local Registry = Class("Registry");

---@alias Asset { content: any, dependents: { [string]: boolean }, dependencies: { [string]: boolean }, loader: Loader }
---@alias Hook { before_load: fun(string), after_load: fun(string) }
---@alias Loader { dependencies: fun(string): string[], can_load: fun(string): boolean, unload: fun(string): any, load: fun(string): any }

Registry.init = function(self)
	self.assets = {};
	self.contexts = {};
	self.hooks = {};
	self.loaders = {};
end

---@param extension string
---@param hook Hook
Registry.add_hook = function(self, extension, hook)
	assert(type(extension) == "string");
	self.hooks[extension:lower()] = hook;
end

---@param extension string
---@param loader Loader
Registry.add_loader = function(self, extension, loader)
	assert(type(extension) == "string");
	extension = extension:lower();
	if not self.loaders[extension] then
		self.loaders[extension] = {};
	end
	table.push(self.loaders[extension], loader);
end

---@param path string
---@return boolean
Registry.is_loaded = function(self, path)
	return self.assets[path] ~= nil;
end

---@param path string
---@return any
Registry.get = function(self, path)
	path = self:normalize(path);
	if self.assets[path] then
		return self.assets[path].content;
	end
	self:load(path, "unplanned");
	if not self.assets[path] then
		error("Failed to load: " .. path);
	end
	return self.assets[path].content;
end

---@param path string
---@param context string
Registry.load = function(self, path, context)
	context = context or "default";
	path = self:normalize(path);
	self:load_internal(path, context);
	if not self.contexts[context] then
		self.contexts[context] = {};
	end
	self.contexts[context][path] = true;
end

---@private
---@param path string
---@param dependent string
Registry.load_internal = function(self, path, dependent)
	assert(type(path) == "string");
	assert(type(dependent) == "string");
	path = self:normalize(path);
	local asset = self.assets[path];
	if not asset then
		self:run_hooks("before_load", path);
		local loader = self:pick_loader(path);
		if loader then
			local dependencies = {};
			if loader.dependencies then
				dependencies = loader.dependencies(path);
			end
			for _, dependency in ipairs(dependencies) do
				self:load_internal(dependency, path);
			end
			asset = {
				path = path,
				loader = loader,
				dependencies = dependencies,
				dependents = {},
			};
			if loader.load then
				asset.content = loader.load(path);
			end
		end
		self:run_hooks("after_load", path);
	end
	if asset then
		self.assets[path] = asset;
		asset.dependents[dependent] = true;
	end
end

---@param path string
---@param context string
Registry.unload = function(self, path, context)
	path = self:normalize(path);
	self:unload_internal(path, context);
	if self.contexts[context] then
		self.contexts[context][path] = nil;
	end
end

---@param path string
---@param dependent string
Registry.unload_internal = function(self, path, dependent)
	assert(type(dependent) == "string");
	path = self:normalize(path);
	local asset = self.assets[path];
	if not asset then
		return;
	end
	asset.dependents[dependent] = nil;
	if table.is_empty(asset.dependents) then
		self.assets[path] = nil;
		if asset.loader.unload then
			asset.loader.unload(path);
		end
		for _, dependency in ipairs(asset.dependencies) do
			self:unload_internal(dependency, path);
		end
	end
end

Registry.unload_all = function(self)
	for context in pairs(self.contexts) do
		self:unload_context(context);
	end
end

---@param context string
Registry.unload_context = function(self, context)
	local assets = self.contexts[context];
	if not assets then
		return;
	end
	for path in pairs(assets) do
		self:unload_internal(path, context);
	end
	self.contexts[context] = nil;
end

---@private
---@param name string
---@param path string
Registry.run_hooks = function(self, name, path)
	local extension = path:file_extension();
	for _, hook in ipairs(self.hooks[extension] or {}) do
		if hook[name] then
			hook[name](path);
		end
	end
end

---@private
---@param path string
---@return Loader
Registry.pick_loader = function(self, path)
	local extension = path:file_extension();
	for _, loader in ipairs(self.loaders[extension] or {}) do
		if loader.can_load == nil or loader.can_load(path) then
			return loader;
		end
	end
	crystal.log.warning("No applicable loader for asset: " .. path);
end

---@private
---@param path string
---@return string
Registry.normalize = function(self, path)
	local normalized = path:lower();
	normalized = normalized:gsub("\\", "/");
	return normalized;
end

return Registry;
