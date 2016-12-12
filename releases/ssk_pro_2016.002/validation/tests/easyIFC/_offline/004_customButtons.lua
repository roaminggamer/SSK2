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

   -- Custom Buttons
   local function onPush( event )
   	print( event.target:getText() )
   end
   easyIFC:presetNavButton( group, "default", curX, curY, 180, 50, "Composer Navigation" )

   curX = curX + 200
   easyIFC:presetBackButton( group, "default_back", curX, curY, 50, 50, "" )

   curX = curX + 200
   --easyIFC:presetAudioButton( group, "default_sound", curX, curY, 50, 50, "" )

   curX = curX + 200
   local function onBob( event )
      table.dump(event)
   end; listen("onBob",onBob)
   easyIFC:presetEventButton( group, "default", curX, curY, 180, 50, "Event: onBob", nil, { eventName = "onBob" } )

   curX = startX
   curY = curY + 100
   easyIFC:presetURLButton( group, "default", curX, curY, 180, 50, "URL: RG Home", nil, { url = "http://roaminggamer.com/" } )

   curX = curX + 200
   easyIFC:presetRateButton( group, "default_rate", curX, curY, 50, 50, "", nil,
      { 
         iosRateID = "iOS Rate ID HERE",
         androidRateID = "Google Play Rate ID HERE",
      } )

   curX = curX + 200
   easyIFC:presetShareButton( group, "default_share", curX, curY, 50, 50, "", nil,
      { 
         share_settings = "tbd"
      } )
   

end


return test
