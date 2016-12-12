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

local misc = ssk.misc

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   -- =============================================================
   -- Connected to web?
   -- =============================================================
   print( "Connected to web ", misc.isConnectedToWWW() )


   -- =============================================================
   -- Test timer formating
   -- =============================================================
   local randomSeconds = mRand(10000,999999)
   
   -- Seconds to timer version 1
   local timerVal = misc.secondsToTimer( randomSeconds, 1 )	
   print( " ver 1 " .. tostring(randomSeconds) .. " => " .. tostring( timerVal ) )

   -- Seconds to timer version 2
   local timerVal = misc.secondsToTimer( randomSeconds, 2 )	
   print( " ver 2 " .. tostring(randomSeconds) .. " => " .. tostring( timerVal ) )

   -- Seconds to timer version 3
   local nDays,nHours,nMins,nSecs = misc.secondsToTimer( randomSeconds, 3 )	
   print( " ver 3 " .. tostring(randomSeconds) .. " => " .. 
          tostring( nDays ) .. " days " ..
          tostring( nHours ) .. " hours " ..
          tostring( nMins ) .. " mins " ..
          tostring( nSecs ) .. " seconds " )


   -- =============================================================
   -- Test Easy Underline
   -- =============================================================
   local tmp = display.newText( "Add a green line under this test", 200, 200 )
   misc.easyUnderline( tmp, _G_, 3, 40)


   -- =============================================================
   -- Test Fit Text
   -- =============================================================
   local tmp = display.newText( "Original line which is too long", 200, 300 )
   local tmp = display.newText( "Original line which is too long", 200, 400 )
   misc.fitText( tmp, "Original line which is too long", 200 )

   -- =============================================================
   -- Test Image Size Discovery
   -- =============================================================
   print( misc.getImageSize( "images/rg256.png" ) )


   -- =============================================================
   -- Test Rotate About
   -- =============================================================
   local circ = display.newCircle( 0, 0, 20)
   local function doRotate( obj )
   	misc.rotateAbout( obj, 600, 500, { startA = 90, delay = 500, onComplete = doRotate } )
   end
   doRotate( circ )

   -- =============================================================
   -- Test Easy Blur
   -- =============================================================
   local group = display.newGroup()
   group:toBack()
	local image = display.newImageRect( group, "images/rg256.png", 256, 256 )
	image.x = right - 250
	image.y = top + 250

	misc.easyBlur( group )

   -- =============================================================
   -- Test Easy Shake
   -- =============================================================
   misc.easyShake( group, 100, 500 )

   -- =============================================================
   -- Test Easy Alert
   -- =============================================================
   misc.easyAlert( "Easy Alert Test", 
   	             "This helper makes it easy to write alerts with functions attached to the buttons.",
   	             {
   	                 { "Boo", function() print( "Ya!" ) end },
   	                 { "Hi", function() print( "there." ) end },
   	                 { "Shake again!", function() misc.easyShake( group, 100, 2000 ) end },
   	             } )


   -- =============================================================
   -- Test Is Valid Email checker.
   -- =============================================================
   local validEmailAddr = "bob@mailserver.com"
   local invalidEmailAddr = "bob@"
   print(validEmailAddr .. " valid? " .. tostring( misc.isValidEmail( validEmailAddr ) ) )
   print(invalidEmailAddr .. " valid? " .. tostring( misc.isValidEmail( invalidEmailAddr ) ) )


end


return test
