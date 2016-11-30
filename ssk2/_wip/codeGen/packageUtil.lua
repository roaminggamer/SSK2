-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- 
-- =============================================================
-- ==
--    Localizations
-- ==
local RGFiles = ssk.RGFiles


local pu = {}

function pu.createFolder( generatedData, folderPath )
	generatedData.folders = generatedData.folders or {}
	local folders = generatedData.folders

	local function appendFolder( root, name )
		root[name] = root[name] or {}
		return root[name]
	end

	local parts = string.split( folderPath, "/" )	
	for i = 1, #parts do
		folders = appendFolder( folders, parts[i] )
	end
	--table.print_r( generatedData.folders )
end

function pu.cloneFolder( generatedData, srcbase, src, dst  )
	generatedData.folders_to_clone = generatedData.folders_to_clone or {}
	local ftc = generatedData.folders_to_clone
	ftc[#ftc+1] = { srcbase = srcbase, src = src, dst = dst }
end


function pu.cloneFile( generatedData, srcbase, src, dst  )
	generatedData.files_to_clone = generatedData.files_to_clone or {}
	local ftc = generatedData.files_to_clone
	ftc[#ftc+1] = { srcbase = srcbase, src = src, dst = dst }
end

function pu.addGC( generatedData, content, dst  )
	local gc = generatedData.generatedContent or {}
	generatedData.generatedContent = gc
	gc[#gc+1] = { content = content , dst = dst }
end

_G.ssk.codeGen.packageUtil = pu

return pu