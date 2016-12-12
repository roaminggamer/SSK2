-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================

-- =============================================================
-- Localizations
-- =============================================================
-- Lua
local getTimer = system.getTimer; local mRand = math.random
local mAbs = math.abs
local strMatch = string.match; local strGSub = string.gsub; local strSub = string.sub
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
ssk.misc.countLocals(1)

-- =============================================================
-- =============================================================

local test = {}

-- Forward Declarations
local drawTrail

local actions 		= ssk.actions
local rgColor 		= ssk.RGColor
local oneTouch 	= ssk.easyInputs.oneTouch


function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   local angle = 0

	--
	-- Start and Configure  physics
	local physics = require "physics"
	physics.start()
	physics.setGravity(0,0)
	--physics.setDrawMode("hybrid")
	

	-- Initialize 'input'
	--
	oneTouch.create( group, { debugEn = false, keyboardEn = true } )

	-- Create an 'arrow' as our player
	--
	local player = newImageRect( group, centerX, centerY, "images/up.png", { size = 40 }, { radius = 20 } )
	player.linearDamping = 1

	-- Create a 'target' to face
	--
	local target = newImageRect( group, centerX, centerY - 150, "images/rg256.png", { size = 40 } )

	-- Draw new 'trail' dot every 100 ms
	-- 
	player.timer = drawTrail
	player.myTimer = timer.performWithDelay( 100, player, -1 )

	-- Have target start listening for enterFrame event
	--
	local lastT = getTimer()
	local dir = 1
	local count = 0
	target.enterFrame = function( self )
		-- Change direction every 240 counts
		count = count + 1
		if (count%240 == 0 ) then
			dir = -dir 
		end
		-- Smoothly calculate a delta angle based on elapsed time and a target
		-- turn rate of 45 degrees per second
		local curT = getTimer()
		local dt = curT - lastT
		lastT = curT
		local dA = dir * 45 * dt/1000

		-- Calculate new position for target and move it there
		--		
		angle = normRot(angle + dA)
		local vec = angle2Vector( angle, true )
		vec = scaleVec( vec, 200 )
		target.x = centerX + vec.x
		target.y = centerY + vec.y
	end; listen( "enterFrame", target )



	-- Have player  start listening for enterFrame event
	--
	player.enterFrame = function( self )
		-- Try to face the target
		actions.face( self, { target = target, rate = 90 } )

		-- Thrust forward (rate equates to a mass independent force)
		actions.movep.thrustForward( self, { rate = 15 } )

	end; listen( "enterFrame", player )


	-- Start listening for one touch event and move the 'target' to the touch
	player.onOneTouch = function( self, event )
		target.x = event.x
		target.y = event.y
		return false
	end; listen( "onOneTouch", player )	

end

-- Helper function to draw a simple 'trail' of dots showing where the player has been
--
drawTrail = function( player )
	local vec = angle2Vector( player.rotation + 180, true )
	vec = scaleVec( vec, player.height/2)
	local dot = display.newCircle( player.parent, player.x + vec.x, player.y + vec.y, 
		                            player.contentWidth/16 )
	dot:toBack()
	transition.to( dot, { alpha = 0, time = 750, onComplete = display.remove } )
end


return test
