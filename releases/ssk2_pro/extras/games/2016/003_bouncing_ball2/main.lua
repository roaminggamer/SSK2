-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
--  main.lua
-- =============================================================
-- Bouncing Ball 2 Starter (609/667)
-- =============================================================
io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)
-- =============================================================
_G.fontN 	= "Raleway-Light.ttf" 
_G.fontB 	= "Raleway-Black.ttf" 
-- =============================================================
-- LOAD & INITIALIZE - SSK 2
-- =============================================================
require "ssk2.loadSSK"
_G.ssk.init( { launchArgs 				= ..., 
	            enableAutoListeners 	= true,
	            exportCore 				= true,
	            exportColors 			= true,	            
	            exportSystem 			= true,
	            gameFont 				= "Prime.ttf",
	            debugLevel 				= 0 } )
-- =============================================================
-- Optionally enable meters to check FPS and Memory usage.
-- =============================================================
--ssk.meters.create_fps(true)
--ssk.meters.create_mem(true)
-- =============================================================
local common 		= require "scripts.common"
local game 			= require "scripts.game"
local factoryMgr 	= ssk.factoryMgr
local soundMgr		= ssk.soundMgr

--
-- Initialize Sound
--
if( soundMgr ) then
	soundMgr.setDebugLevel(1)
	soundMgr.enableSFX(true)
	soundMgr.enableMusic(false)
	soundMgr.setVolume( 0.5, "music" )
	soundMgr.addEffect( "coin", "sounds/sfx/coin.wav")
	soundMgr.addEffect( "gate", "sounds/sfx/gate.wav", { minTweenTime = 100 } )
	soundMgr.addEffect( "died", "sounds/sfx/died.wav")
	soundMgr.addMusic( "soundTrack", "sounds/music/Kick Shock.mp3")
end

--
-- Register Factories
--
factoryMgr.register( "segment", "factories.world.segment" )
factoryMgr.register( "player", "factories.players.bouncing_ball2" )
factoryMgr.register( "coin", "factories.pickups.coin" )
factoryMgr.register( "platform", "factories.world.bouncing_ball2_pillar" )
factoryMgr.register( "scoreHUD", "factories.huds.scoreHUD" )

--
-- Initialize Game & Start
--
game.init()
game.start( nil, { debugEn = true } )

