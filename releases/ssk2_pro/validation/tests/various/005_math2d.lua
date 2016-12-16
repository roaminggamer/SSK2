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

   local math2d = ssk.math2d

   -- NOTE: NOT USING LOCALIZED VERSIONS FOR TESTING


	local vec1 = { x = 1, y = 1 }
	local vec2 = { x = -0.25, y = 0.25 }
	local scale = 1.59
	local angle = -79


	-- Set up some scalars to play with during out exploration of the math2d plugin.
	--
	local x1,y1 = 10,10
	local x2,y2 = 15,-10

	-- Create some objects to play with during out exploration of the math2d plugin.
	--
	local circ = display.newCircle( 100, 100, 30 )
	local rect = display.newRect( 150, 250, 60, 60 )

	--
	-- Vector Addition (Scalars)
	--
	local vx,vy = math2d.add( x1, y1, x2, y2 )        -- Return two numbers
	local vec   = math2d.add( x1, y1, x2, y2, true )  -- Return a table
	print("\nVector Addition (Scalars)")
	print( "        Results: ", vx, vy ) 
	print( "        Results: ", vec.x, vec.y ) 
	print( "Correct Results: 	25	0")
	print( "Correct Results: 	25	0")


	--
	-- Vector Addition (Objects)
	--
	local vx,vy = math2d.add( circ, rect, true )  -- Return two numbers
	local vec   = math2d.add( circ, rect )  -- Return a table
	print("\nVector Addition (Objects)")
	print( "        Results: ", vx, vy ) 
	print( "        Results: ", vec.x, vec.y ) 
	print( "Correct Results: 	250	350")
	print( "Correct Results: 	250	350")

	--
	-- Vector Subtraction (Scalars)
	--
	local vx,vy = math2d.sub( x1, y1, x2, y2 )        -- Return two numbers
	local vec   = math2d.sub( x1, y1, x2, y2, true )  -- Return a table
	print("\nVector Subtraction (Scalars)")
	print( "        Results: ", vx, vy ) 
	print( "        Results: ", vec.x, vec.y ) 
	print( "Correct Results: 	-5	20")
	print( "Correct Results: 	-5	20")

	--
	-- Vector Subtraction (Objects)
	--
	local vx,vy = math2d.sub( circ, rect, true )  -- Return two numbers
	local vec   = math2d.sub( circ, rect )  -- Return a table
	print("\nVector Subtraction (Objects)")
	print( "        Results: ", vx, vy ) 
	print( "        Results: ", vec.x, vec.y )
	print( "Correct Results: 	-50	-150")
	print( "Correct Results: 	-50	-150")

	--
	-- Vector Difference (Scalars)
	--
	local vx,vy = math2d.diff( x1, y1, x2, y2 )        -- Return two numbers
	local vec   = math2d.diff( x1, y1, x2, y2, true )  -- Return a table
	print("\nVector Difference (Scalars)")
	print( "        Results: ", vx, vy ) 
	print( "        Results: ", vec.x, vec.y ) 
	print( "Correct Results: 	5	-20")
	print( "Correct Results: 	5	-20")

	--
	-- Vector Difference (Objects)
	--
	local vx,vy = math2d.diff( circ, rect, true )  -- Return two numbers
	local vec   = math2d.diff( circ, rect )  -- Return a table
	print("\nVector Difference (Objects)")
	print( "        Results: ", vx, vy ) 
	print( "        Results: ", vec.x, vec.y )
	print( "Correct Results: 	50	150")
	print( "Correct Results: 	50	150")

	--
	-- Dot Product (Scalars)
	--
	print("\nDot (inner) Product (Scalars)")
	print( "        Result: ", math2d.dot( x1, y1, x2, y2 ) )
	print( "Correct Result: 	50")

	--
	-- Dot Product (Objects)
	--
	print("\nDot (inner) Product (Objects)")
	print( "        Result: ", math2d.dot( circ, rect ) )
	print( "Correct Result: 	40000")

	--
	-- Cross Product (Scalars)
	--
	print("\nCross (vector) Product (Scalars)")
	print( "        Result: ", math2d.cross( x1, y1, x2, y2 ) )
	print( "Correct Result: 	-250")

	--
	-- Cross Product (Objects)
	--
	print("\nCross (vector) Product (Objects)")
	print( "        Result: ", math2d.cross( circ, rect ) )
	print( "Correct Result: 	10000")

	--
	-- Vector Normalize (Scalars)
	--
	local vx,vy = math2d.sub( x1, y1, x2, y2 ) -- Return two numbers
	vx, vy = math2d.normalize(vx, vy)
	print("\nVector Normalize (Scalars)")
	print( "        Results: ", vx, vy ) 
	print( "Approximate Results: 	-0.24253562503633	0.97014250014533")

	--
	-- Vector Normalize (Objects)
	--
	local vec   = math2d.sub( circ, rect ) -- Return a table
	vec = math2d.normalize(vec) 
	print("\nVector Normalize (Objects)")
	print( "        Results: ", vec.x, vec.y )
	print( "Correct Results: 	-0.31622776601684	-0.94868329805051")

	--
	-- Vector Length (Scalars)
	--
	local vx,vy = math2d.sub( x1, y1, x2, y2 ) -- Return two numbers
	print("\nVector Length (Scalars)")
	print( "            Result: ", math2d.length(vx, vy) ) 
	print( "Approximate Result: 	20.615528128088")

	--
	-- Vector Length (Objects)
	--
	local vec   = math2d.sub( circ, rect ) -- Return a table
	print("\nVector Length (Objects)")
	print( "            Result: ", math2d.length(vec) )
	print( "Approximate Result: 	158.11388300842")

	--
	-- Vector Square Length (Scalars)
	--
	local vx,vy = math2d.sub( x1, y1, x2, y2 ) -- Return two numbers
	print("\nVector Square Length (Scalars)")
	print( "        Result: ", math2d.length2(vx, vy) ) 
	print( "Correct Result: 	425")

	--
	-- Vector Square Length (Objects)
	--
	local vec   = math2d.sub( circ, rect ) -- Return a table
	print("\nVector Square Length (Objects)")
	print( "        Result: ", math2d.length2(vec) )
	print( "Correct Result: 	25000")

	--
	-- Vector To Angle (Scalars)
	--
	local vx,vy = math2d.diff( x1, y1, x2, y2 ) -- Return two numbers
	print("\nVector To Angle (Scalars)")
	print( "        Result: ", math2d.vector2Angle(vx, vy) ) 
	print( "Correct Result: 	15")

	--
	-- Vector To Angle of Object
	--
	local vec   = math2d.diff( circ, rect ) -- Return a table
	print("\nVector To Angle (Objects)")
	print( "        Result: ", math2d.vector2Angle(vec) )
	print( "Correct Result: 	162")

	--
	-- Angle To Vector - Produce Scalars
	--
	local angle = 135
	local vx,vy = math2d.angle2Vector( angle )        -- Return two numbers
	print("\nAngle To Vector (Scalars)")
	print( "        The vector: < " .. vx .. ", " .. vy .. " > " )  -- Print the numbers
	print( "Approximate vector: < 0.70710678118655, 0.70710678118655 > ")

	--
	-- Angle To Vector - Produce Object
	--
	local vec   = math2d.angle2Vector( angle, true )  -- Return a table
	print("\nAngle To Vector (Object)")
	print( "        The vector: < " .. vec.x .. ", " .. vec.y .. " > " ) -- Print the table fields
	print( "Approximate vector: < 0.70710678118655, 0.70710678118655 > ")


	print( 0, -1, "0 degrees ? ", math2d.vector2Angle( 0, -1 ) )
	print( 1, 0, "90 degrees ? ", math2d.vector2Angle( 1, 0 ) )
	print( 0, 1, "180 degrees ? ", math2d.vector2Angle( 0, 1 ) )
	print( -1, 0, "270 degrees ? ", math2d.vector2Angle( -1, 0 ) )

	local angles   =  { 0, 90, 180, 270 }
	local expected =  { "0,\t-1", "1,\t0", "0,\t1", "-1,\t0",}
	for i = 1, #angles do
		local vx, vy =  math2d.angle2Vector( angles[i] )
		print( "---------------\n" )
		print( "Angle: ", angles[i] )
		print( "Calculated Vector: ", math.round(vx),  math.round(vy) )
		print( "Expected Vector: ", expected[i] )
	end

	--
	-- Distance Between
	--
	local vec1 = { x = 0, y = 100 }
	local vec2 = { x = 0, y = 0 }
	print("\Distance Between")
	print( "---------------\n" )
	print("\n<0, 100>  <---->  < 0, 0 >")
	print( "Calculated: ", math2d.distanceBetween( vec1, vec2 ) )
	print( "  Expected: ", 100 )
	print( "Calculated: ", math2d.distanceBetween( 0, 100, 0, 0 )  )
	print( "  Expected: ", 100 )

	--
	-- Is Within Distance
	--
	local vec1 = { x = 0, y = 100 }
	local vec2 = { x = 0, y = 0 }
	print("\Is Within Distance")
	print( "---------------\n" )
	print("\n<0, 100>  <---->  < 0, 0 >")
	print( "Calculated:" )
	print( math2d.isWithinDistance( vec1, vec2, 100 ) ) -- true
	print( math2d.isWithinDistance( vec1, vec2, 99.999 ) ) -- false
	print( math2d.isWithinDistance( 0, 100, 0, 0, 100 ) ) -- true
	print( math2d.isWithinDistance( 0, 100, 0, 0, 99.999 ) ) -- false
	print( "\nExpected:\n\ttrue\n\tfalse\n\ttrue\n\tfalse" )


end


return test
