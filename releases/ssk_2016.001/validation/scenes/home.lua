-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
--  scenes/home" )
-- =============================================================
local composer       = require( "composer" )
local scene          = composer.newScene()
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
--
-- Specialized SSK Features
local actions = ssk.actions
local rgColor = ssk.RGColor

--ssk.misc.countLocals(1)

----------------------------------------------------------------------
-- Locals
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Scene Methods
----------------------------------------------------------------------
function scene:create( event )
   local sceneGroup = self.view

   local background = display.newRect( sceneGroup, centerX, centerY, fullw, fullh )
   background:setFillColor( 0.2, 0.5, 0.8 )
   local title = display.newText( sceneGroup, "SSK2 Validation Sampler", centerX, top + 30, 
                                  native.systemFontBold, 36 )

   local examples = 
   {
      { "Actions - Face Instantly", "tests.actions.001_face_instant" },
      { "Actions - Face Over Time", "tests.actions.002_face_over_time" },
      { "Actions - Move Forward w/ Physics", "tests.actions.003_movep_forward" },
      { "Actions - Thrust Forward", "tests.actions.004_movep_thrust" },
      { "Actions - Limit Velocity", "tests.actions.005_movep_limitv" },
      { "Actions - Impulse Forward", "tests.actions.006_movep_impulse_forward" },
      { "Actions - Screen Wrapping (rectangle)", "tests.actions.007_rect_wrapping" },

      { "Camera - Tracking", "tests.camera.001_tracking" },
      { "Camera - Delayed Tracking", "tests.camera.002_delayedTracking" },
      { "Camera - Loose Rectangular Tracking", "tests.camera.003_trackingLooseRectangle" },
      { "Camera - Loose Circular Tracking", "tests.camera.004_trackingLooseCircle" },

      { "Colors - Globals", "tests.colors.001_globals" },
      { "Colors - HSL", "tests.colors.002_hsl" },
      { "Colors - Pastel", "tests.colors.003_pastel" },

      { "Display - Basic Tests", "tests.display.001_basic" },
      { "Display - Auto Listeners", "tests.display.002_autoListeners" },
      { "Display - Lines", "tests.display.003_lines" },

      { "Easy Interfaces - Basic Buttons", "tests.easyIFC.001_basicButtons" },
      { "Easy Interfaces - Quick Labels", "tests.easyIFC.002_quick_labels" },
      { "Easy Interfaces - Effects", "tests.easyIFC.003_effects" },

      { "Easy Inputs - One Touch", "tests.easyInputs.001_oneTouch" },
      { "Easy Inputs - Two Touch", "tests.easyInputs.002_twoTouch" },
      { "Easy Inputs - One Stick", "tests.easyInputs.003_oneStick" },
      { "Easy Inputs - Two Stick", "tests.easyInputs.004_twoStick" },
      { "Easy Inputs - One Stick + One Touch", "tests.easyInputs.005_oneStickOneTouch" },
      { "Easy Inputs - Prettier One Stick", "tests.easyInputs.006_pretty_oneStick" },
      
      { "Various - Security", "tests.various.001_security" },
      { "Various - Persist", "tests.various.002_persist" },
      { "Various - Misc", "tests.various.003_misc" },
      { "Various - Shuffle Bags", "tests.various.004_shuffleBag" },
      { "Various - Math 2D", "tests.various.005_math2d" },
      { "Various - Sound Manager", "tests.various.006_soundMgr" },
      { "Various - (Basic) Meters", "tests.various.007_meters" },

   }
   print(#examples)

   -- Automatically generate and place buttons to run each sample:
   -- 
   local buttonW = 300
   local buttonH = 32
   local tweenY  = buttonH + 10
   local startY = top + 80
   local startX = left + buttonW/2 + 20
   local curY = startY
   local curX = startX
   local buttons = {}
   local function newButton( num, label, sampleScript )
      buttons[#buttons+1] = easyIFC:presetPush( sceneGroup, "default", curX, curY, 
         buttonW, buttonH, 
         "  (" .. num .. ") " .. label, onTouch, 
         { labelSize = 14, strokeWidth = 0 } )
      buttons[#buttons].sampleScript = sampleScript

      curY = curY + tweenY

      if( curY + tweenY > bottom) then
         curY = startY
         curX = curX + buttonW + 10
      end
   end
   for i = 1, #examples do
      newButton( i, examples[i][1], examples[i][2] )
   end
   --nextFrame( function() buttons[#buttons]:toggle() end )
end

----------------------------------------------------------------------
function scene:willShow( event )
   local sceneGroup = self.view
end

----------------------------------------------------------------------
function scene:didShow( event )
   local sceneGroup = self.view
end

----------------------------------------------------------------------
function scene:willHide( event )
   local sceneGroup = self.view

end

----------------------------------------------------------------------
function scene:didHide( event )
   local sceneGroup = self.view

end

----------------------------------------------------------------------
function scene:destroy( event )
   local sceneGroup = self.view

end

----------------------------------------------------------------------
--          Custom Scene Functions/Methods
----------------------------------------------------------------------
onTouch = function( event )
   --print(event.target.sampleScript)   
   composer.gotoScene( "scenes.runSample", 
      { 
         time = 100, 
         effect = "fade", 
         params = { sampleScript = event.target.sampleScript } 
      } ) 
end

---------------------------------------------------------------------------------
-- Scene Dispatch Events, Etc. - Generally Do Not Touch Below This Line
---------------------------------------------------------------------------------

-- This code splits the "show" event into two separate events: willShow and didShow
-- for ease of coding above.
function scene:show( event )
   local sceneGroup  = self.view
   local willDid  = event.phase
   if( willDid == "will" ) then
      self:willShow( event )
   elseif( willDid == "did" ) then
      self:didShow( event )
   end
end

-- This code splits the "hide" event into two separate events: willHide and didHide
-- for ease of coding above.
function scene:hide( event )
   local sceneGroup  = self.view
   local willDid  = event.phase
   if( willDid == "will" ) then
      self:willHide( event )
   elseif( willDid == "did" ) then
      self:didHide( event )
   end
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
---------------------------------------------------------------------------------
return scene