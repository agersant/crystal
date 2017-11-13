require( "src/utils/OOP" );
local Scene = require( "src/scene/Scene" );
local Damage = require( "src/ui/hud/damage/Damage" );
local Dialog = require( "src/ui/hud/Dialog" );

local HUD = Class( "HUD" );



-- IMPLEMENTATION

local onSceneChanged = function( self )
	self:init();
end


-- PUBLIC API

HUD.init = function( self )
	self._widgets = {};
	self._damage = Damage:new();
	table.insert( self._widgets, self._damage );
	self._dialog = Dialog:new();
	table.insert( self._widgets, self._dialog );
end

HUD.update = function( self, dt )
	local currentScene = Scene:getCurrent();
	if self._scene ~= currentScene then
		self._scene = currentScene;
		onSceneChanged( self );
	end
	for _, widget in ipairs( self._widgets ) do
		widget:update( dt );
	end
end

HUD.draw = function( self )
	for _, widget in ipairs( self._widgets ) do
		widget:draw();
	end
end

HUD.getDialog = function( self )
	return self._dialog;
end

HUD.showDamage = function( self, victim, amount )
	assert( victim );
	assert( amount );
	self._damage:show( victim, amount );
end



local instance = HUD:new();
return instance;
