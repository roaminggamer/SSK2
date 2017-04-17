-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Score HUD Factory
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
	params = params or {}	
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

	local timerVariable = params.timerVariable or "time"
	local timerStyle = params.timerStyle or 1

	local anchorX = params.anchorX or 0.5
	local anchorY = params.anchorY or 0.5

	--
	-- Label(s)
	--
	local hud
	hud = easyIFC:quickLabel( group, common[timerVariable], x, y, 
                             params.font or ssk.gameFont,
                             params.fontSize or 48,
                             params.color or _W_ )
	hud.anchorX = anchorX 
	hud.anchorY = anchorY
	hud.lastTime = common[timerVariable]

	hud.text = ssk.misc.secondsToTimer( common[timerVariable], timerStyle )	

	-- 
	-- Update score text every frame 
	--
	function hud.enterFrame( self )
		--
		-- Skip if no change since last frame
		--
		if( hud.lastTime == common[timerVariable]) then return end
		
		-- 
		-- Update the score text
		--
		self.text = ssk.misc.secondsToTimer( common[timerVariable], timerStyle )	

		--
		-- Track new score
		--
		self.lastTime = common[timerVariable]

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