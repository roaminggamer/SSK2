-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Player Factory
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
local mFloor				= math.floor
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

local segmentSegmentIntersect = ssk.math2d.segmentSegmentIntersect
local movep = ssk.actions.movep

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
	params = params or { }

	-- Create player 
	local player = newImageRect( group, x, y, "images/misc/ringR.png",
		{ 	w = common.playerWidth, h = common.playerHeight }, {	isFixedRotation = true,
			calculator = myCC, colliderName = "player"} )

	player.leftPiece = newImageRect( params.world, x, y, "images/misc/ringL.png",
		{	w = common.playerWidth, h = common.playerHeight })
	player.leftPiece:toBack()


	--
	-- Track player's initial x-position
	--
	player.x0 = player.x	

	--
	-- Add 'enterFrame' listener to player to:
	--
	-- 1. Calculate if a line collision occured.
	-- 2. Dampen vertical velocity, using actions library.
	-- 3. Maintain forward velocity.
	-- 4. Count distance progress.
	--
	player.enterFrame = function( self )

		-- 
		-- Calculate for a line collision
		-- 
		local gameOver = false

		-- A. Find the track segment we are over
		--
		local segment = {}
		local tp1
		local tp2
		local i = 1
		while( not tp1 and i <= #params.trackPoints ) do
			local point = params.trackPoints[i]
			if( point.x >= self.x ) then
				tp1 = params.trackPoints[i-1] 
				tp2 = params.trackPoints[i] 
			end
			i = i + 1
		end
		-- Draw segment if debug enabled
		if( params.debugEn == true ) then
			display.remove( self.curTrackSegment )
			self.curTrackSegment = display.newLine( self.parent, tp1.x, tp1.y, tp2.x, tp2.y )
			self.curTrackSegment.strokeWidth = 4
			self.curTrackSegment:toBack()
		end

		-- B. Cacluate an intersect with that track segment
		--
		local px = self.x
		local py1 = self.y - self.contentHeight/2
		local py2 = self.y + self.contentHeight/2
		local intersect = segmentSegmentIntersect( px, py1, px, py2, 
			                                                   tp1.x, tp1.y, tp2.x, tp2.y )
		-- Draw intersect if debug enabled
		if( params.debugEn == true ) then
			display.remove( self.intersectMarker )
			if( intersect ) then
				self.intersectMarker = newCircle( self.parent, intersect.x, intersect.y, { radius = 8, fill = _P_ } )
				self.intersectMarker:toBack()
				self.curTrackSegment:toBack()
			end
		end

		-- C. If there was no intersection, we are completely off the track!
		--
		if( not intersect ) then
			if( params.debugEn == true ) then
				self:setFillColor(unpack(_R_))
			end

			gameOver = true

		else

			-- D. If there was an intersect, check to see if it is too close to the edge of the ring
			--
			local centerDist = mAbs(self.y - intersect.y)

			if( centerDist > self.contentHeight/2 - common.playerCollisionOffset ) then
				-- Too close
				if( params.debugEn == true ) then
					self:setFillColor(unpack(_R_))
				end

				gameOver = true
			
			else
				-- Still safe
				if( params.debugEn == true ) then
				self:setFillColor(unpack(_W_))
				end
			end
		end

		-- E. Game Over?  
		--
		if( gameOver ) then
			ignore( "enterFrame", self )
			self:stopCamera()
			post("onDied" )
			post("onSound", { sound = "died" } )
		end

		--
		-- Dampen vertical velocity, using actions library.
		--
		movep.dampVert( self, { damping = 2 } )

		--
		-- Maintain forward velocity
		--
		local vx, vy = self:getLinearVelocity()
		self:setLinearVelocity( common.playerVelocity, vy )

		--
		-- Update distance counter if we are tracking distance
		--
		local dx = self.x - self.x0
		common.distance = mFloor( dx/common.pixelsToDistance )

		-- 
		-- Make sure left piece follows right piece
		--
		self.leftPiece.x = self.x
		self.leftPiece.y = self.y


	end; listen("enterFrame",player)

	--
	-- Add One Touch Listener
	--
	player.onOneTouch = function( self, event )
		if( event.phase == "began" ) then 

			--
			-- Apply impulse to player on each touch
			--
			self:applyLinearImpulse( 0, -common.playerImpulse * self.mass, self.x, self.y )

		end
		return true
	end; listen( "onOneTouch", player )

	--
	-- Add Collision Listener 
	--
	player.collision = function( self, event )
		--
		-- Ignore all phases except 'began'
		--
		if( event.phase ~= "began" ) then return false end

		--
		-- Localize other to make typing easier/faster
		--
		local other = event.other

		--
		-- If it is a coin,
		--
		-- 1. Remove the coin.
		-- 2. Add 1 to our coin count
		-- 3. Dipatch a sound event to play coin sound (if it was set up)
		--
		if( other.colliderName == "coin" ) then
			display.remove( other )
			common.coins = common.coins + 1
			post("onSound", { sound = "coin" } )
		end

		return false
	end; player:addEventListener( "collision" )

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	ssk.camera.tracking( player, params.world, { lockY = true } )		

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onOneTouch", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )

	player:setLinearVelocity( common.playerVelocity, 0 )	

	return player
end

return factory