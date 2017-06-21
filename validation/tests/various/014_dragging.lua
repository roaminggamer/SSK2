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
-- =============================================================
local test = {}

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   local physics = require "physics"
   physics.start()
   physics.setGravity(0,10)
   physics.setDrawMode("hybrid")

   local drag1 = newImageRect( group, centerX - 150, centerY, "images/rg256.png", { size = 120 } )
	ssk.misc.addSmartDrag( drag1, { retval = true, toFront = true } )


   local drag2 = newImageRect( group, centerX, centerY, "images/smiley.png", { size = 120 }, { radius = 60 } )
   ssk.misc.addPhysicsDrag( drag2, { force = 300, retval = true, toFront = true } )
   

   local drag3 = newImageRect( group, centerX + 150, centerY, "images/corona256.png", { size = 120 }, { radius = 60 } )
   ssk.misc.addPhysicsDrag( drag3, { force = 300, fromCenter = false, retval = true, toFront = true } )
   

   local plat = newRect( group, centerX, centerY + 100, { w = 600 }, { bodyType = "static" } )

end


return test
