-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- game.lua - Game Module
-- =============================================================
local common 		= require "scripts.common"
local factoryMgr 	= ssk.factoryMgr
local physics 		= require "physics"

-- =============================================================
-- Localizations
-- =============================================================
-- Commonly used Lua Functions
local getTimer          = system.getTimer
local mRand					= math.random
local mAbs					= math.abs
--
-- Common SSK Display Object Builders
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
--
-- Common SSK Helper Modules
local easyIFC = ssk.easyIFC;local persist = ssk.persist
--
-- Common SSK Helper Functions
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert

-- =============================================================
-- Locals
-- =============================================================
local layers

-- =============================================================
-- Module Begins
-- =============================================================
local game = {}


-- ==
--    init() - One-time initialization only.
-- ==
function game.init()

	--
	-- Mark game as not running
	--
	common.gameIsRunning = false

	--
	-- Initialize all factories
	--
	--factoryMgr.init( "segment", { ceilingPosition = centerY - common.playAreaHeight/2,
	                              --floorPosition = centerY + common.playAreaHeight/2 })
	factoryMgr.init()

	--
	-- Trick: Start physics, then immediately pause it.
	-- Now it is ready for future interactions/settings.
	physics.start()
	physics.pause()

	-- Clear Score, Couins, Distance Counters
	common.score 		= 0
	common.coins 		= 0
	common.distance 	= 0
end


-- ==
--    stop() - Stop game if it is running.
-- ==
function game.stop()
 
	--
	-- Mark game as not running
	--
	common.gameIsRunning = false

	--
	-- Pause Physics
	physics.setDrawMode("normal")	
	physics.pause()
end

-- ==
--    destroy() - Remove all game content.
-- ==
function game.destroy() 
	--
	-- Reset all of the factories
	--
	factoryMgr.reset( )

	-- Destroy Existing Layers
	if( layers ) then
		ignoreList( { "onNewSegment", "onDied" }, layers )
		display.remove( layers )
		layers = nil
	end

	-- Clear Score, Couins, Distance Counters
	common.score 		= 0
	common.coins 		= 0
	common.distance 	= 0
end


-- ==
--    start() - Start game actually running.
-- ==
function game.start( group, params )
	params = params or { debugEn = false }

	game.destroy() 

	--
	-- Mark game as running
	--
	common.gameIsRunning = true

	--
	-- Configure Physics
	--
	physics.start()
	physics.setGravity( common.gravityX, common.gravityY )
	if( params.hybridEn ) then
		physics.setDrawMode("hybrid")	
	end

	--
	-- Create Layers
	--
	layers = ssk.display.quickLayers( group, 
		"underlay", 
		"world", 
			{ "content", "player" },
		"overlay",
		"interfaces" )

	--
	-- Create a background color	
	--
	newRect( layers.underlay, centerX, centerY, 
		      { w = fullw, h = fullh, fill = common.backFill1 })

	--[[
	newRect( layers.overlay, centerX, centerY - common.playAreaHeight/2, 
		      { w = fullw, h = fullh, anchorY = 1,
		        fill = common.backFill2 })

	newRect( layers.overlay, centerX, centerY + common.playAreaHeight/2, 
		      { w = fullw, h = fullh, anchorY = 0,
		        fill = common.backFill2 })
	--]]


	--
	-- Create One Touch Easy Input
	--
	ssk.easyInputs.oneTouch.create(layers.underlay , { debugEn = params.debugEn } )

	--
	-- Create HUDs
	--
	--factoryMgr.new( "scoreHUD", layers.interfaces, centerX, top + 40 )	

	--
	-- Add listener to layers to content
	--
	function layers.onNewSegment( self, event )
		-- Don't create content till we hit `creationStartCount`
		if( event.count < common.creationStartCount ) then return end

		local oy = (mRand(1,5) == 5) and -40 or 0
		--oy = 0

		--
		-- Create New Platform Section
		--
		--[[
		display.setDefault( "textureWrapX", "repeat" )
		local plat = factoryMgr.new( "platform", layers.content, event.x, centerY + 200 + oy, 
												{ width = common.segmentWidth, height = 40,
												  fill = _O_, img = "images/fillW.png" } )
		plat.fill.scaleX = 40/plat.contentWidth
		display.setDefault( "textureWrapX", "clampToEdge" )
		--]]

		-- 
		-- Add Spikes
		-- 
		--[[
		local spikes = factoryMgr.new( "spikes", layers.content, event.x, plat.y - 40, 
												{ width = 40, height = 40,
												  fill = _W_ } )
		plat:toFront()
		--]]
		
	end; listen( "onNewSegment", layers )


	--
	--
	-- Add player died listener to layers to allow it to do work if we need it
	function layers.onDied( self, event  )
		ignore( "onDied", self )
		game.stop()	

		--
		-- Blur the whole screen
		--
		local function startOver()
			game.start( group, params )  
		end
		ssk.misc.easyBlur( layers.interfaces, 250, _R_, 
			                { touchEn = true, onComplete = startOver } )


		-- 
		-- Show 'You Died' Message
		--
		local msg1 = easyIFC:quickLabel( layers.interfaces, "Game Over!", centerX, centerY - 50, ssk.gameFont(), 50 )
		local msg2 = easyIFC:quickLabel( layers.interfaces, "Tap To Play Again", centerX, centerY + 50, ssk.gameFont(), 50 )
		easyIFC.easyFlyIn( msg1, { sox = -fullw, delay = 500, time = 750, myEasing = easing.outElastic } )
		easyIFC.easyFlyIn( msg2, { sox = fullw, delay = 500, time = 750, myEasing = easing.outElastic } )


	end; listen( "onDied", layers )


	--
	-- Attach a finalize event to layers so it cleans it self up when removed.
	--	
	layers.finalize = function( self )
		ignoreList( { "onNewSegment", "onDied" }, self )
	end; layers:addEventListener( "finalize" )

	--
	-- Create three initial hall segments
	--
	factoryMgr.new( "segment", layers.content, left, centerY, 
		             { preTrigger = true, segmentWidth = common.segmentWidth, 
		               debugEn = params.debugEn } )

	for i = 2, common.numStartSegments do
		factoryMgr.new( "segment", layers.content, nil, centerY, 
			             { preTrigger = false, segmentWidth = common.segmentWidth, 
			               debugEn = params.debugEn } )
	end



	--
	-- Create Player
	--
	factoryMgr.new( "player", layers.player,  centerX, centerY,  
		            {	world = layers.world, debugEn = params.debugEn,
		               img = "images/misc/kenney2.png" } )	

end


return game
