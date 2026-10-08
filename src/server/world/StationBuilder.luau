local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Runtime = require(Shared.config.Runtime)
local P = require(script.Parent.Primitives)
return function(parent, index, origin, yaw)
    local model = Instance.new("Model")
    model.Name, model.Parent = "Station" .. index, parent
    model:SetAttribute("OwnerUserId", 0)
    local transform = CFrame.new(origin) * CFrame.Angles(0, yaw or 0, 0)
    local function part(name, size, offset, color)
        local object = P.part(model, name, size, transform:PointToWorldSpace(offset), color)
        object.CFrame = transform * CFrame.new(offset)
        return object
    end
    local cream, coral = Color3.fromRGB(255, 247, 226), Color3.fromRGB(245, 112, 113)
    local accent = if index % 2 == 0 then Color3.fromRGB(81, 193, 181) else coral
    part("Plot", Vector3.new(52, 0.4, 52), Vector3.new(0, 0.05, 0), Color3.fromRGB(141, 217, 111))
    part("RestaurantFloor", Vector3.new(42, 0.5, 34), Vector3.new(0, 0.35, -3), cream)
    part("EntrancePath", Vector3.new(12, 0.25, 12), Vector3.new(0, 0.25, 20), Color3.fromRGB(190, 137, 88))
    part("BackWall", Vector3.new(42, 12, 0.8), Vector3.new(0, 6.5, -20), cream)
    part("LeftWall", Vector3.new(0.8, 12, 34), Vector3.new(-21, 6.5, -3), cream)
    part("RightWall", Vector3.new(0.8, 12, 34), Vector3.new(21, 6.5, -3), cream)
    -- A high ceiling meets the walls while leaving the frontage open for entry.
    part("Ceiling", Vector3.new(44, 1, 36), Vector3.new(0, 13, -3), cream)
    part("RoofCap", Vector3.new(44.5, 0.4, 36.5), Vector3.new(0, 13.7, -3), accent)
    part("Fascia", Vector3.new(43, 3.25, 1.2), Vector3.new(0, 10.875, 14), accent)
    for _, x in ipairs({-20, 20}) do
        part("FrontPost", Vector3.new(1, 12, 1), Vector3.new(x, 6.5, 14), accent)
        part("Hedge", Vector3.new(1.5, 2, 50), Vector3.new(x / 20 * 25, 1.3, 0), Color3.fromRGB(73, 178, 51))
    end
    for n = 1, 10 do
        part("AwningStripe" .. n, Vector3.new(4.2, 0.3, 4), Vector3.new(-23.1 + n * 4.2, 11.8, 13),
            if n % 2 == 0 then cream else accent)
    end
    local plaque = part("RestaurantPlaque", Vector3.new(15, 2, 0.2), Vector3.new(0, 10.5, 14.7), accent)
    local sign = P.surfaceLabel(plaque, "RESTAURANT " .. index .. "\nAVAILABLE", Enum.NormalId.Back, cream)
    local claimPart = part("ClaimPoint", Vector3.new(0.5, 0.5, 0.5), Vector3.new(0, 3, 18), accent)
    claimPart.Transparency, claimPart.CanCollide = 1, false
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name, prompt.ActionText, prompt.ObjectText = "ClaimRestaurant", "Claim restaurant", "Restaurant " .. index
    prompt.KeyboardKeyCode, prompt.GamepadKeyCode = Enum.KeyCode.E, Enum.KeyCode.ButtonX
    prompt.HoldDuration, prompt.MaxActivationDistance = 0, Runtime.ClaimDistance
    prompt.RequiresLineOfSight, prompt.ClickablePrompt, prompt.Enabled = false, true, true
    prompt.Parent = claimPart

    part("Counter", Vector3.new(16, 3, 3), Vector3.new(0, 2, -1), accent)
    part("Worktop", Vector3.new(16.5, 0.3, 3.5), Vector3.new(0, 3.65, -1), cream)
    local machine = part("Machine", Vector3.new(3, 2.2, 2.4), Vector3.new(-3.5, 4.9, -1), Color3.fromRGB(189, 212, 230))
    part("MachineScreen", Vector3.new(1.8, 0.7, 0.1), Vector3.new(-3.5, 5.1, 0.25), Color3.fromRGB(126, 245, 215))
    part("FryerBasket", Vector3.new(2.3, 0.15, 1.6), Vector3.new(-3.5, 6.1, -1), Color3.fromRGB(103, 137, 163))
    local bag = part("Bag", Vector3.new(1.8, 1.7, 1.3), Vector3.new(1, 4.65, -1), Color3.fromRGB(245, 195, 106))
    local fries = {}
    for n = 1, 10 do
        local fry = part("Fry" .. n, Vector3.new(0.22, 1.2 + n % 3 * 0.15, 0.22),
            Vector3.new(0.4 + (n - 1) % 5 * 0.29, 5.35, -1.3 + math.floor((n - 1) / 5) * 0.5),
            Color3.fromRGB(255, 208, 63))
        fry.CanCollide, fry.Transparency = false, 1
        table.insert(fries, fry)
    end
    -- No floating equipment labels, including on future fryers.
    part("CustomerBody", Vector3.new(1.8, 2.4, 1), Vector3.new(3.5, 2.8, -5), Color3.fromRGB(96, 190, 239))
    local head = part("CustomerHead", Vector3.new(1.4, 1.4, 1.4), Vector3.new(3.5, 4.7, -5), Color3.fromRGB(255, 205, 163))
    head.Shape = Enum.PartType.Ball
    for _, x in ipairs({3, 4}) do
        part("CustomerLeg", Vector3.new(0.7, 1.4, 0.8), Vector3.new(x, 1.2, -5), Color3.fromRGB(71, 94, 139))
    end
    for _, x in ipairs({-14, 14}) do
        part("DiningTable", Vector3.new(6, 0.4, 5), Vector3.new(x, 3, -11), Color3.fromRGB(255, 221, 158))
        part("TableBase", Vector3.new(1, 2.5, 1), Vector3.new(x, 1.6, -11), accent)
        for _, z in ipairs({-15, -7}) do
            part("DiningBench", Vector3.new(6, 1.6, 1.5), Vector3.new(x, 1.3, z), accent)
        end
    end
    return { model = model, index = index, origin = origin, spawn = transform * CFrame.new(Vector3.new(0, 4, 4)),
        machine = machine, bag = bag, fries = fries, sign = sign, claimPart = claimPart, prompt = prompt }
end
