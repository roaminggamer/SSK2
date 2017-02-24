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

local bulletFirePeriod = 300
local bulletSpeed 	= 250 -- Used for velocity bullets
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

	if( self.target and display.isValid( self.target ) ) then
		local vec = diffVec( self, self.target )		
		local len = lenVec( vec )

		if(len > self.attackRadius) then
			self.target = nil
		end
	end

	local maxDist = self.attackRadius

	if( self.target == nil ) then		
		for k,v in pairs(targets) do
			if( display.isValid(v) ) then
				local vec = diffVec( self, v )		
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


    -- Calculate vector from turret to target
    local aimPoint  = intercept( self, target, bulletSpeed, 0) -- aimJitter 0..100 ++

    local bulletVel = diffVec( self, aimPoint )
    -- Normalize the vector
    bulletVel = normVec( bulletVel ) 

    -- Rotate barrel
    self.barrel.rotation = vector2Angle( bulletVel )
    print(self.barrel.rotation )


    -- scale it so we have the right velocity
    bulletVel = scaleVec( bulletVel, bulletSpeed )

    local function selfDestruct( self )
        display.remove(self)
    end

    local bullet = display.newCircle( layers.content, self.x, self.y, bulletRadius )
    bullet:toBack()


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
    timer.performWithDelay( 10000, function() display.remove( bullet ) end )
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