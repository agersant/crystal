local BasicJoint = require("modules/ui/basic_joint");
local Border = require("modules/ui/border");
local Container = require("modules/ui/container");
local Image = require("modules/ui/image");
local Joint = require("modules/ui/joint");
local Overlay = require("modules/ui/overlay");
local Padding = require("modules/ui/padding");
local UIElement = require("modules/ui/ui_element");
local Wrapper = require("modules/ui/wrapper");

---@alias HorizontalAlignment "left" | "center" | "right" | "stretch"
---@alias VerticalAlignment "top" | "center" | "bottom" | "stretch"

local fonts = {};

return {
	module_api = {
		font = function(name)
			assert(fonts[name]);
			return fonts[name];
		end,
	},
	global_api = {
		BasicJoint = BasicJoint,
		Border = Border,
		Container = Container,
		Image = Image,
		Joint = Joint,
		Overlay = Overlay,
		Padding = Padding,
		UIElement = UIElement,
		Wrapper = Wrapper,
	},
	init = function()
		for name, font in pairs(crystal.conf.fonts) do
			assert(type(name) == "string");
			assert(font:typeOf("Font"));
			fonts[name] = font;
		end
		local built_in_fonts = {
			crystal_console = CRYSTAL_RUNTIME .. "/assets/source_code_pro_medium.otf",
			crystal_body = CRYSTAL_RUNTIME .. "/assets/source_code_pro_bold.otf",
			crystal_header = CRYSTAL_RUNTIME .. "/assets/open_sans_condensed_bold.ttf",
		};
		local built_in_sizes = {
			xs = 12,
			sm = 14,
			md = 16,
			lg = 18,
			xl = 20,
		};
		for name, path in pairs(built_in_fonts) do
			for suffix, size in pairs(built_in_sizes) do
				local font = love.graphics.newFont(path, size);
				font:setFilter("linear", "linear");
				fonts[name .. "_" .. suffix] = font;
			end
		end
	end,
};
