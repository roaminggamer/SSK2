-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Player Factory
-- =============================================================
local common 	= require "scripts.common"
local myCC 		= require "scripts.myCC"
local physics 	= require "physics"
local camera 	= require "scripts.camera"

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

local movep = ssk.actions.movep

-- =============================================================
-- Locals
-- =============================================================
local initialized = false
local firstMount = true

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
	params = params

	firstMount = true

	local radius = params.radius
	radius = (radius) or (params.size) and params.size/2 or 20

	-- Create player
	local player = newImageRect( group, x, y, "images/misc/rg256.png",
		{	size = radius * 2 },
		{	radius = radius, 
			friction = 0,
			density = 1, bounce = 0,
			calculator = myCC, 
			colliderName = "player" } )

	player.mountRadius = params.mountRadius or radius
	
	--
	-- Track player's initial x/y-position
	--
	player.x0 = player.x	
	player.y0 = player.y

	--
	-- Add 'enterFrame' listener to player to:
	--
	-- 1. Dampen vertical velocity, using actions library.
	-- 2. Maintain forward velocity.
	-- 3. Count distance progress.
	--
	player.enterFrame = function( self )
		--movep.dampVert( self, { damping = 2 } )
	end; listen("enterFrame",player)

	--
	-- Add One Touch Listener
	--
	-- EFM try alternate gravity scheme - mario-esque
	--
	player.onOneTouch = function( self, event )

		if(self.isJumping) then return false end
		if(self.applyLinearImpulse == nil) then return false end
		if( autoIgnore( "onOneTouch", self ) ) then return false end

		if( event.phase == "began" ) then 

			self:removeEventListener( "preCollision", self )

			self.isJumping = true

			display.remove( self.joint )				
			self.joint = nil

			self.timer = function() 
				local vec = angle2Vector( self.rotation, true )
				vec = scaleVec( vec, common.playerImpulse * self.mass )
				self:applyLinearImpulse( vec.x, vec.y, self.x, self.y )
				--self.rotation = 0

				post("onSFX", { sfx = "jump" } )

				self.timer = function()
					self:addEventListener( "preCollision", self )
				end
				timer.performWithDelay( 1, self )
			end
			timer.performWithDelay( 1, self )

		end
		return true
	end; listen( "onOneTouch", player )


	--
	--
	--
	player.mountToGear = function( self, gear )
		--
		self.camera:update()

		-- Do some math magic to figure out where the player is relative to the
		-- gear, and to then mount it near that point.
		--
		local tweenX, tweenY = diffVec( gear.x, gear.y, self.x, self.y )
		local angle = vector2Angle( tweenX, tweenY )
		
		local mountPointX, mountPointY = normVec( tweenX, tweenY )
		local dist = self.mountRadius + gear.mountRadius + common.mountOffset
		mountPointX, mountPointY = scaleVec( mountPointX,  mountPointY, dist ) 
			
		mountPointX, mountPointY = addVec( gear.x, gear.y, mountPointX, mountPointY )

		self.rotation = angle
		self.x = mountPointX
		self.y = mountPointY
		self.joint = physics.newJoint( "weld", self, gear, self.x, self.y )

		-- Clear the isJumping flag so that jumps can occur
		--
		self.isJumping = false

		-- Is this the first mount?  If so, initialize the player height counter.
		if( firstMount ) then
			firstMount = false
			self.startY = self.y
		end

	end


	--
	-- Add Collision Listener 
	--
	player.preCollision = function( self, event )
		local other   = event.other
		if( other.colliderName == "platform" ) then
			self:removeEventListener( "preCollision" )
			nextFrame( function() if( self.mountToGear) then self:mountToGear( other ) end end )			
		end
	end; player:addEventListener( "preCollision" )


	--
	-- Add Collision Listener 
	--
	player.collision = function( self, event )
		if( event.phase ~= "began" ) then return false end
		local other = event.other

		--[[
		if( other.colliderName == "coin" ) then
			display.remove( other )
			common.coins = common.coins + 1
			post("onSound", { sound = "coin" } )
		end

		if( other.colliderName == "gate" ) then
			display.remove( other )
			common.score = common.score + 1
			post("onSound", { sound = "gate" } )
		end

		if( other.colliderName == "wall" ) then
			self:stopCamera()
			display.remove( self )
			post("onDied" )
			post("onSound", { sound = "died" } )
		end
		--]]

		return false
	end; player:addEventListener( "collision" )

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	--ssk.camera.tracking( player, params.world, { lockY = true } )
	--ssk.camera.tracking( player, params.world )

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onOneTouch", "enterFrame" }, self )
		if( self.camera ) then
			display.remove(self.camera)
			self.camera = nil
		end
	end; player:addEventListener( "finalize" )

	--player:setLinearVelocity( common.playerVelocity, 0 )	

	player.camera = camera.new( player, params.world, { style = "omni"} )

	player.camera:start()

	return player
end

return factory