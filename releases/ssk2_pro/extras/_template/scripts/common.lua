-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- common.lua - Common Settings Module
-- =============================================================
local common = {}

-- Game Logic Settings
common.gameIsRunning 			= false
common.creationStartCount 		= 4
common.segmentWidth 		  		= w/2 

-- Various Game Metrics & Settings
common.score 						= 0
common.coins 						= 0
common.distance 					= 0
common.distanceUnits				= "floors"

-- World Settings
common.gravityX 					= 0
common.gravityY 					= 20

-- Player Settings
common.playerVelocity 			= 250
common.playerImpulse 			= 13


return common
