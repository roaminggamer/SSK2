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

-- PLUGIN REQUIRES GO HERE

-- =============================================================
local test = {}

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   local math2d = ssk.math2d


	local circ = display.newCircle( group, display.contentCenterX, display.contentCenterY - 100, 20 )
	local rect = display.newRect( group, display.contentCenterX, display.contentCenterY, 40, 40  )

	local angle = 0
	local t = system.getTimer()
	local speed = 45 -- degrees per second
	local speed2 = -45 -- degrees per second
	local fov = 120
	local offsetAngle = 0

	local rotateFOV = false

	local function enterFrame()
			local curT = system.getTimer()
			local dt = curT - t
			t = curT

			-- Rotate Rectangle or FOV and redraw Lines	
			if( rotateFOV ) then
				offsetAngle = offsetAngle + speed2 * (dt/1000)
			else
				rect.rotation = rect.rotation + speed2 * (dt/1000)
			end
			
			display.remove( rect.line1 )
			display.remove( rect.line2 )
			display.remove( rect.line3 )
			local v = math2d.angle2Vector( rect.rotation - fov/2 + offsetAngle, true )
			v = math2d.scale( v, 300 )
			v.x = v.x + rect.x
			v.y = v.y + rect.y
			rect.line1 = display.newLine( group, rect.x, rect.y, v.x, v.y )
			rect.line1.strokeWidth = 2

			local v = math2d.angle2Vector( rect.rotation + fov/2 + offsetAngle, true )
			v = math2d.scale( v, 300 )
			v.x = v.x + rect.x
			v.y = v.y + rect.y
			rect.line2 = display.newLine( group, rect.x, rect.y, v.x, v.y )
			rect.line2.strokeWidth = 2

			local v = math2d.angle2Vector( rect.rotation + offsetAngle, true )
			v = math2d.scale( v, 300 )
			v.x = v.x + rect.x
			v.y = v.y + rect.y
			rect.line3 = display.newLine( group, rect.x, rect.y, v.x, v.y )
			rect.line3.strokeWidth = 2
			rect.line3:setStrokeColor(0,1,1)
			rect:toFront()

			-- Circle
			angle = angle + speed * (dt/1000)
			math2d.rotateAbout( circ, rect, angle, 150 )
			if( math2d.inFOV( circ, rect, fov, offsetAngle ) ) then
				circ:setFillColor(0,1,0) 
			else
				circ:setFillColor(1,0,0) 
			end
	end
	Runtime:addEventListener( "enterFrame" , enterFrame )

end


return test
