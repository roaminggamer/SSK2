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
--
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
	params = params

	local radius = params.radius
	radius = (radius) or (params.size) and params.size/2 or 20

	--
	-- Create a platform
	--
	local hanger  = newRect( group, x, y, 
		                     	{	size = 10, 
		                     	   fill = _DARKGREY_ },
		                        {	radius = radius, 
		                        	bodyType = "static", 
		                        	calculator = myCC, colliderName = "dummy"} )

	local platform = newImageRect( group, x, y, params.img or "images/misc/kenney2.png", 
		                     	{	size = radius * 2, 
		                     	   fill = params.fill },
		                        {	radius = radius, density = 1000,
		                        	bodyType = "dynamic", bounce = 0,
		                        	calculator = myCC, colliderName = "platform"} )
	platform.mountRadius = params.mountRadius or radius

	platform.mountJoint = physics.newJoint( "pivot", platform, hanger, platform.x, platform.y )
	--hanger:toFront()

	--
	--
	--
	platform.enterFrame = function( self )		
		local ds = ssk.getDT() / 1000 
		if( ds <= 0 ) then return end
		local rate = params.rotRate or -180		
		self.rotation = normRot( self.rotation + rate * ds )
		--movep.dampVert( self, { damping = 2 } )
	end; listen("enterFrame", platform)

	--
	-- Attach a finalize event to the platform so it cleans it self up
	-- when removed.
	--	
	platform.finalize = function( self )
		ignoreList( { "enterFrame" }, self )
	end; platform:addEventListener( "finalize" )

	return platform
end



return factory