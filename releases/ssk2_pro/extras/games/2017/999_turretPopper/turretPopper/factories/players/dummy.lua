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
local moves = "horiz"
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
	moves = params.moves or "horiz"
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
		{ 	w = 40, h = 40, alpha = 1, myColor = myColor, fill = myColor, isVisible = isInteractive }, 
		{	isFixedRotation = true, radius = 18, 
			calculator = myCC, colliderName = (isInteractive) and "player" or "altPlayer"} )
	
	--
	-- Track player's initial x-position
	--
	player.x0 = player.x	

	--
	-- Add 'enterFrame' listener to player to:
	--
	-- 1. Dampen vertical velocity, using actions library.
	-- 2. Maintain forward velocity.
	-- 3. Count distance progress.
	--
	player.enterFrame = function( self )
		
		--
		-- Dampen vertical velocity, using actions library.
		--
		--movep.dampVert( self, { damping = 2 } )

		--
		-- Maintain forward velocity
		--
		local vx, vy = self:getLinearVelocity()
		if( moves == "horiz" ) then			
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
	-- Add One Touch Listener
	--
	player.onOneTouch = function( self, event )
		if( event.phase == "began" ) then 

			--
			-- Apply impulse to player on each touch
			--
			--self:applyLinearImpulse( 0, -common.playerImpulse * self.mass, self.x, self.y )

		end
		return true
	end; listen( "onOneTouch", player )

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

			--table.dump(event)
			--table.dump(event.other)

			--
			-- If it is a gate,
			--
			-- 1. Add 1 to our score count if this is the right color gate
			--
			if( other.colliderName == "gate" ) then
				if( self.myColor == other.myColor ) then
					common.score = common.score + 1
					post("onSound", { sound = "gate" } )
					local color = table.getRandom( common.colors )
					self.myColor = color
					self:setFillColor( unpack(color) )
				end
			end

		end

		return false
	end; player:addEventListener( "collision" )

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	if( moves == "horiz" ) then
		ssk.camera.tracking( player, params.world, { lockY = true } )		
	else
		ssk.camera.tracking( player, params.world, { lockX = true } )		
	end

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onOneTouch", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )

	if( moves == "horiz" ) then
		player:setLinearVelocity( common.playerVelocity, 0 )	
	else
		player:setLinearVelocity( 0, -common.playerVelocity )	
	end


	return player
end

return factory