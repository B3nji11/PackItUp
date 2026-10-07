local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
-- Holding and tapping both use the same rate-limited Pack request on the server.
return function(hud, send, getState, isVisible)
    local heldInput = nil
    local holdingKey = false
    local nextPack = 0
    local function pack()
        local state = getState()
        if not state or not state.nearStation or state.profile.bag.fries >= Economy.Capacity then return end
        local now = os.clock()
        if now < nextPack then return end
        nextPack = now + 1 / Economy.ClicksPerSecond + 0.02
        send("Pack")
    end
    hud.pack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            heldInput = input
            pack()
        end
    end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.F then holdingKey = true; pack()
        elseif input.KeyCode == Enum.KeyCode.E then send("Sell")
        elseif input.KeyCode == Enum.KeyCode.Q then
            local state = getState()
            send(if state and state.foldStart then "FinishFold" else "StartFold")
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input == heldInput or input.UserInputType == Enum.UserInputType.MouseButton1 then heldInput = nil end
        if input.KeyCode == Enum.KeyCode.F then holdingKey = false end
    end)
    UserInputService.WindowFocusReleased:Connect(function() heldInput = nil; holdingKey = false end)
    RunService.RenderStepped:Connect(function()
        if heldInput and (not hud.frame.Visible or not isVisible()) then heldInput = nil end
        if heldInput or holdingKey then pack() end
    end)
end
