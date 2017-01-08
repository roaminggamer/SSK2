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

   ssk.display.newRect( group, centerX, centerY, { w = fullw, h = fullh, fill = hexcolor("#ED9C55") } )

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
         easyIFC:presetPush( dialog, "default", 0, 0, 280, 50, "Close Dialog Tray: Style " .. style, closeTray )

         easyIFC.easyFlyIn( dialog, { delay = 250, time = 500, sox = 0, soy = fullh } )
   end

   local function onStyle1( event )
      showDialogTray(1)    
   end
   easyIFC:presetPush( group, "default", centerX - 200, centerY, 280, 50, "Show Dialog Tray: Style 1", onStyle1 )


   local function onStyle2( event )
      showDialogTray(2)    
    
   end
   easyIFC:presetPush( group, "default", centerX + 200, centerY, 280, 50, "Show Dialog Tray: Style 2", onStyle2 )


end


return test
