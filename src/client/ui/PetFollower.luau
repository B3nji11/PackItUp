-- Draws every player's equipped pets locally, following and bobbing behind their character.
-- Reads the server's public "FollowPets" player attribute; no network traffic per frame.
local Players = game:GetService("Players")
local PetModels = require(script.Parent.PetModels)
local PetFollower = {}
PetFollower.__index = PetFollower
-- Slots behind the character, in its local space (studs; -Z is forward).
local Slots = { Vector3.new(-3, -1.2, 3.5), Vector3.new(3, -1.2, 3.5), Vector3.new(0, -0.8, 6) }
local Follow = 8 -- higher catches up faster
function PetFollower.new(localPlayer)
    local folder = Instance.new("Folder")
    folder.Name, folder.Parent = "FollowingPets", workspace
    return setmetatable({ folder = folder, localPlayer = localPlayer, entries = {}, clock = 0, showOthers = true }, PetFollower)
end
function PetFollower:setShowOthers(show) self.showOthers = show ~= false end
function PetFollower:clear(player)
    local entry = self.entries[player]
    if entry then
        for _, pet in ipairs(entry.pets) do pet.model:Destroy() end
        self.entries[player] = nil
    end
end
local function parse(text)
    local list = {}
    for item in string.gmatch(text or "", "[^,]+") do
        local golden = string.sub(item, -1) == "*"
        table.insert(list, { type = if golden then string.sub(item, 1, -2) else item, golden = golden })
        if #list >= #Slots then break end
    end
    return list
end
function PetFollower:step(dt)
    self.clock += math.max(dt or 0, 0)
    local alpha = math.min(1, math.max(dt or 0, 0) * Follow)
    local present = {}
    for _, player in ipairs(Players:GetPlayers()) do
        present[player] = true
        local text = player:GetAttribute("FollowPets") or ""
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local visible = text ~= "" and root ~= nil and humanoid ~= nil and humanoid.Health > 0
            and (player == self.localPlayer or self.showOthers)
        local entry = self.entries[player]
        if not visible then
            self:clear(player)
        else
            if not entry or entry.text ~= text then
                self:clear(player)
                entry = { text = text, pets = {} }
                for _, pet in ipairs(parse(text)) do
                    local model, pieces = PetModels.build(pet.type, pet.golden, self.folder)
                    table.insert(entry.pets, { model = model, pieces = pieces })
                end
                self.entries[player] = entry
            end
            local frame = root.CFrame or CFrame.new(root.Position)
            local forward = frame:PointToWorldSpace(Vector3.new(0, 0, -1)) - root.Position
            for index, pet in ipairs(entry.pets) do
                local bob = math.sin(self.clock * 3 + index * 1.7) * 0.25
                local target = frame:PointToWorldSpace(Slots[index]) + Vector3.new(0, bob, 0)
                -- The first frame snaps into place; later frames ease towards the target.
                pet.position = if pet.position then pet.position + (target - pet.position) * alpha else target
                local base = CFrame.lookAt(pet.position, pet.position + forward)
                for _, piece in ipairs(pet.pieces) do piece.part.CFrame = base * piece.offset end
            end
        end
    end
    for player in pairs(self.entries) do if not present[player] then self:clear(player) end end
end
return PetFollower
