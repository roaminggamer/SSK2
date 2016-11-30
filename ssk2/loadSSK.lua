-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
-- SSK Loader
-- =============================================================
--   Last Updated: 29 NOV 2016
-- Last Validated: 29 NOV 2016
-- =============================================================

-- ==
--    fnn( ... ) - Return first argument from list that is not nil.
--    ... - Any number of any type of arguments.
-- ==
local function fnn( ... ) 
	for i = 1, #arg do
		local theArg = arg[i]
		if(theArg ~= nil) then return theArg end
	end
	return nil
end

-- =============================================================
-- Configure loader
-- =============================================================
local measure 		= false

-- Create ssk as global (temporarily)
_G.ssk = {}

ssk.getVersion = function() return "2016.001" end

local initialized = false
ssk.init = function( params )
	if( initialized ) then return end
	params = params or
	{ 
		gameFont 				= native.systemFont,
		measure 					= false, -- Print out memory usage for SSK libraries.

		exportCore 				= true, -- Export core variables as globals		
		exportSystem			= false,-- Export ssk system variables as globals
		exportColors 			= true, -- Export easy colors as globals

		enableAutoListeners 	= true, -- Allow ssk.display.* functions to automatically start listeners if
		                             -- the are passed in the build parameters

		math2DPlugin 			= false, -- Use math2d plugin if found

		enableWIP 				= false, -- Load WIP code (beware, there be dragons here!)

		debugLevel 				= 0, -- Some modules use this to print extra debug messages
		                          -- Typical levels are 0, 1, 2 (where 2 is the most verbose)
	}

	-- Set defaults if not supplied explicitly
	if( params.exportCore == nil ) then params.exportCore = true; end
	if( params.exportSystem == nil ) then params.exportSystem = false; end
	if( params.exportColors == nil ) then params.exportColors = true; end
	if( params.enableAutoListeners == nil ) then params.enableAutoListeners = true end

	-- Snag the debug level setting
	ssk.__debugLevel = params.debugLevel or 0

	--
	-- Enables automatic attachment of event listeners in extended display library
	--
	ssk.__enableAutoListeners = params.enableAutoListeners

	--
	-- Track the font users asked for as their gameFont 
	--
	ssk.__gameFont = params.gameFont or native.systemFont
	function ssk.gameFont() return ssk.__gameFont end 


	-- =============================================================
	-- If measuring, get replacement 'require'
	-- =============================================================
	local local_require = ( params.measure ) and require("ssk2.measureSSK").measure_require or _G.require
	if( params.measure ) then 
		print(string.rep("-",74))
		print( "-- Initalizing SSK")
		print(string.rep("-",74))
	end	

	-- =============================================================
	-- Load SSK Components
	-- =============================================================
	--
	-- Core
	--
	local_require( "ssk2.core" )

	--
	-- Lua & Corona Module Extensions
	--
	local_require "ssk2.extensions.display"
	local_require "ssk2.extensions.io"
	local_require "ssk2.extensions.math"
	local_require "ssk2.extensions.native"
	local_require "ssk2.extensions.string"
	local_require "ssk2.extensions.table"
	local_require "ssk2.extensions.transition"

	--
	-- System Info
	--
	local_require "ssk2.system"

	--
	-- Android Helpers
	--
	local_require "ssk2.android"

	--
	-- Colors
	--
	local_require "ssk2.colors"

	--
	-- Security (through obfuscation) lib (used by persistence lib)
	--
	local_require "ssk2.security"

	--
	-- Persistence Lib
	--
	local_require "ssk2.persist"

	--
	-- Math2D Lib
	--
	ssk.__math2DPlugin = params.math2DPlugin
	local_require "ssk2.math2d"

	--
	-- Collision Calculator
	--
	local_require "ssk2.cc"

	--
	-- Points Library (used by easyIFC)
	--
	local_require "ssk2.points"

	--
	-- Actions Library
	--
	local_require "ssk2.actions.actions"

	--
	-- Easy Series - Interfaces, Display, Camera, Social
	--
	local_require "ssk2.easyDisplay"
	local_require "ssk2.easyIFC"
	local_require "ssk2.easyInputs"
	local_require "ssk2.easyCamera"
	local_require "ssk2.easySocial"

	--
	-- Miscellaneous
	--
	local_require "ssk2.misc"

	--
	-- Shuffle Bag
	--
	local_require "ssk2.shuffleBag"


	--
	-- External Libs/Modules (Written by others and used with credit.)
	--
	local_require( "ssk2.external.proxy" ) -- Adds "propertyUpdate" events to any Corona display object.; Source unknown
	local_require( "ssk2.external.wait" ) -- Adapted from Steven Johnson's work (ggcrunchy) https://github.com/ggcrunchy/samples
	local_require( "ssk2.external.randomlua" ) -- Various 'math.random' alternatives
	local_require("ssk2.external.30log") -- http://yonaba.github.io/30log/
	local_require("ssk2.external.portableRandom") -- Portable random library


	--
	-- Works In Progress
	--
	if( params.enableWIP ) then
		local_require "ssk2.wip.easyBench"
		local_require "ssk2.wip.files"
	end


	-- =============================================================
	-- Finialize measurements and show report (if measuring enabled)
	-- =============================================================
	-- Meaure Final Cost of SSK (if enabled)
	if( params.measure ) then require("ssk2.measureSSK").summary() end

	-- =============================================================
	-- Frame counter 
	-- =============================================================
	ssk.__lfc = 0
	function ssk.getFrame() return ssk.__lfc end 
	ssk.enterFrame = function( self ) self.__lfc = self.__lfc + 1; end; Runtime:addEventListener("enterFrame",ssk)

	-- =============================================================
	-- Initialize The Core
	-- =============================================================
	ssk.core.init( params.launchArgs or {} )

	--  
	--	Export any Requested Features
	--
	if( params.exportCore ) then ssk.core.export() end
	if( params.exportColors ) then ssk.colors.export() end
	if( params.exportSystem ) then ssk.system.export() end

	-- =============================================================
	-- FIN
	-- =============================================================
	initialized = true
end

return ssk