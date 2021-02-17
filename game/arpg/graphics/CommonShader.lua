require("engine/utils/OOP");
local Assets = require("engine/resources/Assets");
local Shader = require("engine/mapscene/display/Shader");
local Palette = require("arpg/graphics/Palette");

local CommonShader = Class("CommonShader", Shader);

CommonShader.init = function(self)
	Shader.super.init(self);
	self:setShaderResource(Assets:getShader("arpg/assets/shader/common.glsl"));
	self:setHighlightColor();
end

CommonShader.setHighlightColor = function(self, color)
	-- TODO use https://love2d.org/wiki/Shader:sendColor
	-- And enable gamma correct rendering
	if color then
		self:setUniform("highlightColor", color);
	else
		self:setUniform("highlightColor", Palette.black);
	end
end

return CommonShader;
