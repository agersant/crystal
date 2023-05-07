local BasicJoint = require(CRYSTAL_RUNTIME .. "/modules/ui/basic_joint");
local Border = require(CRYSTAL_RUNTIME .. "/modules/ui/border");
local Container = require(CRYSTAL_RUNTIME .. "/modules/ui/container");
local Image = require(CRYSTAL_RUNTIME .. "/modules/ui/image");
local Joint = require(CRYSTAL_RUNTIME .. "/modules/ui/joint");
local List = require(CRYSTAL_RUNTIME .. "/modules/ui/list");
local Overlay = require(CRYSTAL_RUNTIME .. "/modules/ui/overlay");
local Padding = require(CRYSTAL_RUNTIME .. "/modules/ui/padding");
local RoundedCorners = require(CRYSTAL_RUNTIME .. "/modules/ui/rounded_corners");
local Painter = require(CRYSTAL_RUNTIME .. "/modules/ui/painter");
local Router = require(CRYSTAL_RUNTIME .. "/modules/ui/router");
local Switcher = require(CRYSTAL_RUNTIME .. "/modules/ui/switcher");
local Text = require(CRYSTAL_RUNTIME .. "/modules/ui/text");
local UIElement = require(CRYSTAL_RUNTIME .. "/modules/ui/ui_element");
local Widget = require(CRYSTAL_RUNTIME .. "/modules/ui/widget");
local Wrapper = require(CRYSTAL_RUNTIME .. "/modules/ui/wrapper");

---@alias Axis "horizontal" | "vertical"
---@alias Direction "up" | "down" | "left" | "right"
---@alias HorizontalAlignment "left" | "center" | "right" | "stretch"
---@alias VerticalAlignment "top" | "center" | "bottom" | "stretch"

local fonts = {};

local router = Router:new();
UIElement.router = router;

return {
	module_api = {
		register_font = function(name, font)
			assert(not name:starts_with("crystal"));
			assert(type(name) == "string");
			assert(font:typeOf("Font"));
			fonts[name] = font;
		end,
		font = function(name)
			assert(fonts[name]);
			return fonts[name];
		end,
	},
	global_api = {
		BasicJoint = BasicJoint,
		Border = Border,
		Container = Container,
		HorizontalList = List.Horizontal,
		HorizontalListJoint = List.HorizontalJoint,
		Image = Image,
		Joint = Joint,
		ListJoint = List.Joint,
		Overlay = Overlay,
		Padding = Padding,
		Painter = Painter,
		RoundedCorners = RoundedCorners,
		Switcher = Switcher,
		Text = Text,
		UIElement = UIElement,
		VerticalList = List.Vertical,
		VerticalListJoint = List.VerticalJoint,
		Widget = Widget,
		Wrapper = Wrapper,
	},
	start = function()
		local built_in_fonts = {
			crystal_regular = CRYSTAL_RUNTIME .. "/assets/source_code_pro_medium.otf",
			crystal_bold = CRYSTAL_RUNTIME .. "/assets/source_code_pro_bold.otf",
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
	test_harness = function()
		router:reset();
	end,
};
