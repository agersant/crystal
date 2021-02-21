local hotReload = function()
	TERMINAL:run("save hot_reload");
	_G["hotReloading"] = true;
	ENGINE:reloadGame();
	_G["hotReloading"] = false;
	TERMINAL:run("load hot_reload");
end

TERMINAL:addCommand("hotReload", hotReload);
