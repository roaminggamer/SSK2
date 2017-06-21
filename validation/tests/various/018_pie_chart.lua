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

   -- Generate a 32x32 mask
   ssk.misc.genCircleMask( 32, "mask32.png" )

   -- Generate a 64x64 mask
   ssk.misc.genCircleMask( 64, "mask64.png" )

   -- Generate a mask suitable for a 300x300 usage (mask will actually be 512x512 in size )
   ssk.misc.genCircleMask( 300, "mask300.png" )

   -- Create multiple example pie (and non-pie) charts
   timer.performWithDelay( 500,
   	function()
   		-- Chart 1
			local params = 
			{
				slices = 
				{
					{ degrees = 120, color = _R_},
					{ degrees = 120, color = _G_},
					{ degrees = 120, color = _B_},
				},
				mask = "mask32.png",
				maskBase = system.DocumentsDirectory, -- Normally you would source these from the ResourceDirectory, but we
				                                      -- are using the generated masks for this example.
				size = 32,
				maskWidth = 32,
				maskHeight = 32,
		  	}
		  	local pie = ssk.misc.createPieChart( nil, centerX - 100, centerY + 100, params )

   		-- Chart 2
			local params = 
			{
				slices = 
				{
					{ degrees = 120, color = _R_},
					{ degrees = 120, color = _G_},
					{ degrees = 120, color = _B_},
				},
				mask = "mask64.png",
				maskBase = system.DocumentsDirectory, -- Normally you would source these from the ResourceDirectory, but we
				                                      -- are using the generated masks for this example.
				size = 64,
				maskWidth = 64,
				maskHeight = 64,
		  	}
		  	local pie = ssk.misc.createPieChart( nil, centerX, centerY + 100, params )

   		-- Chart 3
			local params = 
			{
				slices = 
				{
					{ degrees = 360/5, color = _R_},
					{ degrees = 360/5, color = _G_},
					{ degrees = 360/5, color = _B_},
					{ degrees = 360/5, color = _O_},
					{ degrees = 360/5, color = _P_},
				},
				mask = "mask300.png",
				maskBase = system.DocumentsDirectory, -- Normally you would source these from the ResourceDirectory, but we
				                                      -- are using the generated masks for this example.
				size = 300,
				maskWidth = 512,
				maskHeight = 512,
				altStrokeColor = _K_,
				altStrokeWidth = 3
		  	}
		  	local pie = ssk.misc.createPieChart( nil, centerX + 150, centerY + 100, params )

		  	function pie.enterFrame( self )
		  		self.rotation = self.rotation + 30 * ssk.getDT()/1000
		  	end; listen( "enterFrame",  pie )

		  	--print("children ", pie.numChildren)



			-- Chart 4 (cool CUBE)
			local params = 
			{
				slices = 
				{
					{ degrees = 120, color = _R_},
					{ degrees = 120, color = _G_},
					{ degrees = 120, color = _B_},
				},
				--mask = "mask32.png",
				size = 64,
				altStrokeColor = _DARKGREY_,
				noMask = true
		  	}
		  	local pie = ssk.misc.createPieChart( nil, centerX - 100, centerY - 100, params )
		  	pie.rotation = -180



			-- Chart 4 (cool other)
			local params = 
			{
				slices = 
				{
					{ degrees = 360/5, color = _R_},
					{ degrees = 360/5, color = _G_},
					{ degrees = 360/5, color = _B_},
					{ degrees = 360/5, color = _O_},
					{ degrees = 360/5, color = _P_},
				},
				--mask = "mask32.png",
				size = 64,
				altStrokeColor = _DARKGREY_,
				noMask = true,
		  	}
		  	local pie = ssk.misc.createPieChart( nil, centerX + 100, centerY - 150, params )
		  	pie.rotation = -180

		  	function pie.enterFrame( self )
		  		self.rotation = self.rotation + 90 * ssk.getDT()/1000
		  	end; listen( "enterFrame",  pie )

		  	--print("children ", pie.numChildren)



   	end )

end


return test
