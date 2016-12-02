-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016
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
--
-- Specialized SSK Features
local rgColor = ssk.RGColor

ssk.misc.countLocals(1)

-- =============================================================
-- =============================================================
-- Forward Declarations
local drawTrail

-- Locals
local player1
local player2
local target

local example = {}
function example.stop()
	physics.pause()
	ignoreList( { "enterFrame" }, player1 )
	ignoreList( { "enterFrame" }, player2 )
	timer.cancel(player1.myTimer)
	timer.cancel(player2.myTimer)
	transition.cancel( target )
end


function example.run( group )
	--
	-- Start and Configure  physics
	local physics = require "physics"
	physics.start()
	physics.setGravity(0,0)
	--physics.setDrawMode("hybrid")


	-- Create an 'arrow' as our player1
	--
	player1 = newImageRect( group, centerX, centerY, "images/proto/arrow.png", 
									{ size = 40, fill = _G_ }, 
									{ radius = 20 } )
	
	player2 = newImageRect( group, centerX, centerY, "images/proto/arrow.png", 
		{ size = 40, fill = _R_ } )

	-- Create a 'target' to face
	--
	target = newImageRect( group, centerX, centerY, "images/rg256.png", { size = 40 } )

	-- Draw new 'trail' dot every 100 ms
	-- 
	player1.timer = drawTrail
	player1.myTimer = timer.performWithDelay( 100, player1, -1 )
	player2.timer = drawTrail
	player2.myTimer = timer.performWithDelay( 100, player2, -1 )

	-- Have the target move around randomly forth to challenge the seeking
	-- logic in player1's enterFrame listener.
	--
	function target.onComplete( self )
		local minX = centerX - fullw/4
		local maxX = centerX + fullw/4
		local minY = centerY - fullh/4
		local maxY = centerY + fullh/4
		transition.to( self, { x = mRand(minX, maxX), y = mRand(minY, maxY), time = 500, onComplete = self } )
	end
	target:onComplete()

-- *****************************************************
-- BEGIN - SAMPLE USAGE 
-- *****************************************************
	-- Have player1  start listening for enterFrame event
	--
	local face = ssk.actions.face
	local move = ssk.actions.move
	local movep = ssk.actions.movep
	player1.enterFrame = function( self )
		-- Try to face the target
		face( self, { target = target, rate = 180 } )

		-- Thrust forward (rate equates to a mass independent force)
		movep.thrustForward( self, { rate = 100 } )

		-- Limit Velocity to maximum rate of 300 pixels per second
		movep.limitV( self, { rate = 300 } )
	end; listen( "enterFrame", player1 )

	player2.enterFrame = function( self )
		-- Try to face the target
		face( self, { target = target, rate = 180 } )

		-- Move forward at fixed rate of 300 pixels per second
		move.forward( self, { rate = 300 } )

	end; listen( "enterFrame", player2 )

-- *****************************************************
-- END - SAMPLE USAGE 
-- *****************************************************

end

-- Helper function to draw a simple 'trail' of dots showing where the player1 has been
--
drawTrail = function( player1 )
	local vec = angle2Vector( player1.rotation + 180, true )
	vec = scaleVec( vec, player1.height/2)
	local dot = display.newCircle( player1.parent, player1.x + vec.x, player1.y + vec.y, 
		                            player1.contentWidth/16 )
	dot:toBack()
	transition.to( dot, { alpha = 0, time = 750, onComplete = display.remove } )
end



return example
