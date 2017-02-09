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

   local back = newRect( group, centerX, centerY, { fill = _DARKERGREY_, w = fullw, h = fullh } )

   -- Rotate 10 squares about axis 1 as same radius
   local axis1 = newCircle( group, centerX - 150, centerY - 100, { fill = _Y_ })

   for i = 1, 10 do
   	local tmp = newRect( group, axis1.x, axis1.y, { fill = randomColor(), size = 10 } )
   	ssk.misc.rotateAbout( tmp, axis1.x, axis1.y, 
   		                  { startA = i * 36, 
   		                    endA = i * 36 + 7200,
   		                    time = 20000, radius = 125 } )
   end


   -- Rotate 10 squares about axis 2 and slowly move them inward too.
   local axis2 = newCircle( group, centerX + 150, centerY - 100, { fill = _O_ })

   for i = 1, 10 do
   	local tmp = newRect( group, axis2.x, axis2.y, { fill = randomColor(), size = 10 } )
   	local doSpin
   	ssk.misc.rotateAbout( tmp, axis2.x, axis2.y, 
   		                  { startA = i * 36, 
   		                    endA = i * 36 + 1800,
   		                    time = 1000, radius = 125, 
   		                    endRadius = 10,
   		                    onComplete = display.remove } )
   end

   -- Inspired by this thread:
   -- https://forums.coronalabs.com/topic/67561-have-multiple-bullets-fire-inward-in-a-circle-formation-ssk2/
   local axis3 = newCircle( group, centerX, centerY + 150, { fill = _R_ })

   local doBullets
   doBullets = function( axis, delay, count )
	   for i = 1, 10 do
	   	local tmp = newRect( group, axis3.x, axis3.y, { fill = _R_, size = 10 } )
	   	local angle = i * 36
	   	ssk.misc.rotateAbout( tmp, axis3.x, axis3.y, 
	   		                  { startA = angle, endA = angle + 360 + 36,
	   		                    time = 2000, radius = 125, 
                                endRadius = 10, radiusTime = 750 } )

         tmp.onComplete = function( self )
         	ignore("enterFrame", self)
         	display.remove( self )
         end

	   end

	   if( count ) then 
	   	count = count - 1
	   	if( count <= 0 ) then return end
	   	timer.performWithDelay( delay, function() doBullets(axis, delay, count) end )
	   end
   end
   doBullets( axis3, 600, 3 )

  

end


return test
