-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
--  main.lua
-- =============================================================
-- 
-- =============================================================
io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)
-- =============================================================
-- LOAD & INITIALIZE - SSK 2
-- =============================================================
require "ssk2.loadSSK"
_G.ssk.init( { launchArgs 				= ..., 
	            enableAutoListeners 	= true,
	            exportCore 				= true,
	            exportColors 			= true,
	            useExternal 			= true,
	            exportSystem 			= true,
	            gameFont 				= "Prime.ttf",
	            debugLevel 				= 0 } )
-- =============================================================
-- Optionally enable meters to check FPS and Memory usage.
-- =============================================================
--ssk.meters.create_fps(true)
ssk.meters.create_mem(true)
-- =============================================================
local common 		= require "scripts.common"
local game 			= require "scripts.game"
local factoryMgr 	= ssk.factoryMgr
local soundMgr		= ssk.soundMgr
--local physics = require "physics"
--physics.setScale( 30 )

--
-- Initialize Sound
--
if( soundMgr ) then
	soundMgr.setDebugLevel(1)
	soundMgr.enableSFX(true)
	soundMgr.enableMusic(false)
	soundMgr.setVolume( 0.5, "music" )
	soundMgr.addEffect( "coin", "sounds/sfx/coin.wav")
	soundMgr.addEffect( "gate", "sounds/sfx/gate.wav")
	soundMgr.addEffect( "died", "sounds/sfx/died.wav")
	soundMgr.addMusic( "soundTrack", "sounds/music/Kick Shock.mp3")
end

--
-- Register Factories
--
factoryMgr.register( "segment", "factories.world.segment" )
factoryMgr.register( "player", "factories.players.dummy" )
factoryMgr.register( "coin", "factories.pickups.coin" )
factoryMgr.register( "gate", "factories.world.flappy_color_gate" )
factoryMgr.register( "scoreHUD", "factories.huds.scoreHUD" )
factoryMgr.register( "coinsHUD", "factories.huds.coinsHUD" )
factoryMgr.register( "distanceHUD", "factories.huds.distanceHUD" )

--
-- Initialize Game & Start
--
game.init()
game.start( nil, { debugEn = true } )

