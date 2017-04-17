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

local difficulty 			= 1

local diffMult 			= 1
local diffMult2 			= 1
local diffMult3 			= 1
local diffMult4			= 1

local rotRate_initial 	= 4 -- 150
local vBase_initial 		= 120 * 2
local vDelta_initial 	= 150 * 2
local vIncr_initial 		= 50 * 2
local vIncr2_initial 	= 150 * 2


local rotRate 				= rotRate_initial
local vBase 				= vBase_initial
local vDelta 				= vDelta_initial
local vIncr 				= vIncr_initial
local vIncr2 				= vIncr2_initial
local vMax 					= vBase
local vCur 					= vBase

-- =============================================================
-- Forward Declarations
-- =============================================================
local moves = "horiz"
local isInteractive = true
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
	moves = params.moves or "horiz"
	isInteractive = fnn(params.isInteractive, isInteractive)

	setDifficulty(1)

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
		{ 	w = 40, h = 40, alpha = 1, myColor = myColor, fill = common.colors.green, 
		  dA = 0 }, 
		{	isFixedRotation = false, radius = 18, gravityScale = 0,
		   density = 1, linearDamping = 1, 
			calculator = myCC, colliderName = "player" } )




	function player.collision( self, event ) 
		local other = event.other
		local phase = event.phase
		local isPlatform = (event.other.colliderName == "platform")

		if( phase == "began" ) then

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
				return
			end


			--
			-- If it is a danger,
			--
			-- 1. Stop the Camera.
			-- 2. Destroy the player.
			-- 3. Dipatch a sound event to play coin sound (if it was set up)
			-- 4. Dispatch a 'player died' event.
			--
			if( other.colliderName == "danger" ) then
				self:stopCamera()
				display.remove( self )
				post("onDied" )
				post("onSound", { sound = "died" } )
				return
			end
		elseif( phase == "ended" ) then

		end
	end
	player:addEventListener( "collision" )

	-- Two-touch handlers
	player.onTwoTouchLeft = function( self, event )
		if( isDestroyed == true or isRunning == false ) then ignore( "onTwoTouchLeft", self ); return; end
		if(event.phase == "began") then 
			self.dA = self.dA - rotRate
			if( self.dA < -rotRate ) then 
				self.dA = -rotRate
			end
			leftThrust = true
			self.leftInputActive = true

		elseif(event.phase == "ended") then 
			if( not self.leftInputActive ) then return true end
			self.leftInputActive = false
			self.dA = self.dA + rotRate
			if( self.dA > rotRate ) then 
				self.dA = rotRate
			end
			leftThrust = false
		end
		return true
	end
	listen( "onTwoTouchLeft", player )

	player.onTwoTouchRight = function( self, event )
		if( isDestroyed == true or isRunning == false ) then ignore( "onTwoTouchRight", self ); return; end
		if(event.phase == "began") then 
			self.dA = self.dA + rotRate
			if( self.dA > rotRate ) then 
				self.dA = rotRate
			end
			rightThrust = true
			self.rightInputActive = true

		elseif(event.phase == "ended") then 
			if( not self.rightInputActive ) then return true end
			self.rightInputActive = false
			self.dA = self.dA - rotRate
			if( self.dA < -rotRate ) then 
				self.dA = -rotRate
			end
			rightThrust = false
		end
		return true
	end
	listen( "onTwoTouchRight", player )

	player.onOneTouch = function( self, event )
	table.dump(event)
		if( event.phase == "began" ) then
			self.inputActive = true
			self.dA = 0
			self.lX = event.x
		elseif( event.phase == "ended" ) then
			self.inputActive = false
			self.dA = 0
		elseif( event.phase == "moved" ) then
			print(rotRate)
			local dx = event.x - self.lX 
			self.lX = event.x
			self.dA = self.dA + dx * rotRate
			
		end
		return false			

	end; listen( "onOneTouch", player)

	-- enterFrame code to handler turning and trail drawing calls
	--
	player.enterFrame = function( self, event )		
		if( isDestroyed == true or isRunning == false ) then ignore( "enterFrame", self ); return; end

		local dt = ssk.getDT()/1000

		----[[
		-- Turn
		local dA = self.dA * dt
		if(dA ~= 0) then
			self.rotation = self.rotation + dA
			if(self.rotation < 0) then self.rotation = self.rotation + 360 end
		end

		--]]

		-- Adjust vMax
		vMax = vBase		
		if(self.inputActive) then vMax = vMax + vDelta * 2 end

		--print(vBase,vMax)

		-- Get Current Velocity
		local vx,vy = self:getLinearVelocity()
		local mag = lenVec( vx, vy )

		-- Adjust vCur
		if(vCur < vMax ) then
			vCur = vCur + vIncr * dt
		elseif(vCur > vMax ) then
			vCur = vCur - vIncr2 * dt
		end

		-- Move
		local vec = angle2Vector( self.rotation, true )
		vec = scaleVec( vec, vCur )
		self:setLinearVelocity( vec.x, vec.y )

		--self:drawTrail()

	end
	listen( "enterFrame", player )

	--
	-- Start tracking the player with the camera (ignore movement in y-axis)
	--
	if( params.moves == "horiz" ) then
		ssk.camera.tracking( player, params.world, { lockY = true } )		
	else
		ssk.camera.tracking( player, params.world, { lockX = true } )		
	end

	--
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onTwoTouchRight", "onTwoTouchLeft", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )


	return player
end

setDifficulty = function( newDiff )
	difficulty  		= newDiff	
	diffMult 			= (1 + (difficulty-1)/15 )
	diffMult2 			= (1 + (difficulty-1)/10 )
	diffMult3 			= (1 + (difficulty-1)/5 )
	diffMult4 			= (1 + (difficulty-1)/30 )
	rotRate 				= rotRate_initial * diffMult2
	vBase 				= vBase_initial * diffMult
	vDelta 				= vDelta_initial * diffMult
	vIncr 				= vIncr_initial * diffMult3
	vIncr2 				= vIncr2_initial * diffMult4
	vMax 					= vBase
	vCur 					= vBase

	-- Caps
	if( rotRate > 360 ) then
		rotRate = 360 
	end

	-- Report
	if( debugEn ) then
		print("difficulty == " .. tostring( difficulty ) )
		print("     vBase == " .. tostring( vBase ) )
		print("    vDelta == " .. tostring( vDelta ) )
		print("     vIncr == " .. tostring( vIncr ) )
		print("    vIncr2 == " .. tostring( vIncr2 ) )
		print("      vMax == " .. tostring( vMax ) )
		print("   rotRate == " .. tostring( rotRate ) )
	end
end


return factory