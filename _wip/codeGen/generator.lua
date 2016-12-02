-- =============================================================
-- =============================================================
-- =============================================================
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
-- Forward Declarations
local RGFiles = ssk.RGFiles
-- =============================================================
-- =============================================================
-- =============================================================
local genUtil 		= ssk.codeGen.genUtil
local pu 	  		= ssk.codeGen.packageUtil

local generator = {}
-- ========================================================
-- ========================================================
-- ========================================================

-- ========================================================
-- ========================================================
-- ========================================================
function generator.run( currentProject )
	print("generator.run()")

	-- Set up default 'current project' settings if not provided.
	currentProject = currentProject or {}
	currentProject.appPath 		= currentProject.appPath or
		                          RGFiles.desktop.getDesktopPath("SSKCodeGenDefaultFolder")
    currentProject.projectName = "SSKCodeGenDefaultProject"		                       

	-- Prep the project for generation...
	local generatedData = genUtil.getEmptyProjectData()

	-- ========================================================
	-- Pre-generate
	-- ========================================================
	local srcbase	= currentProject.srcbase or "resource" -- "resource" or "documents"

	-- 1. Specify any folders (directories) that should be created.
	--
	local createFolders = currentProject.createFolders or {}
	for i = 1, #createFolders do
		pu.createFolder( generatedData, createFolders[i] )	
	end

	-- 2. Specify folders to clone
	--
	local cloneFolders = currentProject.cloneFolders or {}
	for i = 1, #cloneFolders do
		pu.cloneFolder( generatedData, srcbase, cloneFolders[i].src, cloneFolders[i].dst )
	end

	-- 3. Specify files to clone
	--
	local cloneFiles = currentProject.cloneFiles or {}
	for i = 1, #cloneFiles do
		pu.cloneFile( generatedData, srcbase, cloneFiles[i].src, cloneFiles[i].dst )
	end

	-- 4. Add dynamically generated content
	--
	local genContent = currentProject.genContent or {}
	for i = 1, #genContent do
		pu.addGC( generatedData, genContent[i].src, genContent[i].dst )
	end	

	-- ========================================================
	-- Create 'tasks'
	-- ========================================================
	--table.print_r(generatedData)
	generatedData.appPath = RGFiles.util.repairPath( currentProject.appPath  )

	local tasks = {}
	if( currentProject.cleanBuild ) then 
		genUtil.removeGameFolder( generatedData, currentProject, tasks )
	end
	genUtil.createAppFolder( generatedData, currentProject, tasks )
	genUtil.createFolders( generatedData, currentProject, tasks )
	genUtil.cloneFolders( generatedData, currentProject, tasks )
	genUtil.cloneFiles( generatedData, currentProject, tasks )
	genUtil.saveContent( generatedData, currentProject, tasks )

	-- ========================================================
	-- Generate
	-- ========================================================
	--table.print_r(generatedData)
	post( "onSetGenSteps", { count = #tasks } )
	local stepDelay = (#tasks > 0 ) and round(6000/#tasks) or 500
	stepDelay = (stepDelay > 100) and stepDelay or 100 
	stepDelay = 50
	for i = 1, #tasks do
		local curTask = tasks[i]
		timer.performWithDelay( i * stepDelay, curTask )
	end

end


_G.ssk.codeGen.generator = generator
return generator