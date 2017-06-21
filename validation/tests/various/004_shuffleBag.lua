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

local bag1
local bag2

local shuffleBag = ssk.shuffleBag


local test = {}

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   -- Run tests
   bag1(group)

   bag2(group)   

end


-- ==========================================================
-- === Shuffle Bag Example 1
-- ==========================================================
bag1 = function( group )  

	local cardGroup = display.newGroup()
	group:insert( cardGroup )
   
   local cards = shuffleBag.new( "jack.png", "king.png", "queen.png", "ace.png" )
   
   cards:shuffle()
   
   local function showCards( button )
      display.remove(cardGroup)
      cardGroup = display.newGroup()
      group:insert( cardGroup )
      
      for i = 1, 4 do
         local file = cards:get()         
         local card = display.newImageRect( cardGroup, "images/kenney/" .. file, 140, 190 )
         card.x = button.x + 160 * i
         card.y = button.y
      end
   end
      
   --
   -- Basic button to 'run' showCards() when touched.
   --   
   local function onDeal( event )
   	showCards( event.target )
   end
   easyIFC:presetPush( group, "default", left + 75, centerY - 110, 100, 40, "Deal", onDeal,  { strokeWidth = 3 } )
end


-- ==========================================================
-- === Shuffle Bag Example 2 - Insert +  Auto Reshuffle
-- ==========================================================
bag2 = function( group )  
   
	local cardGroup = display.newGroup()
	group:insert( cardGroup )
   
   local cards = shuffleBag.new()
   
   cards:insert( "jack.png" )
   cards:insert( "king.png" )
   cards:insert( "queen.png" )
   cards:insert( "ace.png" )
   
   cards:shuffle()

   local group = display.newGroup()
   
   local function showCards( button )
      display.remove(cardGroup)
      cardGroup = display.newGroup()
      group:insert( cardGroup )
      
      for i = 1, 5 do
         local file = cards:get()         
         local card = display.newImageRect( cardGroup, "images/kenney/" .. file, 140, 190 )
         card.x = button.x + 160 * i
         card.y = button.y
      end
   end
      
   --
   -- Basic button to 'run' showCards() when touched.
   --   
   local function onDeal( event )
   	showCards( event.target )
   end
   easyIFC:presetPush( group, "default", left + 75, centerY + 110 , 100, 40, "Deal", onDeal,  { strokeWidth = 3 } )
end



return test
