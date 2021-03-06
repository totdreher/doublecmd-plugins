-- getfattrcustomwdx.lua
-- 2020.08.05
--[[
Get custom extended attributes. Requires getfattr.
For Unix-like only!

"User defined attribute" returns value of custom extended attribute by name.
See (and edit) list of name these attributes in the "un" table.

"All extended attributes" returns list of all custom extended attributes
(will be separate by semicolon and space, i.e. "; ").
]]

local un = {
"comment",
"target",
"type"
}

function ContentGetSupportedField(FieldIndex)
  if FieldIndex == 0 then
    return "User defined attribute", table.concat(un, '|'), 8
  elseif FieldIndex == 1 then
    return "All extended attributes", "", 8
  end
  return "", "", 0
end

function ContentGetDefaultSortOrder(FieldIndex)
  return 1; --or -1
end

function ContentGetDetectString()
  return 'EXT="*"'
end

function ContentGetValue(FileName, FieldIndex, UnitIndex, flags)
  if FieldIndex > 1 then return nil end
  local h = io.popen('getfattr --dump --encoding=text --no-dereference --absolute-names "' .. FileName .. '"')
  if h == nil then return nil end
  local out = h:read('*a')
  h:close()
  if (out ~= nil) and (out ~= '') then
    local s = ''
    if FieldIndex == 0 then
      if un[UnitIndex + 1] ~= nil then
        s = string.match(out, 'user%.' .. un[UnitIndex + 1] .. '="([^"]+)"')
        if (s ~= nil) and (s ~= '') then return s end
      end
    elseif FieldIndex == 1 then
      for l in string.gmatch(out, 'user%.([^=]+)=') do
        s = s .. '; ' .. l
      end
      s = string.sub(s, 3, -1)
      if string.len(s) > 0 then return s end
    end
  end
  return nil
end
