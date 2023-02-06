local Component = require("ecs/Component");

local Shader = Class("Shader", Component);

Shader.init = function(self, shaderResource)
	Shader.super.init(self);
	self:setShaderResource(shaderResource);
end

Shader.setShaderResource = function(self, shaderResource)
	self._shaderResource = shaderResource;
	self._uniforms = {};
end

Shader.setUniform = function(self, name, value)
	self._uniforms[name] = value;
end

Shader.apply = function(self)
	if not self._shaderResource then
		return;
	end
	for k, v in pairs(self._uniforms) do
		assert(self._shaderResource:hasUniform(k));
		self._shaderResource:send(k, v);
	end
	love.graphics.setShader(self._shaderResource);
end

return Shader;
