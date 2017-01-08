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
	
	return ( util.usingUtils(currentProject) )
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


	genUtil.add( 0, 'local eatSpecial = {}' )
	genUtil.add( 0, 'local listeners = {}' )
	genUtil.nl()

	--
	-- eatSpecial.init()
	--

	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, '-- Unified utilities initializer.  A small set of utilities from plugins require initialization.' )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, 'function eatSpecial.init( delay )' )
	genUtil.nl()


	genUtil.add( 1, '-- Tip: If a "delay" time is supplied, initialization will be postponed' )
	genUtil.add( 1, '--      for that period of time.  This is useful if you need other startup code')
	genUtil.add( 1, '--      to finish executing before you start initializing the analytics providers.')
	genUtil.add( 1, 'local function initializeSpecial()' )


	-- =============================================================
	-- Any OS
	-- =============================================================

	-- ===========
	-- Google Drive
	-- ===========
	if( curPlugins.util_googledrive_plugin )	then
		genUtil.nl()
		genUtil.add( 2, '-- =========================')
		genUtil.add( 2, '-- Initialize Google Drive')
		genUtil.add( 2, '-- =========================')
		if( len(curSettings.utilities_googledrive_client_id) > 0 ) then
			genUtil.add( 2, '-- CLIENT ID: ' .. curSettings.utilities_googledrive_client_id )
		else
			genUtil.add( 2, '-- CLIENT ID: NOT SUPPLIED' )
		end
		if( len(curSettings.utilities_googledrive_client_secret) > 0 ) then
			genUtil.add( 2, '-- CLIENT SECRET: ' .. curSettings.utilities_googledrive_client_secret )
		else
			genUtil.add( 2, '-- CLIENT SECRET: NOT SUPPLIED' )
		end
		if( len(curSettings.utilities_googledrive_redirect_url) > 0 ) then
			genUtil.add( 2, '-- REDIRECT URL: ' .. curSettings.utilities_googledrive_redirect_url )
		else
			genUtil.add( 2, '-- REDIRECT URL: NOT SUPPLIED' )
		end
		genUtil.add( 2, '-- =========================')
		if( len(curSettings.utilities_googledrive_client_id) > 0 and
			len(curSettings.utilities_googledrive_client_secret) > 0 and
			len(curSettings.utilities_googledrive_redirect_url) > 0 ) then
			genUtil.add( 2, 'local googleDrive = require( "plugin.drive" )')
			genUtil.add( 2, 'googleDrive.init( "' ..
				            curSettings.utilities_googledrive_client_id .. '", "' ..
				            curSettings.utilities_googledrive_client_secret .. '", "' ..
				            curSettings.utilities_googledrive_redirect_url .. '" )' )

		else
			genUtil.add( 2, '-- You did not supply an CLIENT ID and/or SECRET ID and/or REDIRECT URL.' )
			genUtil.add( 2, '-- Please update the code below manually:' )
			genUtil.add( 2, '--[[' )
			genUtil.add( 2, 'local googleDrive = require( "plugin.drive" )')
			genUtil.add( 2, 'googleDrive.init( "clientId", "clientSecret", "redirectUrl" )' )
			genUtil.add( 2, '--]]' )
			
		end
	end



	-- =============================================================
	-- Android
	-- =============================================================
	if( curSettings.generate_android == "true" ) then
		genUtil.nl()
		--genUtil.add( 2, 'if( onAndroid and not onNook and not onAmazon ) then ' )
		genUtil.add( 2, 'if( onAndroid ) then ' )


		-- ===========
		-- HockeyApp
		-- ===========
		if( curPlugins.hockeyapp_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize HockeyApp')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.utilities_android_hockeyapp_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.utilities_android_hockeyapp_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.utilities_android_hockeyapp_app_id) > 0 ) then
				genUtil.add( 3, 'local hockeyApp = require( "plugin.hockey" )')
				genUtil.add( 3, 'hockeyApp.init( "' ..
					            curSettings.utilities_android_hockeyapp_app_id .. '" )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local hockeyApp = require( "plugin.hockey" )')
				genUtil.add( 3, 'hockeyApp.init( "APP_ID" )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		genUtil.add( 2, 'end' )
		genUtil.nl()
		
	end


	-- =============================================================
	-- Android OR iOS
	-- =============================================================
	if( curSettings.generate_android == "true" or curSettings.generate_ios == "true" ) then
		genUtil.nl()
		--genUtil.add( 2, 'if( onAndroid and not onNook and not onAmazon ) then ' )
		genUtil.add( 2, 'if( onAndroid or oniOS ) then ' )


		-- ===========
		-- VK
		-- ===========
		if( curPlugins.util_vk_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize VK')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.utilities_vk_scheme) > 0 ) then
				genUtil.add( 3, '-- SCHEME / APP ID: ' .. curSettings.utilities_vk_scheme )
			else
				genUtil.add( 3, '-- SCHEME / APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.utilities_vk_scheme) > 0 ) then
				genUtil.add( 3, 'local vk = require("plugin.vk")')
				genUtil.add( 3, 'local permissions = {} -- You need to fill this in yourself: http://spiralcodestudio.com/plugin-vk/')
				genUtil.add( 3, 'vk.init( "' ..
					            curSettings.utilities_vk_scheme .. '", permissions )' )

			else
				genUtil.add( 3, '-- You did not supply a Scheme.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the scheme to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local vk = require("plugin.vk")')
				genUtil.add( 3, 'local permissions = {} -- You need to fill this in yourself: http://spiralcodestudio.com/plugin-vk/')
				genUtil.add( 3, 'vk.init( "SCHEME_APPID" , permissions) ' )
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
	genUtil.add( 2, 'initializeSpecial()' )
	genUtil.add( 1, 'else' )
	genUtil.add( 2, 'timer.performWithDelay( delay, initializeSpecial )' )
	genUtil.add( 1, 'end' )

	genUtil.add( 0, 'end' )

	genUtil.nl()
	genUtil.add( 0, 'return eatSpecial' )

	return genUtil.getContent()
end



return package


