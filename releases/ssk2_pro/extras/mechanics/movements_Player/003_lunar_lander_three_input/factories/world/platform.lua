-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Platform
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
local mAbs					= math.abs
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
local purgeDistMult		= 3

-- =============================================================
-- Forward Declarations
-- =============================================================
local onSegmentTriggered 
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

	purgeDistMult 		= params.purgeDistMult or purgeDistMult

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
	params = params or { width = w/4, debugEn = false }

	-- Catch case where we enter, but group was just removed
	--
	if( not isValid( group ) ) then return end

	--
	-- Ensure there is a params value 'segmentWidth'
	--
	params.width = params.width or w/4
	
	--
	-- Create a platform
	--
	local platform = newImageRect( group, x, y, params.img or "images/misc/kenney_stone.png", 
		                     	{	w = params.width or 40, h = params.height or 40, 
		                     	   fill = params.fill },
		                        {	bodyType = "static", 
		                        	calculator = myCC, colliderName = "platform"} )


	--
	-- Attach shared 'onSegmentTriggered' listener to this platform.
	--	
	platform.onSegmentTriggered = onSegmentTriggered
	listen( "onSegmentTriggered", platform )

	--
	-- Attach a finalize event to the platform so it cleans it self up
	-- when removed.
	--	
	platform.finalize = function( self )
		ignoreList( { "onSegmentTriggered" }, self )
	end; platform:addEventListener( "finalize" )

	return platform
end

--
-- Shared 'onSegmentTriggered' listener - Cleans up platforms that are 
-- 	well offscreen automatically.
--
onSegmentTriggered = function( self, event )
	local dx = mAbs( self.x - event.x )
	local dy = mAbs( self.y - event.y )
	if( dx > fullw * purgeDistMult or dy > fullh * purgeDistMult ) then
		display.remove( self )
	end
end	


return factory