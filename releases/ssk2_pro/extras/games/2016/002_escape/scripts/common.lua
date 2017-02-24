-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- common.lua - Common Settings Module
-- =============================================================
local common = {}

-- Game Logic Settings
common.gameIsRunning 			= false
common.creationStartCount 		= 2
common.segmentWidth 		  		= w/2 

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
common.playerImpulse 			= 13

-- Rock Height
common.rockMaxHeight 			= 120
common.rockMinWidth 				= 40
common.rockMaxWidth 				= 160
common.rockMaxDelta				= 80
common.rockMinY					= top + 200
common.rockMaxY					= bottom - 100

return common
