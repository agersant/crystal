crystal.assets.add_loader("glsl", {
	load = function(path)
		local shader_code = love.filesystem.read(path);
		assert(shader_code);
		return love.graphics.newShader(shader_code);
	end,
});

crystal.test.add("Load shader", function()
	local assets = Assets:new();
	local shaderPath = "test-data/TestAssets/shader.glsl";
	assets:load(shaderPath);
	local shader = assets:getShader(shaderPath);
	assert(shader);
	assets:unload(shaderPath);
end);
