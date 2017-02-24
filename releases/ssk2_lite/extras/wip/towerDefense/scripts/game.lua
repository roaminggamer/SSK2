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


local predictive 	= require "scripts.predictive"
local blasterTower 	= require "scripts.towers.blasterTower"
local shockTower 	= require "scripts.towers.shockTower"
local laserTower 	= require "scripts.towers.laserTower"
local missileTower 	= require "scripts.towers.missileTower"


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
 
	local targets = {}

	local lastTargetTimer

	local bulletFirePeriod = 300
	local bulletSpeed 	= 250 -- Used for velocity bullets
	local bulletRadius 	= 2




	local function createTarget( minY, maxY, time, minSpd, maxSpd, hits )
		local myCC = require "scripts.myCC"
		
		local x0 = centerX + 10
		local x1 = -10
		local y = mRand( minY, maxY)
		local spd = mRand(minSpd, maxSpd)
		local hits = hits or 5

	    local target = display.newCircle( layers.content, x0, y, 10 )
	    target:setFillColor(1,0,0)
	    target:setStrokeColor(1,0,1)
	    target.strokeWidth = 2
	    -- Listen for touches and move the target when it happens
	    Runtime:addEventListener( "touch", target )
	    physics.addBody( target, "dynamic", { radius = 10, filter = myCC:getCollisionFilter( "target" ) } ) 

	    target.hits = hits

	    targets[target] = target

	    target:setLinearVelocity( -spd, 0 )

	    local hittext = easyIFC:quickLabel( layers.content, hits, target.x, target.y, gameFont, 10, _YELLOW_ )
	    hittext.enterFrame = function( self, event )
	    	if( display.isValid( target ) == false ) then
	    		ignore( "enterFrame", self )
	    		display.remove(self)
	    		return 
	    	end
	    	if( target.hits > 0 ) then
	    		self.text = target.hits
	    	else
	    		self.text = 0
	    	end
	    	self.x = target.x
	    	self.y = target.y
		end
		listen( "enterFrame", hittext )

		timer.performWithDelay( 25000, 
			function()
				if(display.isValid(target) == false) then return end
				targets[target] = nil
				display.remove(target)
			end )

	    lastTargetTimer = timer.performWithDelay( time, function() createTarget(minY,maxY,time,minSpd,maxSpd,hits) end )    
	end


	blasterTower.registerLayers( layers )
	shockTower.registerLayers( layers )
	laserTower.registerLayers( layers )
--	missileTower.registerLayers( layers )

	blasterTower.registerTargets( targets )
	shockTower.registerTargets( targets )
	laserTower.registerTargets( targets )
--	missileTower.registerTargets( targets )

	--towerBuilder.registerLayers( layers )
	--towerBuilder.registerTargets( targets )

	blasterTower.createTurret( 160, 120, 80, _BLUE_ ) 
	--towerBuilder.createTurret( 160, 160, 120, _GREEN_ ) 
	shockTower.createTurret( 160, 200, 80, _YELLOW_ ) 
--	missileTower.createTurret( 160, 160, 120, _GREEN_ ) 

	--createTarget = function( minY, maxY, time, minSpd, maxSpd, hits )
	--createTarget( 60, 260, 500, 60, 80, 10)
	nextFrame( function() createTarget( 100, 240, 1000, 40, 40, 8) end )


end


return game



