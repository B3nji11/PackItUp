-- Lightweight engine doubles exercise wiring, not Roblox rendering/physics/networking.
local scheduled = {}
local function signal()
    local listeners = {}
    return {
        Connect = function(_, fn)
            local connection = { Connected = true }
            function connection:Disconnect() self.Connected = false end
            table.insert(listeners, { connection, fn })
            return connection
        end,
        Fire = function(_, ...)
            for _, pair in ipairs(listeners) do if pair[1].Connected then pair[2](...) end end
        end,
    }
end
local vectorMeta = {}
vectorMeta.__index = function(v, key)
    if key == "Magnitude" then return math.sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z) end
end
Vector3 = { new = function(x,y,z) return setmetatable({X=x,Y=y,Z=z}, vectorMeta) end }
vectorMeta.__add = function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vectorMeta.__sub = function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
Vector3.zero = Vector3.new(0,0,0)
Vector2 = { new = function(x,y) return {X=x,Y=y} end }
CFrame = { new = function(position) return {Position=position} end }
Color3 = { fromRGB = function(r,g,b) return {R=r/255,G=g/255,B=b/255} end }
UDim = { new = function(scale, offset) return {Scale=scale,Offset=offset} end }
UDim2 = { new = function(xs,xo,ys,yo) return {X=UDim.new(xs or 0,xo or 0),Y=UDim.new(ys or 0,yo or 0)} end }
UDim2.fromScale = function(x,y) return UDim2.new(x,0,y,0) end
UDim2.fromOffset = function(x,y) return UDim2.new(0,x,0,y) end
Enum = setmetatable({}, {__index = function(self,key)
    local group = setmetatable({}, {__index = function(_,value) return key.."."..value end})
    rawset(self,key,group); return group
end})
local eventNames = { Activated=true, InputBegan=true, InputEnded=true, OnServerEvent=true,
    OnClientEvent=true, CharacterAdded=true, PlayerAdded=true, PlayerRemoving=true, Heartbeat=true,
    RenderStepped=true, WindowFocusReleased=true }
local instanceMethods = {}
local function makeInstance(class)
    local values = { ClassName=class, Name=class, Visible=true }
    local object = {}
    setmetatable(object, {
        __index = function(self,key)
            if instanceMethods[key] then return instanceMethods[key] end
            if values[key] ~= nil then return values[key] end
            if eventNames[key] then values[key]=signal(); return values[key] end
            for _, child in ipairs(values._children or {}) do if child.Name == key then return child end end
            return nil
        end,
        __newindex = function(self,key,value)
            if key == "Parent" then
                local previous = values.Parent
                if previous and previous._children then
                    for i, child in ipairs(previous._children) do if child == self then table.remove(previous._children,i); break end end
                end
                if value then
                    if not value._children then value._children = {} end
                    table.insert(value._children,self)
                end
            end
            values[key]=value
        end,
    })
    return object
end
function instanceMethods:FindFirstChild(name)
    for _, child in ipairs(self._children or {}) do if child.Name == name then return child end end
    return nil
end
function instanceMethods:WaitForChild(name) return assert(self:FindFirstChild(name), self.Name.." missing "..name) end
function instanceMethods:FindFirstChildOfClass(class)
    for _, child in ipairs(self._children or {}) do if child.ClassName == class then return child end end
end
function instanceMethods:Destroy() self.Parent = nil end
function instanceMethods:PivotTo(cf)
    local root = self:FindFirstChild("HumanoidRootPart")
    if root then root.Position = cf.Position end
end
function instanceMethods:FireClient(player, ...)
    self.lastClient = player; self.lastArgs = {...}
end
function instanceMethods:FireServer(...) self.lastServerArgs = {...} end
Instance = {new=makeInstance}
workspace = makeInstance("Workspace")
local serverTime = 0
function workspace:GetServerTimeNow() return serverTime end
workspace.CurrentCamera = {ViewportSize=Vector2.new(1280,720)}
local replicated = makeInstance("ReplicatedStorage")
nodes.shared.Name = "FriesShared"; nodes.shared.Parent = replicated
replicated._children = {nodes.shared}
local players = makeInstance("Players")
local activePlayers = {}
function players:GetPlayers() return activePlayers end
function players:GetPlayerByUserId(id)
    for _, player in ipairs(activePlayers) do if player.UserId == id then return player end end
end
local runService = makeInstance("RunService")
function runService:IsStudio() return true end
local http = {}
local guids = 0
function http:GenerateGUID() guids += 1; return "guid-"..guids end
local inputService = makeInstance("UserInputService")
function inputService:GetFocusedTextBox() return nil end
local services = { ReplicatedStorage=replicated, Players=players, RunService=runService, HttpService=http,
    DataStoreService={}, UserInputService=inputService, Lighting=makeInstance("Lighting") }
game = {GetService=function(_,name) return assert(services[name], "Unknown service "..name) end,
    BindToClose=function(self,fn) self.closeCallback=fn end}
task = {
    wait=function() error("Unexpected yield in synchronous smoke test") end,
    spawn=function(fn, ...) table.insert(scheduled,{fn=fn,args={...}}) end,
}
Random = {new=function() return {NextNumber=function() return 0 end} end}
local function drain()
    while #scheduled > 0 do
        local job = table.remove(scheduled,1)
        job.fn(table.unpack(job.args))
    end
