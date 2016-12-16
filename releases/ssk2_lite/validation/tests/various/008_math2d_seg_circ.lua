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


	local x1,y1,x2,y2 = display.contentCenterX, display.contentCenterY+200, display.contentCenterX, display.contentCenterY-200
	x1 = x1 - 150
	x2 = x2
	local line1 = display.newLine( group, x1,y1,x2,y2 )
	line1.strokeWidth = 2
	local p1 = { x = x1, y = y1 }
	local p2 = { x = x2, y = y2 }

	local circ = display.newCircle( group, display.contentCenterX, display.contentCenterY, 100 )
	circ:setFillColor(0,0,0,0)
	circ.strokeWidth = 2

	local i1, i2 = math2d.segmentCircleIntersect( { x = p1.x, y = p1.y}, 
		                                              { x = p2.x, y = p2.y}, 
		                                              circ, 
		                                              100 )

	if( i1 ) then
		local hit = display.newCircle( group, i1.x, i1.y, 10 )
		hit:setFillColor(0,1,0)
	end

	if( i2 ) then
		local hit = display.newCircle( group, i2.x, i2.y, 10 )
		hit:setFillColor(0,1,0)
	end
end


return test
