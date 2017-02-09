-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- game.lua - Game Module
-- =============================================================
local common 		= require "scripts.common"
local physics 		= require "physics"

local factoryMgr 	= ssk.factoryMgr

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

local RGTiled = ssk.RGTiled

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
		ignoreList( { "onDied" }, layers )
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
	if( params.debugEn ) then
		--physics.setDrawMode("hybrid")	
	end

	--
	-- Create Layers
	--
	layers = ssk.display.quickLayers( group, 
		"underlay", 
		"world", 
			{ "background", "content", "foreground" },
		"interfaces" )

	--
	-- Create a background color	
	--
	newRect( layers.underlay, centerX, centerY, 
		      { w = fullw, h = fullh, fill = hexcolor("#2FBAB4") })

	--
	-- Create One Touch Easy Input
	--
	ssk.easyInputs.twoTouch.create(layers.underlay , { debugEn = params.debugEn, keyboardEn = true } )

	--
	-- Create HUDs
	--
	factoryMgr.new( "scoreHUD", layers.interfaces, centerX, top + 40 )
	--factoryMgr.new( "coinsHUD", layers.interfaces, left + 10, top + 70, { iconSize = 40, fontSize = 36 } )
	--factoryMgr.new( "distanceHUD", layers.interfaces, centerX, top + 70, { fontSize = 36 } )


   --table.dump(RGTiled, nil, "RGTiled")   
   local level = RGTiled.new()
   
   --table.dump(level, nil, "level")   
   level.setLevelsPath( "levels" )

   level.load( "level1", {} )

   --table.dump(level, nil, "level loaded")   

   local objects = level.getRecords()
   --table.dump(objects,nil,"objects")

   local images = level.getImages()
   --table.dump(images,nil,"images")

   local function simpleSpinner( obj )
   	obj.rotation = 0
   	obj.onComplete = simpleSpinner
   	local rec = obj.rec
   	local properties = obj.rec.properties
   	transition.to( obj, { rotation = 360, time = properties.rotTime or 1000, onComplete = obj } )
   end

   local function func( rec, num )   	
   	local img = level.getImage( rec.gid )
   	local path = img.image
   	if( rec.gid == 3 ) then
   		factoryMgr.new( "platform", layers.content, rec.x, rec.y, 
   			{ width = rec.width, height = rec.height } )
   	elseif( rec.gid == 7 ) then
   		factoryMgr.new( "player", layers.content, rec.x, rec.y, 
   			{ world = layers.world } )
   	else
   		print("GID", rec.gid)
   	end
   	--[[
   	local obj = newImageRect( layers[rec.layer], rec.x, rec.y, path, 
   		{ w = rec.width, h = rec.height, rec = rec }  )
   	if( rec.flip.x ) then obj.xScale = -obj.xScale end
   	if( rec.flip.y ) then obj.yScale = -obj.yScale end
   	--table.dump(rec)

   	if(rec.name == "spinner") then
   		simpleSpinner( obj )
   	end
   	--]]
	end

   level.forEach( func )
	--[[
	--
	-- Add listener to layers to content
	--
	local isFirst = true
	function layers.onNewSegment( self, event  )
		
		-- Don't create content till we hit `creationStartCount`
		if( event.count < common.creationStartCount ) then return end

		local gateY = mRand( centerY - common.gateDelta/2, centerY + common.gateDelta/2 )
		factoryMgr.new( "gate", layers.content, event.x, gateY )

		if( isFirst or mRand(1,common.coinFrequency) == common.coinFrequency ) then
			isFirst = false
			local coinY = mRand( centerY - common.coinYOffset/2, centerY + common.coinYOffset/2 )
			factoryMgr.new( "coin", layers.content, event.x + common.segmentWidth/2, coinY )
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
	factoryMgr.new( "segment", layers.content, left, centerY, 
		             { preTrigger = true, segmentWidth = common.segmentWidth, 
		               debugEn = params.debugEn } )

	factoryMgr.new( "segment", layers.content, nil, centerY, 
		             { preTrigger = false, segmentWidth = common.segmentWidth, 
		               debugEn = params.debugEn } )

	factoryMgr.new( "segment", layers.content, nil, centerY, 
		             { preTrigger = false, segmentWidth = common.segmentWidth,
		               debugEn = params.debugEn } )

	--
	-- Create Player
	--
	factoryMgr.new( "player", layers.player,  centerX, centerY,  
		            {	world = layers.world } )	

	--]]		            

end


return game



