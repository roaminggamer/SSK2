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
local test = {}

local factoryMgr = ssk.factoryMgr

factoryMgr.register( "smiley", "tests.factories.example1" )
factoryMgr.register( "corona", "tests.factories.example2" )
factoryMgr.register( "rg", "tests.factories.example3" )

factoryMgr.init()

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   local tmp = factoryMgr.new( "rg", group, centerX, centerY, { size = 80 } )

   local tmp = factoryMgr.new( "corona", group, centerX - 100, centerY, { size = 50 } )

   local tmp = factoryMgr.new( "smiley", group, centerX + 100, centerY )
  

end


return test
