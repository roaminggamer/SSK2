-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- 
-- =============================================================
local RGFiles 	= ssk.files
local genUtil 	= require( "scripts.generation.genUtil" )
local pu 	  	= require( "scripts.generation.packageUtil" )

local curSettings
local curPlugins

local len = function( str ) 
	if( not str ) then return 0 end
	return string.len( tostring( str ) )
end


local package = {}


-- ==
--		Logic to see if this should be run at all
-- ==
function package.shouldRun( currentProject )
	local util = require "scripts.util"

	if( not currentProject ) then 
		curSettings = {}
		curPlugins = {}
	else
		--table.dump(curSettings,nil,"curSettings")
		curSettings = currentProject.settings
		curPlugins = currentProject.plugins
	end	
	
	return ( util.usingAttribution(currentProject) )
end

-- ==
--		MAIN GENERATOR
-- ==
function package.generate( fileName, currentProject )
	genUtil.resetContent()

	-- Header	
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, "-- " .. (currentProject.copyright_statement or "Your Copyright Statement Goes Here") )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, "--  " .. fileName )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, "--")
	genUtil.add( 0, "-- =============================================================" )

	genUtil.add( 0, 'local onSimulator    = ( system.getInfo( "environment" ) == "simulator" )')
	genUtil.add( 0, 'local oniOS          = ( system.getInfo("platformName") == "iPhone OS" )') 
	genUtil.add( 0, 'local onAndroid      = ( system.getInfo("platformName") == "Android" )') 
	genUtil.add( 0, 'local onWinPhone     = ( system.getInfo("platformName") == "WinPhone" )')
	genUtil.add( 0, 'local onOSX          = ( system.getInfo("platformName") == "Mac OS X" )')
	genUtil.add( 0, 'local onAppleTV      = ( system.getInfo("platformName") == "tvOS" )')
	genUtil.add( 0, 'local onAndroidTV    = ( (system.getInfo("androidDisplayDensityName") == "tvdpi") or')
	genUtil.add( 0, '                         (tostring(system.getInfo("androidDisplayApproximateDpi")) == "213" ) )') 
	genUtil.add( 0, 'local onWin          = ( system.getInfo("platformName") == "Win" )')
	genUtil.add( 0, 'local onNook         = ( system.getInfo("targetAppStore") == "nook" )')
	genUtil.add( 0, 'local onAmazon       = ( system.getInfo("targetAppStore") == "amazon" or')
	genUtil.add( 0, '                         ( string.find( system.getInfo("model"), "Fire" ) ~= nil ) )')
	genUtil.add( 0, 'local onDesktop      = ( ( onOSX or onWin ) and not onSimulator )')
	genUtil.add( 0, 'local onDevice       = ( onAndroid or oniOS or onAppleTVOS or onAndroidTV  )')
	genUtil.nl()

	genUtil.add( 0, '-- Listener generator.  Builds and returns custom listener on demand.')
	genUtil.add( 0, '-- These custom listeners dispatch named Runtime events that you can' )
	genUtil.add( 0, '-- listen for anywhere, making it much easier to deal with ad events.' )	
	genUtil.add( 0, '--' )

	genUtil.add( 0, 'local function genListener( eventName )' )
	genUtil.add( 1, 'local function listener( event )' )
	genUtil.add( 2, '-- For niceness, ensure all ad events include the time the event occured')
	genUtil.add( 2, 'if( not event.time ) then event.time = system.getTimer() end' )
	genUtil.add( 2, 'event.name = eventName')
	genUtil.add( 2, 'Runtime:dispatchEvent( event )' )
	genUtil.add( 1, 'end' )
	genUtil.add( 1, 'return listener' )
	genUtil.add( 0, 'end' )
	genUtil.nl()


	genUtil.add( 0, 'local eatAttribution = {}' )
	genUtil.add( 0, 'local listeners = {}' )
	genUtil.nl()

	--
	-- eatAttribution.init()
	--

	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, '-- Unified attribution initializer. ' )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, 'function eatAttribution.init( delay )' )
	genUtil.nl()

	--table.dump(curSettings,nil,"curSettings")
	--table.dump(curPlugins,nil,"curPlugins")

	for k,v in pairs( curSettings ) do
		if( string.match( k, "attribution_") ) then
			--print( k,v)
		end
	end

	genUtil.add( 1, '-- Tip: If a "delay" time is supplied, initialization will be postponed' )
	genUtil.add( 1, '--      for that period of time.  This is useful if you need other startup code')
	genUtil.add( 1, '--      to finish executing before you start initializing the attibution providers.')
	genUtil.add( 1, 'local function initializeAttribution()' )

	-- =============================================================
	-- Android
	-- =============================================================
	if( curSettings.generate_android == "true" ) then
		genUtil.nl()
		--genUtil.add( 2, 'if( onAndroid and not onNook and not onAmazon ) then ' )
		genUtil.add( 2, 'if( onAndroid ) then ' )


		-- ===========
		-- Kochava
		-- ===========
		if( curPlugins.kochava_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Kochava')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.attribution_kochava_android_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.attribution_kochava_android_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.attribution_kochava_android_app_id) > 0 ) then
				genUtil.add( 3, 'local kochava = require( "plugin.kochava" )')
				genUtil.add( 3, 'kochava.init( genListener( "onAttribution_kochava" ), { appId = "' ..
					            curSettings.attribution_kochava_android_app_id .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local kochava = require( "plugin.kochava" )')
				genUtil.add( 3, 'kochava.init( genListener( "onAttribution_kochava" ), { appId = "YOUR_APP_ID" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		genUtil.add( 2, 'end' )
		genUtil.nl()
		
	end

	-- =============================================================
	-- iOS
	-- =============================================================
	if( curSettings.generate_ios == "true" ) then
		genUtil.nl()
		genUtil.add( 2, 'if( oniOS ) then ' )


		-- ===========
		-- Kochava
		-- ===========
		if( curPlugins.kochava_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Kochava')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.attribution_kochava_ios_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.attribution_kochava_ios_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.attribution_kochava_ios_app_id) > 0 ) then
				genUtil.add( 3, 'local kochava = require( "plugin.kochava" )')
				genUtil.add( 3, 'kochava.init( genListener( "onAttribution_kochava" ), { appId = "' ..
					            curSettings.attribution_kochava_ios_app_id .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local kochava = require( "plugin.kochava" )')
				genUtil.add( 3, 'kochava.init( genListener( "onAttribution_kochava" ), { appId = "YOUR_APP_ID" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		genUtil.add( 2, 'end' )
		genUtil.nl()
		
	end



	-- ===========
	-- ===========
	-- ===========
	-- ===========
	-- ===========
	-- ===========
	-- ===========
	-- ===========
	-- ===========


	genUtil.add( 1, 'end' )
	genUtil.nl()		


	-- ===========
	-- ===========
	-- ===========
	genUtil.add( 1, '-- Initialize immediately or wait a little while?' )
	genUtil.add( 1, 'if( not delay or delay < 1 ) then' )
	genUtil.add( 2, 'initializeAttribution()' )
	genUtil.add( 1, 'else' )
	genUtil.add( 2, 'timer.performWithDelay( delay, initializeAttribution )' )
	genUtil.add( 1, 'end' )

	genUtil.add( 0, 'end' )

	genUtil.nl()
	genUtil.add( 0, 'return eatAttribution' )

	return genUtil.getContent()
end



return package


