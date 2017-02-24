-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- common.lua - Common Settings Module
-- =============================================================
local common = {}

-- Game Logic Settings
common.gameIsRunning 			= false
common.creationStartCount 		= 1
common.segmentWidth 		  		= w/4 

-- Various Game Metrics & Settings
common.score 						= 0
common.coins 						= 0
common.distance 					= 0
common.distanceUnits				= ""
common.pixelsToDistance 		= 50
common.coinFrequency				= 3
common.coinYOffset				= h/3

-- World Settings
common.gravityX 					= 0
common.gravityY 					= 10

-- Player Settings
common.playerVelocity 			= 150
common.playerImpulse 			= 9
common.playerHeight				= 150
common.playerWidth				= common.playerHeight * 0.75
common.playerCollisionOffset	= 20

-- Track Settings
common.trackDeltaY				= 40
common.trackDeltaX				= { 50, 100, 150 }
common.trackMinY 					= top + 200
common.trackMaxY 					= bottom - 200

return common
