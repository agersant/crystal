require("engine/utils/OOP");
local Assets = require("engine/resources/Assets");
local Colors = require("engine/resources/Colors");
local Shader = require("engine/mapscene/display/Shader");

local CommonShader = Class("CommonShader", Shader);

CommonShader.init = function(self)
	Shader.super.init(self);
	self:setShaderResource(Assets:getShader("arpg/assets/shader/common.glsl"));
	self:setHighlightColor();
end

CommonShader.setHighlightColor = function(self, color)
	if color then
		self:setUniform("highlightColor", color);
	else
		self:setUniform("highlightColor", Colors.black);
	end
end

return CommonShader;
