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


   -- 1 Basic Ping Pong (default values)
   --
   local tmp = newImageRect( group, centerX, centerY - 240, "images/rg256.png", { size = 40 } )
   ssk.misc.pingPong( tmp )

   -- 2 Custom Ping Pong (x-only)
   --
   local tmp = newImageRect( group, centerX, centerY - 180, "images/rg256.png", { size = 40 } )
	local ping = { x = tmp.x - 200, myTime = 5000, myDelay = 500, transition = easing.outBounce }
	local pong = { x = tmp.x + 200, myTime = 3000, myDelay = 0, transition = easing.outElastic }
   ssk.misc.pingPong( tmp, { ping = ping, pong = pong } )

   -- 2 Custom Ping Pong (y-only )
   --
   local tmp = newImageRect( group, centerX - 300, centerY, "images/rg256.png", { size = 40 } )
	local ping = { y = tmp.y - 200 }
	local pong = { y = tmp.y + 200 }
   ssk.misc.pingPong( tmp, { ping = ping, pong = pong } )

   -- 3 Custom Ping Pong (x and rotation + offset start + '0' first transition time)
   --
   local tmp = newImageRect( group, centerX - 200, centerY - 120, "images/smiley.png", { size = 40, rotation = -60 } )
	local ping = { x = tmp.x, rotation = -60, time = 10000 }
	local pong = { x = tmp.x + 400, rotation = 60, time = 10000 }
   ssk.misc.pingPong( tmp, { firstTime = 0, ping = ping, pong = pong } )

   -- 4 Custom Ping Pong (x/y + center start; start on pong)
   --
   local tmp = newImageRect( group, centerX, centerY + 80, "images/rg256.png", { size = 40 } )
	local ping = { x = tmp.x - 50, y = tmp.y + 50  }
	local pong = { x = tmp.x + 50, y = tmp.y - 50 }
   ssk.misc.pingPong( tmp, { ping = ping, pong = pong, first = "pong" } )

   -- 5 Complex + Compound Ping Pong
   --
   local tmp = newImageRect( group, centerX, centerY + 200, "images/rg256.png", { size = 40 } )
	local ping = { x = tmp.x - 200, time = 5000 }
	local pong = { x = tmp.x + 200, time = 5000 }
   ssk.misc.pingPong( tmp, { ping = ping, pong = pong } )

	local ping = { y = tmp.y - 50, time = 2500, transition = easing.inOutCirc}
	local pong = { y = tmp.y + 50, time = 2500, transition = easing.inOutCirc }
   ssk.misc.pingPong( tmp, { ping = ping, pong = pong } )

	local ping = { xScale = 1} 
	local pong = { xScale = -1 } 
   ssk.misc.pingPong( tmp, { ping = ping, pong = pong } )


end


return test
