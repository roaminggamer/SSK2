local myCC 			= require "scripts.myCC"
local predictive 	= require "scripts.predictive"

local towerSize = 20


local ammo = {}
ammo[_BLUE_] = 9999
ammo[_GREEN_] = 9999
ammo[_YELLOW_] = 9999

local layers

local targets = {}

local isRunning = true
local lastTargetTimer

local framesPerTrail = 7
local trailLife = 1200
local missileDPS = 180
local retargetDelay = 60
local barrelRotationSpeed = 90
local bulletFirePeriod = 500
local bulletLife = 8000
local bulletSpeed 	= 70 -- Used for velocity bullets
local bulletRadius 	= 2

local createTurret
local fireBullet
local registerLayers
local registerTargets
local cleanUp



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
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert

local tcount 			= table.count
local quad 				= predictive.quad
local intercept  		= predictive.intercept

--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale



----------------------------------------------------------------------
----------------------------------------------------------------------
local faceTarget
faceTarget = function( obj, target, dps, easing )
	--print("faceTarget()", obj, target, dps, easing )
	if( display.isValid(obj) == false ) then
		--print("BYE A ")
		return 
	end
	if( display.isValid(target) == false ) then 
		--print("BYE B ")
		return 
	end
	local origDPS = dps
	local px = target.x
	local py = target.y	
	local dps = dps or 0
	dps = dps/1000
	local easing = easing or transition.linear

	local tweenAngle, vecAngle = ssk.math2d.tweenAngle( obj, {x=px,y=py} )

	-- Instant Turn
	if(dps <=0 ) then
		obj.rotation = vecAngle

	-- Timed Turn
	else
		if(tweenAngle >= 180) then
			vecAngle = vecAngle - 360
			tweenAngle  = vecAngle - obj.rotation
		elseif(tweenAngle <= -180) then
			vecAngle = vecAngle + 360
			tweenAngle  = vecAngle - obj.rotation
		end	

		local rotateTime = math.abs(round(tweenAngle / dps))

		local function onComplete( )
			
			timer.performWithDelay( retargetDelay,
				function()
					--print("PODUNK", getTimer())
					faceTarget( obj, target, origDPS, easing)
				end )
		end

		transition.to( obj, { rotation = vecAngle, time = rotateTime, transition = easing, onComplete = onComplete } )
	end
end



fireBullet = function( self )
	if( display.isValid( self ) == nil ) then 
		if( self.myTimer ) then
			timer.cancel( self.myTimer )
			self.myTimer = nil
		end
		return 
	end

	if( tcount(targets) == 0 ) then 
		self.target = nil

		--if( self.ammoColor == _BLUE_ ) then print("A", tcount(targets), getTimer()) end
		return 
	end

	if( ammo[self.ammoColor] <= 0 ) then 
		--if( self.ammoColor == _BLUE_ ) then print("B", ammo[self.ammoColor], getTimer() ) end
		return 
	end

	local target 

	if( display.isValid(self.target) == false ) then
		self.target = nil	
	end

	if( self.target ) then
		local vec = subVec( self, self.target )		
		local len = lenVec( vec )

		if(len > self.attackRadius) then
			self.target = nil
		end
	end

	local maxDist = self.attackRadius

	if( self.target == nil ) then		
		for k,v in pairs(targets) do
			if( display.isValid(v) ) then
				local vec = subVec( self, v )		
				local len = lenVec( vec )

				if( len <= maxDist ) then
					target = v
					maxDist = len
				end
			end
		end

		self.target = target
	else
		target = self.target
	end

	if( not target ) then 
		--if( self.ammoColor == _BLUE_ ) then print("C no target ", maxDist, getTimer()) end
		return 		
	end 

	ammo[self.ammoColor] = ammo[self.ammoColor] - 1



    local bulletVel = angle2Vector( self.barrel.rotation, true )
    -- Normalize the vector
    bulletVel = normVec( bulletVel ) 

    -- scale it so we have the right velocity
    bulletVel = scaleVec( bulletVel, bulletSpeed )

    local function selfDestruct( self )
        display.remove(self)
    end

    local bullet = display.newRect( layers.content, self.x, self.y, 3, 7  )    
    bullet:toBack()
    bullet.x = self.x
    bullet.y = self.y
    bullet.rotation = self.barrel.rotation

    faceTarget( bullet, target, missileDPS )


    local count = 1
	bullet.enterFrame = function( self )
		if( not self or self.setLinearVelocity == nil ) then
			ignore( "enterFrame", self ) 
			self.enterFrame = nil
			return 
		end		
		count = count + 1
		if(count % framesPerTrail == 0 ) then
			for i = 1, mRand(2,5) do
				local tmp = display.newCircle( self.parent, self.x, self.y, 0.5)
				tmp.x = tmp.x + mRand( -15, 15 ) / 10
				tmp.y = tmp.y + mRand( -15, 15 ) / 10
				tmp:setFillColor( 1,1,1,1 )
				tmp:setStrokeColor(1,1,1,1)
				tmp.strokeWidth = 0
				tmp:toBack()
				transition.to( tmp, { alpha = 0, time = trailLife } )
				timer.performWithDelay( trailLife + 100, function() display.remove( tmp ) end )
			end
		end


		local vec = angle2Vector( self.rotation, true )
		vec = scaleVec( vec, bulletSpeed )
		self:setLinearVelocity( vec.x, vec.y )
	end
	listen( "enterFrame", bullet )



    bullet.collision = function( self, event )
        --if( event.other == target ) then 

        	event.other.hits = event.other.hits - 1

            timer.performWithDelay(1,
                function()
                    display.remove(self)
                    if(event.other.hits <= 0 ) then
                    	--table.removeByRef( targets, event.other )
                    	targets[event.other] = nil
                    	display.remove(event.other)
                    end

                end )
        --end
        return true 
    end
    bullet:addEventListener( "collision" )

    physics.addBody( bullet, "dynamic", { radius = bulletRadius, isSensor = true, isBullet = true, 
    	filter = myCC:getCollisionFilter( "bullet" ) } )

    bullet:setLinearVelocity( bulletVel.x, bulletVel.y )

    -- Destroy bullet in 10 seconds regardless of collision
    timer.performWithDelay( bulletLife, function() display.remove( bullet ) end )
