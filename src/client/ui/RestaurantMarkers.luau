local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Runtime = require(Shared.config.Runtime)
local E = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)
local RestaurantGuides = require(script.Parent.RestaurantGuides)
local RestaurantMarkers = {}
RestaurantMarkers.__index = RestaurantMarkers

function RestaurantMarkers.new(playerGui, userId)
    return setmetatable({ playerGui = playerGui, userId = userId, entries = {}, guides = RestaurantGuides.new() }, RestaurantMarkers)
end

function RestaurantMarkers:create(index, station)
    local gui = Instance.new("BillboardGui")
    gui.Name, gui.Size = "RestaurantMarker" .. index, UDim2.fromOffset(220, 104)
    gui.ResetOnSpawn, gui.AlwaysOnTop, gui.LightInfluence = false, true, 0
    gui.MaxDistance, gui.Enabled = 240, false
    gui.Parent = self.playerGui

    local available = E.box(gui, "Available", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Theme.Background, 0)
    available.BackgroundTransparency = 1
    local caption = E.box(available, "Caption", UDim2.fromOffset(40, 0), UDim2.fromOffset(140, 28), Theme.Background, 10)
    E.stroke(caption, Theme.Gold, 1.5)
    local label = E.label(caption, "AVAILABLE", 28, Theme.Gold)
    label.Font, label.TextSize, label.TextXAlignment = Enum.Font.GothamBold, 13, Enum.TextXAlignment.Center

    local owner = E.box(gui, "Owner", UDim2.fromOffset(0, 14), UDim2.fromOffset(220, 76), Theme.Background, 16)
    E.stroke(owner, Theme.Gold, 2)
    local portrait = E.box(owner, "Portrait", UDim2.fromOffset(8, 8), UDim2.fromOffset(60, 60), Theme.Card, 30)
    local fallback = E.label(portrait, "?", 60, Theme.Gold)
    fallback.Name, fallback.TextSize, fallback.TextXAlignment = "Fallback", 30, Enum.TextXAlignment.Center
    local avatar = Instance.new("ImageLabel")
    avatar.Name, avatar.Size, avatar.BackgroundTransparency = "Avatar", UDim2.fromScale(1, 1), 1
    avatar.Image, avatar.Visible, avatar.Parent = "", false, portrait
    E.corner(avatar, 30)
    local title = E.label(owner, "RESTAURANT " .. index, 18, Theme.Muted)
    title.Position, title.Size, title.TextSize = UDim2.fromOffset(78, 14), UDim2.fromOffset(132, 18), 10
    local username = E.label(owner, "", 28, Theme.Text)
    username.Name, username.Position, username.Size = "Username", UDim2.fromOffset(78, 33), UDim2.fromOffset(132, 28)
    username.Font, username.TextScaled, username.TextWrapped = Enum.Font.GothamBold, true, false
    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize, limit.MaxTextSize, limit.Parent = 9, 15, username
    return { station = station, gui = gui, available = available, owner = owner,
        username = username, avatar = avatar, fallback = fallback, ownerId = 0, generation = 0, attempts = 0 }
end

function RestaurantMarkers:loadPortrait(entry)
    if entry.ownerId <= 0 or entry.pending or entry.avatar.Visible or entry.attempts >= 3
        or os.clock() < (entry.nextAttempt or 0) then return end
    entry.pending, entry.attempts = true, entry.attempts + 1
    local ownerId, generation = entry.ownerId, entry.generation
    -- Thumbnail requests yield and can fail; they must never delay claiming or the HUD.
    task.spawn(function()
        local ok, content, ready = pcall(function()
            return Players:GetUserThumbnailAsync(ownerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if not entry.gui.Parent or entry.generation ~= generation then return end
        entry.pending, entry.nextAttempt = false, os.clock() + 5
        if ok and ready and type(content) == "string" and content ~= "" then
            entry.avatar.Image, entry.avatar.Visible = content, true
            entry.fallback.Visible = false
        end
    end)
end

function RestaurantMarkers:update(hasStation)
    local world = workspace:FindFirstChild("FriesRestaurant")
    local ownsRestaurant = hasStation
    -- Replicated ownership also hides guidance while the private claim snapshot is in flight.
    for index = 1, Runtime.StationCount do
        local station = world and world:FindFirstChild("Station" .. index)
        if station and station:GetAttribute("OwnerUserId") == self.userId then ownsRestaurant = true end
    end
    for index = 1, Runtime.StationCount do
        local station = world and world:FindFirstChild("Station" .. index)
        local entry = self.entries[index]
        if entry and entry.station ~= station then
            entry.gui:Destroy()
            self.entries[index], entry = nil, nil
        end
        local entrance = station and station:FindFirstChild("ClaimPoint")
        local roof = station and station:FindFirstChild("RoofCap")
        local target = nil
        if entrance and roof then
            if not entry then entry = self:create(index, station); self.entries[index] = entry end
            local ownerId = station:GetAttribute("OwnerUserId") or 0
            if entry.ownerId ~= ownerId then
                entry.ownerId, entry.generation = ownerId, entry.generation + 1
                entry.pending, entry.attempts, entry.nextAttempt = false, 0, 0
                entry.avatar.Image, entry.avatar.Visible, entry.fallback.Visible = "", false, true
            end
            local claimed = ownerId ~= 0
            entry.owner.Visible, entry.available.Visible = claimed, not claimed and not ownsRestaurant
            if not claimed and not ownsRestaurant then target = entrance end
            entry.gui.Enabled = claimed or not ownsRestaurant
            entry.gui.Adornee = if claimed then roof else entrance
            entry.gui.StudsOffsetWorldSpace = Vector3.new(0, if claimed then 4 else 3, 0)
            if claimed then
                local username = station:GetAttribute("OwnerUsername") or "Player"
                entry.username.Text = "@" .. username
                entry.fallback.Text = string.upper(string.sub(username, 1, 1))
                self:loadPortrait(entry)
            end
        elseif entry then
            entry.gui.Enabled = false
        end
        self.guides:setTarget(index, target)
    end
end

return RestaurantMarkers
