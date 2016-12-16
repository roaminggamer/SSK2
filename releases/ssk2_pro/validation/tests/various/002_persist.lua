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

local persist = ssk.persist

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   --persist.setSecure()

   --table.dump(persist)

   -- Set some defaults
   persist.setDefault( "persist_test.json", "aBool", true, { save = false } )
   persist.setDefault( "persist_test.json", "anInt", 10, { save = false } )
   persist.setDefault( "persist_test.json", "aString", "A test string.", { save = false } )
   persist.setDefault( "persist_test.json", "aBool2", true, { save = false } )
   persist.setDefault( "persist_test.json", "anInt2", 10, { save = false } )
   persist.setDefault( "persist_test.json", "aString2", "A test string." )

   -- Print the values in our 
   print( persist.get( "persist_test.json", "aBool" ) )
   print( persist.get( "persist_test.json", "anInt" ) )
   print( persist.get( "persist_test.json", "aString" ) )
   print( persist.get( "persist_test.json", "aBool2" ) )
   print( persist.get( "persist_test.json", "anInt2" ) )
   print( persist.get( "persist_test.json", "aString2" ) )
   print("-----------------------")

   -- Print the values in our 
   persist.set( "persist_test.json", "aBool2", not persist.get( "persist_test.json", "aBool2" ) )
   persist.set( "persist_test.json", "anInt2", mRand(1, 100 ) )
   persist.set( "persist_test.json", "aString2", "A string " .. tostring(mRand(1, 100 )) )
   
   -- Re-print the values in our 
   print( persist.get( "persist_test.json", "aBool" ) )
   print( persist.get( "persist_test.json", "anInt" ) )
   print( persist.get( "persist_test.json", "aString" ) )
   print( persist.get( "persist_test.json", "aBool2" ) )
   print( persist.get( "persist_test.json", "anInt2" ) )
   print( persist.get( "persist_test.json", "aString2" ) )

end


return test
