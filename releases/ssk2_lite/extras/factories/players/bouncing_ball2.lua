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
local mAbs 					= math.abs 

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

local movep = ssk.actions.movep

-- =============================================================
-- Locals
-- =============================================================
local initialized 	= false

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
	local player = newImageRect( group, x, y, "images/misc/rg256.png",
		{ 	w = 40, h = 40, alpha = 1 }, 
		{	isFixedRotation = true, bounce = 0.8, radius = 20, 
		   linearDamping = 0, friction = 0,
			calculator = myCC, colliderName = "player"} )
	
	--
	-- Track player's initial x-position
	--
	player.x0 = player.x	

	--
	-- Add 'enterFrame' listener to player to:
	--
	-- 1. Maintain forward velocity.
	-- 2. Count distance progress.
	--
	player.enterFrame = function( self )

		--
		-- Maintain forward velocity
		--
		local vx, vy = self:getLinearVelocity()
		--self:setLinearVelocity( common.playerVelocity, vy )

		--
		-- Update distance counter if we are tracking distance
		--
		local dx = self.x - self.x0
		common.distance = mFloor( dx/common.pixelsToDistance )

	end; listen("enterFrame",player)

	--
	-- Add One Touch Listener
	--
	player.onOneTouch = function( self, event )
		if( event.phase == "began" ) then 

			--
			-- Fall faster
			--
			local vx, vy = self:getLinearVelocity()
			if( vy < 0 ) then vy = 0 end
			self:setLinearVelocity( vx, vy + common.extraDownVelocity )
			--self:applyLinearImpulse( 0, common.playerImpulse * self.mass, self.x, self.y )

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

		--
		-- If it is a platform,
		--
		-- 1. Remove the gate.
		-- 2. Add 1 to our score count
		--
		if( other.colliderName == "platform" ) then
			common.score = common.score + 1
			other:setFillColor(unpack(_O_))

			local onTop = self.y < other.y and 
			              mAbs(self.x - other.x) <= (self.contentWidth/2 + other.contentWidth/2)

			if( onTop ) then 
				post( "onSound", { sound = "gate" } )
			end


			nextFrame(
				function()
					if( not common.gameIsRunning ) then return end
					if( onTop ) then
						self:setLinearVelocity(0,0)
						local impulse = mRand( common.playerMinBounceImpulse * 100, 
							                    common.playerMaxBounceImpulse * 100)/100
						self:setLinearVelocity( common.playerVelocity, 0 )
						self:applyLinearImpulse( 0, -impulse * self.mass, self.x, self.y )
					end
				end )

			nextFrame(
				function()
					if( not common.gameIsRunning ) then return end
					transition.to( other, { y = other.y + fullh, time = 1500 } )
					transition.to( other.base, { y = other.base.y + fullh, time = 1500 } )
				end )
		end


		--
		-- If it is a wall,
		--
		-- 1. Stop the Camera.
		-- 2. Destroy the player.
		-- 3. Dipatch a sound event to play coin sound (if it was set up)
		-- 4. Dispatch a 'player died' event.
		--
		if( other.colliderName == "wall" ) then
			self:stopCamera()
			display.remove( self )
			post("onDied" )
			post("onSound", { sound = "died" } )
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