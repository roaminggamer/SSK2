-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Platform Factory
-- =============================================================
local common 	= require "scripts.common"
local myCC 		= require "scripts.myCC"
local physics 	= require "physics"

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
local initialized 	= false
local platformCount = 0

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
	platformCount = 0
end

-- ==
--    reset() - Reset any per-game logic/settings.
-- ==
function factory.reset( params )
	platformCount = 0
end

-- ==
--    new() - Create new instance(s) of this factory's object(s).
-- ==
function factory.new( group, x, y, params )
	params = params or {}

	local platY = y

		-- Allow platform-y to vary after 5th platform is created
	if( platformCount > 5 ) then
		platY = mRand( common.platformMaxY, common.platformMinY)
	end

	local platform = newRect( group, x, platY,
		{ w = params.width, h = 20, anchorY = 0, fill = _DARKGREY_ },
		{ bodyType = "static",
		  calculator = myCC, colliderName = "platform" }  )

	platform.base = newRect( group, x, platY,
		{ w = params.width, h = fullh, anchorY = 0 } )
	platform:toFront()

	platformCount = platformCount + 1

	return platform
end

return factory