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


   local startX = left + 100
   local startY = top + 100

   local curX = startX
   local curY = startY

	-- Easy Colors
	newRect( group, curX, curY, { size = 60, fill = _T_, stroke = _W_, strokeWidth = 10 } )	

	curX = curX + 100
	newRect( group, curX, curY, { size = 60, fill = _K_, stroke = _R_, strokeWidth = 10 } )	

	curX = curX + 100
	newRect( group, curX, curY, { size = 60, fill = _G_, stroke = _B_, strokeWidth = 10 } )	

	curX = curX + 100
	newRect( group, curX, curY, { size = 60, fill = _Y_, stroke = _O_, strokeWidth = 10 } )	

	curX = curX + 100
	newRect( group, curX, curY, { size = 60, fill = _P_, stroke = _C_, strokeWidth = 10 } )	

	curX = curX + 100
	newRect( group, curX, curY, { size = 60, fill = _BRIGHTORANGE_, stroke = _PURPLE_, strokeWidth = 10 } )	

	curX = startX
	curY = curY + 100
	newRect( group, curX, curY, { size = 80, fill = _WHITE_  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = _LIGHTGREY_  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = _GREY_  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = _DARKGREY_  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = _DARKERGREY_  } )	

	-- Hex Color
	curX = startX
	curY = curY + 100
	newRect( group, curX, curY, { size = 80, fill = hexcolor("bafbb")  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = hexcolor("#002642")  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = hexcolor("0x840032")  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = hexcolor("e59500")  } )	

	curX = curX + 80
	newRect( group, curX, curY, { size = 80, fill = hexcolor("02040f")  } )	


	-- randomRGB
	curX = curX + 100
	local c = ssk.colors.randomRGB()
	newRect( group, curX, curY, { size = 80, fill = c  } )	

	curX = curX + 80
	local c = ssk.colors.randomRGB( c )
	newRect( group, curX, curY, { size = 80, fill = c  } )	

	-- mixRGB
	curX = curX + 100
	local c = ssk.colors.mixRGB( _O_, _P_ )
	newRect( group, curX, curY, { size = 80, fill = c  } )	

	-- randomRGB
	curX = curX + 100
	local c = ssk.colors.pastelRGB()
	newRect( group, curX, curY, { size = 80, fill = c  } )	

	curX = curX + 80
	local c = ssk.colors.pastelRGB( c )
	newRect( group, curX, curY, { size = 80, fill = c  } )	

end

return test
