crystal.assets.add_loader("glsl", {
	load = function(path)
		local shader_code = love.filesystem.read(path);
		assert(shader_code);
		return love.graphics.newShader(shader_code);
	end,
});

crystal.test.add("Can load a shader", function()
	local shader = crystal.assets.get("test-data/shader.glsl");
	assert(shader)
	assert(shader:typeOf("Shader"));
end);
