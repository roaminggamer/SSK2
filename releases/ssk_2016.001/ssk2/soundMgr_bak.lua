-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
--   Last Updated: 30 NOV 2016
-- Last Validated: 30 NOV 2016
-- =============================================================
local soundMgr = {}
_G.ssk.soundMgr = soundMgr

-- Local storage for sound handles
local allSounds 			= {} 

local debugEn 				= false
local globalVolume		= 1.0
local sfxVolume			= 1.0
local musicVolume			= 1.0

local audio    			= require "audio"
local getTimer 			= system.getTimer

local firstChannel 			= 1
local maxMusicChannels 		= 4
local firstMusicChannel 	= audio.findFreeChannel( audio.totalChannels  - maxMusicChannels)
local firstEffectChannel 	= audio.findFreeChannel( firstChannel )

--
-- dump( max ) 
--
function soundMgr.dump( name ) 
	if( name and allSounds[name] ) then
		table.print_r(allSounds[name])
	else
		table.print_r(allSounds)
	end
end

--
-- setMaxMusicChannels( max ) 
--
function soundMgr.setMaxMusicChannels( max ) 
	max = max or 4
	max = (max < 1) and 1 or max
	local maxMusicChannels 		= max
	local firstMusicChannel 	= audio.findFreeChannel( audio.totalChannels  - maxMusicChannels)
	local firstEffectChannel 	= audio.findFreeChannel( firstChannel )

	if( debugEn ) then
		print("soundMgr.setMaxMusicChannels() -  firstMusicChannel == " .. tostring(firstMusicChannel) )
		print("soundMgr.setMaxMusicChannels() - firstEffectChannel == " .. tostring(firstEffectChannel) )
	end

end

-- setVolume( volume, volType ) 
--
function soundMgr.setVolume( volume, volType ) 
	volume = volume or 1
	volume = ( volume > 1 ) and 1 or volume
	volume = ( volume < 0 ) and 0 or volume

	if( volType == nil ) then
		globalVolume = volume
		audio.setVolume( volume )

		if( debugEn ) then
			print("soundMgr.setVolume() - Global Volume == " .. volume )
		end

	elseif( volType == "effect" ) then
		sfxVolume = volume
		for i = firstEffectChannel, firstMusicChannel - 1 do
			audio.setVolume( volume * globalVolume, { channel = i } )
		end

		if( debugEn ) then
			print("soundMgr.setVolume() - Effect Volume == " .. volume )
		end

	elseif( volType == "music" ) then
		musicVolume = musicVolume
		for i = firstMusicChannel, audio.totalChannels do
			audio.setVolume( volume * globalVolume, { channel = i } )
		end

		if( debugEn ) then
			print("soundMgr.setVolume() - Music Volume == " .. volume )
		end

	end
end


-- enableSFX( enable ) - Globally enable/disable sound effects.
--
local sfxEn = true
function soundMgr.enableSFX( enable )
	sfxEn = enable 

	-- EFM following is wrong
	if( enable ) then
		audio.setVolume( 1.0 ) -- Enable all sound channels
	else
		audio.setVolume( 0.0 ) -- Disable all sound channels
	end
end

-- enableMusic( enable ) - Globally enable/disable music
--
local musicEn = true
function soundMgr.enableMusic( enable )
	musicEn = enable 

	-- EFM following is wrong
	if( enable ) then
		audio.setVolume( 1.0 ) -- Enable all sound channels
	else
		audio.setVolume( 0.0 ) -- Disable all sound channels
	end
end

-- enableDebug( enable ) - Globally enable/disable sound debug messaging.
--
function soundMgr.enableDebug( enable )
	debugEn = fnn(enable, true)

	if( debugEn ) then
		print(" firstMusicChannel == " .. tostring(firstMusicChannel) )
		print("firstEffectChannel == " .. tostring(firstEffectChannel) )
	end

end

-- add( name, path, params ) - Add a sound record.
--
function soundMgr.add( name, path, params )

	-- Already exists.  Exit early.
	if( allSounds[name] ) then 
		print("Warning: soundMgr.add() name: ", name, " already exists." )
		return false
	end

	params = params or {}
	local soundType = params.soundType or "effect"
	local baseDir = params.baseDir or system.ResourceDirectory
	local preload = fnn( params.preload, false )

	if( soundType ~= "effect" and 
		 soundType ~= "music" ) then
		error( "soundMgr.add( " .. tostring(name) .. ", ... ) - Unknown soundType: " ..
			    tostring( soundType ) )
		return
	end

	local record = {}

	allSounds[name] = record

	record.name 			= name
	record.path 			= path
	record.baseDir 		= baseDir
	record.soundType 		= soundType
	record.minTweenTime 	= params.minTweenTime
	record.sticky 			= params.sticky
	record.altVolume		= params.altVolume
	
	if( preload )	then
		if( soundType == "effect" ) then
			record.handle = audio.loadSound( path, baseDir )
		else
			record.handle = audio.loadStream( path, baseDir )
		end
		record.loaded = true
	else		
		record.loaded = false
	end
	return true
