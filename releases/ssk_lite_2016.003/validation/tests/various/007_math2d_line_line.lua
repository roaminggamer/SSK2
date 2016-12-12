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

	local x1,y1,x2,y2 = display.contentCenterX, display.contentCenterY-200, display.contentCenterX, display.contentCenterY+200
	local line1 = display.newLine( group, x1,y1,x2,y2 )
	line1.strokeWidth = 2
	local x3,y3,x4,y4 = display.contentCenterX-200, display.contentCenterY, display.contentCenterX + 200, display.contentCenterY
	local line2 = display.newLine( group, x3,y3,x4,y4 )
	line2.strokeWidth = 2

	local period = 60
	local deltaAngle = 5
	local startAngle = 0
	local endAngle = 360
	local angle = startAngle
	local marker

	local function testLineIntersect()
		angle = angle + deltaAngle
		display.remove(line2)
		display.remove(marker)

		--print(angle)
		if( angle > endAngle ) then 		
			return
		end
		local vec = math2d.angle2Vector( angle, true )
		vec = math2d.scale( vec, 250 )
		vec.x = vec.x + x3
		vec.y = vec.y + y3
		line2 = display.newLine( group, x3, y3, vec.x, vec.y )
		line2.strokeWidth = 2
		local intersect = math2d.lineLineIntersect( x3,y3,vec.x,vec.y, x1,y1,x2,y2 )
		if( intersect ) then 
			marker = display.newCircle( group, intersect.x, intersect.y, 10, true, true )
			marker:setFillColor(0,1,0)
		end

		timer.performWithDelay( period, testLineIntersect )
	end
	timer.performWithDelay( period, testLineIntersect )
end


return test
