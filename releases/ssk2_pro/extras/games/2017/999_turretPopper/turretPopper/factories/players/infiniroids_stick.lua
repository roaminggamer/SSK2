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

local debugEn 				= true

local thrustBase 			= 1

local bulletSpeed 		= 500
local bulletTime			= 1000
local firePeriod			= 100

local faceRate 			= 360

-- =============================================================
-- Forward Declarations
-- =============================================================
local bulletEnterFrame
local bulletFinalize

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

	thrustBase 	= fnn( params.thrustBase, thrustBase )
	faceRate 	= params.faceRate or faceRate
	bulletSpeed = params.bulletSpeed or bulletSpeed
	bulletTime 	= params.bulletTime or bulletTime
	firePeriod 	= params.firePeriod or firePeriod

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
	local player = newImageRect( group, x, y, "images/misc/arrow.png",
		{ 	w = params.size or 40, h = params.size or 40, alpha = 1, 
		   myColor = myColor, fill = common.colors.green, 
		   dA = 0,
		   thrustPercent = 0,
		   firing = false, 
		   faceAngle = 0 }, 
		{	isFixedRotation = false, 
			radius = 18, gravityScale = 0,
		   density = 1, linearDamping = 1, 
			calculator = myCC, colliderName = "player" } )


	function player.collision( self, event ) 
		local other = event.other
		local phase = event.phase
		local isPlatform = (event.other.colliderName == "platform")

		if( phase == "began" ) then

			if( other.colliderName == "coin" ) then
				display.remove( other )
				common.coins = common.coins + 1
				post("onSound", { sound = "coin" } )
			end

			if( other.colliderName == "wall" ) then
				self:stopCamera()
				display.remove( self )
				post("onDied" )
				post("onSound", { sound = "died" } )
				return
			end

			if( other.colliderName == "danger" ) then
				self:stopCamera()
				display.remove( self )
				post("onDied" )
				post("onSound", { sound = "died" } )
				return
			end

		elseif( phase == "ended" ) then
		end
	end; player:addEventListener( "collision" )

	-- Two-touch handlers
	player.onJoystick = function( self, event )
		if( isDestroyed == true or isRunning == false ) then ignore( "onJoystick", self ); return; end
		self.firing = (event.phase ~= "ended")
		if( event.phase == "moved" ) then
			self.faceAngle = event.angle
		end
		self.thrustPercent = event.percent
		return true
	end; listen( "onJoystick", player )

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	common.wrapRect = newImageRect( group, centerX, centerY, "ssk2/fillT.png", { w = fullw + (params.size or 40), h = fullh + (params.size or 40)} )




	-- enterFrame code to handler turning and trail drawing calls
	--
	player.enterFrame = function( self )		
		local dt = ssk.getDT()/1000

		-- Turn
		ssk.actions.face( self, { angle = self.faceAngle or self.rotation, rate = faceRate })
		--ssk.actions.face( self, { angle = self.faceAngle or self.rotation })

		-- Move
		local mag = thrustBase * self.thrustPercent/100
		if( mag > 0 ) then
			ssk.actions.movep.thrustForward( self, { rate = mag } )
		end

		ssk.actions.scene.rectWrap( self, common.wrapRect )

		if( self.firing ) then
			self:fire()
		end

		--self:drawTrail()
	end
	listen( "enterFrame", player )

	player.lastFireTime = getTimer()
	function player.fire( self )
		local curTime = getTimer()
		if( curTime - self.lastFireTime < firePeriod ) then
			return
		end
		
		self.lastFireTime = curTime

		local vx,vy = self:getLinearVelocity()

		local bullet = newCircle( self.parent, self.x, self.y, 
			                     	{ size = self.contentWidth/2 },
			                     	{ calculator = myCC, colliderName = "bullet" }  )
		local vec = angle2Vector( self.rotation, true )
		vec = scaleVec( vec, bulletSpeed )
		bullet:setLinearVelocity( vec.x + vx, vec.y + vy )
		transition.to( bullet, { delay = bulletTime, alpha = 0, time = 100, onComplete = display.remove } )
		bullet.enterFrame = bulletEnterFrame
		listen( "enterFrame", bullet )

		bullet.finalize = bulletFinalize
		bullet:addEventListener("finalize")
	end

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onJoystick", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )


	return player
end

-- enterFrame code to handler turning and trail drawing calls
--
bulletEnterFrame = function( self )			
	ssk.actions.scene.rectWrap( self, common.wrapRect )
end

bulletFinalize = function( self )
	ignoreList( { "enterFrame" }, self )
end



return factory