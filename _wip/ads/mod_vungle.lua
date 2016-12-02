-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- EAT Paid Content - Vungle Module
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
 > mod_vungle.register( id, os )	
 > mod_vungle.setListener( customListener )
 > mod_vungle.init( [ showImmediately ] ] )
 > mod_vungle.setAdOptions( name, value )	
 > mod_vungle.setDebugLevel( debugLevel )
 > mod_vungle.show()	
 > 
--]]
-- =============================================================
-- The module
local mod_vungle = {} 

local ads = require "ads"

local _debugLevel 			= 0

local _ids 					= {}
local _customListener				-- Forward declared optional/changable user listener
local _listener 					-- Forward declared private listener

local _options

local _showOnNextLoad


-- ==
--		mod_vungle.register( id, os )
-- ==
function mod_vungle.register( id, os  )	
	_ids[os] = _ids[os] or id

	if( _debugLevel > 1 ) then
		table.print_r(_ids)
	end
end

-- ==
--		mod_vungle.setListener( customListener )	
-- ==
function mod_vungle.setListener( customListener )
	_customListener = customListener
end



-- ==
--		mod_vungle.init( [ showImmediately ] )
-- ==
function mod_vungle.init( showImmediately )
	local id
	if( onAndroid ) then
		id = _ids.android
	elseif( oniOS ) then
		id = _ids.ios
	end

	if(onAndroid ) then
		if( _debugLevel >= 1 ) then	
			print( "mod_vungle.init( " .. tostring(showImmediately) .. " ) id: " .. tostring(id))
		end
		ads.init( "vungle", id, _listener )
		ads:setCurrentProvider("vungle")
	elseif( oniOS ) then
		if( _debugLevel >= 1 ) then	
			print( "mod_vungle.init( " .. tostring(showImmediately) .. " ) id: " .. tostring(id))
		end
		ads.init( "vungle", id, _listener )
		ads:setCurrentProvider("vungle")
	elseif( not onSimulator ) then
		print( "ERROR: mod_vungle.init( " .. tostring(showImmediately) .." ) id: " .. tostring(id))
		return
	end

	-- Note: Docs are wrong.  You don't load here. Load first ad after 'sessionStarted'
	if( showImmediately ) then
		mod_vungle.show( showImmediately )	
	end

end


-- ==
--		mod_vungle.setAdOptions( name, value )
--
--      isAnimated (optional) - Boolean. This parameter only applies to iOS. If true (default), the video ad will transition in with a slide effect. If false, it will appear instantaneously.
--      isAutoRotation (required)- Boolean. If true (default), the video ad will rotate automatically with the device's orientation. If false, it will use the ad's preferred orientation. This is required for Android only. For iOS, look into the orientations key.
--      orientations (optional) - [Boolean][api.type.Integer]. Bitmaks with the possible orientation values. Default is UIInterfaceOrientationMaskAll.
--      isBackButtonEnabled (optional) - Boolean. This parameter only applies to Android. If true, the Android back button will stop playback of the video ad and display the post-roll. If false (default), the back button will be disabled during playback. Note that the back button is always enabled in the post-roll — when pressed, it exits the ad and returns to the application.
--      isSoundEnabled (optional)- Boolean. If true (default), sound will be enabled during video ad playback, subject to the device's sound settings. If false, video playback will begin muted. Note that the user can mute or un-mute sound during playback.
--      username (optional) - String. This parameter only applies to the "incentivized" ad unit type. When specified, it represents the user identifier that you wish to receive in a server-to-server callback that rewards the user for a completed video ad view.
--
-- ==
function mod_vungle.setAdOptions( name, value )	
	_options = _options or {}
	_options[name] = value
end

-- ==
--		mod_vungle.setDebugLevel( debugLevel )	
-- ==
function mod_vungle.setDebugLevel( debugLevel )
	_debugLevel = debugLevel
end

-- ==
--		mod_vungle.show( )
-- ==
function mod_vungle.show( adType )
	ads:setCurrentProvider( "vungle" )
	adType = adType or "interstitial"

	if( onSimulator ) then return end

	local id
	if( onAndroid ) then
		id = _ids.android
	elseif( oniOS ) then
		id = _ids.ios
	end

	if( ads.isAdAvailable() ) then
		if( _debugLevel >= 1 ) then	
			print( "Attempting to show Vungle ad id: " .. tostring(id) )
		end

		ads.show( adType, _options )
	else 
		_showOnNextLoad = adType
		print( "WARNING: Vungle - No Ad Loaded Yet? Attempting to show Vungle ad id: " .. tostring(id) )
		ads.show( adType, _options )		
	end
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
		print("ERROR: Vungle received error?")
		table.print_r( event )
		_showOnNextLoad = nil
	
	elseif( event.phase == "adStart" ) then
		_showOnNextLoad = nil	

	elseif( event.phase == "adView" ) then

	elseif( event.phase == "adEnd" ) then

	elseif( event.phase == "cachedAdAvailable" ) then
		if( _showOnNextLoad ) then
			mod_vungle.show(_showOnNextLoad)
			_showOnNextLoad = nil
		end	
	end
end


return mod_vungle