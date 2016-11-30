-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- EAT Paid Content - AdMob Module
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
--[[
 > mod_admob.register( id, os, adType )	
 > mod_admob.setListener( customListener )
 > mod_admob.setAutoLoad( enable )	
 > mod_admob.setTestMode( enable )	
 > mod_admob.setTargetingOptions( name, value )	
 > mod_admob.setDebugLevel( debugLevel )
 > mod_admob.init( [ adType [ , showImmediately [ , position] ] ] )
 > mod_admob.load( adType )
 > mod_admob.loadAndShow( adType, position )	
 > mod_admob.show( adType, position )	
 > mod_admob.hide()
 > 
--]]
-- =============================================================
-- The module
local mod_admob = {} 

local ads = require "ads"

local _debugLevel 			= 0

local _ids 					= {}
local _customListener				-- Forward declared optional/changable user listener
local _listener 					-- Forward declared private listener

local _testMode 			= true 	-- Always default to testMode true for safety during testing.

local _targetingOptions

local _autoLoad 			= true 	-- Automatically load new ad when 'done' showing current ad (load same type)

local _showOnNextLoad				-- Internal variable used to automatically show the last loaded ad
local _showOnNextLoadPosition


-- ==
--		mod_admob.register( id, os, adType )	
-- ==
function mod_admob.register( id, os, adType  )	
	_ids[os] = _ids[os] or {}
	_ids[os][adType] = _ids[os][adType] or id

	if( _debugLevel > 1 ) then
		table.print_r(_ids)
	end
end

-- ==
--		mod_admob.setListener( customListener )	
-- ==
function mod_admob.setListener( customListener )
	_customListener = customListener
end

-- ==
--		mod_admob.setAutoLoad( enable )	
-- ==
function mod_admob.setAutoLoad( enable )	
	_autoLoad = enable
end

-- ==
--		mod_admob.setTestMode( enable )	
-- ==
function mod_admob.setTestMode( enable )	
	_testMode = enable
end

-- ==
--		mod_admob.setTargetingOptions( name, value )
--      "tagForChildDirectedTreatment" - Set to true if your game specifically targets children.
--      "is_designed_for_families" - (Untested) Set to true if your app is in the "designed for familieies" program.
-- ==
function mod_admob.setTargetingOptions( name, value )	
	_targetingOptions = _targetingOptions or {}
	_targetingOptions[name] = value
end

-- ==
--		mod_admob.setDebugLevel( debugLevel )	
-- ==
function mod_admob.setDebugLevel( debugLevel )
	_debugLevel = debugLevel
end


-- ==
--		mod_admob.init( [ adType [ , showImmediately [ , position] ] ] )
-- ==
function mod_admob.init( adType, showImmediately, position )
	local id
	if( onAndroid ) then
		id = _ids.android[adType]
	elseif( oniOS ) then
		id = _ids.ios[adType]
	end


	if(onAndroid ) then
		if( _debugLevel >= 1 ) then	
			print( "mod_admob.init( " .. tostring(adType) .. " ," .. tostring(showImmediately) .. " ," .. tostring(position) .. " ) id: " .. tostring(id))
		end
		ads.init( "admob", id, _listener )
		ads:setCurrentProvider("admob")
	elseif( oniOS ) then
		if( _debugLevel >= 1 ) then	
			print( "mod_admob.init( " .. tostring(adType) .. " ," .. tostring(showImmediately) .. " ," .. tostring(position) .. " ) id: " .. tostring(id))
		end
		ads.init( "admob", id, _listener )
		ads:setCurrentProvider("admob")
	elseif( not onSimulator ) then
		print( "ERROR: mod_admob.init( " .. tostring(adType) .. " ," .. tostring(showImmediately) .. " ," .. tostring(position) .. " ) id: " .. tostring(id))
		return
	end

	-- Note: Docs are wrong.  You don't load here. Load first ad after 'sessionStarted'
	if( showImmediately and adType == "banner" ) then
		mod_admob.show( adType, position )
	
	elseif( showImmediately ) then
		mod_admob.loadAndShow( adType )

	elseif( _autoLoad and adType == "interstitial" ) then
		mod_admob.load( adType )

	end

end


-- ==
--		mod_admob.load( adType )	
-- ==
function mod_admob.load( adType )	
	ads:setCurrentProvider( "admob" )

	local id
	if( onAndroid ) then
		id = _ids.android[adType]
	elseif( oniOS ) then
		id = _ids.ios[adType]
	end

	if( _debugLevel >= 1 ) then	
		print( "Attempting to load AdMob ad type: " .. tostring(adType) .. " id: " .. tostring(id) )
	end
	ads.load( adType, id )
end


-- ==
--		mod_admob.loadAndShow( adType, position )	
-- ==
function mod_admob.loadAndShow( adType, position )	
	_showOnNextLoad = adType
	_showOnNextLoadPosition = position
	mod_admob.load( adType )
end

-- ==
--		mod_admob.show( adType, position )	
-- ==
function mod_admob.show( adType, position )	
	ads:setCurrentProvider( "admob" )

	local id
	if( onAndroid ) then
		id = _ids.android[adType]
	elseif( oniOS ) then
		id = _ids.ios[adType]
	end

	if( adType == "banner" or ads.isLoaded( "interstitial" ) ) then
		if( _debugLevel >= 1 ) then	
			if( position ) then
				print( "Attempting to show AdMob ad type :" .. tostring(adType) .. " position: " .. tostring(position) .. " id: " .. tostring(id) )
			else
				print( "Attempting to show AdMob ad type :" .. tostring(adType) .. " id: " .. tostring(id) )
			end
		end

		if( adType == "banner" ) then
			local xPos, yPos
			if( position == "top" ) then
				xPos, yPos = display.screenOriginX, top
			else
				xPos, yPos = display.screenOriginX, bottom
			end

			ads.show( "banner", { x = xPos, y = yPos,  
				                  appId = id, targetingOptions = _targetingOptions, testMode = _testMode } )
		else
			ads.show( "interstitial", { appId = id, targetingOptions = _targetingOptions, testMode = _testMode } )
		end
		
	else
		_showOnNextLoad = adType
		_showOnNextLoadPosition = position
		ads.load( adType, id )
	end
end

-- ==
--		mod_admob.hide(  )	
-- ==
function mod_admob.hide(  )
	ads:setCurrentProvider( "admob" )
	if( _debugLevel >= 1 ) then	
		print( "Hiding AdMob" )
	end
	ads.hide( )
end


-- ==
--		Private listener
-- ==
_listener = function( event )
	if( _customListener ) then _customListener(event) end
	if( _debugLevel >= 1 ) then
		table.print_r(event)
	end

	if( event.isError ) then
		print("ERROR: AdMob received error?")
		table.print_r( event )
		-- Clear all action flags.  Something bad happened
		_autoLoad = false
		_showOnNextLoad = nil
		_showOnNextLoadPosition = nil
	
	elseif( event.phase == "loaded" ) then

		if( _showOnNextLoad ) then
			local adType 			= _showOnNextLoad
			local position 			= _showOnNextLoadPosition
			_showOnNextLoad 		= nil
			_showOnNextLoadPosition = nil
			mod_admob.show( adType, position )
		end

	elseif( event.phase == "shown" ) then
		if( _autoLoad ) then
			mod_admob.load( event.type )
		end

	elseif( event.phase == "refreshed" ) then

	
	end
end

return mod_admob