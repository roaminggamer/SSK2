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
--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale


local RGTiled = ssk.tiled
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
	factoryMgr.init( "segment", { segmentType = "vert", 
		                           leftWallPosition = left + 40, 
		                           rightWallPosition = right - 40 })

	factoryMgr.init( "player", { moves = "vert" } ) 

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

	--
	-- Create One Touch Easy Input
	--
	ssk.easyInputs.oneTouch.create(layers.underlay , { debugEn = params.debugEn } )
	--ssk.easyInputs.twoTouch.create(layers.underlay, { debugEn = params.debugEn, keyboardEn = true } )
	--ssk.easyInputs.oneStick.create( layers.underlay, { debugEn = true, joyParams = { doNorm = true } } )
	--ssk.easyInputs.twoStick.create( layers.underlay, { debugEn = true, joyParams = { doNorm = true } } )
	--ssk.easyInputs.oneStickOneTouch.create( layers.underlay, { debugEn = true, joyParams = { doNorm = true } } )

	--
	-- Create HUDs
	--
	--factoryMgr.new( "scoreHUD", layers.interfaces, centerX, top + 40 )	

	--
	-- Add listener to layers to content
	--
	function layers.onNewSegment( self, event  )
		-- Don't create content till we hit `creationStartCount`
		if( event.count < common.creationStartCount ) then return end


		local choice = mRand( 1, 3 )
		if( choice == 1 ) then
			local x,y = event.x + mRand( -fullw/2 + 100, fullw/2 - 100 ), event.y
			local coin = factoryMgr.new( "coin", layers.content, x, y, { size = 24 } )
		elseif( choice == 2 ) then
			local x,y = event.x + mRand( -fullw/2 + 100, fullw/2 - 100 ), event.y
			local coin = factoryMgr.new( "danger", layers.content, x, y, { size = 24 } )
		end

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
	factoryMgr.new( "segment", layers.content, centerX, bottom, 
		             { preTrigger = true, segmentHeight = common.segmentHeight, 
		               debugEn = params.debugEn } )

	for i = 2, common.numStartSegments do
		factoryMgr.new( "segment", layers.content, centerX, nil,
			             { preTrigger = false, segmentHeight = common.segmentHeight, 
			               debugEn = params.debugEn} )
	end

	--
	-- Create Player
	--
	factoryMgr.new( "player", layers.player,  centerX, centerY,  
		            {	world = layers.world } )	

end


return game
