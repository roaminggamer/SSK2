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

   -- Verify Quick Label Anchoring ++   
   easyIFC:quickLabel( group, "left-top", left, top, fontB, 24, _PURPLE_, 0, 0 )
   easyIFC:quickLabel( group, "right-top", right, top, fontB, 24, _G_, 1, 0 )
   easyIFC:quickLabel( group, "left-bottom", left, bottom, fontB, 24, _B_, 0, 1 )
   easyIFC:quickLabel( group, "right-bottom", right, bottom, fontB, 24, _Y_, 1, 1 )

   local tmp = display.newLine( group, centerX, top, centerX, bottom )
   tmp.strokeWidth = 2

   local tmp = display.newLine( group, left, centerY, right, centerY )
   tmp.strokeWidth = 2

   easyIFC:quickLabel( group, "center", centerX, centerY, fontB, 48, _BRIGHTORANGE_ )

end


return test
