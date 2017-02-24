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
	            useExternal				= true,
	            gameFont 				= native.systemFont,
	            debugLevel 				= 0 } )
-- =============================================================
-- Optionally enable meters to check FPS and Memory usage.
-- =============================================================
--ssk.meters.create_fps(true)
--ssk.meters.create_mem(true)
-- =============================================================

local back = ssk.display.newRect( nil, centerX, centerY, { w = fullw, h = fullh, alpha = 0.2 } )
function back.onBoardLock( self, event )
	if( event.locked ) then 
		self:setFillColor( unpack(_P_) )
	else
		self:setFillColor( unpack(_Y_) )
	end
end; listen( "onBoardLock", back )

local m3 = require "scripts.m3"

local board = m3.newBoard( nil, centerX, centerY, { rows = 5, cols = 5, size = 80 } )


--local cardTest = require "cardTest"
--cardTest.run()

--local blackjackTest = require "blackjackTest"
--blackjackTest.run()
--easyAlert( "Choose Game", "", {{"Cards Test", cardTest.run},{"Blackjack Test", blackjackTest.run}})
