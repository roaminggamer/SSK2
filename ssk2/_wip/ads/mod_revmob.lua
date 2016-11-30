-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- EAT Paid Content - RevMob Module
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
 > mod_revmob.register( id, os, adType )	
 > mod_revmob.setListener( customListener )
 > mod_revmob.setAutoLoad( enable )	
 > mod_revmob.setDebugLevel( debugLevel )
 > mod_revmob.init( [ adType [ , showOnFirstLoad [ , position] ] ] )
 > mod_revmob.load( adType )
 > mod_revmob.loadAndShow( adType, position )
 > mod_revmob.show( adType, position )	
 > mod_revmob.hide()
 > 
--]]
-- =============================================================
-- The module
local mod_revmob = {} 

local revmob 				= require( "plugin.revmob" )

local _debugLevel 			= 2

local _ids 					= {}
local _customListener		-- Forward declared optional/changable user listener
local _listener 			-- Forward declared private listener

local _autoLoad 			= true 	-- Automatically load new ad when 'done' showing current ad (load same type)

local _loadOnInit				-- Automatically load an ad after the first load (if this is set to an adType)
local _showOnNextLoad			-- Internal variable used to automatically show the last loaded ad
local _showOnNextLoadPosition


-- ==
--		mod_revmob.register( id, os, adType )	
-- ==
function mod_revmob.register( id, os, adType  )	
	_ids[os] = _ids[os] or {}
	_ids[os][adType] = _ids[os][adType] or id

	if( _debugLevel > 1 ) then
		table.print_r(_ids)
	end
end

-- ==
--		mod_revmob.setListener( customListener )	
-- ==
function mod_revmob.setListener( customListener )
	_customListener = customListener
end

-- ==
--		mod_revmob.setAutoLoad( enable )	
-- ==
function mod_revmob.setAutoLoad( enable )	
	_autoLoad = enable
end

-- ==
--		mod_revmob.setDebugLevel( debugLevel )	
-- ==
function mod_revmob.setDebugLevel( debugLevel )
	_debugLevel = debugLevel
end

-- ==
--		mod_revmob.init( [ adType [ , showOnFirstLoad [ , position] ] ] )
-- ==
function mod_revmob.init( adType, showOnFirstLoad, position )
	if( _debugLevel >= 1 ) then	
		print( "mod_revmob.init( " .. tostring(adType) .. " ," .. tostring(showOnFirstLoad) .. " ," .. tostring(position) .. " ) " )
	end

	local id
	if( onAndroid ) then
		id = _ids.android[adType]
	elseif( oniOS ) then
		id = _ids.ios[adType]
	end

	_loadOnInit 				= adType
	-- This code isn't working becaue RevMob not throwing load
	--_showOnNextLoad 			= (showOnFirstLoad == true) and adType or nil
	--_showOnNextLoadPosition 	= (showOnFirstLoad == true) and position or nil
	if( showOnFirstLoad ) then 
		timer.performWithDelay( 50, function() mod_revmob.show( adType, position ) end )
	end
	revmob.init( _listener, { appId = id  } )
end

-- ==
--		mod_revmob.load( adType )	
-- ==
function mod_revmob.load( adType )	
	local id
	if( onAndroid ) then
		id = _ids.android[adType]
	elseif( oniOS ) then
		id = _ids.ios[adType]
	end

	if( _debugLevel >= 1 ) then	
		print( "Attempting to load RevMob ad type: " .. tostring(adType) .. " id: " .. tostring(id) )
	end
	revmob.load( adType, id )
end

-- ==
--		mod_revmob.loadAndShow( adType, position )
-- ==
function mod_revmob.loadAndShow( adType, position )	
	_showOnNextLoad = adType
	_showOnNextLoadPosition = position
	mod_revmob.load( adType )
end

-- ==
--		mod_revmob.show( adType, position )	
-- ==
function mod_revmob.show( adType, position )	
	local id
	if( onAndroid ) then
		id = _ids.android[adType]
	elseif( oniOS ) then
		id = _ids.ios[adType]
	end

	if( revmob.isLoaded( id ) ) then
		if( _debugLevel >= 1 ) then	
			print( "Attempting to show RevMob ad type :" .. tostring(adType) .. " position: " .. tostring(position) .. " id: " .. tostring(id) )
		end
		revmob.show( id, { yAlign = position or "top" } )
	else
		mod_revmob.loadAndShow( adType, position )	
	end
end

-- ==
--		mod_revmob.hide(  )	
-- ==
function mod_revmob.hide(  )
	local id
	if( onAndroid ) then
		id = _ids.android.banner
	elseif( oniOS ) then
		id = _ids.ios.banner
	end	

	if( not id ) then return end

	if( _debugLevel >= 1 ) then	
		print( "Hiding RevMob ad id: " .. tostring(id) )
	end
	revmob.hide( id  )
end



-- ==
--		Private listener
-- ==
_listener = function( event )
	if( _customListener ) then _customListener(event) end
	if( _debugLevel >= 1 ) then
		table.print_r(event)
	end

	if( event.phase == "init" ) then
		-- Note: Docs are wrong.  You don't load here. Load first ad after 'sessionStarted'
	
	elseif( event.phase == "sessionStarted" ) then
		if( _loadOnInit ) then
			mod_revmob.load( _loadOnInit )
			_loadOnInit = nil
		end

	elseif( event.phase == "loaded" ) then -- RevMob Bug? Not seeing this event any longer? Working around it.

		if( _showOnNextLoad ) then
			local adType 			= _showOnNextLoad
			local position 			= _showOnNextLoadPosition
			_showOnNextLoad 		= nil
			_showOnNextLoadPosition = nil
			mod_revmob.show( adType, position )
		end

	elseif( event.phase == "displayed" ) then
		if( _autoLoad ) then
			mod_revmob.load( event.type )
		end

	elseif( event.phase == "videoPlaybackBegan" ) then
	elseif( event.phase == "videoPlaybackEnded" ) then
	elseif( event.phase == "rewardedVideoPlaybackBegan" ) then
	elseif( event.phase == "rewardedVideoPlaybackEnded" ) then
	elseif( event.phase == "rewardedVideoCompleted" ) then

	elseif( event.phase == "hidden" ) then
		if( _autoLoad ) then
			mod_revmob.load( event.type )
		end

	elseif( event.phase == "clicked" ) then
		if( _autoLoad ) then
			mod_revmob.load( event.type )
		end
		post("onAdClicked" , { type = (event.type == "rewardedVideo") and "video" or event.type, 
			                   isRewarded = (event.type == "rewardedVideo") } )
	
	elseif( event.phase == "failed" ) then
		-- event.response EFM Redirect link not received?; event.isError == true; interstitial

		-- Clear all action flags.  Something bad happened
		_autoLoad = false
		_loadOnInit = nil
		_showOnNextLoad = nil
		_showOnNextLoadPosition = nil
	end
end

return mod_revmob