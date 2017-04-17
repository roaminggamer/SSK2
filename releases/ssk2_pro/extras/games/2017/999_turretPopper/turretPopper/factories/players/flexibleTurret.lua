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
local aimOnOneTouch  = false
local fireOneOneTouchHold = false
local firePeriod = 300
local bulletVelocity = 400
local bulletLifetime = 5000


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

	aimOnOneTouch = fnn(params.aimOnOneTouch, aimOnOneTouch)
	fireOneOneTouchHold = fnn(params.fireOneOneTouchHold, fireOneOneTouchHold)
	
	firePeriod = params.firePeriod or firePeriod
	bulletVelocity = params.bulletVelocity or bulletVelocity
	bulletLifetime = params.bulletLifetime or bulletLifetime

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
	local player = newImageRect( group, x, y, "images/misc/dude.png",
		{ size = params.size or 40 , alpha = 1, curAmmo = "bullets", targetAngle = 0 }, 
		{ radius = 18,  calculator = myCC, colliderName = "player", bodyType = "static" } )


	--
	-- Rotate and Aim To Fire At Touch
	--
	if( aimOnOneTouch ) then
		function player.onOneTouch( self, event )
			if( event.phase == "ended" ) then
				local vec = diffVec( self, event )
				local angle = vector2Angle( vec )
				self.targetAngle = angle
			end
		end; listen( "onOneTouch", player )

		player.lastFireTime = -10000
		function player.fireBullet( self )
			local curTime = getTimer()
			local dt = curTime - self.lastFireTime
			if( dt >= firePeriod ) then
				print("BOOM")
				self.lastFireTime = curTime
				local vec = angle2Vector( self.rotation, true )	
				local vec2 = scaleVec( vec, self.width/2 )
				vec = scaleVec( vec, bulletVelocity )
				
				local bullet = newCircle( self.parent, self.x + vec2.x, self.y + vec2.y, 
													{ size = 8, fill = _Y_ }, 
													{ radius = 4,  calculator = myCC, colliderName = "bullet",
														bounce = 1 } )
				bullet.rotation = self.rotation
				bullet:setLinearVelocity(vec.x, vec.y)
				bullet.timer = display.remove
				timer.performWithDelay( bulletLifetime, bullet )

				self:toFront()
			end	
		end

		function player.enterFrame( self )
			ssk.actions.face( self, { angle = self.targetAngle, rate = 360 } )
			self:fireBullet()
		end; listen( "enterFrame", player )	

	--
	-- Fire if holding down oneTouch
	--
	elseif( fireOneOneTouchHold ) then
		function player.onOneTouch( self, event )
			player.isFiring = ( event.phase ~= "ended" )
		end; listen( "onOneTouch", player )

		player.lastFireTime = -10000
		function player.fireBullet( self )			
			local curTime = getTimer()
			local dt = curTime - self.lastFireTime
			if( dt >= firePeriod ) then
				print("BOOM")
				self.lastFireTime = curTime
				local vec = angle2Vector( self.rotation, true )	
				local vec2 = scaleVec( vec, self.width/2 )
				vec = scaleVec( vec, bulletVelocity )
				
				local bullet = newCircle( self.parent, self.x + vec2.x, self.y + vec2.y, 
													{ size = 8, fill = _Y_ }, 
													{ radius = 4,  calculator = myCC, colliderName = "bullet",
														bounce = 1 } )
				bullet.rotation = self.rotation
				bullet:setLinearVelocity(vec.x, vec.y)
				bullet.timer = display.remove
				timer.performWithDelay( bulletLifetime, bullet )

				self:toFront()
			end	
		end

		function player.enterFrame( self )
			if( self.isFiring ) then
				self:fireBullet()
			end
		end; listen( "enterFrame", player )	



	end
		

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onOneTouch", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )


	return player
end

return factory