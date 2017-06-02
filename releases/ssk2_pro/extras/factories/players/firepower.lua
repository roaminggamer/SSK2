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


local face = ssk.actions.face
local movep = ssk.actions.movep

-- =============================================================
-- Locals
-- =============================================================
local initialized = false

local debugEn 				= true

local cameraStyle = "horiz"
local enableWrapping
local wrapRect

local moveRate 			= 400
local faceRate 			= 180
local firePeriod 			= 250
local bulletSpeed 		= 500

-- =============================================================
-- Forward Declarations
-- =============================================================
local setDifficulty
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

	cameraStyle = params.camera or "horiz"

	enableWrapping = fnn(params.enableWrapping, false)


	initialized = true
end

-- ==
--    reset() - Reset any per-game logic/settings.
-- ==
function factory.reset( params )
	--setDifficulty(1)
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
		   moving = false,
		   moveDeclineFactor  = 0.95,		   		   
		   moveRate = 0,
		   minRate = 100,
		   faceRate  = 0,
		   firing = false, 
		   fireAngle = 0,
		   faceAngle = 0 }, 
		{	isFixedRotation = false, radius = 18, gravityScale = 0,
		   density = 1, --linearDamping = 2, 
			calculator = myCC, colliderName = "player" } )




	function player.collision( self, event ) 
		local other = event.other
		local phase = event.phase
		local isPlatform = (event.other.colliderName == "platform")

		--[[
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
		--]]
	end; player:addEventListener( "collision" )

	-- Two-touch handlers
	player.onLeftJoystick = function( self, event )
		if( isDestroyed == true or isRunning == false ) then ignore( "onLeftJoystick", self ); return; end
		if( event.phase == "moved" ) then
			self.faceAngle = event.angle
		end

		if( event.state == "on" ) then
			self.moving = true
			self.moveRate = moveRate * event.percent/100
		else
			self.moving = false
		end
		return true
	end
	listen( "onLeftJoystick", player )

	player.onRightJoystick = function( self, event )
		if( isDestroyed == true or isRunning == false ) then ignore( "onRightJoystick", self ); return; end

		if( event.state == "on" ) then
			self.firing = true
			self.fireAngle = event.angle
		else
			self.firing = false
		end
		return true
	end
	listen( "onRightJoystick", player )

	-- enterFrame code to handler turning and trail drawing calls
	--
	player.enterFrame = function( self, event )		
		if( isDestroyed == true or isRunning == false ) then ignore( "enterFrame", self ); return; end

		--local ds = ssk.getDT()/1000
		face( self, { angle = self.faceAngle or self.rotation, rate = faceRate })

		local rate = self.moveRate

		if( not self.moving ) then			
			self.moveRate = self.moveRate * self.moveDeclineFactor 
			self.moveRate = (self.moveRate < self.minRate ) and 0 or self.moveRate
		end

		movep.forward( self, { rate = self.moveRate })
		--print( self.moveRate )
		if( self.firing ) then
			self:fire()
		end


		if( wrapRect ) then
			ssk.actions.scene.rectWrap( self, wrapRect )
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

		local bullet = newCircle( self.parent, self.x, self.y, 
			                     	{ size = self.contentWidth/2 },
			                     	{ calculator = myCC, colliderName = "bullet" }  )
		local vec = angle2Vector( self.fireAngle, true )
		vec = scaleVec( vec, bulletSpeed )
		bullet:setLinearVelocity( vec.x, vec.y )
		transition.to( bullet, { delay = bulletTime, onComplete = display.remove } )
	end

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	if( cameraStyle == "none" ) then
		-- Nothing
	elseif( cameraStyle == "horiz" ) then
		ssk.camera.tracking( player, params.world, { lockY = true } )		
	
	elseif( cameraStyle == "vert" ) then
		ssk.camera.tracking( player, params.world, { lockX = true } )		

	elseif( cameraStyle == "omni" ) then
		ssk.camera.tracking( player, params.world )		
	end

	--
	-- Create wrapping rect?
	--	
	if( cameraStyle == "asteroids" or enableWrapping ) then
		wrapRect = newImageRect( group, centerX, centerY, "ssk2/fillT.png", { w = fullw + (params.size or 40), h = fullh + (params.size or 40)} )
	end

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onRightJoystick", "onLeftJoystick", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )


	return player
end


return factory