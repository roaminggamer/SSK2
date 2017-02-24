
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


--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale


local function drawBolt( a, b, segs, p, color, time, iterations, lastBolt )

	local iterations = iterations or 1

	if( lastBolt ) then 
		timer.performWithDelay( time * 0.5, function() display.remove( lastBolt ) end )
	end

	iterations = iterations - 1

	if( display.isValid(a) == false ) then return end
	if( display.isValid(b) == false ) then return end


	if(iterations < 0) then return end

	print(a,b)
	local vec 		= subVec( a, b )
	local len 		= lenVec( vec )
	local segVec 	= normVec(vec)
	segVec			= scaleVec( segVec, len/segs )
	local tmp 		= { x = a.x, y = a.y }


	local pathPoints = {}

	pathPoints[1] = { x = a.x, y = a.y }

	for i = 1, segs-1 do
		tmp = addVec( tmp, segVec )
		pathPoints[#pathPoints+1] = { x = tmp.x, y = tmp.y }
	end

	pathPoints[#pathPoints+1] = { x = b.x, y = b.y }

	for i = 2, #pathPoints-1 do
		local point = pathPoints[i]
		point.x = point.x + mRand( -p, p )
		point.y = point.y + mRand( -p, p )		
	end

	local aBolt = display.newGroup()
	
--	for i = 1, #pathPoints do
--		display.newCircle( pathPoints[i].x, pathPoints[i].y, 2 )
--	end

	local boltLine = display.newLine( aBolt, pathPoints[1].x, pathPoints[1].y, pathPoints[2].x, pathPoints[2].y )
	for i = 3, #pathPoints do
		boltLine:append( pathPoints[i].x, pathPoints[i].y )
	end
	boltLine:setStrokeColor( unpack( color ) )
	boltLine.strokeWidth = 1 -- mRand(1,2)
	boltLine.alpha = mRand( 60,80 ) / 100

	timer.performWithDelay( time, function() drawBolt( a, b, segs, p, color, time, iterations, aBolt ) end )

end


--[[
local bolt = require "scripts.bolt"

local ptA 			= { x = 100, y = 100 }
local ptB 			= { x = 100, y = 300 }
local perturb 		= 5
local numSegments 	= 20

bolt.draw( ptA, ptB, numSegments, perturb, _YELLOW_, 30, 450 )
bolt.draw( ptA, ptB, numSegments, perturb, _YELLOW_, 30, 450 )
--]]


local public = {}

public.draw = drawBolt

return public