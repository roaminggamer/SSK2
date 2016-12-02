-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- EAT Paid Content - AppLovin Module
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
 > mod_applovin.register( id  )	
 > mod_applovin.setListener( customListener )
 > mod_applovin.setAutoLoad( enable )	
 > mod_applovin.setOptions( name, value )	 
 > mod_applovin.setDebugLevel( debugLevel )
 > mod_applovin.init( [ showOnFirstLoad ] ] )
 > mod_applovin.load( )
 > mod_applovin.loadAndShow( )
 > mod_applovin.show()	
 > mod_applovin.hide()
 > 
--]]
-- =============================================================
-- The module
local mod_applovin = {} 

local applovin 			= require( "plugin.applovin" )

local _debugLevel 		= 0

local _id 		= ""
local _customListener			-- Forward declared optional/changable user listener
local _listener 				-- Forward declared private listener

local _options				= {}

local _autoLoad 			= true 	-- Automatically load new ad when 'done' showing current ad (load same type)

local _loadOnInit				-- Automatically load an ad after the first load if 'true'
local _showOnNextLoad			-- If 'true' show ad as soon as loaded


-- ==
--		mod_applovin.register( id )	
-- ==
function mod_applovin.register( id  )	
	_id = id
end


-- ==
--		mod_applovin.setListener( customListener )	
-- ==
function mod_applovin.setListener( customListener )
	_customListener = customListener
end


-- ==
--		mod_applovin.setAutoLoad( enable )	
-- ==
function mod_applovin.setAutoLoad( enable )	
	_autoLoad = enable
end


-- ==
--		mod_applovin.setOptions( name, value )	
--      "verboseLogging" - true or false
-- 		"isIncentivized" - true or false
-- ==
function mod_applovin.setOptions( name, value )	
	_options = _options or {}
	_options[name] = value
end


-- ==
--		mod_applovin.setDebugLevel( debugLevel )	
-- ==
function mod_applovin.setDebugLevel( debugLevel )
	_debugLevel = debugLevel
	if( debugLevel > 2 ) then
		mod_applovin.setOptions( "verboseLogging", true )
	end
end


-- ==
--		mod_applovin.init( [showOnFirstLoad ] )
-- ==
function mod_applovin.init( showOnFirstLoad )
	if( _debugLevel >= 1 ) then	
		print( "mod_applovin.init( " .. tostring(showOnFirstLoad) .. " ) " )
	end
	_loadOnInit 				= _autoLoad or showOnFirstLoad
	_showOnNextLoad 			= showOnFirstLoad
	applovin.init( _listener, { sdkKey = _id, verboseLogging = _options.verboseLogging } )
end


-- ==
--		mod_applovin.load( )	
-- ==
function mod_applovin.load( )	
	if( _debugLevel >= 1 ) then	
		print( "Attempting to load AppLovin ad id: " .. tostring(_id) )
	end
	applovin.load( adType, _id )
end

-- ==
--		mod_applovin.loadAndShow( )
-- ==
function mod_applovin.loadAndShow( )	
	_showOnNextLoad = true
	mod_applovin.load()
end

-- ==
--		mod_applovin.show( )	
-- ==
function mod_applovin.show( )	
	if( applovin.isLoaded( _id ) ) then
		if( _debugLevel >= 1 ) then	
			print( "Attempting to show AppLovin ad isIncentivized: " .. tostring( _options.isIncentivized)  )
		end
		applovin.show( _options.isIncentivized  )
	else
		_showOnNextLoad = true
		applovin.load( _options.isIncentivized )
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

	if( event.phase == "gotError" ) then
		print("ERROR: AppLovin received error?")
		table.print_r( event )

		-- Clear all action flags.  Something bad happened
		_autoLoad = false
		_loadOnInit = nil
		_showOnNextLoad = nil
	elseif( event.phase == "init" ) then

		if( _loadOnInit ) then
			mod_applovin.load()
			_loadOnInit = nil
		end

	elseif( event.phase == "loaded" ) then
		if( _showOnNextLoad ) then
			_showOnNextLoad 		= nil
			mod_applovin.show()
		end

	elseif( event.phase == "displayed" ) then
		if( _autoLoad ) then
			mod_applovin.load( event.type )
		end

	elseif( event.phase == "playbackBegan") then -- (video)
	elseif( event.phase == "playbackEnded") then --

	elseif( event.phase == "declinedToView") then -- Indicates that the user chose “no” when prompted to view the ad.
	elseif( event.phase == "validationSucceeded") then -- Indicates that the user viewed the ad and that their reward was approved by the AppLovin server.
		post("onAdWatched" , { type = "video", isRewarded = true } )
	elseif( event.phase == "validationExceededQuota") then -- Indicates that the AppLovin server was contacted, but the user has already received the maximum amount of rewards allowed in a given day.
		post("onAdWatched" , { type = "video", isRewarded = true } )
	elseif( event.phase == "validationRejected") then -- Indicates that the AppLovin server rejected the reward request.
		post("onAdWatched" , { type = "video", isRewarded = true } )
	elseif( event.phase == "validationFailed") then -- Indicates that the AppLovin server could not be contacted.
		post("onAdWatched" , { type = "video", isRewarded = false } )

	elseif( event.phase == "hidden" ) then
		if( _autoLoad ) then
			mod_applovin.load( event.type )
		end

	elseif( event.phase == "clicked" ) then
		if( _autoLoad ) then
			mod_applovin.load( event.type )
		end
		post("onAdClicked" , { type = video, isRewarded = (_options.isIncentivized == true) } )
	
	end
end

return mod_applovin