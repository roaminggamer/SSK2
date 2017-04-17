-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- asteroid: Generic Factory
-- =============================================================
local common 	= require "scripts.common"
local myCC 		= require "scripts.myCC"
local physics 	= require "physics"

-- =============================================================

-- =============================================================
-- Localizations
-- =============================================================
-- Commonly used Lua Functions
local getTimer          = system.getTimer
local mRand					= math.random
local mFloor				= math.floor
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

-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale

-- =============================================================
-- Locals
-- =============================================================
local initialized = false

-- =============================================================
-- Forward Declarations
-- =============================================================
local asteroidEnterFrame
local asteroidFinalize
local asteroidCollision

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
	params = params or { width = w/4, debugEn = false }

	-- Catch case where we enter, but group was just removed
	--
	if( not isValid( group ) ) then return end

	--
	-- Ensure there is a params value 'segmentWidth'
	--
	params.width = params.width or w/4
	
	--
	-- Create a asteroid
	--
	local size = params.size or 40
	local asteroid = newImageRect( group, x, y, "images/misc/circle.png", 
		                     	{	size = size, fill = _GREY_ },
		                        {	radius = size/2, bodyType = "dynamic", isSensor = true,
		                        	calculator = myCC, colliderName = "danger"} )

	asteroid.canWrapTime = getTimer() + (params.wrapDelay or 0)

	local vec = angle2Vector( params.initialAngle or 0, true)
	vec = scaleVec( vec, params.rate )
	asteroid:setLinearVelocity( vec.x, vec.y )


	asteroid.enterFrame = asteroidEnterFrame
	listen( "enterFrame", asteroid )

	asteroid.finalize = asteroidFinalize
	asteroid:addEventListener("finalize")

	asteroid.collision = asteroidCollision
	asteroid:addEventListener("collision")

	

	return asteroid
end

-- enterFrame code to handler turning and trail drawing calls
--
asteroidEnterFrame = function( self )			
	ssk.actions.scene.rectWrap( self, common.wrapRect )
end

asteroidFinalize = function( self )
	ignoreList( { "enterFrame" }, self )
end


asteroidCollision = function( self, event ) 
	local other = event.other
	local phase = event.phase

	if( phase == "began" ) then

		if( other.colliderName == "bullet" ) then
			display.remove( other )
			display.remove(self)
			--coin = coin + 1
			--post("onSound", { sound = "coin" } )
		end

	elseif( phase == "ended" ) then
	end
end

return factory