end
local function newPlayer(id)
    local player = makeInstance("Player")
    player.UserId, player.DisplayName, player.Name = id, "Tester"..id, "Tester"..id
    player.Parent = players
    player.Character = makeInstance("Model")
    local root = makeInstance("Part"); root.Name = "HumanoidRootPart"; root.Position=Vector3.zero; root.Parent=player.Character
    local humanoid = makeInstance("Humanoid"); humanoid.Health=100; humanoid.Parent=player.Character
    local gui = makeInstance("PlayerGui"); gui.Name="PlayerGui"; gui.Parent=player
    function player:Kick(message) self.kickMessage=message end
    return player
end

test("server composition starts and constructs six complete stations", function()
    loadModule("server/Main")
    local restaurant = assert(workspace:FindFirstChild("FriesRestaurant"))
    for i = 1, 6 do
        local station = assert(restaurant:FindFirstChild("Station"..i))
        assert(station:FindFirstChild("Bag")); assert(station:FindFirstChild("Fry10"))
    end
    assert(replicated:FindFirstChild("FriesRemotes"))
end)
local first = newPlayer(101)
local second = newPlayer(202)
test("players join separate counters and receive independent profiles", function()
    activePlayers = {first,second}
    players.PlayerAdded:Fire(first); players.PlayerAdded:Fire(second); drain()
    assert(not first.kickMessage and not second.kickMessage)
    assert(first.Character.HumanoidRootPart.Position.X ~= second.Character.HumanoidRootPart.Position.X)
    runService.Heartbeat:Fire(0.2)
    local snapshot = replicated.FriesRemotes.State.lastArgs[1]
    eq(snapshot.profile.cash,0); eq(snapshot.nearStation,true)
end)
test("remote flow packs sells upgrades and rejects malformed commands", function()
    local remote = replicated.FriesRemotes.Action
    for _ = 1,20 do serverTime += 0.3; remote.OnServerEvent:Fire(first,"Pack") end
    serverTime += 1; remote.OnServerEvent:Fire(first,"Sell")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.cash,10)
    serverTime += 1; remote.OnServerEvent:Fire(first,"Sell")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.cash,10)
    remote.OnServerEvent:Fire(first,"Roll",{forged=true})
    remote.OnServerEvent:Fire(first,"UnknownAction","arbitrary")
    remote.OnServerEvent:Fire(first,"Upgrade")
    serverTime += 2; remote.OnServerEvent:Fire(second,"Sync")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.cash,0)
end)
test("server distance checks reject work away from the station", function()
    first.Character.HumanoidRootPart.Position=Vector3.new(1000,4,0)
    serverTime += 1; replicated.FriesRemotes.Action.OnServerEvent:Fire(first,"Pack")
    eq(replicated.FriesRemotes.Notice.lastArgs[2],false)
    serverTime += 1; replicated.FriesRemotes.Action.OnServerEvent:Fire(first,"Return")
    assert(first.Character.HumanoidRootPart.Position.X < 100)
end)
test("client composition constructs every screen and renders server state", function()
    players.LocalPlayer=first
    loadModule("client/Main")
    local gui = first.PlayerGui:FindFirstChild("FriesInterface")
    assert(gui and gui.Panel)
    local state = replicated.FriesRemotes.State.lastArgs[1]
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    replicated.FriesRemotes.Notice.OnClientEvent:Fire("Smoke test",true)
    runService.RenderStepped:Fire()
    -- The client Sync loop observes the state above and exits without yielding.
    drain()
    local content
    for _, child in ipairs(gui.Panel._children) do
        if child.ClassName=="Frame" then content=child end
    end
    assert(content.Play and content.Upgrades and content.Delivery and content.Gear and content.Index)
end)
test("portrait and landscape menu bounds fit the viewport", function()
    for _, viewport in ipairs({Vector2.new(390,844),Vector2.new(844,390),Vector2.new(1280,720)}) do
        workspace.CurrentCamera.ViewportSize=viewport
        runService.RenderStepped:Fire()
        local panel=first.PlayerGui.FriesInterface.Panel
        local scale=panel:FindFirstChildOfClass("UIScale").Scale
        assert(panel.Size.X.Offset*scale <= viewport.X-24+0.001)
        assert(panel.Size.Y.Offset*scale <= viewport.Y-65+0.001)
    end
end)
test("every machine and bag cosmetic can be constructed and replaced", function()
    local builder = loadModule("server/world/StationBuilder")
    local render = loadModule("server/world/EquipmentVisuals")
    local equipment = loadModule("shared/config/Equipment")
    local station = builder(workspace,99,Vector3.zero)
    for _, rarity in ipairs(equipment.Rarities) do
        render(station,equipment.Pools.Machine[rarity.id],equipment.Pools.Bag[rarity.id])
        assert(station.model:FindFirstChild("EquipmentDetails"))
    end
    render(station,"starter_fryer","starter_bag")
    eq(station.machine.Transparency,0)
    station.model:Destroy()
end)
test("unknown action names cannot grow per-player cooldown storage", function()
    local ActionService = loadModule("server/services/ActionService")
    local actionService = ActionService.new(nil,nil,nil,nil,nil,nil)
    for i=1,1000 do
        serverTime += 1
        actionService:handle(first,"Unknown"..i)
    end
    eq(next(actionService.cooldowns),nil)
end)
test("disconnect releases station and shutdown closes memory sessions", function()
    players.PlayerRemoving:Fire(first)
    eq(workspace.FriesRestaurant.Station1.Counter.Sign.TextLabel.Text,"AVAILABLE COUNTER")
    players.PlayerRemoving:Fire(second)
    game:closeCallback()
    drain()
end)
