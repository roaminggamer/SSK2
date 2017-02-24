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
	--newRect( layers.underlay, centerX, centerY, 
		      --{ w = fullw, h = fullh, fill = hexcolor("#2FBAB4") })

	--
	-- Create One Touch Easy Input
	--
	--ssk.easyInputs.oneTouch.create(layers.underlay, { debugEn = params.debugEn, keyboardEn = true } )
	--ssk.easyInputs.twoTouch.create(layers.underlay, { debugEn = params.debugEn, keyboardEn = true } )
	--ssk.easyInputs.oneStick.create( layers.underlay, { debugEn = true, joyParams = { doNorm = true } } )
	--ssk.easyInputs.twoStick.create( layers.underlay, { debugEn = true, joyParams = { doNorm = true } } )
	--ssk.easyInputs.oneStickOneTouch.create( layers.underlay, { debugEn = true, joyParams = { doNorm = true } } )


	--
	-- Create HUDs
	--
	--factoryMgr.new( "scoreHUD", layers.interfaces, centerX, top + 40 )
	--factoryMgr.new( "coinsHUD", layers.interfaces, left + 10, top + 70, { iconSize = 40, fontSize = 36 } )
	--factoryMgr.new( "distanceHUD", layers.interfaces, centerX, top + 70, { fontSize = 36 } )

	local myCC = require "scripts.myCC"

	local allBalloons = {}


	local lw = ssk.display.newRect( nil, left, centerY, 
		                           	{ anchorX = 0, h = fullh, w = 40, fill = _GREY_ }, 
		                           	{ bodyType = "static", calculator = myCC, colliderName = "wall"} )


	local rw = ssk.display.newRect( nil, right, centerY, 
		                           	{ anchorX = 1, h = fullh, w = 40, fill = _GREY_ }, 
		                           	{ bodyType = "static", calculator = myCC, colliderName = "wall"} )

	local function onTouch( self, event )
		allBalloons[self] = nil
		display.remove(self)
		return true
	end


	local function createBalloon( )
		-- Randomly create one of five balloon images
		local imgNum = math.random( 1, 5 )	
		local tmp = ssk.display.newImageRect( nil, 0, 0, "images/balloons/balloon" .. imgNum .. ".png",
														 { w = 295/5, h = 482/5, isBalloon = true },
														 { calculator = myCC, colliderName = "balloon", isSensor = true } )

		-- Randomly place the balloon
		tmp.y = top-50
		local ox = (fullw - 250)/2
		tmp.x = centerX + math.random( -ox, ox )

		-- Scale it to make a 'smaller' balloon
		--tmp:scale( 0.1, 0.1 )

		-- add a touch listener
		tmp.touch = onTouch
		tmp:addEventListener( "touch" )

		-- Give it a body so 'gravity' can pull on it
		physics.addBody( tmp, { radius = tmp.contentWidth/2} )

		-- Give the body a random rotation
		tmp.angularVelocity = math.random( -180, 180 )

		-- Give it drag so it doesn't accelerate too fast
		tmp.linearDamping = 2

		-- Self destruct in 5 seconds
		timer.performWithDelay( 15000,
			function()
				allBalloons[tmp] = nil
				display.remove( tmp )
			end )
	end


	-- Create a new baloon every 1/2 second  forever
	timer.performWithDelay( 2500, createBalloon, -1  )


	local ping
	local pong
	local rTime 		=  2000
	local rDelay 		= 250
	local arrowRate 	= 200

	ping = function( self, isFirst )
		self.onComplete = pong
		if( isFirst ) then
			transition.to( self, { rotation = 60, time = rTime/2, delay = rDelay, onComplete = self } )
		else
			transition.to( self, { rotation = 60, time = rTime, delay = rDelay, onComplete = self } )
		end
	end

	pong = function( self )
		self.onComplete = ping
		transition.to( self, { rotation = -60, time = rTime, delay = rDelay, onComplete = self } )
	end

	local dude = ssk.display.newImageRect( nil, centerX, bottom - 125, "images/dude.png",
														{ size = 75}, 
														{ bodyType = "kinematic", isSensor = true } )

	ping(dude, true )

	ssk.easyInputs.oneTouch.create( nil, { debugEn = false, keyboardEn = true } )


	local function onCollision( self, event )
		if( event.phase == "began" ) then
			if(event.other.isBalloon) then
				allBalloons[event.other] = nil
				display.remove( event.other )
				display.remove(self)
			end
		end
		return false
	end

	function dude.onOneTouch( self, event )
		if( event.phase == "began" ) then 
			local arrow = ssk.display.newImageRect( nil, self.x, self.y, "images/arrow.png",
															 { radius = 10, collision = onCollision },
															 { radius = 10, bounce = 1, friction = 0,
															   calculator = myCC, colliderName = "arrow", 
															   gravityScale = 0 } )
			arrow:toBack()
			arrow.rotation = self.rotation

			local vec = ssk.math2d.angle2Vector( self.rotation, true )
			vec = ssk.math2d.scale( vec, arrowRate )

			arrow:setLinearVelocity( vec.x, vec.y )

			transition.to( arrow, { alpha = 0, delay = 5000, time = 0, onComplete = display.remove })
		end
		return false
	end; listen( "onOneTouch", dude )






end


return game



