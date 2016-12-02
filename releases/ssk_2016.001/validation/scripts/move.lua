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
local player
local target

local example = {}
function example.stop()
	physics.pause()
	ignoreList( { "enterFrame" }, player )
	timer.cancel(player.myTimer)
	transition.cancel( target )
end


function example.run( group )
	--
	-- Start and Configure  physics
	local physics = require "physics"
	physics.start()
	physics.setGravity(0,0)
	--physics.setDrawMode("hybrid")


	-- Create an 'arrow' as our player
	--
	player = newImageRect( group, centerX, centerY, "images/proto/arrow.png", 
								{ size = 40, fill = _R_ }  )

	-- Create a 'target' to face
	--
	target = newImageRect( group, centerX, centerY, "images/rg256.png", { size = 40 } )

	-- Draw new 'trail' dot every 100 ms
	-- 
	player.timer = drawTrail
	player.myTimer = timer.performWithDelay( 100, player, -1 )

	-- Have the target move around randomly forth to challenge the seeking
	-- logic in player's enterFrame listener.
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
	-- Have player  start listening for enterFrame event
	--
	local face = ssk.actions.face
	local move = ssk.actions.move
	player.enterFrame = function( self )
		-- Try to face the target
		face( self, { target = target, rate = 180 } )

		-- Move forward at fixed rate of 300 pixels per second
		move.forward( self, { rate = 300 } )

	end; listen( "enterFrame", player )
-- *****************************************************
-- END - SAMPLE USAGE 
-- *****************************************************

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



return example