end

-- addEffect( name, path, params )
--
function soundMgr.addEffect( name, path, params )
	params = params or {}
	params.soundType = "effect"
	soundMgr.add( name, path, params )
end

-- soundMgr.addMusic( name, path, params )
--
function soundMgr.addMusic( name, path, params )
	params = params or {}
	params.soundType = "music"
	soundMgr.add( name, path, params )
end


-- load( name ) - Load a specific sound to prepare it for playing.
--
function soundMgr.load( name )
	local record = allSounds[name]
	if( not record ) then return false end
	if( record.loaded ) then return true end		

	if( record.soundType == "effect" ) then
		record.handle = audio.loadSound( record.path, record.baseDir )
		record.loaded = true
		if( debugEn ) then
			print("Loaded effect:", record.name, record.handle )
		end

	elseif( record.soundType == "music" ) then

		record.handle = audio.loadStream( record.path, record.baseDir )
		record.loaded = true
		if( debugEn ) then
			print("Loaded music:", record.name, record.handle )
		end
	end

	return true
end

-- release( releaseType ) - Release sound resources.
--
function soundMgr.releaseAll( releaseType, force )
	force = fnn( force, false )

	-- Effects
	for k,v in pairs( allSounds ) do
		if( v.loaded and ( releaseType == nil or releaseType == v.soundType) ) then
			if( force or not v.sticky ) then
				if( debugEn ) then
					print("Unloading sound:", v.name, v.handle )
				end
				audio.dispose( v.handle )
				v.handle = nil
				v.loaded = false
			else
				if( debugEn ) then
					print("soundMgr.releaseAll() - Skipping unload of sticky sound: " .. tostring( v.name ) )
				end
			end
		end
	end
end

-- release( name, force ) - Release sound resources.
--
function soundMgr.release( name, force )	
	local record = allSounds[name]
	if( not record ) then return false end
	if( not record.loaded ) then return true end

	if( record.soundType == "effect" ) then
		record.handle = audio.loadSound( record.path, record.baseDir )
		record.loaded = true
		if( debugEn ) then
			print("Loaded effect:", record.name, record.handle )
		end
	elseif( record.soundType == "music" ) then
	end
end


-- onSound (event listener)
--
local function onSound( event )
	local record = allSounds[event.sound]

	if( debugEn ) then
		table.dump( event )
	end


	-- No Record found... abort
	if( not record ) then return end

	-- Make sure this type of sound is enabled.
	if(record.soundType == "effect" and sfxEn == false ) then 
		if( debugEn ) then
			print("onSound() - Received 'effect' event, but effects are disabled." )
		end
		return 
	end
	if(record.soundType == "music" and musicEn == false  )then 
		if( debugEn ) then
			print("onSound() - Received 'music' event, but music is disabled." )
		end
		return 
	end

	-- Load the sound if it isn't loaded yet.
	if( not record.loaded ) then
		if( record.soundType == "effect" ) then
			record.handle = audio.loadSound( record.path, record.baseDir )
			record.loaded = true

			if( debugEn ) then
				print("Late loaded effect:", record.name, record.handle )
			end

		elseif( record.soundType == "music" ) then
			record.handle = audio.loadStream( record.path, record.baseDir )
			record.loaded = true

			if( debugEn ) then
				print("Late loaded music:", record.name, record.handle )
			end
		end

	end

	local curTime = getTimer()   
	if( record.minTweenTime and record.lastTime ) then      
		if( debugEn ) then
			print( "Current / minTween / Last times: ", curTime, record.minTweenTime, record.lastTime )
		end
		if( curTime - record.lastTime < record.minTweenTime ) then			
			print( "Warning: Tried to play ", record.name, "too soon (before tween time).  Skipping.")
			return
		end
	end
	record.lastTime = curTime

	local channel 
	if( record.soundType == "music" ) then
		channel = audio.findFreeChannel( firstMusicChannel )
	else
		channel = audio.findFreeChannel( firstEffectChannel )
	end	

	if( record.soundType == "music" and record.lastChannel ) then
		if( audio.isChannelPlaying( record.lastChannel)	 ) then
			print( "Warning: Tried to play ", record.name, "music and it is already playing.  Skipping.")
			return
		else
			record.lastChannel = nil
			record.playHandle = nil
		end
	end

	if( channel ) then
		local playHandle = audio.play( record.handle,  { channel = channel, 
			                           loops 	= event.loops,
			                           duration = event.duration,
			                           onComplete = event.onComplete,
			                           fadein  	= event.fadein } )

		if( record.soundType == "music" ) then
			record.lastChannel = channel
			record.playHandle = playHandle
		end
	end
end; Runtime:addEventListener( "onSound", onSound )



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