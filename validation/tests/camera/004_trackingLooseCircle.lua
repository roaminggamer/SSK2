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

   -- Init physics
   local physics = require "physics"
   physics.start()
   physics.setGravity(0,0)

   -- Create some basic layers.
   --
   local layers = quickLayers( group, 
         "underlay",
         "world",
            { "circles", "player" },
         "overlay" )

   -- Create 5000 circles in random locations to act as stuff in our 'world'
   --
   for i = 1, 5000 do
      newCircle( layers.circles, 
                 mRand( -4 * fullw, 4 * fullw ),
                 mRand( -4 * fullh, 4 * fullh ),
                 { size = mRand( 20,40 ), alpha = 0.5,
                   fill = ssk.colors.pastelRGB( ssk.colors.randomRGB() ) } )
   end

   -- Create a joystick to move our 'player'
   --
   ssk.easyInputs.oneStick.create( layers.overlay , 
                                   { joyParams = { doNorm = true } } )

   -- Create a player with a 'enterFrame' listener to 'move' it.
   --
   local function enterFrame( self, event )      
      self:setLinearVelocity( self.vx, self.vy )
   end
   local player = newImageRect( layers.player, centerX, centerY, 
                                "images/smiley.png", 
                                { enterFrame = enterFrame, 
                                  vx = 0, vy = 0 }, {} )

   -- Add a joystick listener to the player
   function player.onJoystick( self, event )     
      if( event.state == "off" ) then
         self.vx = 0
         self.vy = 0
      else
         self.vx = event.nx * 500 * event.percent/100
         self.vy = event.ny * 500 * event.percent/100
      end
   end; listen( "onJoystick", player )


   -- ***************************************
   -- Attach a Tracking Camera To Player + World
   -- ***************************************
   ssk.camera.trackingLooseCircle( player, layers.world, { debugEn = true } )

end


return test
