-- Sergey Lerg's brilliant idea - I added Base as a default because I declare it as a global so much.

if system.getInfo('environment') == 'simulator' then  
    -- Prevent global missuse
    local mt = getmetatable(_G)
    if mt == nil then
      mt = {}
      setmetatable(_G, mt)
    end

    mt.__declared = { Base = true }

    mt.__newindex = function (t, n, v)
      if not mt.__declared[n] then
        local w = debug.getinfo(2, 'S').what
        if w ~= 'main' and w ~= 'C' then
          error('assign to undeclared variable \'' .. n .. '\'', 2)
        end
        mt.__declared[n] = true
      end
      rawset(t, n, v)
    end

    mt.__index = function (t, n)
      if not mt.__declared[n] and debug.getinfo(2, 'S').what ~= 'C' then
        error('variable \'' .. n .. '\' is not declared', 2)
      end
      return rawget(t, n)
    end
end  