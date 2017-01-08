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

require "presets.fantasygui.presets"

-- =============================================================
local test = {}

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   -- Hack to move all buttons up 100 pixels so I don't need to adjust code (which I copied from another example I wrote)
   local group2 = display.newGroup()
   group:insert(group2)
   group2.y = -100

   local function onTouch( event )
      print( "Button pressed ?", event.target:pressed() )
   end

   local b = {}

   b[#b+1] = easyIFC:presetPush( group2, "wip", centerX - 150, centerY - 100, 200, 60, "", onTouch, {touchOffset          = {3,3}} )
   b[#b+1] = easyIFC:presetPush( group2, "wip", centerX - 150, centerY, 200, 60, "", onTouch, {touchOffset          = {3,3}} )

   b[#b+1] = easyIFC:presetToggle( group2, "wip", centerX - 150, centerY + 100, 200, 60, "", onTouch, {touchOffset           = {3,3}} )
   
   b[#b+1] = easyIFC:presetRadio( group2, "wip", centerX - 150, centerY + 200, 200, 60, "", onTouch, {touchOffset            = {3,3}} )
   b[#b+1] = easyIFC:presetRadio( group2, "wip", centerX - 150, centerY + 275, 200, 60, "", onTouch, {touchOffset            = {3,3}} )

   --local tmp = easyIFC:presetPush( group2, "default", centerX, centerY, 200, 60, "BOO", onTouch )

   b[1]:disable()
   --b[1]:enable()


   local b = {}

   b[#b+1] = easyIFC:presetPush( group2, "wip2", centerX + 150, centerY - 100, 200, 60, "", onTouch, {touchOffset          = {3,3}} )
   b[#b+1] = easyIFC:presetPush( group2, "wip2", centerX + 150, centerY, 200, 60, "", onTouch, {touchOffset          = {3,3}} )

   b[#b+1] = easyIFC:presetToggle( group2, "wip2", centerX + 150, centerY + 100, 200, 60, "", onTouch, {touchOffset          = {3,3}} )
   
   b[#b+1] = easyIFC:presetRadio( group2, "wip2", centerX + 150, centerY + 200, 200, 60, "", onTouch, {touchOffset          = {3,3}} )
   b[#b+1] = easyIFC:presetRadio( group2, "wip2", centerX + 150, centerY + 275, 200, 60, "", onTouch, {touchOffset          = {3,3}} )

   --local tmp = easyIFC:presetPush( sceneGroup, "default", centerX, centerY, 200, 60, "BOO", onTouch )

   b[1]:disable()

   timer.performWithDelay( 1000, function() b[4]:disable() end )
   timer.performWithDelay( 2000, function() b[4]:enable() end )
   --b[1]:enable()

  
end


return test
