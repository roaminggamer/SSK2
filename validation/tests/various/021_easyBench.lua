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

   local function run1()
		local easyBench 	= ssk.easyBench

		-- Slow version
		local function test1( iter)
			local function onEnterFrame( self, event ) end
			local function onTouch( self, event  ) end
			local function onTimer( self )  end
			local function onMouse( self, event  ) end
			local function onFinalize( self ) ignoreList({"onMouse", "onEnterFrame"}, self );  end
			local group = display.newGroup()
			for i = 1, 200 do
				local tmp = newRect( group, centerX, centerY,  
					{ 	listeners = { 
					   enterFrame 	= onEnterFrame,
						touch 		= onTouch,					
						mouse 		= onMouse,
						finalize 	= onFinalize, },
						timer 		= onTimer,
					} )	
			end
			display.remove(group)
		end

		-- Faster Version
		local function test2()
			local function onEnterFrame( self, event ) end
			local function onTouch( self, event  ) end
			local function onTimer( self )  end
			local function onMouse( self, event  ) end
			local function onFinalize( self ) ignoreList({"onMouse", "onEnterFrame"}, self );  end
			local group = display.newGroup()
			for i = 1, 200 do
				local tmp = display.newRect( group, centerX, centerY, 40, 40 )	
				enterFrame 		= onEnterFrame; listen("touch",tmp)
				tmp.touch 		= onTouch; tmp:addEventListener("touch")
				tmp.timer 		= onTimer
				tmp.mouse 		= onMouse; listen("mouse",tmp)
				tmp.finalize 	= onFinalize; tmp:addEventListener("finalize")
			end
			display.remove(group)
		end


		-- Measuring attempt 1 (one iteration per test)
		--
		local time1,time2,delta,speedup = easyBench.measureABTime( test1, test2, 5 )
		local dt = time1 - time2
		time1 = round(time1/1000,4)
		time2 = round(time2/1000,4)

		print( "Test 1: " .. time1 .. " seconds.")
		print( "Test 2: " .. time2 .. " seconds.")
		print( dt, dt < 0.01 )
		if( math.abs(dt) < 0.01 ) then
			print( "Test 1 & 2 are about the same." )
		elseif( time1 < time2 ) then
			print( "Test 2 is " .. math.abs(speedup) .. " percent SLOWER .")
		else
			print( "Test 2 is " .. math.abs(speedup) .. " percent FASTER .")
		end
	end
   
   local function run2()
		local easyBench 	= ssk.easyBench

		-- Slow version
		local function test1( iter)
			local group = display.newGroup()
			for i = 1, 500 do
				local tmp = newRect( group, centerX, centerY, { } )	
			end
			display.remove(group)
		end

		-- Faster Version
		local function test2()
			local group = display.newGroup()
			for i = 1, 500 do
				local tmp = display.newRect( group, centerX, centerY, 40, 40 )	
			end
			display.remove(group)
		end


		-- Measuring attempt 1 (one iteration per test)
		--
		local time1,time2,delta,speedup = easyBench.measureABTime( test1, test2, 5 )
		local dt = time1 - time2

		--time1 = round(time1/1000,4)
		--time2 = round(time2/1000,4)

		print( "Test 1: " .. time1 .. " ms.")
		print( "Test 2: " .. time2 .. " ms.")
		print( " Delta: " .. delta)
		print( " dt: " .. dt)
		print( dt, dt < 0.01 )
		if( math.abs(dt) < 0.01 ) then
			print( "Test 1 & 2 are about the same." )
		elseif( time1 < time2 ) then
			print( "Test 2 is " .. math.abs(speedup) .. " percent SLOWER .")
		else
			print( "Test 2 is " .. math.abs(speedup) .. " percent FASTER .")
		end
	end


   print("RUNNING EASY BENCHMARKS TESTS")
   --print("------------------------------")
	--run1()
	print("------------------------------")
	run2()

end


return test
