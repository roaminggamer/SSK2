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

-- =============================================================
-- Forward Declarations
-- =============================================================
local moves = "horiz"
local isInteractive = true

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
		{ w = 40, h = 40, alpha = 1, curAmmo = "bullets", targetAngle = 0,
			firePeriod = 300, bulletVelocity = 400,
			rotRate = 180 }, 
		{ radius = 18,  calculator = myCC, colliderName = "player", bodyType = "kinematic" } )


	function player.onTwoTouchLeft( self, event )
		--table.dump(event)
		if( event.phase == "began" ) then
			self.leftRot = true
		else
			self.leftRot = false
		end
	end; listen( "onTwoTouchLeft", player )

	function player.onTwoTouchRight( self, event )
		--table.dump(event)
		if( event.phase == "began" ) then
			self.rightRot = true
		else
			self.rightRot = false
		end
	end; listen( "onTwoTouchRight", player )

	player.lastFireTime = -10000
	function player.fireBullet( self )
		local curTime = getTimer()
		local dt = curTime - self.lastFireTime
		if( dt >= self.firePeriod ) then
			--print("BOOM")
			self.lastFireTime = curTime
			local vec = angle2Vector( self.rotation, true )	
			local vec2 = scaleVec( vec, self.width/2 )
			vec = scaleVec( vec, self.bulletVelocity )
			
			local bullet = newCircle( self.parent, self.x + vec2.x, self.y + vec2.y, 
												{ size = 8, fill = _Y_ }, 
												{ radius = 4,  calculator = myCC, colliderName = "bullet",
													bounce = 1 } )
			bullet.rotation = self.rotation
			bullet:setLinearVelocity(vec.x, vec.y)

			self:toFront()
		end	
	end

	function player.enterFrame( self )

		local dt = ssk.getDT()/1000

		local rotDelta = 0
		rotDelta = rotDelta  + ( (self.leftRot) and -90 or 0 )
		rotDelta = rotDelta  + ( (self.rightRot) and 90 or 0 )
		local rotTarget = self.rotation + rotDelta
		ssk.actions.face( self, { angle = rotTarget, rate = self.rotRate })


		-- Just in case, delete any lingering 'laser'
		display.remove(self.laser)

		if( self.curAmmo == "bullets" ) then
			self:fireBullet() 
		elseif( self.curAmmo == "laser" ) then
		elseif( self.curAmmo == "missile" ) then
		elseif( self.curAmmo == "explosive" ) then
		end
	end; listen( "enterFrame", player )	

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
			if( other.colliderName == "wall" ) then
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
	-- Attach a finalize event to the player so it cleans it self up
	-- when removed.
	--	
	player.finalize = function( self )
		ignoreList( { "onTwoTouchLeft","onTwoTouchRight", "enterFrame" }, self )
	end; player:addEventListener( "finalize" )


	return player
end

return factory