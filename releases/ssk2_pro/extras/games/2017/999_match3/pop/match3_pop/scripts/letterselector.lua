-- =============================================================
-- letterselector.lua 
-- Letter selector library
-- =============================================================
-- Last Modified: 27 APR 2014
-- =============================================================

local theDie = {}
theDie[1] = "AAEEEE"
theDie[2] = "AAFIRS"
theDie[3] = "ADENNN"
theDie[4] = "AEEEEM"
theDie[5] = "AEEGME"
theDie[6] = "AEGMNN"
theDie[7] = "AFIRSY"
theDie[8] = "BJKQXZ"
theDie[9] = "CCNSTW"
theDie[10] = "CEIILT"
theDie[11] = "CEILPT"
theDie[12] = "CEIPST"
theDie[13] = "DHHNOT"
theDie[14] = "DHHLOR"
theDie[15] = "DHLNOR"
theDie[16] = "DDLNOR"
theDie[17] = "EIIITT"
theDie[18] = "EMOTTT"
theDie[19] = "ENSSSE"
theDie[20] = "FIPRSY"
theDie[21] = "GORRVW"
theDie[22] = "HIPRRY"
theDie[23] = "NOOTEW"
theDie[24] = "OOOTTE"
theDie[25] = "AAAFRS"

theDie[26] = "AAEEEE"
theDie[27] = "AAFIRS"
theDie[28] = "ADENNN"
theDie[29] = "AEEEEM"
theDie[30] = "AEEGME"
theDie[31] = "AEGMNN"
theDie[32] = "AFIRSY"
theDie[33] = "BJKQXZ"
theDie[34] = "CCNSTW"
theDie[35] = "CEIILT"
theDie[36] = "CEILPT"
theDie[37] = "CEIPST"
theDie[38] = "DHHNOT"
theDie[39] = "DHHLOR"
theDie[40] = "DHLNOR"
theDie[41] = "DDLNOR"
theDie[42] = "EIIITT"
theDie[43] = "EMOTTT"
theDie[44] = "ENSSSE"
theDie[45] = "FIPRSY"
theDie[46] = "GORRVW"
theDie[47] = "HIPRRY"
theDie[48] = "NOOTEW"
theDie[49] = "OOOTTE"
theDie[50] = "AAAFRS"

theDie[51] = "AAEEEE"
theDie[52] = "AAFIRS"
theDie[53] = "ADENNN"
theDie[54] = "AEEEEM"
theDie[55] = "AEEGME"
theDie[56] = "AEGMNN"
theDie[57] = "AFIRSY"
theDie[58] = "BJKQXZ"
theDie[59] = "CCNSTW"
theDie[60] = "CEIILT"
theDie[61] = "CEILPT"
theDie[62] = "CEIPST"
theDie[63] = "DHHNOT"
theDie[64] = "DHHLOR"
theDie[65] = "DHLNOR"
theDie[66] = "DDLNOR"
theDie[67] = "EIIITT"
theDie[68] = "EMOTTT"
theDie[69] = "ENSSSE"
theDie[70] = "FIPRSY"
theDie[71] = "GORRVW"
theDie[72] = "HIPRRY"
theDie[73] = "NOOTEW"
theDie[74] = "OOOTTE"
theDie[75] = "AAAFRS"

local lastDieNum = #theDie

local lastLetter = ' '

local lastLetters = ""


