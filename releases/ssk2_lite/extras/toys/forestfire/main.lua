-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
--  main.lua
-- =============================================================
-- Start (code/comments)
-- =============================================================
io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)
-- =============================================================
-- LOAD & INITIALIZE - SSK 2
-- =============================================================
require "ssk2.loadSSK"
_G.ssk.init()
_G.ssk.init( { launchArgs 				= ..., 
	            enableAutoListeners 	= true,
	            exportCore 				= true,
	            exportColors 			= true,
	            exportSystem 			= true,
	            measure					= false,
	            gameFont 				= native.systemFont,
	            debugLevel 				= 0 } )
-- =============================================================
-- Optionally enable meters to check FPS and Memory usage.
-- =============================================================
ssk.meters.create_fps(true)
--ssk.meters.create_mem(true)

-- =============================================================
-- Localizations
-- =============================================================
-- Commonly used Lua Functions
local getTimer          = system.getTimer
local mRand					= math.random
local mAbs					= math.abs
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

local RGTiled = ssk.RGTiled


-- =============================================================
-- Forest Fire Automaton Rules: http://rosettacode.org/wiki/Forest_fire
-- =============================================================
-- At each step:
-- 1) a burning tree disappears
-- 2) a non-burning tree starts burning if any of its neighbors is
-- 3) an empty spot may generate a tree with prob P
-- 4) a non-burning tree may ignite with prob F

local function forestFire( params  )
	params = params or {}

	-- =============================================================
	-- Locals
	-- =============================================================
	local cellSize 				= params.cellSize or 20
	local stepTime 				= params.stepTime or 500
	local steps 					= params.steps or 100
	local growProbability 		= params.growProbability or 25
	local igniteProbability 	= params.igniteProbability or 25

	-- =============================================================
	-- Forward Declarations
	-- =============================================================
	local getNeighbors
	local burnBabyBurn
	local onStep

	-- =============================================================
	-- Get neighbors of current cell
	-- =============================================================
	getNeighbors = function( cell )		
		local col 			= cell.col
		local row 			= cell.row
		local cols 			= cell.cols
		local rows 			= cell.rows
		local neighbors 	= {}

		for i = col-1, col+1 do
			for j = row-1, row+1 do			
				if( i > 0 and i <= cols and
					 j > 0 and j <= rows and
					 not (i == col and j == row) ) then	

					local id = string.format("%02.2d_%02.2d", i, j)
					neighbors[#neighbors+1] = cell.grid[id]
				end
			end
		end
		return neighbors
	end

	-- =============================================================
	-- Burn a cell
	-- =============================================================
	burnBabyBurn = function( cell )
		cell:setFillColor( unpack(ssk.colors.pastelRGB( _R_ ) ) )
		cell.empty = true
		cell.burning = true
	end

	-- =============================================================
	-- Listener to Step a cell 
	-- =============================================================
	onStep = function ( self )	

		-- 1) a burning tree disappears
		if( self.burning ) then
			nextFrame(
				function()
					self.burning = false
					self:setFillColor( 0 )
				end )
			return
		end

		-- 2) a non-burning tree starts burning if any of its neighbors is
		if( not self.empty ) then
			
			-- Trick: Only build neighbors list ONCE per cell
			local neighbors = self.neighbors or getNeighbors(self)
			self.neighbors = neighbors

			for i = 1, #neighbors do
				if( neighbors[i].burning ) then
					nextFrame( function() burnBabyBurn( self ) end )
					return
				end
			end
		end

		-- 3) an empty spot may generate a tree with prob P
		if( self.empty ) then
			local grow = (mRand(1,growProbability) == growProbability)
			if( grow ) then
				nextFrame(
				function()
					self.empty = false
					self:setFillColor( unpack(ssk.colors.pastelRGB( _G_ ) ) )
				end )
				return
			end

		end

		-- 4) a non-burning tree may ignite with prob F
		if( not self.empty ) then
			local ignite = (igniteProbability ~= 0) and (mRand(1,igniteProbability) == igniteProbability)
			if( ignite ) then
				nextFrame( function() burnBabyBurn( self ) end )					
				return
			end
		end
	end


	-- =============================================================
	-- Lay out grid
	-- =============================================================
	local cols 		= math.floor(fullw/cellSize)
	local rows 		= math.floor(fullh/cellSize)

	local startX 	= centerX - (cols*cellSize)/2 + cellSize/2
	local startY 	= centerY - (rows*cellSize)/2 + cellSize/2

	local curX 		= startX
	local curY 		= startY

	local forest = display.newGroup()
	local grid = {}

	for row = 1, rows do
		for col = 1, cols do		
			local id = string.format("%02.2d_%02.2d", col, row)
			local cell = newImageRect( forest, curX, curY, "images/fillW.png", 
				                        { size = cellSize,  fill = _K_ } )
			grid[id] = cell		

			cell.col 	= col
			cell.row 	= row
			cell.cols   = cols
			cell.rows   = rows
			cell.grid 	= grid

			cell.empty = (mRand(1,growProbability) == growProbability) or params.startEmpty

			if( not cell.empty ) then				
				cell:setFillColor( unpack(ssk.colors.pastelRGB( _G_ ) ) )
			end

			if( igniteProbability == 0 ) then
				cell.lastTime = getTimer()
				function cell.touch( self, event )
					if( not self.empty ) then
						local curTime = getTimer()
						local dt = curTime - self.lastTime
						if( dt > 100 ) then
							self.lastTime = curTime
							burnBabyBurn( self )
						end
					else
					end					
				end
				cell:addEventListener( "touch" )
			end

			curX = curX + cellSize
		end
		curY = curY + cellSize
		curX = startX
	end

	timer.performWithDelay( stepTime, 
		function()
			for k,v in pairs( grid ) do
				onStep( v )
			end
		end, steps )

	print("Forest has ", table.count(grid), " cells.")

	return forest
end


forest = forestFire( 
	{  steps 				= 0, 
		stepTime 			= 100, 
		cellSize 			= 12, 
		startEmpty 			= false,
		growProbability 	= 150,
		igniteProbability = 0 } )