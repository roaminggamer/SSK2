-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- m3.lua - Single Touch To 'Match 3' With Drop Effect
-- =============================================================

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

-- =============================================================
-- Locals
-- =============================================================
local blocks = {}
local gameParams = {}

local newBlock
local removeBlock
local removeMatchedBlocks
local settleBoard
local refillBoard

local findMatches
local findHMatches
local findVMatches
local findFloodMatches

local dumpGrid

local onTouch

local minMatches = 3

local colors = { _R_, _G_, _B_ }

local ignoreTileClick = true
local removedTiled = 0

-- =============================================================
-- Module Begins
-- =============================================================
local m3 = {}

-- ==
--    
-- ==
function m3.newBoard( group, x, y, params )
	group = group or display.currentStage
	x = x or centerX
	y = y or centerY

	post("onBoardLock", { locked = true, board = nil } )

	-- Blank Board
	local board = display.newGroup()
	group:insert(board)
	board.blocks = {}
	board.grid = {}
	board.params = params and table.deepCopy(params) or {}

	-- Supply default settings if needed
	board.params.size 		= board.params.size or 40
	board.params.tween 		= board.params.tween or board.params.size + 5
	board.params.rows 		= board.params.rows or 3
	board.params.cols 		= board.params.cols or 3

	-- Create columns and rows
	for col = 1, board.params.cols do
		local curColumn = {}
		board.grid[col] = curColumn
		for row = 1 , board.params.rows do
			local cell = {}
			cell.row = row
			cell.col = col
			curColumn[row] = cell
		end
	end	

	-- Attach methods to board
	board.dumpGrid 			= dumpGrid

	-- Create initial set of blocks
	local startX = x - board.params.cols * board.params.tween/2 + board.params.tween/2
	local startY = y - board.params.rows * board.params.tween/2 + board.params.tween/2
	local curX = startX
	local curY = startY

	for row = 1 , board.params.rows do	
		curX = startX
		for col = 1, board.params.cols do
			local cell = board.grid[col][row] 
			local tmp = newBlock( board, cell, curX, curY )
			curX = curX + board.params.tween
		end
		curY = curY + board.params.tween
	end

	post("onBoardLock", { locked = false, board = board } )
	ignoreTileClick = false

	return board
end