end


----------------------------------------------------------------------
----------------------------------------------------------------------
createTurret = function( x, y, attackRadius, turretColor ) 
	-- Create a 'Turret'
	--local turret = display.newCircle(  layers.content, x or centerX, y or centerY, 15 )
	local turret = newImageRect( layers.content, x or centerX, y or centerY, "images/towers/blaster.png",{ size = towerSize } )

	--turret:setFillColor(unpack(turretColor))
	turret.attackRadius = attackRadius
	turret.ammoColor = turretColor

	local radiusShadow = display.newCircle(  layers.content, x or centerX, y or centerY, attackRadius or 100)
	radiusShadow:setFillColor(0.2,0.2,0.2)
	radiusShadow:setStrokeColor(1,1,1)
	radiusShadow.strokeWidth = 2
	radiusShadow.alpha = 0.2
	radiusShadow:toBack()


	--local barrel = newRect( layers.content, turret.x, turret.y, { w = 4, h = 25, anchorY = 0.75, fill = _TRANSPARENT_, stroke = {1,0,1}, strokeWidth = 1})
	local barrel = newImageRect( layers.content, turret.x, turret.y, "images/towers/blaster_barrel_1.png", { size = towerSize } )
	turret.barrel = barrel


	barrel.lastTime = getTimer()
	barrel.enterFrame = function( self )
		if( display.isValid(self) == false ) then
			ignore( "enterFrame", self ) 
			self.enterFrame = nil
			return 
		end
		local curTime = getTimer()
		local dt = curTime - self.lastTime  
		self.lastTime = curTime

		local dr = barrelRotationSpeed * (dt/1000)
		self.rotation = self.rotation + dr

		if( self.rotation >= 360 ) then self.rotation = self.rotation - 360 end
		if( self.rotation < 0 ) then  self.rotation = self.rotation + 360 end
	end
	listen( "enterFrame", barrel )

    local ammotext = easyIFC:quickLabel( layers.content, ammo[turretColor], turret.x, turret.y, gameFont, 10, _BLACK_ )
    ammotext.enterFrame = function( self, event )
    	if( display.isValid( turret ) == false ) then
    		ignore( "enterFrame", self )
    		display.remove(self)
    		return 
    	end
    	if( ammo[turretColor] > 0 ) then
    		self.text = ammo[turretColor]
    	else
    		self.text = 0
    	end
    	self.x = turret.x
    	self.y = turret.y
	end
	listen( "enterFrame", ammotext )

	ammotext.alpha = 0--EDO



	turret.timer = fireBullet
	turret.myTimer = timer.performWithDelay( bulletFirePeriod, turret, -1 ) 



    return turret
end

registerTargets = function( targetTable )
	targets = targetTable
end


registerLayers = function( gameLayers )
	layers = gameLayers
end


cleanUp = function( )
	targets = {}
	layers  = nil
end


local public = {}
public.registerLayers 	= registerLayers
public.registerTargets 	= registerTargets
public.createTurret 	= createTurret
public.cleanUp 			= cleanUp
return public