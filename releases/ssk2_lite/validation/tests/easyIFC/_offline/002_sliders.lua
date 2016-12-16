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

   local curX = centerX
   local curY = startY

   -- Preset Slider
   --local function onEvent( event )
   	--table.dump(event)
     -- print("onEvent() ", event.target:getValue())
   --end

   --local function onRelease( event )
      --table.dump(event)
      --print("onRelease() ", event.target:getValue())
   --end

   local tmp = easyIFC:presetSlider( group, "default_slider", curX, curY, 400, 40, onEvent, onRelease)
   tmp:setValue(0.25)


   -- Quick Horiz Slider
   curY = curY + 200
   --quickHorizSlider( group, x, y, w, h, imageBase, onEvent, onRelease, knobImgBase, kw, kh )

end


return test
