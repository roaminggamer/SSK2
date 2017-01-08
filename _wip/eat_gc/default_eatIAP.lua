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
	
	return ( util.usingIAP(currentProject) )
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


	genUtil.add( 0, 'local eatIAP = {}' )
	genUtil.add( 0, 'local listeners = {}' )
	genUtil.nl()

	--
	-- eatIAP.init()
	--

	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, '-- Unified IAP initializer (IAP Badger is handled separately). ' )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, 'function eatIAP.init( delay )' )
	genUtil.nl()

	genUtil.add( 1, '-- Tip: If a "delay" time is supplied, initialization will be postponed' )
	genUtil.add( 1, '--      for that period of time.  This is useful if you need other startup code')
	genUtil.add( 1, '--      to finish executing before you start initializing the analytics providers.')
	genUtil.add( 1, 'local function initializeIAP()' )





	-- =============================================================
	-- Android
	-- =============================================================
	if( curSettings.generate_android == "true" ) then
		genUtil.nl()
		--genUtil.add( 2, 'if( onAndroid and not onNook and not onAmazon ) then ' )
		genUtil.add( 2, 'if( onAndroid ) then ' )


		-- ===========
		-- Fortumo
		-- ===========
		if( curPlugins.iap_fortumo_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Fortumo')
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.iap_fortumo_service_id) > 0 ) then
				genUtil.add( 3, '-- SERVICE ID: ' .. curSettings.iap_fortumo_service_id )
			else
				genUtil.add( 3, '-- SERVICE ID: NOT SUPPLIED' )
			end
			if( len(curSettings.iap_fortumo_app_secret) > 0 ) then
				genUtil.add( 3, '-- APP SECRET: ' .. curSettings.iap_fortumo_app_secret )
			else
				genUtil.add( 3, '-- APP SECRET: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.iap_fortumo_service_id) > 0 and 
				len(curSettings.iap_fortumo_app_secret) > 0 ) then
				genUtil.add( 3, 'local fortumo = require( "plugin.fortumo" )')
				genUtil.add( 3, 'fortumo.findService({ serviceId  = "' ..
					curSettings.iap_fortumo_service_id .. '", appSecret = "' ..
					curSettings.iap_fortumo_app_secret .. '" }, genListener( "onIAP_fortumo_find" ) )' )
				genUtil.add( 3, 'fortumo.setStatusChangeListener( genListener( "onIAP_fortumo" ) )' )

			else
				genUtil.add( 3, '-- You did not supply either a Service ID and/or an App Secret.  Please get both and re-run EAT, or ' )
				genUtil.add( 3, '-- add them to the code below:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local fortumo = require( "plugin.fortumo" )')
				genUtil.add( 3, 'fortumo.findService({ serviceId  = "SERVICE_ID", appSecret = "APP_SECRET" }, genListener( "onIAP_fortumo_find" ) )' )
				genUtil.add( 3, 'fortumo.setStatusChangeListener( genListener( "onIAP_fortumo" ) )' )

				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Google IAP
		-- ===========
		if( curPlugins.iap_google_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Google IAP')
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, 'local store = require( "plugin.google.iap.v3" )')
			genUtil.add( 3, 'store.init( genListener( "onIAP_google" ) )' )				
		end


		genUtil.add( 2, 'end' )
		genUtil.nl()
		
	end

	-- =============================================================
	-- Kindle
	-- =============================================================
	if( curSettings.generate_android == "true" ) then
		genUtil.nl()
		genUtil.add( 2, 'if( onAndroid and onAmazon ) then ' )

		-- ===========
		-- Amazon IAP
		-- ===========
		if( curPlugins.iap_amazon_plugin )	then
			genUtil.nl()
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Amazon IAP')
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, 'local store = require( "plugin.amazon.iap" )')
			genUtil.add( 3, 'store.init( genListener( "onIAP_amazon" ) )' )				
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
	genUtil.add( 2, 'initializeIAP()' )
	genUtil.add( 1, 'else' )
	genUtil.add( 2, 'timer.performWithDelay( delay, initializeIAP )' )
	genUtil.add( 1, 'end' )

	genUtil.add( 0, 'end' )

	genUtil.nl()
	genUtil.add( 0, 'return eatIAP' )

	return genUtil.getContent()
end



return package


