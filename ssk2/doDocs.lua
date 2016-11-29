-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2016 (All Rights Reserved)
-- =============================================================
-- Private Index Generator (Used during Docs Production)
-- =============================================================
--   Last Updated: 23 NOV 2016
-- Last Validated: 23 NOV 2016
-- =============================================================
local function dumpSSK()
	local out = "----\n"
	local sskLibs = {}
	for k,v in pairs(ssk) do
		sskLibs[#sskLibs+1] = k
	end
	table.sort(sskLibs)
	for i = 1, #sskLibs do
		local libName = sskLibs[i]
		local lib = ssk[sskLibs[i]]	

		out = out .. "## " .. tostring(libName) .. "\n"

		-- Grab the current library (if it is one)		
		if( type(lib) == "table" ) then
			
			-- Extract and print fields
			local fields = {}
			for k,v in pairs(lib) do
				if( type( v ) ~= "function" ) then
					fields[#fields+1] = k
				end
			end
			table.sort(fields)
			if( #fields > 0 ) then
				out = out .. "### Fields:\n"
				for j = 1, #fields do
					local name = tostring(fields[j])
					out = out .. "+ [" .. name .. "](" .. libName .. "/#" .. name ..") - TBD\n"
				end
			end

			-- Extract and print functions/methods
			local fields = {}
			for k,v in pairs(lib) do
				if( type( v ) == "function" ) then
					fields[#fields+1] = k
				end
			end
			table.sort(fields)
			if( #fields > 0 ) then
				out = out .. "### Functions/Methods:\n"
				for j = 1, #fields do
					local name = tostring(fields[j])
					out = out .. "+ [" .. name .. "](" .. libName .. "/#" .. name ..") - TBD\n"
				end
			end


		end
	end

	out = out .. "----\n"
	print(out)
end

dumpSSK()