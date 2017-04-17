-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Generic Counter HUD
-- =============================================================
local common 	= require "scripts.common"

-- =============================================================
-- Localizations
-- =============================================================
-- Commonly used Lua Functions
local getTimer          = system.getTimer
local mRand					= math.random
--
-- Common SSK Display Object Builders
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
--
-- Common SSK Helper Modules
local easyIFC = ssk.easyIFC;local persist = ssk.persist
--
-- Common SSK Helper Functions
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = math.normRot;local easyAlert = ssk.misc.easyAlert

-- =============================================================
-- Locals
-- =============================================================
local initialized = false

-- =============================================================
-- Forward Declarations
-- =============================================================

-- =============================================================
-- Factory Module Begins
-- =============================================================
local factory = {}

-- ==
--    init() - One-time initialization only.
-- ==
function factory.init( params )
	if(initialized) then return end
	initialized = true
end

-- ==
--    reset() - Reset any per-game logic/settings.
-- ==
function factory.reset( params )
end

-- ==
--    new() - Create new instance(s) of this factory's object(s).
-- ==
function factory.new( group, x, y, params )
	params = params or {}

	--
	-- Label
	--
	local hud = easyIFC:quickLabel( group, common.count, x, y, 
		                             params.font or ssk.gameFont,
		                             params.fontSize or 48,
		                             params.color or _W_ )
	hud.lastCount = common.count

	-- 
	-- Update count text every frame 
	--
	function hud.enterFrame( self )
		--
		-- Skip if no change since last frame
		--
		if( hud.lastCount == common.count) then return end
		
		-- 
		-- Update the count text
		--
		self.text = tostring(common.count)

		--
		-- Track new count
		--
		self.lastCount = common.count

	end; listen( "enterFrame", hud )

	--
	-- Attach a finalize event to the hud so it cleans it self up
	-- when removed.
	--	
	hud.finalize = function( self )
		ignoreList( { "enterFrame" }, self )
	end; hud:addEventListener( "finalize" )

	return hud
end

return factory