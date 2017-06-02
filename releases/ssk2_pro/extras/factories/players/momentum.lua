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

local movep = ssk.actions.movep

-- =============================================================
-- Locals
-- =============================================================
local initialized = false
local isInvulnerable = false
local camera = "horiz"
local isInteractive = true

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
	camera = params.camera or "horiz"
	isInteractive = fnn(params.isInteractive, isInteractive)
	initialized = true
	isInvulnerable = fnn( params.invulnerable, isInvulnerable )
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
	local myColor = common.colors[mRand(1,4)]
	local player = newImageRect( group, x, y, "images/misc/circle.png",
		{ 	w = 40, h = 40, alpha = 1, fill = myColor, 
		   isVisible = isInteractive,
		   thrustMag = 100 }, 
		{	isFixedRotation = true, radius = 18, linearDamping = 2,
			calculator = myCC, colliderName = (isInteractive) and "player" or "altPlayer"} )
	
	--
	-- Track player's initial x-position
	--
	player.x0 = player.x	


	--
	-- Set player as initially not thrusting
	-- 
	player.thrust = 0

	--
	-- Add 'enterFrame' listener to player to:
	--
	-- 1. Dampen vertical velocity, using actions library.
	-- 2. Maintain forward velocity.
	-- 3. Count distance progress.
	--
	player.enterFrame = function( self )
		

		if( self.thrust ~= 0 ) then
			self:applyForce( self.thrust * self.mass * self.thrustMag, 0, self.x, self.y )
		end


		-- Maintain forward velocity
		--
		local vx, vy = self:getLinearVelocity()
		if( camera == "horiz" ) then			
			self:setLinearVelocity( common.playerVelocity, vy )
		else
			self:setLinearVelocity( vx, -common.playerVelocity )
		end

		--
		-- Update distance counter if we are tracking distance
		--
		local dx = self.x - self.x0
		common.distance = mFloor( dx/common.pixelsToDistance )

	end; listen("enterFrame",player)

	--
	-- Add Two Touch Listeners
	--
	player.onTwoTouchLeft = function( self, event )
		if( event.phase == "began" ) then 
			self.thrust = self.thrust - 1
		elseif( event.phase == "ended" ) then 
		self.thrust = self.thrust + 1
		end
		return true
	end; listen( "onTwoTouchLeft", player )

	player.onTwoTouchRight = function( self, event )
		if( event.phase == "began" ) then 
			self.thrust = self.thrust + 1
		elseif( event.phase == "ended" ) then 
		self.thrust = self.thrust - 1
		end
		return true
	end; listen( "onTwoTouchRight", player )

	--
	-- Add Collision Listener 
	--
	player.collision = function( self, event )

		--
		-- Localize other to make typing easier/faster
		--
		local other = event.other

		if( event.phase == "began" ) then 

			--
			-- If it is a wall,
			--
			-- 1. Stop the Camera.
			-- 2. Destroy the player.
			-- 3. Dipatch a sound event to play coin sound (if it was set up)
			-- 4. Dispatch a 'player died' event.
			--
			if( other.colliderName == "wall" and not isInvulnerable ) then
				self:stopCamera()
				display.remove( self )
				post("onDied" )
				post("onSound", { sound = "died" } )
				return
			end

		elseif( event.phase == "ended" ) then

		end

		return false
	end; player:addEventListener( "collision" )

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	if( camera == "horiz" ) then
		ssk.camera.tracking( player, params.world, { lockY = true } )		
	else
		ssk.camera.tracking( player, params.world, { lockX = true } )		
	end

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onTwoTouchLeft", "onTwoTouchRight", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )

	if( camera == "horiz" ) then
		player:setLinearVelocity( common.playerVelocity, 0 )	
	else
		player:setLinearVelocity( 0, -common.playerVelocity )	
	end


	return player
end

return factory