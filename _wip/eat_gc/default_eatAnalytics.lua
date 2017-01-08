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
	
	return ( util.usingAnalytics(currentProject) )
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


	genUtil.add( 0, 'local eatAnalytics = {}' )
	genUtil.add( 0, 'local listeners = {}' )
	genUtil.nl()

	--
	-- eatAnalytics.init()
	--

	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, '-- Unified analytics initializer. ' )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, 'function eatAnalytics.init( delay )' )
	genUtil.nl()

	--table.dump(curSettings,nil,"curSettings")
	--table.dump(curPlugins,nil,"curPlugins")

	for k,v in pairs( curSettings ) do
		if( string.match( k, "analytics_") ) then
			--print( k,v)
		end
	end


	genUtil.add( 1, '-- Tip: If a "delay" time is supplied, initialization will be postponed' )
	genUtil.add( 1, '--      for that period of time.  This is useful if you need other startup code')
	genUtil.add( 1, '--      to finish executing before you start initializing the analytics providers.')
	genUtil.add( 1, 'local function initializeAnalytics()' )

	-- =============================================================
	-- Android
	-- =============================================================
	if( curSettings.generate_android == "true" ) then
		genUtil.nl()
		--genUtil.add( 2, 'if( onAndroid and not onNook and not onAmazon ) then ' )
		genUtil.add( 2, 'if( onAndroid ) then ' )


		-- ===========
		-- Flurry (legacy)
		-- ===========
		if( curPlugins.flurry_plugin_legacy )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Flurry (legacy)')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_android_flurry_legacy_api_key) > 0 ) then
				genUtil.add( 3, '-- API KEY: ' .. curSettings.analytics_android_flurry_legacy_api_key )
			else
				genUtil.add( 3, '-- API KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_android_flurry_legacy_api_key) > 0 ) then
				genUtil.add( 3, 'local analytics = require( "analytics" )')
				genUtil.add( 3, 'analytics.init( "' ..
					            curSettings.analytics_android_flurry_legacy_api_key .. '" )' )

			else
				genUtil.add( 3, '-- You did not supply an API Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local analytics = require( "analytics" )')
				genUtil.add( 3, 'analytics.init( "API_KEY" )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Flurry
		-- ===========
		if( curPlugins.flurry_plugin_legacy )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Flurry')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.flurry_plugin) > 0 ) then
				genUtil.add( 3, '-- API KEY: ' .. curSettings.analytics_android_flurry_api_key )
			else
				genUtil.add( 3, '-- API KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_android_flurry_api_key) > 0 ) then
				genUtil.add( 3, 'local flurryAnalytics = require( "plugin.flurry.analytics" )')
				genUtil.add( 3, 'flurryAnalytics.init( genListener( "onAnalytics_flurry" ), { apiKey =  "' ..
					            curSettings.analytics_android_flurry_api_key .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an API Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local flurryAnalytics = require( "plugin.flurry.analytics" )')
				genUtil.add( 3, 'flurryAnalytics.init( genListener( "onAnalytics_flurry" ), { apiKey = "YOUR_API_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Google Analytics
		-- ===========
		if( curPlugins.google_analytics_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Google Analytics')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_android_google_app_name) > 0 ) then
				genUtil.add( 3, '-- APP NAME: ' .. curSettings.analytics_android_google_app_name )
			else
				genUtil.add( 3, '-- APP NAME: NOT SUPPLIED' )
			end
			if( len(curSettings.analytics_android_google_tracking_id) > 0 ) then
				genUtil.add( 3, '-- TRACKING ID: ' .. curSettings.analytics_android_google_tracking_id )
			else
				genUtil.add( 3, '-- TRACKING ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.analytics_android_google_app_name) > 0 and 
				len(curSettings.analytics_android_google_tracking_id) > 0 ) then
				genUtil.add( 3, 'local googleAnalytics = require( "plugin.googleAnalytics" )')
				genUtil.add( 3, 'googleAnalytics.init( "' .. curSettings.analytics_android_google_app_name .. 
					            '", "' .. curSettings.analytics_android_google_tracking_id .. '" )' )

			else
				genUtil.add( 3, '-- You are missing an App Name and/or a Tracking ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Google Analytics.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local googleAnalytics = require( "plugin.googleAnalytics" )')
				genUtil.add( 3, 'googleAnalytics.init( "APP_NAME", "TRACKING_ID" )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Parse
		-- ===========
		if( curPlugins.parse_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Parse')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_android_parse_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.analytics_android_parse_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			if( len(curSettings.analytics_android_parse_rest_key) > 0 ) then
				genUtil.add( 3, '-- REST KEY: ' .. curSettings.analytics_android_parse_rest_key )
			else
				genUtil.add( 3, '-- REST KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.analytics_android_parse_app_id) > 0 and 
				len(curSettings.analytics_android_parse_rest_key) > 0 ) then
				genUtil.add( 3, 'local parse = require("plugin.parse")')
				genUtil.add( 3, 'parse.config:applicationId("' .. curSettings.analytics_android_parse_app_id .. '")')
				genUtil.add( 3, 'parse.config:restApiKey("' .. curSettings.analytics_android_parse_rest_key .. '")')

			else
				genUtil.add( 3, '-- You are missing an App ID and/or a REST Key. ' )
				genUtil.add( 3, '-- Both are required to initialize Google Analytics.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local parse = require("plugin.parse")')
				genUtil.add( 3, 'parse.config:applicationId("PARSE_APP_ID")')
				genUtil.add( 3, 'parse.config:restApiKey("PARSE_REST_KEY")')
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
		-- Flurry (legacy)
		-- ===========
		if( curPlugins.flurry_plugin_legacy )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Flurry (legacy)')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_ios_flurry_legacy_api_key) > 0 ) then
				genUtil.add( 3, '-- API KEY: ' .. curSettings.analytics_ios_flurry_legacy_api_key )
			else
				genUtil.add( 3, '-- API KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_ios_flurry_legacy_api_key) > 0 ) then
				genUtil.add( 3, 'local analytics = require( "analytics" )')
				genUtil.add( 3, 'analytics.init( "' ..
					            curSettings.analytics_ios_flurry_legacy_api_key .. '" )' )

			else
				genUtil.add( 3, '-- You did not supply an API Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local analytics = require( "analytics" )')
				genUtil.add( 3, 'analytics.init( "API_KEY" )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Flurry
		-- ===========
		if( curPlugins.flurry_plugin_legacy )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Flurry')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.flurry_plugin) > 0 ) then
				genUtil.add( 3, '-- API KEY: ' .. curSettings.analytics_ios_flurry_api_key )
			else
				genUtil.add( 3, '-- API KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_ios_flurry_api_key) > 0 ) then
				genUtil.add( 3, 'local flurryAnalytics = require( "plugin.flurry.analytics" )')
				genUtil.add( 3, 'flurryAnalytics.init( genListener( "onAnalytics_flurry" ), { apiKey =  "' ..
					            curSettings.analytics_ios_flurry_api_key .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an API Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local flurryAnalytics = require( "plugin.flurry.analytics" )')
				genUtil.add( 3, 'flurryAnalytics.init( genListener( "onAnalytics_flurry" ), { apiKey = "YOUR_API_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Google Analytics
		-- ===========
		if( curPlugins.google_analytics_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Google Analytics')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_ios_google_app_name) > 0 ) then
				genUtil.add( 3, '-- APP NAME: ' .. curSettings.analytics_ios_google_app_name )
			else
				genUtil.add( 3, '-- APP NAME: NOT SUPPLIED' )
			end
			if( len(curSettings.analytics_ios_google_tracking_id) > 0 ) then
				genUtil.add( 3, '-- TRACKING ID: ' .. curSettings.analytics_ios_google_tracking_id )
			else
				genUtil.add( 3, '-- TRACKING ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.analytics_ios_google_app_name) > 0 and 
				len(curSettings.analytics_ios_google_tracking_id) > 0 ) then
				genUtil.add( 3, 'local googleAnalytics = require( "plugin.googleAnalytics" )')
				genUtil.add( 3, 'googleAnalytics.init( "' .. curSettings.analytics_ios_google_app_name .. 
					            '", "' .. curSettings.analytics_ios_google_tracking_id .. '" )' )

			else
				genUtil.add( 3, '-- You are missing an App Name and/or a Tracking ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Google Analytics.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local googleAnalytics = require( "plugin.googleAnalytics" )')
				genUtil.add( 3, 'googleAnalytics.init( "APP_NAME", "TRACKING_ID" )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Parse
		-- ===========
		if( curPlugins.parse_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Parse')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.analytics_ios_parse_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.analytics_ios_parse_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			if( len(curSettings.analytics_ios_parse_rest_key) > 0 ) then
				genUtil.add( 3, '-- REST KEY: ' .. curSettings.analytics_ios_parse_rest_key )
			else
				genUtil.add( 3, '-- REST KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.analytics_ios_parse_app_id) > 0 and 
				len(curSettings.analytics_ios_parse_rest_key) > 0 ) then
				genUtil.add( 3, 'local parse = require("plugin.parse")')
				genUtil.add( 3, 'parse.config:applicationId("' .. curSettings.analytics_ios_parse_app_id .. '")')
				genUtil.add( 3, 'parse.config:restApiKey("' .. curSettings.analytics_ios_parse_rest_key .. '")')

			else
				genUtil.add( 3, '-- You are missing an App ID and/or a REST Key. ' )
				genUtil.add( 3, '-- Both are required to initialize Google Analytics.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local parse = require("plugin.parse")')
				genUtil.add( 3, 'parse.config:applicationId("PARSE_APP_ID")')
				genUtil.add( 3, 'parse.config:restApiKey("PARSE_REST_KEY")')
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
	genUtil.add( 2, 'initializeAnalytics()' )
	genUtil.add( 1, 'else' )
	genUtil.add( 2, 'timer.performWithDelay( delay, initializeAnalytics )' )
	genUtil.add( 1, 'end' )

	genUtil.add( 0, 'end' )

	genUtil.nl()
	genUtil.add( 0, 'return eatAnalytics' )

	return genUtil.getContent()
end



return package


