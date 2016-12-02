-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- EAT Apple TV RelSwipe Module (Proprietary Paid Content)
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

local mAbs = math.abs
local mFloor = math.floor


local relSwipe = {}

local horizThreshold 	= 450
local vertThreshold 	= 300 
local horizMouseThreshold = 180 
local vertMouseThreshold = 90

local enableMulti 		= false

local lrx = 0
local lry = 0

local function relativeTouch( event )
	if( event.phase == "began" ) then
		lrx = 0
		lry = 0
	else
		local dx = event.x - lrx
		local dy = event.y - lry

		if( mAbs(dx) >= horizThreshold ) then
			local eventCount = mFloor( mAbs(dx) / horizThreshold )
			if( not enableMulti ) then eventCount = 1 end
			if( dx < 0 ) then -- left
				if( enableMulti ) then
					for i = 1, eventCount do
						lrx = lrx - horizThreshold 
						Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "left" } )						
					end
				else
					lrx = event.x
					Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "left" } )					
				end
			else -- right
				if( enableMulti ) then
					for i = 1, eventCount do
						lrx = lrx + horizThreshold 
						Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "right" } )
					end
				else
					lrx = event.x
					Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "right" } )
				end
			end
		end

		if( mAbs(dy) >= vertThreshold ) then
			local eventCount = mFloor( mAbs(dy) / vertThreshold )
			if( not enableMulti ) then eventCount = 1 end
			if( dy < 0 ) then -- up
				if( enableMulti ) then
					for i = 1, eventCount do
						lry = lry - vertThreshold 
						Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "up" } )
					end
				else
					lry = event.y
					Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "up" } )
				end
			else -- down
				if( enableMulti ) then
					for i = 1, eventCount do
						lry = lry + vertThreshold 
						Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "down" } )
					end
				else
					lry = event.y
					Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "down" } )
				end
			end
		end

		if( event.phase == "moved" ) then
		elseif( event.phase == "ended" ) then
		end
	end
	--table.dump(event)
end


local mouse
local onSimulator = system.getInfo( "environment" ) == "simulator"
if( onSimulator ) then
	local mrx
	local mry
	local enableMouse = false

	--[[
	local function key( event )
		if( event.keyName == "leftControl" ) then
			if( event.phase == "down" ) then
				mrx = nil 
				mry = nil
				enableMouse = true
			else
				enableMouse = false
			end
		end
		return false
	end; Runtime:addEventListener( "key", key )

	local function mouse( event )
		--if( not enableMouse ) then return end
	--]]
	mouse = function( event )			
		if( not mrx or not event.isSecondaryButtonDown ) then
			mrx = event.x
			mry = event.y
			return
		end

		local dx = event.x - mrx
		local dy = event.y - mry

		if( mAbs(dx) >= horizMouseThreshold ) then
			if( dx < 0 ) then -- left
				mrx = event.x
				Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "left" } )
			else -- right
				mrx = event.x
				Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "right" } )
			end
		end

		if( mAbs(dy) >= vertMouseThreshold ) then
			if( dy < 0 ) then -- up
				mry = event.y
				Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "up" } )
			else -- down
				mry = event.y
				Runtime:dispatchEvent( { name = "relButtonSwipe", dir = "down" } )				
			end
		end
	end	
end

local mouseActivated = false
local started = false
function relSwipe.start( enableMouse )
	if( started ) then return end
	Runtime:addEventListener( "relativeTouch", relativeTouch )	
	if( onSimulator and enableMouse ) then
		mouseActivated = true		
		Runtime:addEventListener( "mouse", mouse )
	end
	started = true
end

function relSwipe.stop( enableMouse)
	if( not started ) then return end
	Runtime:removeEventListener( "relativeTouch", relativeTouch )
	if( onSimulator and enableMouse ) then
		mouseActivated = false
		Runtime:removeEventListener( "mouse", mouse )
	end
	started = true
end

function relSwipe.getThresholds( )
	return horizThreshold, vertThreshold, horizMouseThreshold, vertMouseThreshold
end

function relSwipe.setThresholds( params )
	horizThreshold =  newHorizThreshold or params.horizThreshold
	vertThreshold = newVertThreshold or params.vertThreshold
	horizMouseThreshold =  newHorizThreshold or params.horizMouseThreshold
	vertMouseThreshold = newVertThreshold or params.vertMouseThreshold
end


return relSwipe