util = {}

function util.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. util.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

util.string = {}

function util.string.split(string, sep, n)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  string:gsub(pattern, function(c)
    if n ~= nil and #fields > n then
      fields[#fields] = string.format('%s%s%s', fields[#fields], sep, c)
    else
      fields[#fields+1] = c
    end
  end)
  return fields
end

function util.string.join(list, sep)
  if #list == 0 then return "" end
  local string = list[1]
  for i, v in ipairs(list) do
    string = string .. sep .. v
  end
  return string
end

function util.string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


util.http = {}

function util.http.header_string_to_table(header_string)
  local headers = {}
  local rows = util.string.split(header_string, "\n")
  local sep = ":"
  for i, row in ipairs(rows) do
    if string.find(row, sep) ~= nil then
      split = util.string.split(util.string.trim(row), sep, 1)
      local k = split[1]
      local v = util.string.trim(split[2])
      headers[k] = v
    end
  end
  return headers
end

function util.http.header_table_to_string(header_table)
  local headers = {}
  for k, v in pairs(header_table) do
    headers[#headers+1] = k .. ": " .. v
  end
  return util.string.join(headers, "\n")
end

return util
