-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
--  main.lua
-- =============================================================
-- =============================================================
io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)
-- =============================================================
_G.fontN 	= "Raleway-Light.ttf" 
_G.fontB 	= "Raleway-Black.ttf" 
-- =============================================================
--require "com.roaminggamer.ssk.loadSSK"
-- =============================================================

require "ssk2.loadSSK"
_G.ssk.init( { launchArgs 				= ..., 
	            gameFont 				= "Raleway-Light.ttf",
	            measure 					= false,
	            math2DPlugin 			= false,
	            enableAutoListeners 	= true,
	            exportColors 			= true,
	            exportCore 				= true,
	            exportSystem 			= true,
	            debugLevel 				= 0 } )

local composer = require "composer"
composer.gotoScene( "scenes.home" )

