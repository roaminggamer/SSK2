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
common.playAreaHeight 	  		= 480


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
common.gravityY 					= 22

-- Player Settings
common.playerVelocity 			= 250
common.playerImpulse 			= 13

-- Colors (player and gate)
local green							= hexcolor("#4bcc5a")
local pink							= hexcolor("#d272b4")
local red							= hexcolor("#ff452d")
local yellow						= hexcolor("##ffcc00")
common.colors 						= { green, pink, red, yellow }

-- Colors (Level and Interface)
common.backFill1					= hexcolor("#49432b")
common.backFill2					= hexcolor("#171717")

-- Gate Settings
common.gateHeight 				= common.playAreaHeight/4
common.gateWidth 					= 40
common.gateDelta					= fullh - 300

return common
