local Theme = require(script.Parent.Theme)
local RestaurantGuides = {}
RestaurantGuides.__index = RestaurantGuides
local FLOW_CYCLES_PER_SECOND = 0.8
-- Reuse fade values rather than allocating a new sequence for every chevron each frame.
local fades = {}
for i = 0, 20 do fades[i] = NumberSequence.new(1 - 0.9 * i / 20) end

local function beam(parent, name, start, finish)
    local line = Instance.new("Beam")
    line.Name, line.Attachment0, line.Attachment1 = name, start, finish
    line.Width0, line.Width1, line.Segments = 0.22, 0.22, 1
    line.FaceCamera, line.LightInfluence, line.LightEmission = true, 0, 0.5
    line.Color, line.Transparency = ColorSequence.new(Theme.Gold), NumberSequence.new(0.1)
    line.Enabled, line.Parent = false, parent
    return line
end

local function chevron(parent, index)
    local points = {}
    for _, name in ipairs({"Left", "Tip", "Right"}) do
        local point = Instance.new("Attachment")
        point.Name, point.Parent = "Chevron" .. index .. name, parent
        points[name] = point
    end
    points.leftArm = beam(parent, "Chevron" .. index .. "LeftArm", points.Left, points.Tip)
    points.rightArm = beam(parent, "Chevron" .. index .. "RightArm", points.Right, points.Tip)
    return points
end

function RestaurantGuides.new()
    local folder = Instance.new("Folder")
    folder.Name, folder.Parent = "RestaurantGuides", workspace
    return setmetatable({ folder = folder, entries = {}, phase = 0 }, RestaurantGuides)
end

function RestaurantGuides:setTarget(index, entrance)
    local entry = self.entries[index]
    if entry and entry.entrance ~= entrance then
        entry.finish:Destroy()
        entry.base:Destroy()
        self.entries[index], entry = nil, nil
    end
    if not entrance or entry then return end
    local finish = Instance.new("Attachment")
    finish.Name, finish.Position, finish.Parent = "RestaurantGuideEnd", Vector3.new(0, 1, 0), entrance
    local base = Instance.new("Part")
    base.Name, base.Size = "ChevronGuide" .. index, Vector3.new(0.1, 0.1, 0.1)
    base.Anchored, base.Transparency = true, 1
    base.CanCollide, base.CanTouch, base.CanQuery, base.CastShadow = false, false, false, false
    base.Parent = self.folder
    self.entries[index] = { entrance = entrance, finish = finish, base = base, chevrons = {} }
end

function RestaurantGuides:step(character, dt)
    self.phase = (self.phase + math.max(dt or 0, 0) * FLOW_CYCLES_PER_SECOND) % 1
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local head = character and character:FindFirstChild("Head")
    if not humanoid or humanoid.Health <= 0 or not next(self.entries) then head = nil end
    if self.head ~= head then
        if self.origin then self.origin:Destroy() end
        self.head, self.origin = head, nil
        if head then
            local origin = Instance.new("Attachment")
            origin.Name, origin.Position = "RestaurantGuideStart", Vector3.new(0, head.Size.Y / 2 + 1.5, 0)
            origin.Parent, self.origin = head, origin
        end
    end
    for _, entry in pairs(self.entries) do
        local count = 0
        if self.origin and entry.entrance.Parent then
            local finish = entry.finish.WorldPosition
            local delta = finish - self.origin.WorldPosition
            local length = delta.Magnitude
            if length > 1 then
                entry.base.Position = self.origin.WorldPosition
                local direction = delta.Unit
                local camera = workspace.CurrentCamera
                local look = if camera and camera.CFrame then camera.CFrame.LookVector else Vector3.new(0, -1, 0)
                local side = direction:Cross(look)
                if side.Magnitude < 0.001 then side = direction:Cross(Vector3.new(0, 1, 0)) end
                side = if side.Magnitude < 0.001 then Vector3.new(1, 0, 0) else side.Unit
                count = math.clamp(math.floor(length / 6), 1, 24)
                local depth = math.min(1.8, length / 3)
                -- Reuse a bounded set of open > shapes, with clear gaps and no connecting shaft.
                for i = 1, count do
                    local mark = entry.chevrons[i]
                    if not mark then mark = chevron(entry.base, i); entry.chevrons[i] = mark end
                    local distance = ((i - 0.5 + self.phase) % count) * length / count
                    local center = direction * distance
                    -- Fade and shrink at the ends so the looping pattern never jumps visibly
                    -- or extends beyond the player's head and the restaurant endpoint.
                    local edge = math.min(distance, length - distance)
                    local halfDepth = math.min(depth / 2, edge)
                    local rear = center - direction * halfDepth
                    mark.Tip.Position = center + direction * halfDepth
                    mark.Left.Position = rear + side * halfDepth
                    mark.Right.Position = rear - side * halfDepth
                    local fade = fades[math.floor(math.min(edge / depth, 1) * 20 + 0.5)]
                    mark.leftArm.Transparency, mark.rightArm.Transparency = fade, fade
                end
            end
        end
        for i, mark in ipairs(entry.chevrons) do
            mark.leftArm.Enabled, mark.rightArm.Enabled = i <= count, i <= count
        end
    end
end

return RestaurantGuides
