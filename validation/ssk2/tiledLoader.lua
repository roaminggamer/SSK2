-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- Tiled Loader
-- =============================================================
-- Development Notes:
-- -none-
-- =============================================================
-- ==
--    Localizations
-- ==
local getTimer = system.getTimer

-- Helpers taken from PonyTiled: 
-- https://github.com/ponywolf/ponytiled/blob/master/com/ponywolf/ponytiled.lua
--
local FlippedHorizontallyFlag   = 0x80000000
local FlippedVerticallyFlag     = 0x40000000
local FlippedDiagonallyFlag     = 0x20000000
local ClearFlag                 = 0x1FFFFFFF
local function hasbit(x, p) return x % (p + p) >= p end
local function setbit(x, p) return hasbit(x, p) and x or x + p end
local function clearbit(x, p) return hasbit(x, p) and x - p or x end

-- https://github.com/ponywolf/ponyblitz/blob/master/com/ponywolf/ponytiled.lua
local function centerAnchor(obj)
  if obj.contentBounds then 
    local bounds = obj.contentBounds
    local actualCenterX, actualCenterY =  (bounds.xMin + bounds.xMax)/2 , (bounds.yMin + bounds.yMax)/2
    obj.anchorX, obj.anchorY = 0.5, 0.5  
    obj.x = actualCenterX
    obj.y = actualCenterY 
  end
end

local dataCache = {}

local tiledLoader = {}
if( _G.ssk ) then _G.ssk.tiled = tiledLoader end

ssk.tiled.centerAnchor = centerAnchor

local levelsPath 	= "levels"
local assetsRoot 	= "levels"

