local P = require(script.Parent.Primitives)
return function(parent, index, origin)
    local model = Instance.new("Model")
    model.Name = "Station" .. index
    model.Parent = parent
    P.part(model, "Mat", Vector3.new(15, 0.2, 14), origin + Vector3.new(0, 0.2, 0), Color3.fromRGB(55, 65, 83))
    local counter = P.part(model, "Counter", Vector3.new(12, 3, 3), origin + Vector3.new(0, 1.7, -1), Color3.fromRGB(190, 70, 64))
    P.part(model, "Worktop", Vector3.new(12.5, 0.3, 3.5), origin + Vector3.new(0, 3.35, -1), Color3.fromRGB(238, 225, 197))
    local machine = P.part(model, "Machine", Vector3.new(3, 2.2, 2.4), origin + Vector3.new(-3.5, 4.6, -1), Color3.fromRGB(145, 151, 161))
    P.part(model, "MachineScreen", Vector3.new(1.8, 0.7, 0.1), origin + Vector3.new(-3.5, 4.8, 0.25), Color3.fromRGB(100, 234, 198), Enum.Material.Neon)
    local bag = P.part(model, "Bag", Vector3.new(1.8, 1.7, 1.3), origin + Vector3.new(1, 4.35, -1), Color3.fromRGB(165, 130, 92))
    local fries = {}
    for n = 1, 10 do
        local x = (n - 1) % 5
        local z = math.floor((n - 1) / 5)
        local fry = P.part(model, "Fry" .. n, Vector3.new(0.22, 1.2 + (n % 3) * 0.15, 0.22),
            origin + Vector3.new(0.4 + x * 0.29, 5.05, -1.3 + z * 0.5), Color3.fromRGB(247, 191, 69))
        fry.CanCollide = false
        fry.Transparency = 1
        table.insert(fries, fry)
    end
    local sign = P.label(counter, "AVAILABLE COUNTER", Vector3.new(0, 6.8, 0), 270, 90)
    local equipmentSign = P.label(machine, "Training Fryer", Vector3.new(0, 2.2, 0), 190, 40)
    local customer = P.part(model, "CustomerBody", Vector3.new(1.8, 2.4, 1), origin + Vector3.new(3.5, 2.5, -5), Color3.fromRGB(68, 156, 195))
    local head = P.part(model, "CustomerHead", Vector3.new(1.4, 1.4, 1.4), origin + Vector3.new(3.5, 4.4, -5), Color3.fromRGB(235, 189, 146))
    head.Shape = Enum.PartType.Ball
    P.part(model, "CustomerLeg1", Vector3.new(0.7, 1.4, 0.8), origin + Vector3.new(3, 0.9, -5), Color3.fromRGB(35, 47, 76))
    P.part(model, "CustomerLeg2", Vector3.new(0.7, 1.4, 0.8), origin + Vector3.new(4, 0.9, -5), Color3.fromRGB(35, 47, 76))
    local orderSign = P.label(customer, "Put the fries in the bag!", Vector3.new(0, 4.5, 0), 200, 55)
    return { model = model, origin = origin, spawn = CFrame.new(origin + Vector3.new(0, 4, 4)),
        machine = machine, bag = bag, fries = fries, sign = sign, equipmentSign = equipmentSign, orderSign = orderSign }
end
