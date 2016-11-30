-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- EAT Apple TV YSwipe Module (Proprietary Paid Content)
-- =============================================================
--
-- This module is proprietary paid content, that is  ONLY available 
-- through the EAT Framwork Tool.  
--
-- This content may only delivered to third parties as part of a 
-- completed game developed using EAT.
--
-- This content may not be distributed as an example, in any how-to
-- guides, or bundled with educational products not also bundled with
-- a paid copy of EAT.
--
-- If any of the above limitations is true, you and the third party may
-- be in violation of the EAT EULA.  Please delete this content immediately,
-- and contact EAT support for clarification.
--
-- =============================================================
local ySwipe = {}

local lastValue = 0
local threshold = 0.3 -- Make bigger to make less sensitive

-- This fixes an issue where lifting finger sends an errant left swipe
local ignoreThreshold = 0.05 -- ignore normalized values smaller than this

local function axis( event )

	if( not event.axis or event.axis.type ~= "y" ) then return false end
	
	local value = event.normalizedValue

	-- Detect finger lift and don't sent a event
	if( math.abs(value) <= ignoreThreshold ) then 
		lastValue = value
		return false 		
	end

	local delta = math.abs(  value - lastValue )

	if( delta < threshold ) then return false end

	if( (value - lastValue ) > 0 ) then 
		Runtime:dispatchEvent( { name = 'ySwipe', dir = "down" } )
		--print("right @ ", system.getTimer())
	else
		Runtime:dispatchEvent( { name = 'ySwipe', dir = "up" } )
		--print("left @ ", system.getTimer())
	end
	lastValue = value
	return false
end


local started = false
function ySwipe.start( enableMouse )
	if( started ) then return end
	Runtime:addEventListener( "axis", axis )
	started = true
end


function ySwipe.stop( enableMouse)
	if( not started ) then return end
	Runtime:removeEventListener( "axis", axis )
	started = true
end

return ySwipe