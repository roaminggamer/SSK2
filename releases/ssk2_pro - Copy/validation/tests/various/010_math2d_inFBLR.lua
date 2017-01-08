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


	local observer = display.newImageRect( group, "images/up.png", 50, 50)
	observer.x = display.contentCenterX
	observer.y = display.contentCenterY


	local circles = {}
	circles[#circles+1] = display.newCircle( group, observer.x - 150, observer.y, 20 )
	circles[#circles+1] = display.newCircle( group, observer.x + 150, observer.y, 20 )
	circles[#circles+1] = display.newCircle( group, observer.x, observer.y - 150, 20 )
	circles[#circles+1] = display.newCircle( group, observer.x, observer.y + 150, 20 )

	local period = 2000

	observer.rotation = -15
	local function testInFBLR()
		observer.rotation = observer.rotation + 15

		for i = 1, #circles do
			local color = { 0,0,0 }
			
			local hit = false
			if( math2d.isToLeft( circles[i], observer ) ) then
				hit = true
				color[1] = 1
			end
			if( math2d.isToRight( circles[i], observer ) ) then
				hit = true
				color[2] = 1
			end
			if( math2d.isInFront( circles[i], observer ) ) then
				hit = true
				color[3] = 1
			end
			if( hit ) then
				circles[i]:setFillColor( unpack(color))
			else
				circles[i]:setFillColor( 0.25, 0.25, 0.25 )
			end
		end

		timer.performWithDelay( period, testInFBLR )
	end
	testInFBLR()
	timer.performWithDelay( period, testInFBLR )

end


return test
