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

function util.string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


util.http = {}

function util.http.header_string_to_table(string)
  headers = {}
  rows = util.string.split(string, "\n")
  sep = ": "
  for i, row in ipairs(rows) do
    if string.find(row, sep) ~= nil then
      split = util.string.split(util.string.trim(row), sep)
      headers[split[1]] = split[2]
    end
  end
  return headers
end

return util