-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
--   Last Updated: 
-- Last Validated: 
-- =============================================================

_G.ssk = _G.ssk or {}
local soundMgr = {}
_G.ssk.soundMgr = soundMgr

local audio    	= require "audio"
local lastTime 	= {}
local getTimer 	= system.getTimer

-- Local storage for effect handles
--
local effects = {}

-- setMinTweenTime( name, time ) - Set (optional) minimum tween-time.  
--                                 i.e. specify a minimum time between sound repeats
--
-- name - Name of sound effect to limit
-- time - Do not allow sound to repeat more often than this time period in milliseconds
--
local minTweenTime = {}
function soundMgr.setMinTweenTime( name, time )
	minTweenTime[name] = time
end

-- setAltVolume( name, volume ) -- Select an alternate volume for this sound. This allows you to
--                                 level sounds that are little too loud or quiet to better match other 
--                                 sound volumes.
--
-- name - Name of sound effect to limit
-- volume - Value between 0.0 and 1.0 specifying volume levels between 0% and 100% respectively.
--
local altVolume = {}
function soundMgr.setAltVolume( name, volume )
	altVolume[name] = volume
end


-- enableSFX( enable ) - Globally enable/disable sound effects.
--
local sfxEn = false
function soundMgr.enableSFX( enable )
	sfxEn = enable 
	if( enable ) then
		audio.setVolume( 1.0 ) -- Enable all sound channels
	else
		audio.setVolume( 0.0 ) -- Disable all sound channels
	end
end


-- Sound Effect EVENT listener
--
local function onSFX( event )
	local sfx = effects[event.sfx]
	if( not sfx ) then return end
	if( not sfxEn ) then return end


	local curTime = getTimer()   
	print(curTime, minTweenTime[event.sfx], lastTime[event.sfx] )
	if( minTweenTime[event.sfx] and lastTime[event.sfx] ) then      
		if( curTime - lastTime[event.sfx] < minTweenTime[event.sfx] ) then
			return
		end
	end
	lastTime[event.sfx] = curTime

	local channel = audio.findFreeChannel( 2 ) -- Leave channel 1 for sound track

	if( channel ) then
		audio.setVolume( altVolume[event.sfx] or 1, { channel = channel  }  )
		audio.play( sfx,  { channel = channel  } )
	end
end; Runtime:addEventListener( "onSFX", onSFX )

-- loadSound( name, path ) - (Pre-) load sound (once) in order to play it later.
--
function soundMgr.loadSound( name, path )
	effects[name] = audio.loadSound( path )
end


-- Play/Resume the sound track (this module only supports one sound track)
--
local firstPlay = true
soundMgr.playSoundTrack = function( path )
	if( firstPlay ) then
		firstPlay = false
		local soundTrack = audio.loadStream( path )
		audio.play( soundTrack,  { channel=1, loops=-1, fadein = 3000 } )
	else
		audio.resume( 1 )
	end
end

--
-- Pause the sound track
--
soundMgr.pauseSoundTrack = function( )
	audio.pause( 1 )
end


return soundMgr