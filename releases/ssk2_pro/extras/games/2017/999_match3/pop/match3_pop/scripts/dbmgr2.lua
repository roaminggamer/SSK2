-- =============================================================
-- dbmgr.lua 
-- Database Manager
-- =============================================================
-- Last Modified: 27 APR 2014
-- =============================================================

local path
local db

local function initDB( dbfile )
	print("\n**** DBMGR: initDB() -> " .. dbfile .. "\n")
	db = table.load( dbfile, system.ResourceDirectory )
	print("\n**** DBMGR: initDB() - Completed")		
	--local len = 0
	--for k,v in pairs(db) do len = len + 1 end
	--end
	--print("DB entries: " .. len)
	
end

local function isWordInDB( word )
	local word = string.lower( word )
	--print(word , db[word])
	if(db[word]) then 
		return true
	else
		return false
	end
end

local function findWordInDB( word )
	return isWordInDB( word )
end



local mRandom = math.random
local function testSearchSpeed( iterations )
	local iterations = iterations or 100
	local testwords = {}
	testwords[0] = "actor"
	testwords[1] = "plenty"
	testwords[2] = "dog"
	testwords[3] = "cat"
	testwords[4] = "penny"
	testwords[5] = "quarter"
	testwords[6] = "lane"
	testwords[7] = "man"
	testwords[8] = "woman"
	testwords[9] = "exact"

	local startTime = system.getTimer()
	--print( startTime )
	for i=0, iterations do
		findWordInDB( testwords[mRandom(0, 9)] )
		--isWordInDB( testwords[mRandom(0, 9)] )
		--findWordInDB( testwords[iterations%10] )
	end
	local endTime = system.getTimer()
	--print( endTime )

	local result = "Did " .. iterations .. " searches in " .. endTime - startTime .. " ms"
	print(result)

	--local t = display.newText(result, 10, 140, null, 24)
	--t.anchorX = 0
	--t:setFillColor(1,0,0)
end

local public = {}

public.initDB			= initDB
public.isWordInDB 		= isWordInDB
public.findWordInDB 	= findWordInDB
public.testSearchSpeed 	= testSearchSpeed

return public