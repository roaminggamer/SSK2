-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Hallway Segment Factory
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
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert

-- =============================================================
-- Locals
-- =============================================================
local initialized 		= false
local lastX
local lastY

local segmentType		 	= "horiz"

local count 				= 1
local hasCeiling 			= false
local hasFloor 			= false
local ceilingPosition	= 0
local floorPosition		= 0

local hasLeftWall 		= false
local hasRightWall 		= false
local leftWallPosition	= 0
local rightWallPosition	= 0
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

	segmentType = params.segmentType or segmentType

	--
	-- Initialize 'Ceiling, Floor, and Wall' settings.
	--
	hasCeiling 			= params.ceilingPosition ~= nil
	hasFloor 			= params.floorPosition ~= nil
	ceilingPosition	= params.ceilingPosition or top
	floorPosition		= params.floorPosition or bottom

	hasLeftWall 		= params.leftWallPosition ~= nil
	hasRightWall 		= params.rightWallPosition ~= nil
	leftWallPosition	= params.leftWallPosition or left
	rightWallPosition	= params.rightWallPosition or right

	purgeDistMult 		= params.purgeDistMult or purgeDistMult

	initialized = true
end

-- ==
--    reset() - Reset any per-game logic/settings.
-- ==
function factory.reset( params )
	lastX 	= nil
	lastY 	= nil
	count 	= 1
end

-- ==
--    new() - Create new instance(s) of this factory's object(s).
-- ==
function factory.new( group, x, y, params )
	params = params or { preTrigger = false, debugEn = false }

	-- Catch case where we enter, but group was just removed
	--
	if( not isValid( group ) ) then return end

	--
	-- Calculate next x if needed.
	--
	if( segmentType == "horiz" ) then
		x = x or lastX + params.segmentWidth or w/4		
	else
		y = y or lastY - params.segmentHeight or h/4		
	end

	--
	-- Create a group to represent this segment and insert all parts to it.
	--
	local segment = display.newGroup()
	group:insert( segment )

	--
	-- Set flag for later use in logic below
	--
	segment.isHSegment = ( segmentType == "horiz" )

	--
	-- Custom 'collision' listener to throw event 'onSegmentTriggered', and
	-- to create next segment.
	--
	local function onCollision ( self, event )
		if( event.phase == "began" ) then
			if( self.isTriggered ) then return true end
			self.isTriggered = true
			self:setFillColor(unpack(_C_))
			if( segmentType == "horiz" ) then
				nextFrame( function() factory.new( group, nil, self.y, params ) end )
			else
				nextFrame( function() factory.new( group, self.x, nil, params ) end )
			end
			post( "onSegmentTriggered",{ x = self.x, y = self.y,
				                          segmentWidth = params.segmentWidth, 
				                          segmentHeight = params.segmentHeight }  )
		end
		return true
	end

	-- 
	-- Create a ceiling, floor, walls, and segment trigger
	--
	segment.trigger = newRect( segment, x, y,
		{ w = params.segmentWidth or fullw, h = params.segmentHeight or fullh, fill = _Y_, 
		  alpha = (params.debugEn) and 0.05 or 0, stroke = _Y_, 
		  collision = onCollision, isTriggered = params.preTrigger }, 		
		{ bodyType = "static", bounce = 0, friction = 0, isSensor = true ,
		  calculator = myCC, colliderName = "trigger" } )

	--
	-- Add Label (if debuEn == true)
	--
	if( params.debugEn ) then
		segment.label = easyIFC:quickLabel( segment, count, x, y, ssk.gameFont(), 48 )
		segment.label.alpha = 0.5
		--segment.label = display.newText( segment, count, x, y,ssk.gameFont(), 48 )
	end

	-- 
	-- Create bottom and top wall segments
	--
	if( hasCeiling ) then
		--print("a")
		local tmp = newRect( segment, x, ceilingPosition,
			{ w = params.segmentWidth, h = 40, fill = _G_, 
			  alpha = 1, anchorY = 1, }, 
			{ bodyType = "static", bounce = 0, friction = 0, 
			  calculator = myCC, colliderName = "wall" } )		
	end

	if( hasFloor ) then
		--print("b")
		local tmp = newRect( segment, x, floorPosition,
			{ w = params.segmentWidth, h = 40, fill = _G_, 
			  alpha = 1, anchorY = 0, }, 
			{ bodyType = "static", bounce = 0, friction = 0, 
			  calculator = myCC, colliderName = "wall" } )		
	end

	if( hasLeftWall ) then
		--print("c")
		local tmp = newRect( segment, leftWallPosition, y,
			{ h = params.segmentHeight, w = 40, fill = _G_, 
			  alpha = 1, anchorX = 1, }, 
			{ bodyType = "static", bounce = 0, friction = 0, 
			  calculator = myCC, colliderName = "wall" } )		
	end

	if( hasRightWall ) then
		--print("d")
		local tmp = newRect( segment, rightWallPosition, y,
			{ h = params.segmentHeight, w = 40, fill = _G_, 
			  alpha = 1, anchorX = 0, }, 
			{ bodyType = "static", bounce = 0, friction = 0, 
			  calculator = myCC, colliderName = "wall" } )		
	end


	--
	-- Dispatch a Created Trigger event for other game logic
	--
	post( "onNewSegment", { x = x, y = y, count = count, segment = segment  }  )	

	--
	-- Attach shared 'onSegmentTriggered' listener to this segment.
	--	
	segment.onSegmentTriggered = onSegmentTriggered
	listen( "onSegmentTriggered", segment )

	--
	-- Attach a finalize event to the segment so it cleans it self up
	-- when removed.
	--	
	segment.finalize = function( self )	
		ignoreList( { "onSegmentTriggered" }, self )
		display.remove(self.label)
	end; segment:addEventListener( "finalize" )

	--
	-- Handle the 'preTriggered' special case
	--
	if( segment.trigger.isTriggered == true ) then
		segment.trigger:setFillColor(unpack(_C_))
		segment.trigger:removeEventListener("collision")
	end

	--
	-- Increment Count
	--
	count = count + 1

	--
	-- Track lastX and lastY
	--
	lastX = x
	lastY = y
	--print( count, y, lastY, segmentType, params.segmentWidth, params.segmentHeight)
	--print( count, x, lastX, segmentType, params.segmentWidth, params.segmentHeight)

end

-- =============================================================
-- Local Function Definitions
-- =============================================================

--
-- Shared 'onSegmentTriggered' listener - Cleans up segments that are 
-- 	well offscreen automatically.
--
onSegmentTriggered = function( self, event )	
	-- Uncomment following to check for a 'purge' leak.
	--print( self.parent.numChildren )
	--print( display.currentStage.numChildren )
	if( self.isHSegment ) then
		local dx = mAbs( self.trigger.x - event.x )
		if( dx > fullw * purgeDistMult) then
			display.remove( self )
		end
	else
		local dy = mAbs( self.trigger.y - event.y )
		if( dy > fullh *purgeDistMult ) then
			display.remove( self )
		end
	end		
end

return factory