function tiledLoader.new()
	local loader = {}

	-- Raw level data
	local data

	-- Processed records for each object
	local oRec = {}

	-- Image records containing: full path, width, height
	local images = {}

	-- Set Path for tiled levels
	function loader.setLevelsPath( path )
		levelsPath = string.gsub( path, "%/", "." )
		assetsRoot = path
	end

	-- Load and pre-process level
	--
	function loader.load( path, lparams )   
		lparams = lparams or {}

		-- Raw Tiled Level
		data = table.deepCopy(require( levelsPath .. "." .. path ))

		-- Parse objects into useable records
		for i = 1, #data.layers do 
			local layerData = data.layers[i]
			local layerName = data.layers[i].name
			local objects 	= layerData.objects

			if( layerData.type == "tilelayer" ) then
				-- Skip these
			elseif( layerData.name == "ignore" ) then				

			elseif( layerData.type == "objectgroup" ) then 
				for i = 1, #objects do
					local rec = table.deepCopy(objects[i])
					local gid = tonumber(rec.gid)
					local flip = {}
					if( gid ) then
			      	flip.x 	= hasbit(gid, FlippedHorizontallyFlag)
			      	flip.y 	= hasbit(gid, FlippedVerticallyFlag)          
			      	flip.xy = hasbit(gid, FlippedDiagonallyFlag) 
		      	
			      	gid = clearbit(gid, FlippedHorizontallyFlag)
			      	gid = clearbit(gid, FlippedVerticallyFlag)
			      	gid = clearbit(gid, FlippedDiagonallyFlag)    
			      end
		      	rec.gid = gid
		      	rec.flip = flip

					oRec[#oRec+1] = rec					
					--rec.x = rec.x + rec.width/2
					--rec.y = rec.y - rec.height/2
					rec.layer = layerName
				end
			end
		end
		-- Create id indexed list of image records with this data:
		--  image - Full path to image
		--  width - Image original width
		-- height - Image original height
		-- 
		for k,v in pairs( data.tilesets ) do
			local firstgid = v.firstgid
			for i = 1, #v.tiles do
				local tile = v.tiles[i]
				local rec = table.shallowCopy( tile )
				images[firstgid+rec.id] = rec
				rec.id = nil
				if( string.match( rec.image, "%.%." ) ) then
					rec.image = string.gsub(rec.image,"%.%.", "" )
					while( string.sub( rec.image, 1, 1 ) == "/" ) do
						rec.image = string.sub( rec.image, 2 )
					end
				else
					rec.image = assetsRoot .. "/" .. rec.image
				end
			end		
		end

		--
		-- Attach image path to each record
		--
		for i = 1, #oRec do
			local rec = oRec[i]
			if( rec.gid ) then
				rec.image = images[rec.gid].image
			end
		end		
	end

	--
	-- Draw Object
	--
	local newImageRect = ssk.display.newImageRect
	function loader.drawObj( group, rec, params ) 
		group = group or display.currentStage
		params = params or {}
		local obj
		local ox = params.ox or 0
		local oy = params.oy or 0
		if( rec.gid ) then
   		obj = newImageRect( group, rec.x + ox, rec.y + oy, images[rec.gid].image, 
   			{ w = rec.width, h = rec.height, rotation = rec.rotation, rec = rec, anchorX = 0, anchorY = 1 } )
   	else
   		obj = newRect( group, rec.x + ox, rec.y + oy, 
   			{ w = rec.width, h = rec.height, rotation = rec.rotation, rec = rec, fill = _P_, anchorX = 0, anchorY = 1 } )
   	end
   	if( rec.flip.x ) then obj.xScale = -obj.xScale end
   	if( rec.flip.y ) then obj.yScale = -obj.yScale end
   	centerAnchor(obj)   	

   	if( params.showNumber and params.num ) then
   		local label = display.newText( group, params.num, obj.x, obj.y, native.systemFont, params.numberFontSize or 10 )
   		label:setFillColor( unpack( params.numberFill or { 0, 0 , 0 } ) )
   		local scale1 = (label.contentWidth/obj.contentWidth)
   		local scale2 = (label.contentHeight/obj.contentHeight)
   		if( scale1 > 1 or scale2 > 1 ) then
   			if( scale1 > scale2 ) then
   				label:scale( 1/scale1, 1/scale1 )
   			else
   				label:scale( 1/scale2, 1/scale2 )
   			end
   		end
   	end

	end

	--
	-- Draw Object With Builder
	--
	local newImageRect = ssk.display.newImageRect
	function loader.drawObjWithBuilder( group, rec, builders, params ) 
		group = group or display.currentStage
		params = params or {}
		local obj
		local ox = params.ox or 0
		local oy = params.oy or 0
		local bType = rec.type
		local buildFunc = builders[bType]
		if( buildFunc ) then
			obj = buildFunc( group, rec.x + ox, rec.y + oy, rec, params )
		
		elseif( rec.gid ) then
   		obj = newImageRect( group, rec.x + ox, rec.y + oy, images[rec.gid].image, 
   			{ w = rec.width, h = rec.height, rotation = rec.rotation, rec = rec, anchorX = 0, anchorY = 1 } )
	   	if( rec.flip.x ) then obj.xScale = -obj.xScale end
	   	if( rec.flip.y ) then obj.yScale = -obj.yScale end
	   	centerAnchor(obj)
   	else
   		obj = newRect( group, rec.x + ox, rec.y + oy, 
   			{ w = rec.width, h = rec.height, rotation = rec.rotation, rec = rec, fill = _P_, anchorX = 0, anchorY = 1 } )
	   	if( rec.flip.x ) then obj.xScale = -obj.xScale end
	   	if( rec.flip.y ) then obj.yScale = -obj.yScale end
	   	centerAnchor(obj)
   	end

   	if( params.showNumber and params.num ) then
   		local label = display.newText( group, params.num, obj.x, obj.y, native.systemFont, params.numberFontSize or 10 )
   		label:setFillColor( unpack( params.numberFill or { 0, 0 , 0 } ) )
   		local scale1 = (label.contentWidth/obj.contentWidth)
   		local scale2 = (label.contentHeight/obj.contentHeight)
   		if( scale1 > 1 or scale2 > 1 ) then
   			if( scale1 > scale2 ) then
   				label:scale( 1/scale1, 1/scale1 )
   			else
   				label:scale( 1/scale2, 1/scale2 )
   			end
   		end
   	end
	end

	--
	-- Draw All Objects
	--
	function loader.draw( group, params ) 
		group = group or display.currentStage
		params = params or {}
		for i = 1, #oRec do
			if( params.showNumber ) then
				params.num = i
			end
			loader.drawObj( group, oRec[i], params )
		end
	end
	function loader.forEach( func ) 
		for i = 1, #oRec do func(oRec[i], i) end
	end
	
	--
	-- Get 'Level' width
	--
	function loader.getWidth(  ) 
		return (data.width * data.tilewidth)
	end

	--
	-- Get 'Level' height
	--
	function loader.getHeight(  ) 
		return (data.height * data.tileheight)
	end

	--
	-- Get images
	--
	function loader.getImages( ) 
		return images
	end

	-- Get image
	--
	function loader.getImage( gid )		
		return images[gid]
	end

	--
	-- Get image
	--
	function loader.getImagePath( gid )
		return images[gid].image
	end

	--
	-- Get all objects
	--
	function loader.getRecords( ) 
		return oRec
	end

	-- Get an object by type
	--
	function loader.getRecordsByType( getType ) 
		local objs = {}
		-- Draw all non-excluded objects
		for i = 1, #oRec do
			local rec = oRec[i]
			if( rec.type == getType ) then
				objs[#objs+1] = rec
			end
		end
		return objs
	end

	return loader
end

-- ==
--    EFM() - EFM
-- ==
function tiledLoader.getLevel( name, params )
   params = params or { debugEn = false }
   local level = tiledLoader.new()
   if( params.levelPath ) then
      level.setLevelsPath( params.levelPath  )
   end
   level.load( name, params )
   return level
end

function tiledLoader.stitch( records, level, params )
   params = params or {}
   
   local cur = level.getRecords()
   
   for i = 1, #cur do
      local rec = table.deepCopy(cur[i])
      records[#records+1] = rec

      if( params.ox ) then rec.x = rec.x + params.ox end
      if( params.oy ) then rec.y = rec.y + params.oy end
   end

   return records
end

return tiledLoader
