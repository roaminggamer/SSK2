-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Distance HUD Factory
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
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert

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
	-- 'Units' Label + Label
	--
	local inLabel = easyIFC:quickLabel( group, common.distanceUnits, x, y, 
		                             		params.font or ssk.gameFont,
		                             		params.fontSize or 48,
		                             		params.color or _W_, 1 )

	
	local hud = easyIFC:quickLabel( group, round(common.distance), 
		                             inLabel.x - inLabel.contentWidth - 15, y, 
		                             params.font or ssk.gameFont,
		                             params.fontSize or 48,
		                             params.color or _W_, 1 )
	hud.lastDistance = common.distance
	hud.inLabel = inLabel

	-- 
	-- Update distance text every frame 
	--
	function hud.enterFrame( self )
		--
		-- Skip if no change since last frame
		--
		if(hud.lastDistance == common.distance) then return end
		
		-- 
		-- Update the distance text
		--
		self.text = tostring(round(common.distance))

		--
		-- Track new distance
		--
		self.lastDistance = common.distance

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