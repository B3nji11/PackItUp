-- Saved player settings. Pure rules.
local Config = require(script.Parent.Parent.config.Settings)
local Settings = {}
function Settings.isSetting(key) return type(key) == "string" and Config.Defaults[key] ~= nil end
function Settings.get(p, key)
    local saved = type(p.settings) == "table" and p.settings[key]
    if type(saved) == "boolean" then return saved end
    return Config.Defaults[key]
end
function Settings.toggle(p, key)
    if not Settings.isSetting(key) then return false, "That setting is unavailable." end
    if type(p.settings) ~= "table" then p.settings = {} end
    p.settings[key] = not Settings.get(p, key)
    return true, p.settings[key]
end
function Settings.snapshot(p)
    local values = {}
    for _, key in ipairs(Config.Order) do values[key] = Settings.get(p, key) end
    return values
end
return Settings