newBlock = function( board, cell, x, y )
	local color = colors[mRand(1,#colors)]

	local block = newRect( board, x, y, { size = board.params.size, fill = color } )

	board.blocks[block] = block
	
	cell.block = block
	cell.x0 = cell.x0 or x
	cell.y0 = cell.y0 or y	
	
	block.color = color
	block.board = board
	block.cell 	= cell
	
	block.touch = onTouch
	block:addEventListener("touch")	
	
	return block
end

settleBoard = function( board )
	local rows = board.params.rows
	local cols = board.params.cols
	local grid = board.grid

	for col = 1, cols do
		for row = rows, 1, -1 do
			local cell = grid[col][row] 
			if( not cell.block ) then
				print("settle @  row " .. tostring(row))

				local row2 = row-1
				local moved = false
				while( not moved and row2 > 0 ) do
					local cell2 = grid[col][row2] 
					if(cell2.block) then						
						local block = cell2.block
						block.cell.block = nil
						cell.block = block
						block.cell = cell
						transition.to( block, { y = cell.y0, delay = 250/2, time = 250/2 } )

						moved = true
					end
					row2 = row2 - 1
				end
			end
		end
	end
end


refillBoard = function( board )
	local rows = board.params.rows
	local cols = board.params.cols
	local grid = board.grid

	local count = 0
	local function enableClicks( )
		if( removedTiled > 0 ) then
			removedTiled = removedTiled - 1
		end

		if( removedTiled < 1 ) then
			ignoreTileClick = false
			removedTiled = 0
			post("onBoardLock", { locked = false, board = board } )
		end
	end

	for col = 1, cols do
		for row = rows, 1, -1 do
			local cell = grid[col][row] 
			if( not cell.block ) then
				print("refill @  row " .. tostring(row))
				local block = newBlock( board, cell, cell.x0 , cell.y0 - 150 )
				transition.to( block, { y = cell.y0, delay = 500/2, time = 750/2, transition = easing.outBounce, onComplete = enableClicks })
				count = count + 1
			end
		end
	end
	if( count == 0 ) then
		enableClicks()
	end
end


dumpGrid = function( self )
	table.print_r(self.grid)
end

removeBlock = function( board, theBlock )
	if( theBlock.removed ) then return end	
	local cell = theBlock.cell
	cell.block = nil
	--transition.to( theBlock, { y = theBlock.y  + fullh, time = 1000, onComplete = display.remove } )
	transition.to( theBlock, { y = theBlock.y + 150, time = 1000/2, onComplete = display.remove } )
	theBlock.removed = true
	removedTiled = removedTiled + 1
	theBlock:toFront()
end



findHMatches = function( board, theBlock )
	local rows = board.params.rows
	local cols = board.params.cols
	local grid = board.grid
	
	local col0 = theBlock.cell.col
	local row0 = theBlock.cell.row

	local color = theBlock.color

	local hMatches = { theBlock }

	-- Check for matches leftward
	local continueMatching = true
	local col = col0 - 1
	while( continueMatching and col > 0 ) do
		if( grid[col][row0].block.color == color ) then
			hMatches[#hMatches+1] = grid[col][row0].block
		else 
			continueMatching = false
		end
		col = col - 1
	end

	-- Check for matches rightward
	local continueMatching = true
	local col = col0 + 1
	while( continueMatching and col <= cols  ) do
		if( grid[col][row0].block.color == color ) then
			hMatches[#hMatches+1] = grid[col][row0].block
		else 
			continueMatching = false
		end
		col = col + 1
	end

	-- Mark Matches
	if( #hMatches >= minMatches ) then
		for i = 1, #hMatches do
			hMatches[i].matched = true
		end
	end
end

findVMatches = function( board, theBlock )
	local rows = board.params.rows
	local cols = board.params.cols
	local grid = board.grid
	
	local col0 = theBlock.cell.col
	local row0 = theBlock.cell.row

	local color = theBlock.color

	local vMatches = { theBlock }


	-- Check for matches upward
	local continueMatching = true
	local row = row0 - 1
	while( continueMatching and row > 0  ) do
		if( grid[col0][row].block.color == color ) then
			vMatches[#vMatches+1] = grid[col0][row].block
		else 
			continueMatching = false
		end
		row = row - 1
	end
	-- Check for matches downward
	local continueMatching = true
	local row = row0 + 1
	while( continueMatching and row <= rows  ) do
		if( grid[col0][row].block.color == color ) then
			vMatches[#vMatches+1] = grid[col0][row].block
		else 
			continueMatching = false
		end
		row = row + 1
	end

	-- Mark Matches
	if( #vMatches >= minMatches ) then
		for i = 1, #vMatches do
			vMatches[i].matched = true
		end
	end
end

findFloodMatches = function( board, theBlock, matches )
	local isRoot = (matches == nil)

	matches = matches or {}

	matches[theBlock] = theBlock

	local rows = board.params.rows
	local cols = board.params.cols
	local grid = board.grid	
	
	local col = theBlock.cell.col
	local row = theBlock.cell.row
	
	local color = theBlock.color

	-- Check Left
	if( col > 1 ) then
		local block = grid[col-1][row].block
		if( block.color == color and not matches[block] ) then
			findFloodMatches( board, block, matches )
		end
	end
	-- Check Right
	if( col < cols ) then
		print("left")
		local block = grid[col+1][row].block
		if( block.color == color and not matches[block] ) then
			findFloodMatches( board, block, matches )
		end
	end
	-- Check Up
	if( row > 1 ) then
		local block = grid[col][row-1].block
		if( block.color == color and not matches[block] ) then
			findFloodMatches( board, block, matches )
		end
	end
	-- Check Down
	if( row < rows ) then
		local block = grid[col][row+1].block
		if( block.color == color and not matches[block] ) then
			findFloodMatches( board, block, matches )
		end
	end

	if( isRoot ) then
		print( table.count( matches ), " matches found ")
		if( table.count(matches) >= minMatches ) then
			for k,v in pairs( matches ) do
				v.matched = true
			end
		end
	end
end


removeMatchedBlocks = function( board )
	for k,v in pairs(board.blocks) do
		if(v.matched) then
			removeBlock( board, v) 
		end
	end
end


onTouch = function( self, event )		

	if( ignoreTileClick == false and event.phase == "ended" ) then
		post("onBoardLock", { locked = true, board = self.board } ) --EFM
		ignoreTileClick = true
		findFloodMatches( self.board, self )
		removeMatchedBlocks( self.board )
		settleBoard( self.board )
		refillBoard( self.board )
		--table.dump( event )
	end
	return true
end

onTouch_v2 = function( self, event )		
	if( ignoreTileClick == false and event.phase == "ended" ) then
		post("onBoardLock", { locked = true, board = self.board } )
		ignoreTileClick = true
		findHMatches( self.board, self )
		findVMatches( self.board, self )
		removeMatchedBlocks( self.board )
		settleBoard( self.board )
		refillBoard( self.board )
		--table.dump( event )
	end
	return true
end

onTouch_v1 = function( self, event )		
	if( ignoreTileClick == false and event.phase == "ended" ) then
		post("onBoardLock", { locked = true, board = self.board } )
		ignoreTileClick = true
		removeBlock( self.board, self )
		settleBoard( self.board )
		refillBoard( self.board )
		--table.dump( event )
	end
	return true
end

return m3



