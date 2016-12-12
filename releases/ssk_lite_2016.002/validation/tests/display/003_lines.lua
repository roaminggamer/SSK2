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


   -- Basic
   local newLine 	= ssk.display.newLine
	newLine( group, 50, top + 50, 450, top + 50 )
	newLine( group, 50, top + 50 + 20, 450, top + 50 + 20, { w = 2, fill = _R_ } )
	newLine( group, 50, top + 50 + 40, 450, top + 50 + 40, { w = 1, dashLen = 3, gapLen = 5, fill = _C_, style = "dashed" } )
	newLine( group, 50, top + 50 + 60, 450, top + 50 + 60, { radius = 3, gapLen = 5, fill = _O_, style = "dotted", stroke = _Y_, strokeWidth = 1} )
	newLine( group, 50, top + 50 + 80, 450, top + 50 + 80, { gapLen = 10, dashLen = 6, headSize = 4, fill = _O_, style = "arrows"} )
	newLine( group, 50, top + 50 + 100, 450, top + 50 + 100, { gapLen = 10, dashLen = 0, headSize = 4, fill = _C_, style = "arrows"} )


	-- Angle lines
	local newAngleLine = ssk.display.newAngleLine
	local curY = top + 200
	local tmp = newAngleLine( group, 50, curY, 135, 200 )
	curY = curY + 20
	local tmp = newAngleLine( group, 50, curY, 135, 200, { w = 2, fill = _R_ } )
	curY = curY + 20
	local tmp = newAngleLine( group, 50, curY, 135, 200, { w = 1, dashLen = 3, gapLen = 5, fill = _C_, style = "dashed" } )
	curY = curY + 20
	local tmp = newAngleLine( group, 50, curY, 135, 200, { radius = 3, gapLen = 5, fill = _O_, style = "dotted", stroke = _Y_, strokeWidth = 1} )
	curY = curY + 20
	local tmp = newAngleLine( group, 50, curY, 135, 200, { gapLen = 10, dashLen = 6, headSize = 4, fill = _O_, style = "arrows"} )
	curY = curY + 20
	local tmp = newAngleLine( group, 50, curY, 135, 200, { gapLen = 10, dashLen = 1, headSize = 4, fill = _C_, style = "arrows"} )

	-- Complex Lines
	local newPointsLine 	= ssk.display.newPointsLine
	local newPoints 		= ssk.points.new
	local easyIFC 			= ssk.easyIFC
	local mRand				= math.random
	local reDrawLines
	local lastGroup

	reDrawLines = function()
		display.remove( lastGroup )

		lastGroup = display.newGroup()
		group:insert( lastGroup )

		lastGroup.x  = lastGroup.x + 200

		local curY = 250

		local points = newPoints()
		for i = 1, 36 do
			points:add( 50 + (i-1) * 10, curY + mRand(-5,5) )
		end
		local tmp = newPointsLine( lastGroup, points  )
		
		local points = newPoints()	
		curY = curY + 20
		for i = 1, 36 do
			points:add( 50 + (i-1) * 10, curY + mRand(-5,5) )
		end
		local tmp = newPointsLine( lastGroup, points, { w = 2, fill = _R_ } )

		local points = newPoints()
		curY = curY + 20	
		for i = 1, 36 do
			points:add( 50 + (i-1) * 10, curY + mRand(-5,5) )
		end
		local tmp = newPointsLine( lastGroup, points, { w = 1, dashLen = 1, gapLen = 2, fill = _C_, style = "dashed" } )

		local points = newPoints()
		curY = curY + 20
		for i = 1, 36 do
			points:add( 50 + (i-1) * 10, curY + mRand(-5,5) )
		end
		local tmp = newPointsLine( lastGroup, points, { radius = 3, gapLen = 5, fill = _O_, style = "dotted", stroke = _Y_, strokeWidth = 1} )

		local points = newPoints()
		curY = curY + 20
		for i = 1, 36 do
			points:add( 50 + (i-1) * 10, curY + mRand(-5,5) )
		end
		local tmp = newPointsLine( lastGroup, points, { gapLen = 10, dashLen = 6, headSize = 4, fill = _O_, style = "arrowheads"} )

		local points = newPoints()
		curY = curY + 20
		for i = 1, 36 do
			points:add( 50 + (i-1) * 10, curY + mRand(-5,5) )
		end
		local tmp = newPointsLine( lastGroup, points, { fill = {1,1,1,0.2} } )
		local tmp = newPointsLine( lastGroup, points, { gapLen = 10, dashLen = 1, headSize = 4, fill = _C_, style = "arrowheads"} )

		timer.performWithDelay( 100, reDrawLines )
	end

	reDrawLines()
end

return test
