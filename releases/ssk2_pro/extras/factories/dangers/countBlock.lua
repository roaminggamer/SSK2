-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- Danger: Count Block
-- =============================================================
local common 	= require "scripts.common"
local myCC 		= require "scripts.myCC"
local physics 	= require "physics"

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

-- =============================================================
-- Locals
-- =============================================================
local initialized = false

-- =============================================================
-- Forward Declarations
-- =============================================================

-- =============================================================
-- Factory Module Begins
-- =============================================================
local factory = {}

-- ==
--    init() - One-time initialization only.
-- ==
function factory.init( params )
	if(initialized) then return end
	initialized = true
end

-- ==
--    reset() - Reset any per-game logic/settings.
-- ==
function factory.reset( params )
end

-- ==
--    new() - Create new instance(s) of this factory's object(s).
-- ==
function factory.new( group, x, y, params )
	params = params or { width = w/4, debugEn = false }

	-- Catch case where we enter, but group was just removed
	--
	if( not isValid( group ) ) then return end

	--
	-- Ensure there is a params value 'segmentWidth'
	--
	params.width = params.width or w/4
	
	--
	-- Create a danger
	--
	local size = params.size or 80
	local danger = newRect( group, x, y, 		
		                     	{	size = size, fill = _T_, stroke = params.color or _R_, 
		                     	   strokeWidth = 2,
		                     	   myCount = params.count or 1 },
		                        {	bodyType = "kinematic",
		                           isSleepingAllowed = false,
		                        	calculator = myCC, colliderName = "danger"} )

	danger.label = easyIFC:quickLabel( group, params.count or 1, x, y, 
												 params.font or ssk.gameFont,
		                               params.fontSize or 48,
		                               params.color or _R_ )


	function danger.enterFrame( self )
		self.label.x = self.x
		self.label.y = self.y
		self.label.rotation = self.rotation
		self.label.text = self.myCount

		if( params.colors ) then
			local color = params.colors[self.myCount]
			self:setStrokeColor( unpack( color ) ) 
			self.label:setFillColor( unpack( color ) ) 
		end



	end; listen( "enterFrame", danger )

	function danger.finalize( self )
		display.remove(self.label)
		ignore("enterFrame", self)
	end; danger:addEventListener( "finalize" )

	function danger.collision( self, event )
		local other = event.other
		local phase = event.phase

		if(phase == "began" ) then
			if(other.colliderName == "player") then
			elseif(other.colliderName == "bullet") then
				self.myCount = self.myCount - 1
				if( self.myCount <= 0 ) then
					ignore("enterFrame", self)
					display.remove( self.label )
					display.remove( self )
				end
			end
		end
	end; danger:addEventListener("collision")

	return danger
end

return factory