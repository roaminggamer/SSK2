-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================

-- =============================================================
-- Localizations
-- =============================================================
-- Lua
local getInfo           = system.getInfo
local getTimer          = system.getTimer
local mRand          	= math.random
local mAbs 					= math.abs

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
-- =============================================================
-- =============================================================

-- =============================================================

-- Start and Configure  physics
local physics = require "physics"
physics.start()
physics.setGravity(0,0)
--physics.setDrawMode("hybrid")

local minSpinRate = 12500
local maxSpinRate = 50000

local kernel = {}

local function createWheel( group, imageName, pegAngle, slices )
	local wheel = newImageRect( group, centerX, centerY, 
		                         "images/dials/" .. imageName,
		                         { size = 500 }, 
		                         { angularDamping = 1.25, radius = 250 } )

	-- A flag to be used in the spinning logic
	wheel.isSpinning = false

	-- Helper function to spin wheel using angular impulse
	--
	function wheel.spin( self, impulse )
		print("Spin wheel with starting impulse " .. round(impulse/self.mass) .. " x mass" )
		self.isSpinning = true
		self:applyAngularImpulse( impulse )
	end

	-- Helper function to get current slice next to peg
	--
	function wheel.getCurrentSlice( self )
		-- Clean the object's rotation to make sure it is in the range [0,360)
		local rotation = normRot( self.rotation - pegAngle )
		local slice = #slices
		local angle = 0 
		while( slice > 0 ) do
			angle = angle + slices[slice][1]
			--print( angle, rotation, slices[slice][2])
			if( angle > rotation ) then
				return slices[slice][2]				
			end
			slice = slice - 1
		end
		return "error"
	end

	local vec = angle2Vector( pegAngle, true )
	vec = scaleVec( vec, 260 )

	local peg = newCircle( group, wheel.x + vec.x, wheel.y + vec.y, 
		                   { fill = _C_, radius = 10 } )

	-- Check to see if we are spinning and need to stop
	--
	wheel.minAV = 25 -- Stop as soon as AV hits for falls below this value

	wheel.enterFrame = function( self )
		if( self.isSpinning ) then
			--print( mAbs(self.angularVelocity) )
			if( mAbs(self.angularVelocity) <= self.minAV ) then
				self.isSpinning = false
				self.angularVelocity = 0
				post("onSpinComplete", { slice = self:getCurrentSlice() } )
			end
		end
	end; listen( "enterFrame", wheel )

	return wheel
end

-- Spin when touched, using an impulse
--
local function touchSpinner( self, event )
	if( event.phase == "began" and self.isSpinning == false ) then
		self:spin( mRand(minSpinRate,maxSpinRate) * self.mass )
	end
	return true
end

-- Spin when touched, using an impulse
--
local flickMultiplier = 7500
local function flickSpinner( self, event )
	if( self.isSpinning ) then return true end

	if( event.phase == "began" ) then
		self.isFocus = true
		self.t0 = event.time
		display.currentStage:setFocus( self, event.id )

	elseif( self.isFocus and  event.phase == "ended" ) then
		self.isFocus = false
		display.currentStage:setFocus( self, nil )		
		--table.dump(event)

		local dt = event.time - self.t0
		local vec = { x = event.x - event.xStart, y = event.y - event.yStart }
		local len = lenVec( vec )
		local rate = flickMultiplier * len/dt

		print("Initial flick rate: " .. rate)
		if( rate < minSpinRate ) then
			rate = mRand(minSpinRate,maxSpinRate)			
		elseif( rate > maxSpinRate ) then
			rate = maxSpinRate
		end
		print("Post processed flick rate: " .. rate)

		self:spin( rate * self.mass )
	end	
	return true
end


function kernel.run( group, params )
   group = group or display.currentStage
   params = params or {}

   -- Check parameters for example settings
   --
   local example = params.example or 1

   -- Create a wheel that spins when you touch it
   local wheel

   if( example == 1 ) then
   	wheel = createWheel( group, "pie3.png", 0,
   		               	{ 
   		                 		{ 120, "Yellow" },
   		                 		{ 120, "Orange" }, 
   		                 		{ 120, "Blue" } 
   		                 	} )
   	wheel.touch = touchSpinner
   	wheel:addEventListener( "touch" )
   
   elseif( example == 2 ) then
   	wheel = createWheel( group, "pie4.png", 90,
   		               	{ 
   		               		{ 90, "Green" },
   		                 		{ 90, "Yellow" },
   		                 		{ 90, "Orange" }, 
   		                 		{ 90, "Blue" } 
   		                 	} )

		wheel.touch = flickSpinner
		wheel:addEventListener( "touch" )

   elseif( example == 3 ) then
   	wheel = createWheel( group, "pie5A.png", 180,
   		               	{ 
   		               		{ 72, "Red" },
   		               		{ 72, "Green" },
   		                 		{ 72, "Yellow" },
   		                 		{ 72, "Orange" }, 
   		                 		{ 72, "Blue" } 
   		                 	} )

		wheel.touch = touchSpinner
		wheel:addEventListener( "touch" )

   elseif( example == 4 ) then
   	wheel = createWheel( group, "pie5B.png", 270,
   		               	{ 
   		               		{ 90, "Red" },
   		               		{ 90, "Green" },
   		                 		{ 45, "Yellow" },
   		                 		{ 45, "Orange" }, 
   		                 		{ 90, "Blue" } 
   		                 	} )
    	wheel.touch = touchSpinner
   	wheel:addEventListener( "touch" )

   end

   --wheel.rotation = 135
   print( wheel.rotation, wheel:getCurrentSlice() )
end

return kernel
