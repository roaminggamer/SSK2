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

   --ssk.display.newRect( group, centerX, centerY, { w = fullw, h = fullh, fill = hexcolor("#ED9C55") } )
   ssk.display.newRect( group, centerX, centerY, { w = fullw, h = fullh, fill = _W_ } )

   test.basic( group, params )
   test.custom( group, params )
end

function test.basic( group, params )
   local function showDialogTray( style )

         local width = 600
         local height = 400

         local function onClose( self, onComplete )
            transition.to( self, { y = centerY + fullh, transition = easing.inBack, onComplete = onComplete } )
         end

         local dialog = ssk.dialogs.basic.create( group, centerX, centerY, 
                        { fill = hexcolor("#56A5EC"), 
                          width = width,
                          height = height,
                          softShadow = true,
                          softShadowOX = 8,
                          softShadowOY = 8,
                          softShadowBlur = 6,
                          closeOnTouchBlocker = true, 
                          blockerFill = _K_,
                          blockerAlpha = 0.55,
                          softShadowAlpha = 0.6,
                          blockerAlphaTime = 100,
                          onClose = onClose,
                          style = style } )

         table.dump(dialog)


         local function closeTray( event )
            onClose( dialog, function() dialog.frame:close() end )
         end
         easyIFC:presetPush( dialog, "default", 0, 0, 320, 50, "Close Basic Dialog Tray: Style " .. style, closeTray )

         easyIFC.easyFlyIn( dialog, { delay = 250, time = 500, sox = 0, soy = fullh } )
   end

   local function onStyle1( event )
      showDialogTray(1)    
   end
   easyIFC:presetPush( group, "default", centerX - 200, centerY - 75, 320, 50, "Show Basic Dialog Tray: Style 1", onStyle1 )


   local function onStyle2( event )
      showDialogTray(2)    
    
   end
   easyIFC:presetPush( group, "default", centerX - 200, centerY, 320, 50, "Show Basic Dialog Tray: Style 2", onStyle2 )


end


-- ==
--    
-- ==
function test.custom( group )

   local function showDialogTray( scale, style )
      scale = scale or 1

      local width, height = ssk.misc.getImageSize( "images/fantasygui/dialog" .. style .. ".png" )
      width = width * scale
      height = height * scale

      local function onClose( self, onComplete )
         transition.to( self, { y = centerY + fullh, transition = easing.inBack, 
                                         onComplete = onComplete } )
      end

      local dialog = ssk.dialogs.custom.create( group, centerX, centerY, 
                     { width = width,
                       height = height,
                       softShadow = true,
                       softShadowOX = 8,
                       softShadowOY = 8,
                       softShadowBlur = 6,
                       closeOnTouchBlocker = true, 
                       blockerFill = _K_,
                       blockerAlpha = 0.15,
                       softShadowAlpha = 0.3,
                       blockerAlphaTime = 100,
                       onClose = onClose,
                       trayImage = "images/fantasygui/dialog" .. style .. ".png",
                       shadowImage = "images/fantasygui/dialog" .. style .. "_shadow.png" } )


      local function closeTray( event )
         onClose( dialog, function() dialog.frame:close() end )
      end

      ssk.easyIFC:presetPush( dialog, "default", 0, 0, 320, 50, 
                                 "Close Custom Dialog Tray: Example " .. style, closeTray )

      ssk.easyIFC.easyFlyIn( dialog, { delay = 250, time = 500, sox = 0, soy = fullh } )
   end

   local function onStyle1( event )
      showDialogTray(0.5,1)
   end
   ssk.easyIFC:presetPush( group, "default", centerX + 200, centerY - 75, 320, 50, 
                            "Show Custom Dialog Tray: Example 1", onStyle1 )


   local function onStyle2( event )
      showDialogTray(0.75,2)
   end
   ssk.easyIFC:presetPush( group, "default", centerX + 200, centerY, 320, 50, 
                            "Show Custom Dialog Tray: Example 2", onStyle2 )

   local function onStyle3( event )
      showDialogTray(0.75,3)
   end
   ssk.easyIFC:presetPush( group, "default", centerX + 200, centerY + 75, 320, 50, 
                            "Show Custom Dialog Tray: Example 3", onStyle3 )


end

return test