-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- 
-- =============================================================

----------------------------------------------------------------------
--								LOCALS								              --
----------------------------------------------------------------------
-- ==
--    Localizations
-- ==
-- Corona & Lua
--
local mAbs = math.abs;local mRand = math.random;local mDeg = math.deg;
local mRad = math.rad;local mCos = math.cos;local mSin = math.sin;
local mAcos = math.acos;local mAsin = math.asin;local mSqrt = math.sqrt;
local mCeil = math.ceil;local mFloor = math.floor;local mAtan2 = math.atan2;
local mPi = math.pi
local pairs = pairs;local getInfo = system.getInfo;local getTimer = system.getTimer
local strFind = string.find;local strFormat = string.format;local strFormat = string.format
local strGSub = string.gsub;local strMatch = string.match;local strSub = string.sub
--
-- Common SSK Display Object Builders
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
--
-- Common SSK Helper Modules
local easyIFC = ssk.easyIFC;local persist = ssk.persist
--
-- Common SSK Helper Functions
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert
--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale

-- Variables
local debugEn = false
local currentContent

-- Forward Declarations
local RGFiles = ssk.RGFiles

-- Uncomment following line to count currently decalred locals (can't have more than 200)
--ssk.misc.countLocals(1)
----------------------------------------------------------------------
--	Scene Methods
----------------------------------------------------------------------
local util = {}
local private = {}

-- ==
-- Reset the current generated content (string)
-- ==
function util.enableDebug( en )
	debugEn = en == true
	if( debugEn ) then print( "RGCodeGen - genUtil Debug Enabled" ) end
end


-- ========================================
-- Current content modification utilities
-- ========================================
-- ==
-- Reset the current generated content (string)
-- ==
function util.resetContent()
	currentContent = nil
end

-- ==
-- Get the current generated content (string)
-- ==
function util.getContent( )
	return currentContent 
end

-- ==
-- Return indentation string (spaces or indentChar)
-- ==
function util.indent( line, level, indentChar )
	indentChar = indentChar or "   "
	return string.rep( indentChar, level ) .. line
end

-- ==
-- Add a line of script to the current generated content
-- ==
function util.add( indent, line ) 
	currentContent = (currentContent == nil) and "" or (currentContent .. "\n")
	currentContent = currentContent .. util.indent( line, indent, "   "  )
end

-- ==
-- EFM
-- ==
function util.nl()
	util.add( 0, "" )
end

-- ==
-- EFM
-- ==
function util.cap( indent, skipNewLine, noComma )
	if( noComma ) then
		util.add( indent, "}" )
	else
		util.add( indent, "}," )
	end
	if( not skipNewLine ) then util.nl() end
end

-- ==
-- EFM
-- ==
function util.decimal_param( indent, pad, name, value )
	util.add( indent, string.format("%s = %d,", name:rpad(pad, " "), tonumber( value ) ) )
end

-- ==
-- EFM
-- ==
function util.float_param( indent, pad, name, value )
	util.add( indent, string.format("%s = %1.1f,", name:rpad(pad, " "), tonumber( value ) ) )
end

-- ==
-- EFM
-- ==
function util.string_param( indent, pad, name, value )
	util.add( indent, string.format("%s = \"%s\",", name:rpad(pad, " "), value ) )
end

-- ==
-- EFM
-- ==
function util.bool_param( indent, pad, name, value )
	util.add( indent, string.format("%s = %s,", name:rpad(pad, " "), tostring(value) ) )
end	

-- ==
-- EFM
-- ==
function util.string_table_param( indent, pad, name, values )
	local value = "{ "
	for k, v in pairs( values )do
		value = value .. '"' .. v .. '", '
	end
	value = value .. "}"
	util.add( indent, string.format("%s = %s,", name:rpad(pad, " "), value ) )
end

-- ========================================
-- Project Creation Tools
-- ========================================

-- ==
-- EFM
-- ==
function util.getEmptyProjectData( )
	local generatedData = {}
	generatedData.folders = {}
	generatedData.folders_to_clone = {}
	generatedData.files_to_clone = {}
	generatedData.generatedContent = {}
	return generatedData
end	

-- ==
-- Delete the 'game' folder (WARNING: Dangerous Operation.)
-- ==
function util.removeGameFolder( generatedData, currentProject, tasks )
	tasks[#tasks+1] =
		function()
			RGFiles.util.rmFolder( generatedData.appPath )
			post("onGenerateStep", { details = "Remove folder: " .. tostring(generatedData.appPath) } )
		end
end

-- ==
-- Create the 'game' folder.
-- ==
function util.createAppFolder( generatedData, currentProject, tasks )
	tasks[#tasks+1] =
		function()
			RGFiles.util.mkFolder( generatedData.appPath )
			post("onGenerateStep", { details = "Make folder: " .. tostring(generatedData.appPath) } )
		end
end

-- ==
-- Explore game folder using OS's File Explorer
-- ==
function util.exploreAppFolder( generatedData )
	RGFiles.util.explore( generatedData.appPath )
end

-- ==
-- Create folders
-- ==
function util.createFolders( generatedData, currentProject, tasks )
	local steps = 0
	local saveRoot = generatedData.appPath
	local foldersToCreate = {}
	--
	-- Build the paths
	--	
	local buildPaths
	buildPaths = function( folders, path )
		for k,v in pairs(folders) do
			steps = steps + 1
			foldersToCreate[#foldersToCreate+1] =  RGFiles.util.repairPath(  path .. "/" .. k )
			buildPaths( v, path .. "/" .. k )
		end
	end
	buildPaths( generatedData.folders, generatedData.appPath )	

	--
	-- Sort them to ensure proper creation order
	--	
	table.sort( foldersToCreate )
	if(debugEn) then table.dump( foldersToCreate, nil, "util.createFolders()") end
	--
	-- Create the folders
	--
	for i = 1, #foldersToCreate do
		tasks[#tasks+1] =
			function()
				if(debugEn) then print("util.createFolders() ", i, foldersToCreate[i] ) end
				RGFiles.util.mkFolder( foldersToCreate[i] )
				post("onGenerateStep", { details = "Make folder: " .. tostring(foldersToCreate[i]) } )
			end
	end
	--table.dump(tasks)

	return steps
end

-- ==
-- Clone all folders marked for cloning
-- ==
function util.cloneFolders( generatedData, currentProject, tasks )
	local foldersToClone = generatedData.folders_to_clone

	for i = 1, #foldersToClone do
		local toClone = foldersToClone[i]
		if(debugEn) then table.dump( toClone, nil, "util.cloneFolders()") end
		local srcbase = toClone.srcbase	
		local sourceRoot 
		if( srcbase == "documents" ) then
			sourceRoot = RGFiles.documents.getRoot( )
		else
			sourceRoot = RGFiles.resource.getRoot( )
		end

		local src = sourceRoot .. toClone.src
		local dst = generatedData.appPath .. "/" .. toClone.dst

		src = RGFiles.util.repairPath( src )
		dst = RGFiles.util.repairPath( dst )

		tasks[#tasks+1] =
			function()
				if(debugEn) then print("util.cloneFolders() ", i, src, dst ) end
				RGFiles.util.cpFolder( src, dst )
				post("onGenerateStep", { details = "Clone Folder: " .. tostring(toClone.src) } )
			end
	end
end

-- ==
-- Clone all files marked for cloning
-- ==
function util.cloneFiles( generatedData, currentProject, tasks )
	local filesToClone = generatedData.files_to_clone

	for i = 1, #filesToClone do
		local toClone = filesToClone[i]
		if(debugEn) then table.dump( toClone, nil, "util.cloneFiles()") end

		local srcbase = toClone.srcbase	
		local sourceRoot 
		if( srcbase == "documents" ) then
			sourceRoot = RGFiles.documents.getRoot( )
		else
			sourceRoot = RGFiles.resource.getRoot( )
		end

		local src = sourceRoot .. toClone.src
		local dst = generatedData.appPath .. "/" .. toClone.dst
		
		src = RGFiles.util.repairPath( src )
		dst = RGFiles.util.repairPath( dst )

		tasks[#tasks+1] =
			function()
				if(debugEn) then print("util.cloneFiles() ", i, src, dst ) end
				RGFiles.util.cpFile( src, dst )
				post("onGenerateStep", { details = "Clone File: " .. tostring(toClone.src) } )
			end
	end
end


-- ==
-- Save generated scripts to their respective files.
-- ==
function util.saveContent( generatedData, currentProject, tasks )
	if(debugEn) then table.dump(generatedData) end
	if(debugEn) then table.dump(generatedData.generatedContent[1]) end

	local saveRoot = generatedData.appPath
	local generatedContent = generatedData.generatedContent

	for i = 1, #generatedContent do
		local path = RGFiles.util.repairPath( saveRoot .. "/" .. generatedContent[i].dst )
		tasks[#tasks+1] =
			function()
				if(debugEn) then print("util.saveContent() ", i, " Writing generated content ==> " .. path ) end
				RGFiles.util.writeFile( generatedContent[i].content, path )
				post("onGenerateStep", { details = "Generate source code: " .. tostring(generatedContent[i].dst) } )
			end
	end
end

_G.ssk.codeGen.genUtil = util
return util