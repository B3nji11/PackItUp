-- Short number text for Cash, prices, and stats: 950, 1.25K, 12.5K, 125K, 1.25M, ... 1.2Dc, then
-- scientific notation (1.2e36). Three significant digits, trailing zeros dropped. Pure.
local Format = {}
local Suffixes = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
Format.Suffixes = Suffixes
local function trim(text)
    if string.find(text, "%.") then text = string.gsub(string.gsub(text, "0+$", ""), "%.$", "") end
    return text
end
-- Three significant digits for a value from 1 to 999.9...
local function significant(v)
    if v < 10 then return trim(string.format("%.2f", v)) end
    if v < 100 then return trim(string.format("%.1f", v)) end
    return string.format("%.0f", v)
end
-- `decimals` is used below 1,000 for values that are not whole (2 for money, else up to 2).
function Format.short(value, decimals)
    if type(value) ~= "number" or value ~= value then return "0" end
    if value == math.huge or value == -math.huge then return "MAX" end
    local sign = if value < 0 then "-" else ""
    local n = math.abs(value)
    if n < 1000 then
        if math.abs(n - math.floor(n + 0.5)) < 1e-6 then return sign .. string.format("%d", math.floor(n + 0.5)) end
        local text = string.format("%." .. (decimals or 2) .. "f", n)
        return sign .. (if decimals then text else trim(text))
    end
    local tier = math.floor(math.log10(n) / 3 + 1e-9)
    local v = n / 1000 ^ tier
    -- 999.96K rounds to 1000K; show it as 1M instead.
    if tonumber(significant(v)) >= 1000 then tier += 1; v = n / 1000 ^ tier end
    if tier > #Suffixes then
        local text = string.format("%.2e", n)
        local mantissa, exponent = string.match(text, "^([%d%.]+)e%+?(%-?%d+)$")
        return sign .. trim(mantissa) .. "e" .. tostring(tonumber(exponent))
    end
    return sign .. significant(v) .. Suffixes[tier]
end
-- Dollars: "$40", "$1.50", "$1.25K", "$3.4B".
function Format.money(value) return "$" .. Format.short(value, 2) end
return Format
