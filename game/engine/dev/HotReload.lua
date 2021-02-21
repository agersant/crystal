local hotReload = function()
	TERMINAL:run("save hot_reload");
	ASSETS:unloadAll();
	-- TODO This doesnt reload shit!
	package.loaded = {};
	TERMINAL:run("load hot_reload");
end

TERMINAL:addCommand("hotReload", hotReload);
