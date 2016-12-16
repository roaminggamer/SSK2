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

local pex = ssk.pex

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

   -- ==========================================
   -- 1. Particle Designer Format
   -- ==========================================
   local emitter1 = pex.loadPD2( nil, centerX - 200, centerY, 
                          "emitters/ParticleDesigner2/Comet.json",
                           { texturePath = "emitters/ParticleDesigner2/" } )
   emitter1.rotation = 45

   -- ==========================================
   -- 2. Roaming Gamer Particle Editor (1 & 2)
   -- ==========================================
   local emitter2 = pex.loadRG( nil, centerX, centerY, 
                          "emitters/RG/emitter16178.rg",
                           { texturePath = "emitters/RG/",
                           altTexture = "particle78348.png" } )

   -- ==========================================
   -- 3. Starling Format
   -- ==========================================
   local emitter3 = pex.loadStarling( nil, centerX + 200, centerY, 
                          "emitters/Starling/particle3.pex",
                           { altTexture = "images/star.png" } )


end


return test
