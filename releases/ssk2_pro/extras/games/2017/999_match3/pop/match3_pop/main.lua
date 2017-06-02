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

local gb 			= require "scripts.gameboard"
local dbmgr 		= require "scripts.dbmgr2"
local letterSel 	= require "scripts.letterselector"

----------------------------------------------------------------------
--	2. Initialization
----------------------------------------------------------------------
dbmgr.initDB( "data/enable1.tbl" )
letterSel.randomizeDieOrder(100)

-- Create some rendering layers


local function runTest( test )
	test = test or 1

	local layers = ssk.display.quickLayers( nil, "underlay", "background", "content", "buttons", "overlay" )

	ssk.display.newImageRect( layers.underlay, centerX, centerY, 
	           "images/ui/protoBack.png", 
	           { w = 760, h = 1140 } )

	if( test == 1 ) then
		gb.newLettersRectBoard( layers.content, centerX, centerY, 
			{ img = "images/letters/button_toonMarble.png", size = 60, offset = 5, rows = 5, cols = 5, touchRadius = 40 })
	
	elseif( test == 2 ) then
		gb.newLettersRectBoard( layers.content, centerX, centerY, 
		              	{ img = "images/letters/squareTile2.png", 
		              	size = 60, offset = 1, rows = 7, cols = 7, touchRadius = 40 })

	elseif( test == 3 ) then
		local board = gb.newLettersCircleBoard( layers.content, centerX, centerY, 
			              { img = "images/letters/button_toonMarble.png", 
			              size = 60, offset = 5, rings = 3, touchRadius = 30, doHex = false })


	elseif( test == 4 ) then
		gb.newColorsRectBoard( layers.content, centerX, centerY, 
			              { img = "images/letters/squareTile2.png", 
			              size = 80, offset = 5, rows = 5, cols = 5, touchRadius = 40 })

	elseif( test == 5 ) then
		local gems = "images/gems/"
		local board = gb.newColorsCircleBoard( layers.content, centerX, centerY + 70, 
			              { --img = "images/letters/button_toonMarble.png", 
			              colorImgs = { gems .. "1.png",
			                            gems .. "2.png", 
			                            gems .. "3.png",
			                            gems .. "6.png",
			                            gems .. "8.png" },
			              size = 80, offset = 2, rings = 4, 
			              touchRadius = 36, doHex = true })
	end


	if( test == 5 ) then
		local meters = display.newGroup()
		local allMeters = {}
		layers.content:insert( meters )
		local colors = { _R_, _G_, _B_ }
		local colorNames = { "Red", "Green", "Blue" }
		local x = { centerX - 100, centerX - 25, centerX + 100 - 50}
		for i = 1, #colors do
			local meterBack = ssk.display.newRect( meters, x[i], top + 110, { w = 54, h = 24, } )
			meterBack.anchorX = 0
			local meter = ssk.display.newRect( meters, x[i], top + 110, { w = 50, h = 20, fill = colors[i] } )
			meter.label = display.newText( meters, "FULL", x[i] + 27, top + 110, system.nativeFont, 10 )
			meter.label.isVisible = false
			meter.anchorX = 0
			meter.x = meter.x + 2
			meter.total = 1
			meter.max = 6
			meter.myColor = colors[i]
			transition.to(meter, { xScale = meter.total/meter.max, time = 250 })
			meter.onTilesMatch = function( self, event  )
				if( autoIgnore( "onTilesMatch", self ) ) then return end
				if( self.myColor ~= event.color ) then return end
				if( event.count > 0 ) then
					self.total = self.total + event.count
					if(self.total > self.max) then 
						self.total = self.max 
					end
				end
				local onComplete = function( self )
					self.label.isVisible = ( self.total == self.max )
				end

				transition.cancel( self )
				transition.to( self, { xScale = self.total/self.max, time = 1000, onComplete = onComplete })
			end; listen( "onTilesMatch", meter )
		end
	end
end

--runTest(5)

----[[
ssk.misc.easyAlert( "Choose Test", 
	"Tile Type + Tile Style + Board Style", 
	{
		{"5 - Colors + Image + Hex", function() runTest(5) end },
		{"4 - Colors + Square + Square", function() runTest(4) end },
		{"3 - Letters + Round + Circle", function() runTest(3) end },
		{"2 - Letters + Square + Square", function() runTest(2) end },
		{"1 - Letters + Round + Square", function() runTest(1) end },
	})
--]]
