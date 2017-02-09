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
	soundMgr.enableVoice( true )
	soundMgr.enableMusic( true )

	soundMgr.setVolume(0.5)
	
	soundMgr.setDebugLevel( 1 )


	soundMgr.add( "click", "sounds/sfx/click.mp3", { preload = true, minTweenTime = 200 } )

	soundMgr.addEffect( "explosion", "sounds/sfx/explosion.wav", { preload = true, sticky = true } )

	soundMgr.addVoice( "count1", "sounds/vo/count_1.mp3" )
	soundMgr.addVoice( "count2", "sounds/vo/count_2.mp3" )
	soundMgr.addVoice( "count3", "sounds/vo/count_3.mp3" )
	soundMgr.addVoice( "count4", "sounds/vo/count_4.mp3" )

	soundMgr.addMusic( "Sugar Plum Breakdown", "sounds/music/Sugar Plum Breakdown.mp3" )

	soundMgr.release( "click" )
	soundMgr.release( "explosion" )

	--
	-- Validation Sequence
	-- 

	local function valSequence()
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

	--
	-- Individual Sounds and Features
	-- 
	local function onPress( event ) 
		local sName = event.target.sName
		post( "onSound", { sound = sName } )
	end

	local curY = centerY - 300

   easyIFC:presetPush( group, "default", centerX, curY, 300, 40, "Run Validation Sequence", valSequence )

   curY = curY + 50
   local tmp = easyIFC:presetPush( group, "default", centerX, curY, 300, 40, "SFX - Click", onPress )
   tmp.sName = "click"

   curY = curY + 50
   local tmp = easyIFC:presetPush( group, "default", centerX, curY, 300, 40, "VO - Count 1", onPress )
   tmp.sName = "count1"

   curY = curY + 50
   local tmp = easyIFC:presetPush( group, "default", centerX, curY, 300, 40, "VO - Count 2", onPress )
   tmp.sName = "count2"

   curY = curY + 50
   local tmp = easyIFC:presetPush( group, "default", centerX, curY, 300, 40, "VO - Count 3", onPress )
   tmp.sName = "count3"

   curY = curY + 50
   local tmp = easyIFC:presetPush( group, "default", centerX, curY, 300, 40, "Music - Sugar Plum Breakdown", onPress )
   tmp.sName = "Sugar Plum Breakdown"






end


return test
