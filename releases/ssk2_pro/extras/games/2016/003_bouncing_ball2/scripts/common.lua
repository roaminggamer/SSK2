-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- common.lua - Common Settings Module
-- =============================================================
local common = {}


-- Game Logic Settings
common.gameIsRunning 			= false
common.creationStartCount 		= 1
common.segmentWidth 		  		= 220 

-- Various Game Metrics & Settings
common.score 						= 0
common.coins 						= 0
common.distance 					= 0
common.distanceUnits				= "meters"
common.pixelsToDistance 		= 100
common.coinFrequency				= 3
common.coinYOffset				= h/3

-- World Settings
common.gravityX 					= 0
common.gravityY 					= 20

-- Player Settings
common.playerVelocity 			= 250
common.extraDownVelocity		= 700
common.playerMinBounceImpulse = 12
common.playerMaxBounceImpulse = 16

-- Platform Height
common.platformWidth 			= { 20, 40, 55, 75 } 
common.platformDeltaY			= { 10, 20, 30 }
common.platformStartY			= centerY + 160
common.platformMinY				= common.platformStartY + 80
common.platformMaxY				= common.platformStartY - 80


return common
