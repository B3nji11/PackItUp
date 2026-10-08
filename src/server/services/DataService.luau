local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Runtime = require(Shared.config.Runtime)
local Profile = require(Shared.domain.Profile)
local Copy = require(Shared.util.Copy)
local ProfileStore = require(script.Parent.Parent.storage.ProfileStore)
local DataService = {}
DataService.__index = DataService
function DataService.new()
    local volatile = RunService:IsStudio() and not Runtime.StudioUseDataStore
    local self = setmetatable({ entries = {}, loading = {}, closing = false, volatile = volatile }, DataService)
    if not volatile then
        local name = if RunService:IsStudio() then Runtime.StudioStoreName else Runtime.LiveStoreName
        self.repository = ProfileStore.new(DataStoreService:GetDataStore(name), {
            validate = Profile.validate, newProfile = Profile.new, copy = Copy,
            now = os.time, wait = task.wait, attempts = Runtime.SaveAttempts, leaseSeconds = Runtime.LeaseSeconds,
        })
    end
    return self
end
function DataService:load(player)
    if self.closing or self.loading[player] or self.entries[player] then return false end
    self.loading[player] = true
    local token = HttpService:GenerateGUID(false)
    local key = "Player_" .. player.UserId
    local data, expires
    if self.volatile then data, expires = Profile.new(), math.huge
    else data, expires = self.repository:load(key, token) end
    if not data then
        self.loading[player] = nil
        warn("[Fries] Load failed for", player.UserId, expires)
        if player.Parent then player:Kick("Could not safely load your progress. Please rejoin shortly.") end
        return false
    end
    self.entries[player] = { data = data, key = key, token = token, expires = expires,
        saving = false, closing = false, nextSave = os.clock() + Runtime.AutoSaveSeconds + math.random() * 10 }
    self.loading[player] = nil
    if self.closing or not player.Parent then self:close(player); return false end
    return true
end
function DataService:get(player)
    local entry = self.entries[player]
    if not entry or entry.closing or entry.lost then return nil end
    if not self.volatile and os.time() >= entry.expires - Runtime.LeaseSafetySeconds then
        entry.lost = true
        player:Kick("Saving is unavailable. Please rejoin to protect your saved progress.")
        return nil
    end
    return entry.data
end
function DataService:save(player, release)
    local entry = self.entries[player]
    if not entry then return end
    if not release and (entry.saving or entry.closing or entry.lost) then return end
    while entry.saving do task.wait(0.05) end
    if self.entries[player] ~= entry then return end
    entry.saving = true
    local ok, result = true, math.huge
    if not self.volatile then
        ok, result = self.repository:save(entry.key, entry.token, entry.data, release)
    end
    entry.saving = false
    if ok then entry.expires = result
    else
        warn("[Fries] Save failed for", player.UserId, result)
        if result == "Lost session lock." then
            entry.lost = true
            if player.Parent then player:Kick("Your session moved. Please rejoin.") end
        end
    end
    if release then self.entries[player] = nil end
end
function DataService:close(player)
    local entry = self.entries[player]
    if not entry or entry.closing then return end
    entry.closing = true
    self:save(player, true)
end
function DataService:tick()
    if self.closing then return end
    for player, entry in pairs(self.entries) do
        if not entry.closing and not entry.saving and os.clock() >= entry.nextSave then
            entry.nextSave = os.clock() + Runtime.AutoSaveSeconds
            task.spawn(function() self:save(player, false) end)
        end
    end
end
function DataService:shutdown()
    self.closing = true
    for player in pairs(self.entries) do task.spawn(function() self:close(player) end) end
    local deadline = os.clock() + 25
    while (next(self.entries) or next(self.loading)) and os.clock() < deadline do task.wait(0.1) end
    if next(self.entries) or next(self.loading) then warn("[Fries] Shutdown save deadline reached.") end
end
return DataService
