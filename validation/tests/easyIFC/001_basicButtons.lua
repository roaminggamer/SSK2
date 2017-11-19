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

   -- Push Buttons
   local function onPush( event )
   	print( event.target:getText() )
   end
   easyIFC:presetPush( group, "default", curX, curY, 180, 50, "Push Button 1", onPush )

   curX = curX + 200
   easyIFC:presetPush( group, "default_edgeless", curX, curY, 180, 50, "Push Button 2", onPush )

   curX = curX + 200
   easyIFC:presetPush( group, "default_edgeless2", curX, curY, 180, 50, "Push Button 3", onPush )

   curX = curX + 140
   easyIFC:presetPush( group, "default_corona", curX, curY, nil, nil, "", onPush )

   curX = curX + 140
   easyIFC:presetPush( group, "default_corona2", curX, curY, nil, nil, "", onPush )

   curX = curX + 150
   easyIFC:presetPush( group, "default_rg", curX, curY, nil, nil, "", onPush )

   -- Toggle Buttons
   curX = startX
   curY = curY + 200
   local function onToggle( event )
   	print( event.target:getText(), event.target:pressed() )
   end
   easyIFC:presetToggle( group, "default", curX, curY, 180, 50, "Toggle Button 1", onToggle )

   curX = curX + 200
   easyIFC:presetToggle( group, "default_check", curX, curY, 35, 35, "Toggle Button 2", onToggle )

   curX = curX + 200
   easyIFC:presetToggle( group, "default_check2", curX, curY, 35, 35, "Toggle Button 3", onToggle )

   curX = curX + 140
   easyIFC:presetToggle( group, "default_corona", curX, curY, nil, nil, "", onToggle )

   curX = curX + 140
   easyIFC:presetToggle( group, "default_corona2", curX, curY, nil, nil, "", onToggle )

   curX = curX + 150
   easyIFC:presetToggle( group, "default_rg", curX, curY, nil, nil, "", onToggle )

   -- Radio Buttons Set A
   local groupA = display.newGroup()
   group:insert(groupA)
   curX = startX
   curY = curY + 150
   local function onRelease( event )
   	print( event.target:getText(), event.target:pressed() )
   end
   easyIFC:presetRadio( groupA, "default", curX, curY, 180, 50, "Radio Button 1", onRelease )

   curX = curX + 200
   easyIFC:presetRadio( groupA, "default_radio", curX, curY-10, 35, 35, "Radio Button 2", onRelease )

   curX = curX + 200
   easyIFC:presetRadio( groupA, "default_radio", curX, curY-10, 35, 35, "Radio Button 3", onRelease )

   curX = curX + 200
   easyIFC:presetRadio( groupA, "default_radio", curX, curY-10, 35, 35, "Radio Button 4", onRelease )

   local outline = newRect( groupA, centerX, curY, { fill = _T_, strokeWidth = 2, w = fullw-4, h = 80 })
   local label = display.newText( groupA, "Radio Set A", left+ 5, outline.y - 45, "Raleway-Light.ttf", 22 )
   label.anchorX = 0
   label.anchorY = 1


   -- Radio Buttons Set B
   local groupB = display.newGroup()
   group:insert(groupB)
   curX = startX
   curY = curY + 120
   local function onRelease( event )
      print( event.target:getText(), event.target:pressed() )
   end
   easyIFC:presetRadio( groupB, "default", curX, curY, 180, 50, "Radio Button 1", onRelease )

   curX = curX + 200
   easyIFC:presetRadio( groupB, "default_radio", curX, curY-10, 35, 35, "Radio Button 2", onRelease )

   curX = curX + 200
   easyIFC:presetRadio( groupB, "default_radio", curX, curY-10, 35, 35, "Radio Button 3", onRelease )

   curX = curX + 200
   easyIFC:presetRadio( groupB, "default_radio", curX, curY-10, 35, 35, "Radio Button 4", onRelease )

   local outline = newRect( groupB, centerX, curY, { fill = _T_, strokeWidth = 2, w = fullw-4, h = 80 })
   local label = display.newText( groupB, "Radio Set B", left+ 5, outline.y - 45, "Raleway-Light.ttf", 22 )
   label.anchorX = 0
   label.anchorY = 1


end


return test
