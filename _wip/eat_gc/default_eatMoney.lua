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

	
	return ( util.usingMonetizers(currentProject) )
end

-- ==
--		EAT MONEY GENERATOR
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


	genUtil.add( 0, 'local eatMoney = {}' )
	genUtil.add( 0, 'local listeners = {}' )
	genUtil.nl()

	-- Init Code	
	package.create_init( fileName, currentProject )
	genUtil.nl()

	-- Helper Code
	package.create_helpers( fileName, currentProject )
	genUtil.nl()


	genUtil.add( 0, 'return eatMoney' )

	return genUtil.getContent()
end


-- ==
--		EAT MONEY GENERATOR
-- ==
function package.create_init( fileName, currentProject )
	
	--
	-- eatMoney.init()
	--

	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, '-- Unified monetizer initializer. ' )
	genUtil.add( 0, "-- =============================================================" )
	genUtil.add( 0, 'function eatMoney.init( delay )' )
	genUtil.nl()

	--table.dump(curSettings,nil,"curSettings")
	--table.dump(curPlugins,nil,"curPlugins")


	genUtil.add( 1, '-- Tip: If a "delay" time is supplied, initialization will be postponed' )
	genUtil.add( 1, '--      for that period of time.  This is useful if you need other startup code')
	genUtil.add( 1, '--      to finish executing before you start initializing the ad networks.')
	genUtil.add( 1, 'local function initializeMonetizers()' )

	-- =============================================================
	-- Android
	-- =============================================================
	if( curSettings.generate_android == "true" ) then
		genUtil.nl()
		--genUtil.add( 2, 'if( onAndroid and not onNook and not onAmazon ) then ' )
		genUtil.add( 2, 'if( onAndroid ) then ' )

		-- ===========
		-- AdBuddiz
		-- ===========
		if( curPlugins.monetization_adbuddiz_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AdBuddiz')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/adbuddiz/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_adbuddiz_publisher_key) > 0 ) then
				genUtil.add( 3, '-- Publisher Key: ' .. curSettings.ads_android_adbuddiz_publisher_key )
			else
				genUtil.add( 3, '-- Publisher Key: NOT SUPPLIED' )
			end
			--[[
			if( len(curSettings.ads_android_adbuddiz_rewarded_publisher_key) > 0 ) then
				genUtil.add( 3, '-- Rewarded Publisher Key: ' .. curSettings.ads_android_adbuddiz_rewarded_publisher_key )
			else
				genUtil.add( 3, '-- Rewarded Publisher Key: NOT SUPPLIED' )
			end
			--]]
			genUtil.add( 3, '-- =========================')

			--[[
			if( len(curSettings.ads_android_adbuddiz_publisher_key) > 0 and 
				 len(curSettings.ads_android_adbuddiz_rewarded_publisher_key) > 0 ) then
				genUtil.add( 3, '-- Tip: You supplied two keys.  EAT Only supports using one. I will use the rewarded key.' )

				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setAndroidPublisherKey( "' .. 
					             curSettings.ads_android_adbuddiz_rewarded_publisher_key .. '" ) ' ) 
				genUtil.add( 3, 'Runtime:addEventListener( "AdBuddizRewardedVideoEvent", genListener( "onAd_adbuddiz" ) )' )
				
			else
			--]]
			if( len(curSettings.ads_android_adbuddiz_publisher_key) > 0 ) then
				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setAndroidPublisherKey( "' .. 
					             curSettings.ads_android_adbuddiz_publisher_key .. '" ) ' ) 
				genUtil.add( 3, 'Runtime:addEventListener( "AdBuddizEvent", genListener( "onAd_adbuddiz" ) )' )

			--[[
			elseif( len(curSettings.ads_android_adbuddiz_rewarded_publisher_key) > 0 ) then
				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setAndroidPublisherKey( "' .. 
					             curSettings.ads_android_adbuddiz_rewarded_publisher_key .. '" ) ' ) 
				genUtil.add( 3, 'Runtime:addEventListener( "AdBuddizRewardedVideoEvent", genListener( "onaAd_adbuddiz" ) )' )
			--]]
			else
				genUtil.add( 3, '-- You did not supply a Publisher ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the id to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setAndroidPublisherKey( "TEST_PUBLISHER_KEY" ) ' ) 
				genUtil.add( 3, '--Runtime:addEventListener( "AdBuddizEvent", genListener( "onAd_adbuddiz" ) )' )
				genUtil.add( 3, '--Runtime:addEventListener( "AdBuddizRewardedVideoEvent", genListener( "onAd_adbuddiz" ) )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AdMob
		-- ===========
		if( curPlugins.monetization_admob_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AdMob')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/ads-admob-v2/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_admob_banner_app_id) > 0 ) then
				genUtil.add( 3, '-- Banner AppId: ' .. curSettings.ads_android_admob_banner_app_id )
			else
				genUtil.add( 3, '-- Banner AppId: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_admob_interstitial_app_id) > 0 ) then
				genUtil.add( 3, '-- Interstitial AppId: ' .. curSettings.ads_android_admob_interstitial_app_id )
			else
				genUtil.add( 3, '-- Interstitial AppId: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_admob_banner_app_id) > 0 and 
				 len(curSettings.ads_android_admob_interstitial_app_id) > 0 ) then
				genUtil.add( 3, '-- Tip: You supplied two IDs.  AdMob only needs one to initialize, so I will use the Interstitial App ID. ' )

				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "' .. 
					             curSettings.ads_android_admob_interstitial_app_id .. 
					             '", genListener( "onAd_admob" ) )' )

			elseif( len(curSettings.ads_android_admob_banner_app_id) > 0 ) then
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "' .. 
					             curSettings.ads_android_admob_banner_app_id .. 
					             '", genListener( "onAd_admob" ) )' )

			elseif( len(curSettings.ads_android_admob_interstitial_app_id) > 0 ) then
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "' .. 
					             curSettings.ads_android_admob_interstitial_app_id .. 
					             '", genListener( "onAd_admob" ) )' )
			else
				genUtil.add( 3, '-- You did not supply an AppId.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the id to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "YOUR_APP_ID_HERE", genListener( "onAd_admob" ) )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AppLovin
		-- ===========
		if( curPlugins.monetization_applovin_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AppLovin')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/applovin/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_applovin_sdk_key) > 0 ) then
				genUtil.add( 3, '-- SDK Key: ' .. curSettings.ads_android_applovin_sdk_key )
			else
				genUtil.add( 3, '-- SDK Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_applovin_sdk_key) > 0 ) then
				genUtil.add( 3, 'local applovin = require( "plugin.applovin" )')
				genUtil.add( 3, 'applovin.init( ' .. 
					            'genListener( "onAd_applovin" ), { sdkKey = "' .. 
					            curSettings.ads_android_applovin_sdk_key .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an SDK Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local applovin = require( "plugin.applovin" )')
				genUtil.add( 3, 'applovin.init( genListener( "onAd_applovin" ), { sdkKey = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AppNext
		-- ===========
		if( curPlugins.monetization_appnext_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Appnext')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/appnext/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_appnext_placement_id) > 0 ) then
				genUtil.add( 3, '-- Placement ID / App Key: ' .. curSettings.ads_android_appnext_placement_id )
			else
				genUtil.add( 3, '-- Placement ID / App Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, 'local appnext = require( "plugin.appnext" )')
			genUtil.add( 3, 'appnext.init( genListener( "onAd_appnext" ) )' )
		end

		-- ===========
		-- AppoDeal
		-- ===========
		if( curPlugins.monetization_appodeal_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Appodeal')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/appodeal/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_appodeal_app_key) > 0 ) then
				genUtil.add( 3, '-- APP Key: ' .. curSettings.ads_android_appodeal_app_key )
			else
				genUtil.add( 3, '-- APP Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_appodeal_app_key) > 0 ) then
				genUtil.add( 3, 'local appodeal = require( "plugin.appodeal" )')
				genUtil.add( 3, 'appodeal.init( ' .. 
					            'genListener( "onAd_appodeal" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_android_appodeal_app_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local appodeal = require( "plugin.appodeal" )')
				genUtil.add( 3, 'appodeal.init( genListener( "onAd_appodeal" ), { appKey = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Corona Ads
		-- ===========
		if( curPlugins.monetization_corona_ads_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Corona Ads')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/coronaads/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_corona_ads_placement_id) > 0 ) then
				genUtil.add( 3, '-- Placement ID: ' .. curSettings.ads_android_corona_ads_placement_id )
			else
				genUtil.add( 3, '-- Placement ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_corona_ads_placement_id) > 0 ) then
				genUtil.add( 3, 'local coronaAds = require( "plugin.coronaAds" )')
				genUtil.add( 3, 'coronaAds.init( "' .. curSettings.ads_android_corona_ads_placement_id .. '", ' ..
					            'genListener( "onAd_coronaads" ) )' )
			else
				genUtil.add( 3, '-- You did not supply a Placement ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local coronaAds = require( "plugin.coronaAds" )')
				genUtil.add( 3, 'coronaAds.init( "YOUR_PLACEMENT_ID_HERE", genListener( "onAd_coronaads" ) )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- FAN
		-- ===========
		if( curPlugins.monetization_fan_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Facebook Ad Network')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/fbAudienceNetwork/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_fan_placement_id) > 0 ) then
				genUtil.add( 3, '-- Placement ID: ' .. curSettings.ads_android_fan_placement_id )
			else
				genUtil.add( 3, '-- Placement ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, 'local fbAudienceNetwork = require( "plugin.fbAudienceNetwork" )')
			genUtil.add( 3, 'appnext.init( genListener( "onAd_fan" ) )' )
		end

		-- ===========
		-- InMobi
		-- ===========
		if( curPlugins.monetization_inmobi_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize InMobi')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/inmobi/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_inmobi_account_id) > 0 ) then
				genUtil.add( 3, '-- ACCOUNT ID: ' .. curSettings.ads_android_inmobi_account_id )
			else
				genUtil.add( 3, '-- ACCOUNT ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_inmobi_account_id) > 0 ) then
				genUtil.add( 3, 'local inMobi = require( "plugin.inMobi" )')
				genUtil.add( 3, 'inMobi.init( ' .. 
					            'genListener( "onAd_inmobi" ), ' .. 
					            '{ accountId = "' .. curSettings.ads_android_inmobi_account_id ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an Account ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local inMobi = require( "plugin.inMobi" )')
				genUtil.add( 3, 'inMobi.init( genListener( "onAd_inmobi" ), { accountId = "YOUR_ACCOUNT_ID" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Kidoz
		-- ===========
		if( curPlugins.monetization_kidoz_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Kidoz')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/kidoz/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_kidoz_publisher_id) > 0 ) then
				genUtil.add( 3, '-- PUBLISHER ID: ' .. curSettings.ads_android_kidoz_publisher_id )
			else
				genUtil.add( 3, '-- PUBLISHER ID: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_kidoz_security_token) > 0 ) then
				genUtil.add( 3, '-- SECURITY TOKEN: ' .. curSettings.ads_android_kidoz_security_token )
			else
				genUtil.add( 3, '-- SECURITY TOKEN: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_kidoz_publisher_id) > 0 and 
				len(curSettings.ads_android_kidoz_security_token) > 0 ) then
				genUtil.add( 3, 'local kidoz = require( "plugin.kidoz" )')
				genUtil.add( 3, 'kidoz.init( ' .. 
					            'genListener( "onAd_kidoz" ), ' .. 
					            '{ publisherID = "' .. curSettings.ads_android_kidoz_publisher_id ..'", ' ..
					            'securityToken = "' .. curSettings.ads_android_kidoz_security_token ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing a Publisher ID and/or a Security Token. ' )
				genUtil.add( 3, '-- Both are required to initialize Kidoz.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local kidoz = require( "plugin.kidoz" )')
				genUtil.add( 3, 'kidoz.init( genListener( "onAd_kidoz" ), { publisherID = "YOUR_PUBLISHER_ID", securityToken = "YOUR_SECURITY_TOKEN" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- MediaBrix
		-- ===========
		if( curPlugins.monetization_mediabrix_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize MediaBrix')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/mediaBrix/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_mediabrix_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_android_mediabrix_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_mediabrix_app_id) > 0 ) then
				genUtil.add( 3, 'local mediaBrix = require( "plugin.mediaBrix" )')
				genUtil.add( 3, 'mediaBrix.init( ' .. 
					            'genListener( "onAd_mediabrix" ), ' .. 
					            '{ appId = "' .. curSettings.ads_android_mediabrix_app_id ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local mediaBrix = require( "plugin.mediaBrix" )')
				genUtil.add( 3, 'mediaBrix.init( genListener( "onAd_mediabrix" ), { appId = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Peanut Labs
		-- ===========
		if( curPlugins.monetization_peanuts_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Peanut Labs')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/peanutlabs/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_peanutlabs_user_id) > 0 ) then
				genUtil.add( 3, '-- USER ID: ' .. curSettings.ads_android_peanutlabs_user_id )
			else
				genUtil.add( 3, '-- USER ID: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_peanutlabs_app_key) > 0 ) then
				genUtil.add( 3, '-- APP KEY: ' .. curSettings.ads_android_peanutlabs_app_key )
			else
				genUtil.add( 3, '-- APP KEY: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_peanutlabs_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_android_peanutlabs_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_peanutlabs_user_id) > 0 and 
				len(curSettings.ads_android_peanutlabs_app_key) > 0 and 
				len(curSettings.ads_android_peanutlabs_app_id) > 0 ) then
				genUtil.add( 3, 'local peanutlabs = require( "plugin.peanutlabs" )')
				genUtil.add( 3, 'peanutlabs.init( ' .. 
					            'genListener( "onAd_peanutlabs" ), ' .. 
					            '{ userId = "' .. curSettings.ads_android_peanutlabs_user_id .. '", ' ..
					            'appKey = "' .. curSettings.ads_android_peanutlabs_app_key ..  '", ' ..
					            'appId = ' .. curSettings.ads_android_peanutlabs_app_id .. ' } )' )

			else
				genUtil.add( 3, '-- You are missing a User ID and/or an App Key and/or an App ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Peanut Labs.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local peanutlabs = require( "plugin.peanutlabs" )')
				genUtil.add( 3, 'peanutlabs.init( genListener( "onAd_peanutlabs" ), { userId = "USER_ID", appKey = "YOUR_APP_KEY", appId = 2222 } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Persona.ly
		-- ===========
		if( curPlugins.monetization_personaly_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Persona.ly')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/personaly/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_personaly_app_hash) > 0 ) then
				genUtil.add( 3, '-- APP HASH: ' .. curSettings.ads_android_personaly_app_hash )
			else
				genUtil.add( 3, '-- APP HASH: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_personaly_user_id) > 0 ) then
				genUtil.add( 3, '-- USER ID: ' .. curSettings.ads_android_personaly_user_id )
			else
				genUtil.add( 3, '-- USER ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_personaly_app_hash) > 0 and 
				len(curSettings.ads_android_personaly_user_id) > 0 ) then
				genUtil.add( 3, 'local personaly = require( "plugin.personaly" )')
				genUtil.add( 3, 'kidoz.init( ' .. 
					            'genListener( "onAd_personaly" ), ' .. 
					            '{ appHash = "' .. curSettings.ads_android_personaly_app_hash ..'", ' ..
					            'userId = "' .. curSettings.ads_android_personaly_user_id ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing an App Hash and/or a User ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Persona.ly.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local personaly = require( "plugin.personaly" )" )')
				genUtil.add( 3, 'kidoz.init( genListener( "onAd_personaly" ), { appHash = "YOUR_APP_HASH", userId = "UNIQUE_USER_ID" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Pollfish
		-- ===========
		if( curPlugins.monetization_pollfish_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Pollfish')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/pollfish/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_pollfish_api_key) > 0 ) then
				genUtil.add( 3, '-- API KEY: ' .. curSettings.ads_android_pollfish_api_key )
			else
				genUtil.add( 3, '-- API KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_pollfish_api_key) > 0 ) then
				genUtil.add( 3, 'local pollfish = require( "plugin.pollfish" )')
				genUtil.add( 3, 'pollfish.init( ' .. 
					            'genListener( "onAd_pollfish" ), ' .. 
					            '{ apiKey = "' .. curSettings.ads_android_pollfish_api_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an API KEY.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the KEY to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local pollfish = require( "plugin.pollfish" )')
				genUtil.add( 3, 'pollfish.init( genListener( "onAd_pollfish" ), { apiKey = "YOUR_API_KEY" }  )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- RevMob
		-- ===========
		if( curPlugins.monetization_revmob_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize RevMob')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/revmob/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_revmob_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_android_revmob_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_revmob_app_id) > 0 ) then
				genUtil.add( 3, 'local revmob = require( "plugin.revmob" )')
				genUtil.add( 3, 'revmob.init( ' .. 
					            'genListener( "onAd_revmob" ), ' .. 
					            '{ appId = "' .. curSettings.ads_android_revmob_app_id ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local revmob = require( "plugin.revmob" )')
				genUtil.add( 3, 'revmob.init( genListener( "onAd_revmob" ), { appId = "YOUR_APP_ID" }  )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Super Awesome
		-- ===========
		if( curPlugins.monetization_superawesome_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Super Awesome')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/superawesome/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_superawesome_placement_id) > 0 ) then
				genUtil.add( 3, '-- PLACEMENT ID: ' .. curSettings.ads_android_superawesome_placement_id )
			else
				genUtil.add( 3, '-- PLACEMENT ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			genUtil.add( 3, 'local superawesome = require( "plugin.superawesome" )')
			genUtil.add( 3, 'superawesome.init( ' ..  'genListener( "onAd_superawesome" ) )' )

		end

		-- ===========
		-- Supersonic
		-- ===========
		if( curPlugins.monetization_supersonic_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Supersonic')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/superawesome/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_supersonic_app_key) > 0 ) then
				genUtil.add( 3, '-- APP KEY: ' .. curSettings.ads_android_supersonic_app_key )
			else
				genUtil.add( 3, '-- APP KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_supersonic_app_key) > 0 ) then
				genUtil.add( 3, 'local supersonic = require( "plugin.supersonic" )')
				genUtil.add( 3, 'supersonic.init( ' .. 
					            'genListener( "onAd_supersonic" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_android_supersonic_app_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP KEY.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the KEY to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local supersonic = require( "plugin.supersonic" )')
				genUtil.add( 3, 'supersonic.init( genListener( "onAd_supersonic" ), { appKey = "YOUR_APP_ID" }  )' )
				genUtil.add( 3, '--]]' )				
			end
		end

		-- ===========
		-- Stripe
		-- ===========
		if( curPlugins.monetization_stripe_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Stripe')
			genUtil.add( 3, '-- http://www.jasonschroeder.com/2016/02/22/stripe-plugin-for-corona-sdk/' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_stripe_secret_key) > 0 ) then
				genUtil.add( 3, '-- SECRET KEY: ' .. curSettings.ads_android_stripe_secret_key )
			else
				genUtil.add( 3, '-- SECRET KEY: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_stripe_publishable_key) > 0 ) then
				genUtil.add( 3, '-- PUBLISHABLE KEY: ' .. curSettings.ads_android_stripe_publishable_key )
			else
				genUtil.add( 3, '-- PUBLISHABLE KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_stripe_secret_key) > 0 and 
				len(curSettings.ads_android_stripe_publishable_key) > 0 ) then
				genUtil.add( 3, 'local stripe = require("plugin.stripe")')
				genUtil.add( 3, 'stripe.init( ' .. 
					            '{ secretKey = "' .. curSettings.ads_android_stripe_secret_key ..'", ' ..
					            'publishableKey = "' .. curSettings.ads_android_stripe_publishable_key ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing an Secret Key and/or a Public (publishable) Key. ' )
				genUtil.add( 3, '-- Both are required to initialize Stripe.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local stripe = require("plugin.stripe")')
				genUtil.add( 3, 'stripe.init( { secretKey  = "SECRET_KEY", publishableKey  = "PUBLIC_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Trial Pay
		-- ===========
		if( curPlugins.monetization_trial_pay_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Trial Pay')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/trialPay/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_trial_pay_app_key) > 0 ) then
				genUtil.add( 3, '-- APP KEY: ' .. curSettings.ads_android_trial_pay_app_key )
			else
				genUtil.add( 3, '-- APP KEY: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_android_trial_pay_sid) > 0 ) then
				genUtil.add( 3, '-- SID: ' .. curSettings.ads_android_trial_pay_sid )
			else
				genUtil.add( 3, '-- SID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_trial_pay_app_key) > 0 and 
				len(curSettings.ads_android_trial_pay_sid) > 0 ) then
				genUtil.add( 3, 'local trialPay = require( "plugin.trialPay" )')
				genUtil.add( 3, 'trialPay.init( genListener( "onAd_trial_pay" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_android_trial_pay_app_key ..'", ' ..
					            'sid = "' .. curSettings.ads_android_trial_pay_sid ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing an App Key and/or a User ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Trial Pay.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local trialPay = require( "plugin.trialPay" )')
				genUtil.add( 3, 'trialPay.init( genListener( "onAd_trial_pay" ) , { appKey = "YOUR_APP_KEY", sid = "user1" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Vungle
		-- ===========
		if( curPlugins.monetization_vungle_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Vungle')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/vungle/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_android_vungle_app_key) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_android_vungle_app_key )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_android_vungle_app_key) > 0 ) then
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "vungle", "' .. curSettings.ads_android_vungle_app_key  .. '", ' ..
					            'genListener( "onAd_vungle" ) )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "vungle", "myAppId", genListener( "onAd_vungle" ) )' )
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
		-- AdBuddiz
		-- ===========
		if( curPlugins.monetization_adbuddiz_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AdBuddiz')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/adbuddiz/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_adbuddiz_publisher_key) > 0 ) then
				genUtil.add( 3, '-- Publisher Key: ' .. curSettings.ads_ios_adbuddiz_publisher_key )
			else
				genUtil.add( 3, '-- Publisher Key: NOT SUPPLIED' )
			end
			--[[
			if( len(curSettings.ads_ios_adbuddiz_rewarded_publisher_key) > 0 ) then
				genUtil.add( 3, '-- Rewarded Publisher Key: ' .. curSettings.ads_ios_adbuddiz_rewarded_publisher_key )
			else
				genUtil.add( 3, '-- Rewarded Publisher Key: NOT SUPPLIED' )
			end
			--]]
			genUtil.add( 3, '-- =========================')

			--[[
			if( len(curSettings.ads_ios_adbuddiz_publisher_key) > 0 and 
				 len(curSettings.ads_ios_adbuddiz_rewarded_publisher_key) > 0 ) then
				genUtil.add( 3, '-- Tip: You supplied two keys.  EAT Only supports using one. I will use the rewarded key.' )

				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setIOSPublisherKey( "' .. 
					             curSettings.ads_ios_adbuddiz_rewarded_publisher_key .. '" ) ' ) 
				genUtil.add( 3, 'Runtime:addEventListener( "AdBuddizRewardedVideoEvent", genListener( "onAd_adbuddiz" ) )' )
				
			else
			--]]
			if( len(curSettings.ads_ios_adbuddiz_publisher_key) > 0 ) then
				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setIOSPublisherKey( "' .. 
					             curSettings.ads_ios_adbuddiz_publisher_key .. '" ) ' ) 
				genUtil.add( 3, 'Runtime:addEventListener( "AdBuddizEvent", genListener( "onAd_adbuddiz" ) )' )
			--[[
			elseif( len(curSettings.ads_ios_adbuddiz_rewarded_publisher_key) > 0 ) then
				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setIOSPublisherKey( "' .. 
					             curSettings.ads_ios_adbuddiz_rewarded_publisher_key .. '" ) ' ) 
				genUtil.add( 3, 'Runtime:addEventListener( "AdBuddizRewardedVideoEvent", genListener( "onaAd_adbuddiz" ) )' )
			--]]
			else
				genUtil.add( 3, '-- You did not supply a Publisher ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the id to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local adbuddiz = require( "plugin.adbuddiz" )')
				genUtil.add( 3, 'adbuddiz.setIOSPublisherKey( "TEST_PUBLISHER_KEY" ) ' ) 
				genUtil.add( 3, '--Runtime:addEventListener( "AdBuddizEvent", genListener( "onAd_adbuddiz" ) )' )
				genUtil.add( 3, '--Runtime:addEventListener( "AdBuddizRewardedVideoEvent", genListener( "onAd_adbuddiz" ) )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AdMob
		-- ===========
		if( curPlugins.monetization_admob_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AdMob')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/ads-admob-v2/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_admob_banner_app_id) > 0 ) then
				genUtil.add( 3, '-- Banner AppId: ' .. curSettings.ads_ios_admob_banner_app_id )
			else
				genUtil.add( 3, '-- Banner AppId: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_admob_interstitial_app_id) > 0 ) then
				genUtil.add( 3, '-- Interstitial AppId: ' .. curSettings.ads_ios_admob_interstitial_app_id )
			else
				genUtil.add( 3, '-- Interstitial AppId: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_admob_banner_app_id) > 0 and 
				 len(curSettings.ads_ios_admob_interstitial_app_id) > 0 ) then
				genUtil.add( 3, '-- Tip: You supplied two IDs.  AdMob only needs one to initialize, so I will use the Interstitial App ID. ' )

				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "' .. 
					             curSettings.ads_ios_admob_interstitial_app_id .. 
					             '", genListener( "onAd_admob" ) )' )

			elseif( len(curSettings.ads_ios_admob_banner_app_id) > 0 ) then
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "' .. 
					             curSettings.ads_ios_admob_banner_app_id .. 
					             '", genListener( "onAd_admob" ) )' )

			elseif( len(curSettings.ads_ios_admob_interstitial_app_id) > 0 ) then
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "' .. 
					             curSettings.ads_ios_admob_interstitial_app_id .. 
					             '", genListener( "onAd_admob" ) )' )
			else
				genUtil.add( 3, '-- You did not supply an AppId.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the id to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "admob", "YOUR_APP_ID_HERE", genListener( "onAd_admob" ) )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AppLovin
		-- ===========
		if( curPlugins.monetization_applovin_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AppLovin')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/applovin/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_applovin_sdk_key) > 0 ) then
				genUtil.add( 3, '-- SDK Key: ' .. curSettings.ads_ios_applovin_sdk_key )
			else
				genUtil.add( 3, '-- SDK Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_applovin_sdk_key) > 0 ) then
				genUtil.add( 3, 'local applovin = require( "plugin.applovin" )')
				genUtil.add( 3, 'applovin.init( ' .. 
					            'genListener( "onAd_applovin" ), { sdkKey = "' .. 
					            curSettings.ads_ios_applovin_sdk_key .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an SDK Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local applovin = require( "plugin.applovin" )')
				genUtil.add( 3, 'applovin.init( genListener( "onAd_applovin" ), { sdkKey = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AppNext
		-- ===========
		if( curPlugins.monetization_appnext_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Appnext')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/appnext/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_appnext_placement_id) > 0 ) then
				genUtil.add( 3, '-- Placement ID / App Key: ' .. curSettings.ads_ios_appnext_placement_id )
			else
				genUtil.add( 3, '-- Placement ID / App Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, 'local appnext = require( "plugin.appnext" )')
			genUtil.add( 3, 'appnext.init( genListener( "onAd_appnext" ) )' )
		end

		-- ===========
		-- AppoDeal
		-- ===========
		if( curPlugins.monetization_appodeal_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Appodeal')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/appodeal/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_appodeal_app_key) > 0 ) then
				genUtil.add( 3, '-- APP Key: ' .. curSettings.ads_ios_appodeal_app_key )
			else
				genUtil.add( 3, '-- APP Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_appodeal_app_key) > 0 ) then
				genUtil.add( 3, 'local appodeal = require( "plugin.appodeal" )')
				genUtil.add( 3, 'appodeal.init( ' .. 
					            'genListener( "onAd_appodeal" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_ios_appodeal_app_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local appodeal = require( "plugin.appodeal" )')
				genUtil.add( 3, 'appodeal.init( genListener( "onAd_appodeal" ), { appKey = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Corona Ads
		-- ===========
		if( curPlugins.monetization_corona_ads_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Corona Ads')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/coronaads/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_corona_ads_placement_id) > 0 ) then
				genUtil.add( 3, '-- Placement ID: ' .. curSettings.ads_ios_corona_ads_placement_id )
			else
				genUtil.add( 3, '-- Placement ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_corona_ads_placement_id) > 0 ) then
				genUtil.add( 3, 'local coronaAds = require( "plugin.coronaAds" )')
				genUtil.add( 3, 'coronaAds.init( "' .. curSettings.ads_ios_corona_ads_placement_id .. '", ' ..
					            'genListener( "onAd_coronaads" ) )' )
			else
				genUtil.add( 3, '-- You did not supply a Placement ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local coronaAds = require( "plugin.coronaAds" )')
				genUtil.add( 3, 'coronaAds.init( "YOUR_PLACEMENT_ID_HERE", genListener( "onAd_coronaads" ) )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- FAN
		-- ===========
		if( curPlugins.monetization_fan_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Facebook Ad Network')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/fbAudienceNetwork/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_fan_placement_id) > 0 ) then
				genUtil.add( 3, '-- Placement ID: ' .. curSettings.ads_ios_fan_placement_id )
			else
				genUtil.add( 3, '-- Placement ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, 'local fbAudienceNetwork = require( "plugin.fbAudienceNetwork" )')
			genUtil.add( 3, 'appnext.init( genListener( "onAd_fan" ) )' )
		end

		-- ===========
		-- InMobi
		-- ===========
		if( curPlugins.monetization_inmobi_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize InMobi')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/inmobi/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_inmobi_account_id) > 0 ) then
				genUtil.add( 3, '-- ACCOUNT ID: ' .. curSettings.ads_ios_inmobi_account_id )
			else
				genUtil.add( 3, '-- ACCOUNT ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_inmobi_account_id) > 0 ) then
				genUtil.add( 3, 'local inMobi = require( "plugin.inMobi" )')
				genUtil.add( 3, 'inMobi.init( ' .. 
					            'genListener( "onAd_inmobi" ), ' .. 
					            '{ accountId = "' .. curSettings.ads_ios_inmobi_account_id ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an Account ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local inMobi = require( "plugin.inMobi" )')
				genUtil.add( 3, 'inMobi.init( genListener( "onAd_inmobi" ), { accountId = "YOUR_ACCOUNT_ID" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Kidoz
		-- ===========
		if( curPlugins.monetization_kidoz_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Kidoz')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/kidoz/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_kidoz_publisher_id) > 0 ) then
				genUtil.add( 3, '-- PUBLISHER ID: ' .. curSettings.ads_ios_kidoz_publisher_id )
			else
				genUtil.add( 3, '-- PUBLISHER ID: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_kidoz_security_token) > 0 ) then
				genUtil.add( 3, '-- SECURITY TOKEN: ' .. curSettings.ads_ios_kidoz_security_token )
			else
				genUtil.add( 3, '-- SECURITY TOKEN: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_kidoz_publisher_id) > 0 and 
				len(curSettings.ads_ios_kidoz_security_token) > 0 ) then
				genUtil.add( 3, 'local kidoz = require( "plugin.kidoz" )')
				genUtil.add( 3, 'kidoz.init( ' .. 
					            'genListener( "onAd_kidoz" ), ' .. 
					            '{ publisherID = "' .. curSettings.ads_ios_kidoz_publisher_id ..'", ' ..
					            'securityToken = "' .. curSettings.ads_ios_kidoz_security_token ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing a Publisher ID and/or a Security Token. ' )
				genUtil.add( 3, '-- Both are required to initialize Kidoz.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local kidoz = require( "plugin.kidoz" )')
				genUtil.add( 3, 'kidoz.init( genListener( "onAd_kidoz" ), { publisherID = "YOUR_PUBLISHER_ID", securityToken = "YOUR_SECURITY_TOKEN" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- MediaBrix
		-- ===========
		if( curPlugins.monetization_mediabrix_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize MediaBrix')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/mediaBrix/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_mediabrix_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_ios_mediabrix_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_mediabrix_app_id) > 0 ) then
				genUtil.add( 3, 'local mediaBrix = require( "plugin.mediaBrix" )')
				genUtil.add( 3, 'mediaBrix.init( ' .. 
					            'genListener( "onAd_mediabrix" ), ' .. 
					            '{ appId = "' .. curSettings.ads_ios_mediabrix_app_id ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local mediaBrix = require( "plugin.mediaBrix" )')
				genUtil.add( 3, 'mediaBrix.init( genListener( "onAd_mediabrix" ), { appId = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Peanut Labs
		-- ===========
		if( curPlugins.monetization_peanuts_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Peanut Labs')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/peanutlabs/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_peanutlabs_user_id) > 0 ) then
				genUtil.add( 3, '-- USER ID: ' .. curSettings.ads_ios_peanutlabs_user_id )
			else
				genUtil.add( 3, '-- USER ID: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_peanutlabs_app_key) > 0 ) then
				genUtil.add( 3, '-- APP KEY: ' .. curSettings.ads_ios_peanutlabs_app_key )
			else
				genUtil.add( 3, '-- APP KEY: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_peanutlabs_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_ios_peanutlabs_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_peanutlabs_user_id) > 0 and 
				len(curSettings.ads_ios_peanutlabs_app_key) > 0 and 
				len(curSettings.ads_ios_peanutlabs_app_id) > 0 ) then
				genUtil.add( 3, 'local peanutlabs = require( "plugin.peanutlabs" )')
				genUtil.add( 3, 'peanutlabs.init( ' .. 
					            'genListener( "onAd_peanutlabs" ), ' .. 
					            '{ userId = "' .. curSettings.ads_ios_peanutlabs_user_id .. '", ' ..
					            'appKey = "' .. curSettings.ads_ios_peanutlabs_app_key ..  '", ' ..
					            'appId = ' .. curSettings.ads_ios_peanutlabs_app_id .. ' } )' )

			else
				genUtil.add( 3, '-- You are missing a User ID and/or an App Key and/or an App ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Peanut Labs.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local peanutlabs = require( "plugin.peanutlabs" )')
				genUtil.add( 3, 'peanutlabs.init( genListener( "onAd_peanutlabs" ), { userId = "USER_ID", appKey = "YOUR_APP_KEY", appId = 2222 } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Persona.ly
		-- ===========
		if( curPlugins.monetization_personaly_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Persona.ly')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/personaly/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_personaly_app_hash) > 0 ) then
				genUtil.add( 3, '-- APP HASH: ' .. curSettings.ads_ios_personaly_app_hash )
			else
				genUtil.add( 3, '-- APP HASH: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_personaly_user_id) > 0 ) then
				genUtil.add( 3, '-- USER ID: ' .. curSettings.ads_ios_personaly_user_id )
			else
				genUtil.add( 3, '-- USER ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_personaly_app_hash) > 0 and 
				len(curSettings.ads_ios_personaly_user_id) > 0 ) then
				genUtil.add( 3, 'local personaly = require( "plugin.personaly" )')
				genUtil.add( 3, 'kidoz.init( ' .. 
					            'genListener( "onAd_personaly" ), ' .. 
					            '{ appHash = "' .. curSettings.ads_ios_personaly_app_hash ..'", ' ..
					            'userId = "' .. curSettings.ads_ios_personaly_user_id ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing an App Hash and/or a User ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Persona.ly.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local personaly = require( "plugin.personaly" )" )')
				genUtil.add( 3, 'kidoz.init( genListener( "onAd_personaly" ), { appHash = "YOUR_APP_HASH", userId = "UNIQUE_USER_ID" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Pollfish
		-- ===========
		if( curPlugins.monetization_pollfish_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Pollfish')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/pollfish/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_pollfish_api_key) > 0 ) then
				genUtil.add( 3, '-- API KEY: ' .. curSettings.ads_ios_pollfish_api_key )
			else
				genUtil.add( 3, '-- API KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_pollfish_api_key) > 0 ) then
				genUtil.add( 3, 'local pollfish = require( "plugin.pollfish" )')
				genUtil.add( 3, 'pollfish.init( ' .. 
					            'genListener( "onAd_pollfish" ), ' .. 
					            '{ apiKey = "' .. curSettings.ads_ios_pollfish_api_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an API KEY.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the KEY to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local pollfish = require( "plugin.pollfish" )')
				genUtil.add( 3, 'pollfish.init( genListener( "onAd_pollfish" ), { apiKey = "YOUR_API_KEY" }  )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- RevMob
		-- ===========
		if( curPlugins.monetization_revmob_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize RevMob')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/revmob/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_revmob_app_id) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_ios_revmob_app_id )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_revmob_app_id) > 0 ) then
				genUtil.add( 3, 'local revmob = require( "plugin.revmob" )')
				genUtil.add( 3, 'revmob.init( ' .. 
					            'genListener( "onAd_revmob" ), ' .. 
					            '{ appId = "' .. curSettings.ads_ios_revmob_app_id ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local revmob = require( "plugin.revmob" )')
				genUtil.add( 3, 'revmob.init( genListener( "onAd_revmob" ), { appId = "YOUR_APP_ID" }  )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- Super Awesome
		-- ===========
		if( curPlugins.monetization_superawesome_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Super Awesome')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/superawesome/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_superawesome_placement_id) > 0 ) then
				genUtil.add( 3, '-- PLACEMENT ID: ' .. curSettings.ads_ios_superawesome_placement_id )
			else
				genUtil.add( 3, '-- PLACEMENT ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			genUtil.add( 3, 'local superawesome = require( "plugin.superawesome" )')
			genUtil.add( 3, 'superawesome.init( ' ..  'genListener( "onAd_superawesome" ) )' )

		end

		-- ===========
		-- Supersonic
		-- ===========
		if( curPlugins.monetization_supersonic_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Supersonic')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/superawesome/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_supersonic_app_key) > 0 ) then
				genUtil.add( 3, '-- APP KEY: ' .. curSettings.ads_ios_supersonic_app_key )
			else
				genUtil.add( 3, '-- APP KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_supersonic_app_key) > 0 ) then
				genUtil.add( 3, 'local supersonic = require( "plugin.supersonic" )')
				genUtil.add( 3, 'supersonic.init( ' .. 
					            'genListener( "onAd_supersonic" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_ios_supersonic_app_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP KEY.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the KEY to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local supersonic = require( "plugin.supersonic" )')
				genUtil.add( 3, 'supersonic.init( genListener( "onAd_supersonic" ), { appKey = "YOUR_APP_ID" }  )' )
				genUtil.add( 3, '--]]' )				
			end
		end

		-- ===========
		-- Stripe
		-- ===========
		if( curPlugins.monetization_stripe_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Stripe')
			genUtil.add( 3, '-- http://www.jasonschroeder.com/2016/02/22/stripe-plugin-for-corona-sdk/' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_stripe_secret_key) > 0 ) then
				genUtil.add( 3, '-- SECRET KEY: ' .. curSettings.ads_ios_stripe_secret_key )
			else
				genUtil.add( 3, '-- SECRET KEY: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_stripe_publishable_key) > 0 ) then
				genUtil.add( 3, '-- PUBLISHABLE KEY: ' .. curSettings.ads_ios_stripe_publishable_key )
			else
				genUtil.add( 3, '-- PUBLISHABLE KEY: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_stripe_secret_key) > 0 and 
				len(curSettings.ads_ios_stripe_publishable_key) > 0 ) then
				genUtil.add( 3, 'local stripe = require("plugin.stripe")')
				genUtil.add( 3, 'stripe.init( ' .. 
					            '{ secretKey = "' .. curSettings.ads_ios_stripe_secret_key ..'", ' ..
					            'publishableKey = "' .. curSettings.ads_ios_stripe_publishable_key ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing an Secret Key and/or a Public (publishable) Key. ' )
				genUtil.add( 3, '-- Both are required to initialize Stripe.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local stripe = require("plugin.stripe")')
				genUtil.add( 3, 'stripe.init( { secretKey  = "SECRET_KEY", publishableKey  = "PUBLIC_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end




		-- ===========
		-- Trial Pay
		-- ===========
		if( curPlugins.monetization_trial_pay_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Trial Pay')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/trialPay/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_trial_pay_app_key) > 0 ) then
				genUtil.add( 3, '-- APP KEY: ' .. curSettings.ads_ios_trial_pay_app_key )
			else
				genUtil.add( 3, '-- APP KEY: NOT SUPPLIED' )
			end
			if( len(curSettings.ads_ios_trial_pay_sid) > 0 ) then
				genUtil.add( 3, '-- SID: ' .. curSettings.ads_ios_trial_pay_sid )
			else
				genUtil.add( 3, '-- SID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_trial_pay_app_key) > 0 and 
				len(curSettings.ads_ios_trial_pay_sid) > 0 ) then
				genUtil.add( 3, 'local trialPay = require( "plugin.trialPay" )')
				genUtil.add( 3, 'trialPay.init( genListener( "onAd_trial_pay" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_ios_trial_pay_app_key ..'", ' ..
					            'sid = "' .. curSettings.ads_ios_trial_pay_sid ..'" } )' )

			else
				genUtil.add( 3, '-- You are missing an App Key and/or a User ID. ' )
				genUtil.add( 3, '-- Both are required to initialize Trial Pay.  Please get them and ' )
				genUtil.add( 3, '-- paste the details into EAT, or add them to the code below. ' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local trialPay = require( "plugin.trialPay" )')
				genUtil.add( 3, 'trialPay.init( genListener( "onAd_trial_pay" ) , { appKey = "YOUR_APP_KEY", sid = "user1" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end


		-- ===========
		-- Vungle
		-- ===========
		if( curPlugins.monetization_vungle_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Vungle')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/vungle/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_ios_vungle_app_key) > 0 ) then
				genUtil.add( 3, '-- APP ID: ' .. curSettings.ads_ios_vungle_app_key )
			else
				genUtil.add( 3, '-- APP ID: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_ios_vungle_app_key) > 0 ) then
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "vungle", "' .. curSettings.ads_ios_vungle_app_key  .. '", ' ..
					            'genListener( "onAd_vungle" ) )' )

			else
				genUtil.add( 3, '-- You did not supply an APP ID.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the ID to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local ads = require( "ads" )')
				genUtil.add( 3, 'ads.init( "vungle", "myAppId", genListener( "onAd_vungle" ) )' )
				genUtil.add( 3, '--]]' )				
			end
		end
		genUtil.add( 2, 'end' )
		genUtil.nl()

	end

	-- =============================================================
	-- Apple TV
	-- =============================================================
	if( curSettings.generate_apple_tv == "true" ) then
		genUtil.nl()
		genUtil.add( 2, 'if( onAppleTV ) then ' )

		-- ===========
		-- AppLovin
		-- ===========
		if( curPlugins.monetization_applovin_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize AppLovin')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/applovin/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_apple_tv_applovin_sdk_key) > 0 ) then
				genUtil.add( 3, '-- SDK Key: ' .. curSettings.ads_apple_tv_applovin_sdk_key )
			else
				genUtil.add( 3, '-- SDK Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_apple_tv_applovin_sdk_key) > 0 ) then
				genUtil.add( 3, 'local applovin = require( "plugin.applovin" )')
				genUtil.add( 3, 'applovin.init( ' .. 
					            'genListener( "onAd_applovin" ), { sdkKey = "' .. 
					            curSettings.ads_apple_tv_applovin_sdk_key .. '" } )' )

			else
				genUtil.add( 3, '-- You did not supply an SDK Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local applovin = require( "plugin.applovin" )')
				genUtil.add( 3, 'applovin.init( genListener( "onAd_applovin" ), { sdkKey = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		-- ===========
		-- AppoDeal
		-- ===========
		if( curPlugins.monetization_appodeal_plugin ) then
			genUtil.add( 3, '-- =========================')
			genUtil.add( 3, '-- Initialize Appodeal')
			genUtil.add( 3, '-- https://docs.coronalabs.com/daily/plugin/appodeal/index.html' )
			genUtil.add( 3, '-- =========================')
			if( len(curSettings.ads_apple_tv_appodeal_app_key) > 0 ) then
				genUtil.add( 3, '-- APP Key: ' .. curSettings.ads_apple_tv_appodeal_app_key )
			else
				genUtil.add( 3, '-- APP Key: NOT SUPPLIED' )
			end
			genUtil.add( 3, '-- =========================')

			if( len(curSettings.ads_apple_tv_appodeal_app_key) > 0 ) then
				genUtil.add( 3, 'local appodeal = require( "plugin.appodeal" )')
				genUtil.add( 3, 'appodeal.init( ' .. 
					            'genListener( "onAd_appodeal" ), ' .. 
					            '{ appKey = "' .. curSettings.ads_apple_tv_appodeal_app_key ..'" } )' )

			else
				genUtil.add( 3, '-- You did not supply an APP Key.  Please get one and re-run EAT, or ' )
				genUtil.add( 3, '-- add the key to the following code:' )
				genUtil.add( 3, '--[[' )
				genUtil.add( 3, 'local appodeal = require( "plugin.appodeal" )')
				genUtil.add( 3, 'appodeal.init( genListener( "onAd_appodeal" ), { appKey = "YOUR_SDK_KEY" } )' )
				genUtil.add( 3, '--]]' )
				
			end
		end

		

		genUtil.add( 2, 'end' )
		genUtil.nl()

	end

	genUtil.add( 1, 'end' )
	genUtil.nl()		



	--------------------------------
	--------------------------------
	--------------------------------
	genUtil.add( 1, '-- Initialize immediately or wait a little while?' )
	genUtil.add( 1, 'if( not delay or delay < 1 ) then' )
	genUtil.add( 2, 'initializeMonetizers()' )
	genUtil.add( 1, 'else' )
	genUtil.add( 2, 'timer.performWithDelay( delay, initializeMonetizers )' )
	genUtil.add( 1, 'end' )

	genUtil.add( 0, 'end' )
	
end


-- ==
--		HELPER CODE
-- ==
function package.create_helpers( fileName, currentProject )
	
	--
	-- Ad Mob Banners
	--
	if( curPlugins.monetization_admob_plugin ) then
		genUtil.add( 0, "-- =============================================================" )
		genUtil.add( 0, '-- AdMob Helpers ' )
		genUtil.add( 0, "-- =============================================================" )
		genUtil.add( 0, 'eatMoney.admob = {}' )

		genUtil.add( 0, '-- Show Banner Helper' )
		genUtil.add( 0, 'function eatMoney.admob.showBanner( atTop )' )
		genUtil.add( 1, 'local pos = { x = 0, y = 0 }')
		genUtil.add( 1, 'local appId = ""' )
		genUtil.nl()
		genUtil.add( 1, 'if( atTop == false ) then')
		genUtil.add( 2, 'pos.y = display.contentCenterY + display.actualContentHeight/2')
		genUtil.add( 1, 'end')
		genUtil.nl()
		

		genUtil.add( 1, 'if( onAndroid ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_android_admob_banner_app_id) > 0) and 
				curSettings.ads_android_admob_banner_app_id or "NOT SUPPLIED") .. '"' )
		
		genUtil.add( 1, 'elseif( oniOS ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_ios_admob_banner_app_id) > 0) and 
				curSettings.ads_ios_admob_banner_app_id or "NOT SUPPLIED") .. '"' )
		genUtil.add( 1, 'end' )
		genUtil.nl()

		genUtil.add( 1, 'local ads = require( "ads" )' )
		genUtil.add( 1, 'ads:setCurrentProvider("admob")' )
		genUtil.add( 1, 'ads.show( "banner", {x = pos.x, y = pos.y, testMode = true, appId = appId } )' )

		genUtil.add( 0, 'end' )
		genUtil.nl()		

		genUtil.add( 0, '-- Show Interstitial Helper' )
		genUtil.add( 0, 'function eatMoney.admob.showInterstitial()' )
		genUtil.add( 1, 'local appId = ""' )
		genUtil.nl()
		
		genUtil.add( 1, 'if( onAndroid ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_android_admob_interstitial_app_id) > 0) and 
				curSettings.ads_android_admob_interstitial_app_id or "NOT SUPPLIED") .. '"' )
		
		genUtil.add( 1, 'elseif( oniOS ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_ios_admob_interstitial_app_id) > 0) and 
				curSettings.ads_ios_admob_interstitial_app_id or "NOT SUPPLIED") .. '"' )
		genUtil.add( 1, 'end' )
		genUtil.nl()

		genUtil.add( 1, 'local ads = require( "ads" )' )
		genUtil.add( 1, 'ads:setCurrentProvider("admob")' )
		genUtil.add( 1, 'ads.show( "interstitial", { testMode = true, appId = appId } )' )

		genUtil.add( 0, 'end' )
		genUtil.nl()		

		genUtil.add( 0, '-- AdMob Hide Helper' )		
		genUtil.add( 0, 'function eatMoney.admob.hide()' )
		genUtil.add( 1, 'local ads = require( "ads" )' )
		genUtil.add( 1, 'ads:setCurrentProvider("admob")' )
		genUtil.add( 1, 'ads.hide()' )
		genUtil.add( 0, 'end' )
		genUtil.nl()		

		genUtil.add( 0, '-- Load Banner Helper' )
		genUtil.add( 0, 'function eatMoney.admob.loadBanner()' )
		genUtil.add( 1, 'local appId = ""' )
		genUtil.nl()
		

		genUtil.add( 1, 'if( onAndroid ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_android_admob_banner_app_id) > 0) and 
				curSettings.ads_android_admob_banner_app_id or "NOT SUPPLIED") .. '"' )
		
		genUtil.add( 1, 'elseif( oniOS ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_ios_admob_banner_app_id) > 0) and 
				curSettings.ads_ios_admob_banner_app_id or "NOT SUPPLIED") .. '"' )
		genUtil.add( 1, 'end' )
		genUtil.nl()

		genUtil.add( 1, 'local ads = require( "ads" )' )
		genUtil.add( 1, 'ads:setCurrentProvider("admob")' )
		genUtil.add( 1, 'ads.load( "banner", { testMode = true, appId = appId } )' )

		genUtil.add( 0, 'end' )
		genUtil.nl()		

		genUtil.add( 0, '-- Load Interstitial Helper' )
		genUtil.add( 0, 'function eatMoney.admob.loadInterstitial()' )
		genUtil.add( 1, 'local appId = ""' )
		genUtil.nl()
		
		genUtil.add( 1, 'if( onAndroid ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_android_admob_interstitial_app_id) > 0) and 
				curSettings.ads_android_admob_interstitial_app_id or "NOT SUPPLIED") .. '"' )
		
		genUtil.add( 1, 'elseif( oniOS ) then')
		genUtil.add( 2, 'appId = "' .. 
			((len(curSettings.ads_ios_admob_interstitial_app_id) > 0) and 
				curSettings.ads_ios_admob_interstitial_app_id or "NOT SUPPLIED") .. '"' )
		genUtil.add( 1, 'end' )
		genUtil.nl()

		genUtil.add( 1, 'local ads = require( "ads" )' )
		genUtil.add( 1, 'ads:setCurrentProvider("admob")' )
		genUtil.add( 1, 'ads.load( "interstitial", { testMode = true, appId = appId } )' )

		genUtil.add( 0, 'end' )
		genUtil.nl()		

	end


	--
	-- Appplovin Banners
	--
	if( curPlugins.monetization_applovin_plugin ) then
		genUtil.add( 0, "-- =============================================================" )
		genUtil.add( 0, '-- Appplovin Helpers ' )
		genUtil.add( 0, "-- =============================================================" )
		genUtil.add( 0, 'eatMoney.applovin = {}' )

		genUtil.add( 0, '-- Show Helper' )
		genUtil.add( 0, 'function eatMoney.applovin.show( isIncentivized )' )
		genUtil.add( 1, 'local applovin = require( "plugin.applovin" )' )
		genUtil.add( 1, 'applovin.show( isIncentivized )' )
		genUtil.add( 0, 'end' )
		genUtil.nl()		

		genUtil.add( 0, '-- Load Helper' )
		genUtil.add( 0, 'function eatMoney.applovin.load( isIncentivized )' )
		genUtil.add( 1, 'local applovin = require( "plugin.applovin" )' )
		genUtil.add( 1, 'applovin.load( isIncentivized )' )
		genUtil.add( 0, 'end' )
		genUtil.nl()		

		genUtil.add( 0, '-- Is Loaded Helper' )
		genUtil.add( 0, 'function eatMoney.applovin.isLoaded( isIncentivized )' )
		genUtil.add( 1, 'local applovin = require( "plugin.applovin" )' )
		genUtil.add( 1, 'applovin.isLoaded( isIncentivized )' )
		genUtil.add( 0, 'end' )
		genUtil.nl()		

	end
end



return package


