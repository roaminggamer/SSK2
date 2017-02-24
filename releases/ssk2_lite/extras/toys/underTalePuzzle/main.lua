-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
--  main.lua
-- =============================================================
-- Start (code/comments)
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
	            exportSystem 			= true,
	            measure					= false,
	            --useExternal				= true,
	            gameFont 				= native.systemFont,
	            debugLevel 				= 0 } )
-- =============================================================
-- Optionally enable meters to check FPS and Memory usage.
-- =============================================================
--ssk.meters.create_fps(true)
--ssk.meters.create_mem(true)
-- =============================================================
local physics 		= require "physics"
physics.start()

local undertale = require "scripts.undertale"

local offsets = { 0, 10, 20, 30, 40, 30, 20, 10, 0, -10, -20, -30, -40, -30, -20, 0}

local container = undertale.run( nil, offsets, 10, 300 )

-- Hack to delete after 11 seconds
transition.to( container, { alpha = 0, delay = 10000, onComplete = display.remove } )