local function randomizeDieOrder(iter)
	local iter = iter or 1000
	for i = 1, iter do
		local from = math.random(1,#theDie)
		local to = math.random(1,#theDie)
		local tmp = theDie[to]
		theDie[to] = theDie[from]
		theDie[from] = tmp
	end
end

local function getRandomLetter()
	lastDieNum = lastDieNum + 1
	if(lastDieNum > #theDie) then
		lastDieNum = 1
	end
	local aDie = theDie[lastDieNum]
	--print (lastDieNum)
	--local letterNum = math.ceil(math.random(1,60) / 10)
	--print (letterNum)

	local letterNum = math.random(1,6)

	local aLetter = aDie:sub( letterNum, letterNum )
	while( aLetter == lastLetter ) do
		letterNum = math.random(1,6)
		aLetter = aDie:sub( letterNum, letterNum )
	end

	lastLetter = aLetter 

	local returnVal = aDie:sub(letterNum,letterNum)

	if( returnVal == "Q" ) then
		returnVal = "Qu"
	end

	return returnVal
end

local function getRandomLetters( numLetters )
	local numLetters = numLetters or 1

	local theLetters = ""
	for i = 0, numLetters-1 do
		theLetters = theLetters .. getRandomLetter()
	end
	return theLetters
end

local function generateRandomLetters( numLetters )
	local numLetters = numLetters or 1

	lastLetters = ""
	for i = 0, numLetters-1 do
		lastLetters = lastLetters .. getRandomLetter()
	end
end

local function getlastLetters()
	return lastLetters
end

--
-- Letter Pregeneration
--
--system.ResourceDirectory
local function generateRandomLetterFile( numLetters, fileName )
	local randLetters = {}
	for i = 1, numLetters do
		table.insert( randLetters, getRandomLetters(1) )
	end
	table.save( randLetters, fileName )
end

local function preGen20( )
	for i = 1, 20 do
		generateRandomLetterFile( 1000, "pgl_" .. i .. ".txt" )
	end
end

local pregen_curNum = 1
local pregen_maxNum = 20
local pregen_letters = {}

local function pregen_clear(  )
	pregen_letters = {}
end

local function pregen_load( fileNum, offset )
	local offset = offset or 1
	local tmpTable = {}
	local fileName = "data/pgl_" .. fileNum .. ".txt"
	print(fileName, fileNum, offset)
	tmpTable = table.load(fileName, system.ResourceDirectory )
	for i=offset, #tmpTable do
		table.insert(pregen_letters, tmpTable[i])

		if( i < 20 ) then
			print(tmpTable[i])
		end
	end

	pregen_curNum = fileNum
end

local function pregen_loadNext()
	pregen_curNum = pregen_curNum + 1
	if(pregen_curNum > pregen_maxNum) then 
		pregen_curNum = 1
	end
	pregen_load( pregen_curNum )
end

local function pregen_randomLoad( randOffset )
	if( randOffset ) then
		pregen_load( math.random(1,20), math.random(1, 750) ) 
	else
		pregen_load( math.random(1,20) ) 
	end
end

local function pregen_getRandomLetters( numLetters )
	local numLetters = numLetters or 1

	local theLetters = ""
	for i = 0, numLetters-1 do
		theLetters = theLetters .. pregen_letters[1]
		table.remove(pregen_letters, 1)
	end

	if(#pregen_letters < 100) then
		pregen_loadNext()
	end

	return theLetters
end


local public = {}

public.randomizeDieOrder 		= randomizeDieOrder
public.getRandomLetter 			= getRandomLetter
public.getRandomLetters 		= getRandomLetters
public.generateRandomLetters 	= generateRandomLetters
public.getlastLetters			= getlastLetters
public.preGen20 				= preGen20
public.pregen_clear 			= pregen_clear
public.pregen_load 				= pregen_load
public.pregen_loadNext 			= pregen_loadNext
public.pregen_randomLoad 		= pregen_randomLoad
public.pregen_getRandomLetters 	= pregen_getRandomLetters


return public


--[[

local theDie = {}
theDie[1] = "AAEEEE"
theDie[2] = "AAFIRS"
theDie[3] = "ADENNN"
theDie[4] = "AEEEEM"
theDie[5] = "AEEGMU"
theDie[6] = "AEGMNN"
theDie[7] = "AFIRSY"
theDie[8] = "BJKQXZ"
theDie[9] = "CCNSTW"
theDie[10] = "CEIILT"
theDie[11] = "CEILPT"
theDie[12] = "CEIPST"
theDie[13] = "DHHNOT"
theDie[14] = "DHHLOR"
theDie[15] = "DHLNOR"
theDie[16] = "DDLNOR"
theDie[17] = "EIIITT"
theDie[18] = "EMOTTT"
theDie[19] = "ENSSSU"
theDie[20] = "FIPRSY"
theDie[21] = "GORRVW"
theDie[22] = "HIPRRY"
theDie[23] = "NOOTUW"
theDie[24] = "OOOTTU"
theDie[25] = "AAAFRS"

theDie[26] = "AAEEEE"
theDie[27] = "AAFIRS"
theDie[28] = "ADENNN"
theDie[29] = "AEEEEM"
theDie[30] = "AEEGMU"
theDie[31] = "AEGMNN"
theDie[32] = "AFIRSY"
theDie[33] = "BJKQXZ"
theDie[34] = "CCNSTW"
theDie[35] = "CEIILT"
theDie[36] = "CEILPT"
theDie[37] = "CEIPST"
theDie[38] = "DHHNOT"
theDie[39] = "DHHLOR"
theDie[40] = "DHLNOR"
theDie[41] = "DDLNOR"
theDie[42] = "EIIITT"
theDie[43] = "EMOTTT"
theDie[44] = "ENSSSU"
theDie[45] = "FIPRSY"
theDie[46] = "GORRVW"
theDie[47] = "HIPRRY"
theDie[48] = "NOOTUW"
theDie[49] = "OOOTTU"
theDie[50] = "AAAFRS"

theDie[51] = "AAEEEE"
theDie[52] = "AAFIRS"
theDie[53] = "ADENNN"
theDie[54] = "AEEEEM"
theDie[55] = "AEEGMU"
theDie[56] = "AEGMNN"
theDie[57] = "AFIRSY"
theDie[58] = "BJKQXZ"
theDie[59] = "CCNSTW"
theDie[60] = "CEIILT"
theDie[61] = "CEILPT"
theDie[62] = "CEIPST"
theDie[63] = "DHHNOT"
theDie[64] = "DHHLOR"
theDie[65] = "DHLNOR"
theDie[66] = "DDLNOR"
theDie[67] = "EIIITT"
theDie[68] = "EMOTTT"
theDie[69] = "ENSSSU"
theDie[70] = "FIPRSY"
theDie[71] = "GORRVW"
theDie[72] = "HIPRRY"
theDie[73] = "NOOTUW"
theDie[74] = "OOOTTU"
theDie[75] = "AAAFRS"
--]]