-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- common.lua - Common Settings Module
-- =============================================================
local common = {}

-- Game Logic Settings
common.gameIsRunning 			= false

-- Various Game Metrics & Settings
common.score 						= 0
common.coins 						= 0
common.distance 					= 0
common.distanceUnits				= "some unit"

-- World Settings
common.gravityX 					= 0
common.gravityY 					= 9.8

-- Player Settings
common.playerVelocity 			= 250
common.playerImpulse 			= 13

return common
