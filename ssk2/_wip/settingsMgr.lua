-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- 
-- =============================================================
_G.ssk = _G.ssk or {}
local settingsMgr = {}
_G.ssk.settingsMgr = settingsMgr

local getTimer 	   = system.getTimer
--
-- Note 1: The secure saves in this module use the 'default' RGSecurity key.
--
-- If you want to change it, do this:
--
-- 1. Generate a new one: ssk.security.genKey()
-- 2. Print it to the console: ssk.security.printKeyString()
-- 3. Grab the key from the console.
-- 4. Uncomment the following line and paste your key between the quotes:
-- ssk.security.loadKeyFromKeyString( keyString )
--
-- Note 2: This module will use unsecure saves while you use the simulator,
-- and secure saves for all devices, dekstop, and TV.
--
-- =============================================================
-- Module Begins here
-- =============================================================
local settingsFile = "gameSettings.json"

local table_save = (onSimulator) and table.save or table.secure_save
local table_load = (onSimulator) and table.load or table.secure_load

local settings = table_load( settingsFile ) or { }
settings.defaults = settings.defaults or {}

-- =============================================================
-- Set
-- =============================================================
function settingsMgr.set( key, value, skipAutoSave )
	settings[key] = value
	if( not skipAutoSave ) then
		table_save( settings, settingsFile )
	end
end

-- =============================================================
-- Get
-- =============================================================
function settingsMgr.get( key )
	-- Ensure numbers always come back as numbers, because
	-- json save/load can sometimes coerce numbers into strings.
	if( settings[key] ~= nil ) then
		return tonumber(settings[key]) or settings[key]
	end
	return tonumber(settings.defaults[key]) or settings.defaults[key]
end

-- =============================================================
-- Set Default
-- =============================================================
function settingsMgr.setDefault( key, value, skipAutoSave )
	settings.defaults[key] = value
	if( not skipAutoSave ) then
		table_save( settings, settingsFile )
	end
end



return settingsMgr