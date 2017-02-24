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
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert
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
local firePeriod = 300
local bulletVelocity = 400
local bulletLifetime = 5000
local continousFire = false
local bulletLimit


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

	firePeriod = params.firePeriod or firePeriod
	bulletVelocity = params.bulletVelocity or bulletVelocity
	bulletLifetime = params.bulletLifetime or bulletLifetime
	continousFire = fnn(params.continousFire, continousFire)
	bulletLimit = params.bulletLimit

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

	local bullets = {}

	if( bulletLimit ) then
		common.count = bulletLimit - table.count( bullets )
	end

	-- Create player 
	local player = newRect( group, x, bottom + (params.size or 40)/2, 
		{ size = params.size or 40 , alpha = 1, curAmmo = "bullets", targetAngle = 0, isVisible = false }, 
		{ radius = 18,  calculator = myCC, colliderName = "player", bodyType = "static" } )


	--
	-- Move Player to Touch and Fire (test w/ and w/ autoFire)
	--
	function player.onOneTouch( self, event )
		self.x = event.x
		if( continousFire ) then
			player.isFiring = ( event.phase ~= "ended" )
		else
			player.isFiring = ( event.phase == "ended" )
		end
	end; listen( "onOneTouch", player )

	player.lastFireTime = -10000
	local function onCollision( self, event )
		if( event.phase ~= "began" ) then return false end 
		nextFrame( function() 
			self:destroy()
			end )
		return false
	end

	function player.fireBullet( self )
		if( bulletLimit and table.count(bullets) > bulletLimit ) then return end

		local curTime = getTimer()
		local dt = curTime - self.lastFireTime
		if( dt >= firePeriod ) then			
			
			local vec = angle2Vector( self.rotation, true )	
			local vec2 = scaleVec( vec, self.width/2 )
			vec = scaleVec( vec, bulletVelocity )

			
			local bullet = newCircle( self.parent, self.x + vec2.x, self.y + vec2.y, 
												{ size = 14, fill = _Y_, collision = onCollision }, 
												{ radius = 8,  calculator = myCC, colliderName = "bullet",
													bounce = 1 } )
			bullets[bullet] = bullet
			common.count = bulletLimit - table.count( bullets )

			bullet.rotation = self.rotation
			bullet:setLinearVelocity(vec.x, vec.y)
			
			function bullet.destroy(self)
				self.timer = function() end
				bullets[self] = nil
				print("bulletCount", table.count(bullets))
				display.remove( self )
				common.count = bulletLimit - table.count( bullets )
			end

			bullet.timer = bullet.destroy
			timer.performWithDelay( bulletLifetime, bullet )

			if( not continousFire ) then
				self.isFiring = false
			end

			self:toFront()
		end	
	end

	function player.enterFrame( self )
		if( self.isFiring ) then
			self:fireBullet()
		end
	end; listen( "enterFrame", player )	
		

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