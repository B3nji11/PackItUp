-- Client composition root. Cash and sales are determined by the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AppView = require(script.Parent.ui.AppView)
local RestaurantMarkers = require(script.Parent.ui.RestaurantMarkers)
local InputController = require(script.Parent.controllers.InputController)
local remotes = ReplicatedStorage:WaitForChild("FriesRemotes")
local action = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")
local noticeRemote = remotes:WaitForChild("Notice")
local state = nil
local function send(name, argument) action:FireServer(name, argument) end
local app = AppView.new(Players.LocalPlayer:WaitForChild("PlayerGui"), send)
local markers = RestaurantMarkers.new(Players.LocalPlayer.PlayerGui, Players.LocalPlayer.UserId)
stateRemote.OnClientEvent:Connect(function(snapshot)
    state = snapshot
    app:update(snapshot)
    markers:update(snapshot.hasStation)
end)
noticeRemote.OnClientEvent:Connect(function(text, success) app:notice(text, success) end)
InputController(app.hud, send, function() return state end)
RunService.RenderStepped:Connect(function(dt)
    markers.guides:step(Players.LocalPlayer.Character, dt)
    local camera = workspace.CurrentCamera
    if camera then app:resize(camera.ViewportSize) end
end)
task.spawn(function()
    while not state do
        send("Sync")
        task.wait(2)
    end
end)
