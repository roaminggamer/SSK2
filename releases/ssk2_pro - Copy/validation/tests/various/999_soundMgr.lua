-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================

-- =============================================================
-- Localizations
-- =============================================================
-- Lua
local getTimer = system.getTimer; local mRand = math.random
local mAbs = math.abs
local strMatch = string.match; local strGSub = string.gsub; local strSub = string.sub
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
local normRot = math.normRot;local easyAlert = ssk.misc.easyAlert
--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale
ssk.misc.countLocals(1)

-- =============================================================
-- =============================================================

-- PLUGIN REQUIRES GO HERE

-- =============================================================
local test = {}

function test.run( group, params )
   group = group or display.currentStage
   params = params or {}

	local soundMgr = ssk.soundMgr

	soundMgr.enableSFX( true )
	soundMgr.enableMusic( true )

	soundMgr.setVolume(0.5)
	
	soundMgr.setDebugLevel( 1 )

	soundMgr.add( "click", "sounds/sfx/click.mp3", { preload = true, minTweenTime = 200 } )
	
	soundMgr.addEffect( "explosion", "sounds/sfx/explosion.wav", { preload = true, sticky = true } )

	soundMgr.addMusic( "Sugar Plum Breakdown", "sounds/music/Sugar Plum Breakdown.mp3" )

	soundMgr.release( "click" )
	soundMgr.release( "explosion" )

	post( "onSound", { sound = "click" } )
	nextFrame( function() post( "onSound", { sound = "click" } ) end, 100 )

	timer.performWithDelay( 2000, 
		function()
			post( "onSound", { sound = "explosion" } )
			nextFrame( function() post( "onSound", { sound = "explosion" } ) end, 250 )
		end )

	local function onComplete()
		print("All sounds should be done.")
		soundMgr.dump()
	end

	timer.performWithDelay( 3000, 
		function()
			post( "onSound", { sound = "Sugar Plum Breakdown", fadein = 1500, loops = 0, onComplete = onComplete } )
		end )

	timer.performWithDelay( 3500, 
		function()
			print("Stopping early.")
			soundMgr.stopAll("music")
		end )

end


return test
