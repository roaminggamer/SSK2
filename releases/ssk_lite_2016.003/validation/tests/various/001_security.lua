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

local security = ssk.security

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   table.dump(security)

   -- Print current key (default key)
   local curKey = security.getKeyString()
   print( "Default Key: ", curKey)

   -- Generate and set a new key
   security.genKey()
   local newKey = security.getKeyString()
   print( "Generated key: ", newKey )

   -- Test encoding and decoding.
   local origString = "This is a random string 1234567890."
   local encodedString = security.encode( origString )
   local decodedString = security.decode( encodedString )

   print( "   Original string: " .. tostring( origString ) )
   print( "    Encoded string: " .. tostring( encodedString ) )
   print( "    Decoded string: " .. tostring( decodedString ) )
   print( "    Strings match?: " .. tostring( origString == decodedString ) )

   -- Save key
   security.saveKey( "key.json")

   -- Generate a new key
   security.genKey() 

   -- Load saved key   
	security.loadKey( "key.json")


	-- Test saved, generated, reloaded key
   local reDecodedString = security.decode( encodedString )

   print( " Re-Decoded string: " .. tostring( reDecodedString ) )
   print( "    Strings match?: " .. tostring( origString == decodedString ) )
end


return test
