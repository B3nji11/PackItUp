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
local cfMeta = {}
CFrame = { new = function(position) return setmetatable({Position=position, yaw=0}, cfMeta) end }
function CFrame.Angles(_, yaw, _) return setmetatable({Position=Vector3.zero, yaw=yaw}, cfMeta) end
cfMeta.__index = {PointToWorldSpace=function(cf, point)
    return cf.Position + Vector3.new(math.cos(cf.yaw)*point.X + math.sin(cf.yaw)*point.Z,
        point.Y, -math.sin(cf.yaw)*point.X + math.cos(cf.yaw)*point.Z)
end}
cfMeta.__mul = function(a,b)
    return setmetatable({Position=a:PointToWorldSpace(b.Position), yaw=a.yaw+b.yaw}, cfMeta)
end
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
    RenderStepped=true, WindowFocusReleased=true, Triggered=true,
    MouseEnter=true, MouseLeave=true, SelectionGained=true, SelectionLost=true }
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
function instanceMethods:SetAttribute(name, value)
    if not self._attributes then self._attributes = {} end
    self._attributes[name] = value
end
function instanceMethods:GetAttribute(name) return self._attributes and self._attributes[name] end
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

test("server constructs six stations with only basic fryers and bags", function()
    loadModule("server/Main")
    local restaurant = assert(workspace:FindFirstChild("FriesRestaurant"))
    for i = 1, 6 do
        local station = assert(restaurant:FindFirstChild("Station"..i))
        assert(station:FindFirstChild("Machine") and station:FindFirstChild("FryerBasket"))
        assert(station:FindFirstChild("Bag") and station:FindFirstChild("Fry10"))
        eq(station.Machine:FindFirstChild("Sign"), nil)
        assert(station.ClaimPoint.ClaimRestaurant.Enabled)
        eq(station:GetAttribute("OwnerUserId"), 0)
        eq(station.RestaurantPlaque.WallArt.ClassName, "SurfaceGui")
    end
    eq(restaurant:FindFirstChild("RushBoard"), nil)
    eq(restaurant:FindFirstChild("TitleBoard"), nil)
    eq(restaurant.MuralWall.WallArt.ClassName, "SurfaceGui")
    eq(restaurant.MuralWall.WallArt.AlwaysOnTop, false)
    assert(restaurant.Ground.Size.X >= 200 and restaurant.Ground.Size.Z >= 180)
    assert(replicated:FindFirstChild("FriesRemotes"))
end)
local first = newPlayer(101)
local second = newPlayer(202)
local remote = replicated.FriesRemotes.Action

test("joining leaves all restaurants available and production waits for claiming", function()
    activePlayers = {first,second}
    players.PlayerAdded:Fire(first); players.PlayerAdded:Fire(second); drain()
    assert(not first.kickMessage and not second.kickMessage)
    eq(first.Character.HumanoidRootPart.Position.Magnitude, 0)
    eq(second.Character.HumanoidRootPart.Position.Magnitude, 0)
    runService.Heartbeat:Fire(0.2)
    local state = replicated.FriesRemotes.State.lastArgs[1]
    eq(state.profile.cash, 0); eq(state.nearStation, false); eq(state.hasStation, false)
    eq(state.profile.bag.fries, 0)
    eq(state.stats.perClick, 1); eq(state.stats.perSecond, 0.5); eq(state.stats.saleValue, 10)
    eq(state.rush, nil); eq(state.foldStart, nil); eq(state.profile.tickets, nil)
end)

test("unclaimed players cannot pack sell or return to an arbitrary restaurant", function()
    for _, action in ipairs({"Pack", "Sell", "Return"}) do
        serverTime += 1; remote.OnServerEvent:Fire(first, action)
        eq(replicated.FriesRemotes.Notice.lastArgs[2], false)
    end
    eq(first.Character.HumanoidRootPart.Position.Magnitude, 0)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries, 0)
end)

test("claiming enforces distance life ownership and one restaurant per player", function()
    local world = workspace.FriesRestaurant
    serverTime += 1; world.Station1.ClaimPoint.ClaimRestaurant.Triggered:Fire(first)
    eq(world.Station1:GetAttribute("OwnerUserId"), 0)
    first.Character.HumanoidRootPart.Position = world.Station1.ClaimPoint.Position
    first.Character.Humanoid.Health = 0
    serverTime += 1; world.Station1.ClaimPoint.ClaimRestaurant.Triggered:Fire(first)
    eq(world.Station1:GetAttribute("OwnerUserId"), 0)
    first.Character.Humanoid.Health = 100
    serverTime += 1; world.Station1.ClaimPoint.ClaimRestaurant.Triggered:Fire(first)
    eq(world.Station1:GetAttribute("OwnerUserId"), first.UserId)
    eq(world.Station1.ClaimPoint.ClaimRestaurant.Enabled, false)
    eq(replicated.FriesRemotes.State.lastArgs[1].hasStation, true)
    eq(replicated.FriesRemotes.State.lastArgs[1].nearStation, true)
    second.Character.HumanoidRootPart.Position = world.Station1.ClaimPoint.Position
    serverTime += 1; world.Station1.ClaimPoint.ClaimRestaurant.Triggered:Fire(second)
    eq(world.Station1:GetAttribute("OwnerUserId"), first.UserId)
    eq(replicated.FriesRemotes.State.lastArgs[1].hasStation, false)
    second.Character.HumanoidRootPart.Position = world.Station5.ClaimPoint.Position
    serverTime += 1; world.Station5.ClaimPoint.ClaimRestaurant.Triggered:Fire(second)
    eq(world.Station5:GetAttribute("OwnerUserId"), second.UserId)
    first.Character.HumanoidRootPart.Position = world.Station2.ClaimPoint.Position
    serverTime += 1; world.Station2.ClaimPoint.ClaimRestaurant.Triggered:Fire(first)
    eq(world.Station2:GetAttribute("OwnerUserId"), 0)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Return")
end)

test("plots are separated and entrances face the central plaza", function()
    local world = workspace.FriesRestaurant
    for i=1,6 do
        local station=world["Station"..i]
        for j=i+1,6 do
            local other=world["Station"..j]
            assert((station.Plot.Position-other.Plot.Position).Magnitude >= 64-0.001)
        end
        assert(math.abs(station.ClaimPoint.Position.Z) < math.abs(station.Plot.Position.Z))
        eq(station.ClaimPoint.ClaimRestaurant.KeyboardKeyCode, Enum.KeyCode.E)
    end
end)

test("admission reserves six player spaces even before restaurants are claimed", function()
    local extra = {}
    for id=401,404 do
        local player=newPlayer(id); table.insert(extra, player); table.insert(activePlayers, player)
        players.PlayerAdded:Fire(player); drain(); eq(player.kickMessage, nil)
    end
    local seventh = newPlayer(405)
    players.PlayerAdded:Fire(seventh); drain(); assert(seventh.kickMessage)
    seventh.Character.HumanoidRootPart.Position=workspace.FriesRestaurant.Station2.ClaimPoint.Position
    serverTime += 1; workspace.FriesRestaurant.Station2.ClaimPoint.ClaimRestaurant.Triggered:Fire(seventh)
    eq(workspace.FriesRestaurant.Station2:GetAttribute("OwnerUserId"), 0)
    for _,player in ipairs(extra) do players.PlayerRemoving:Fire(player) end
    activePlayers={first,second}
end)

test("remote fill sell repeat loop awards cash once per full bag", function()
    for round = 1, 2 do
        for _ = 1, 20 do serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack") end
        serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
        local state = replicated.FriesRemotes.State.lastArgs[1]
        eq(state.profile.cash, round * 10); eq(state.profile.bag.fries, 0)
        serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
        eq(replicated.FriesRemotes.State.lastArgs[1].profile.cash, round * 10)
    end
    serverTime += 1; remote.OnServerEvent:Fire(first, "Pack")
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.cash, 20)
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries, 1)
    serverTime += 1; remote.OnServerEvent:Fire(second, "Sync")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.cash, 0)
end)

test("server rejects work away from the counter and teleport returns its owner", function()
    first.Character.HumanoidRootPart.Position=Vector3.new(1000,4,0)
    for _, name in ipairs({"Pack", "Sell"}) do
        serverTime += 1; remote.OnServerEvent:Fire(first, name)
        eq(replicated.FriesRemotes.Notice.lastArgs[2], false)
    end
    serverTime += 1; remote.OnServerEvent:Fire(first, "Return")
    eq(replicated.FriesRemotes.State.lastArgs[1].nearStation, true)
    assert(first.Character.HumanoidRootPart.Position.X ~= second.Character.HumanoidRootPart.Position.X)
end)

test("basic fryer fills online and stops at capacity", function()
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    local before = replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries
    runService.Heartbeat:Fire(0.2)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    near(replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries, before + 0.1)
    for _ = 1, 20 do serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack") end
    runService.Heartbeat:Fire(0.5)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries, 20)
end)

test("removed actions and malformed core arguments are rejected before dispatch", function()
    local actions = loadModule("server/services/ActionService").new(nil, nil, nil, nil)
    for _, name in ipairs({"StartFold", "FinishFold", "Upgrade", "Roll", "Equip", "Unequip", "Unknown"}) do
        serverTime += 1; actions:handle(first, name, "ufo")
        serverTime += 1; actions:handle(first, name)
    end
    for _, name in ipairs({"Pack", "Sell", "Return", "Sync"}) do
        serverTime += 1; actions:handle(first, name, {cash=999})
        serverTime += 1; actions:handle(first, name, "forged")
    end
    eq(next(actions.cooldowns), nil)
end)

test("legacy progression stays out of snapshots and cannot change basic stats", function()
    local p = loadModule("shared/domain/Profile").new()
    p.upgrades={Click=20,Sales=20}; p.tickets=99; p.equipped={Machine="ufo",Bag="briefcase"}
    local state
    local snapshots = loadModule("server/services/SnapshotService").new(
        {get=function() return p end, volatile=true},
        {near=function() return true end, hasStation=function() return true end},
        {State={FireClient=function(_, _, value) state=value end}})
    snapshots:send(first)
    eq(state.profile.upgrades, nil); eq(state.profile.tickets, nil); eq(state.profile.equipped, nil)
    eq(state.stats.perClick, 1); eq(state.stats.perSecond, 0.5); eq(state.stats.saleValue, 10)
    state.profile.bag.fries=20; eq(p.bag.fries, 0)
end)

test("client has exactly click sell and teleport with no feature panels", function()
    players.LocalPlayer=first
    loadModule("client/Main")
    local gui = first.PlayerGui:FindFirstChild("FriesInterface")
    assert(gui and gui.Actions.Click and gui.Actions.Sell and gui.Teleport)
    eq(gui:FindFirstChild("Panel"), nil); eq(gui:FindFirstChild("Navigation"), nil)
    local count = 0
    local function visit(node)
        if node.ClassName == "TextButton" then count += 1 end
        for _, child in ipairs(node._children or {}) do visit(child) end
    end
    visit(gui); eq(count, 3)
    replicated.FriesRemotes.State.OnClientEvent:Fire(replicated.FriesRemotes.State.lastArgs[1])
    replicated.FriesRemotes.Notice.OnClientEvent:Fire("Core loop ready", true)
    runService.RenderStepped:Fire(); drain()
    eq(gui.CashCard.Cash.Text, "$20")
    assert(gui.CashCard.Coin)
    remote.lastServerArgs = nil; gui.Teleport.Activated:Fire()
    eq(remote.lastServerArgs[1], "Return")
    remote.lastServerArgs = nil
    inputService.InputBegan:Fire({KeyCode=Enum.KeyCode.Q}, false)
    eq(remote.lastServerArgs, nil)
    inputService.InputBegan:Fire({KeyCode=Enum.KeyCode.E}, false)
    eq(remote.lastServerArgs, nil)
end)

test("permanent core controls fit portrait landscape and desktop", function()
    for _, viewport in ipairs({Vector2.new(320,568),Vector2.new(390,844),Vector2.new(568,320),Vector2.new(844,390),Vector2.new(1280,720)}) do
        workspace.CurrentCamera.ViewportSize=viewport; runService.RenderStepped:Fire()
        local gui = first.PlayerGui.FriesInterface
        local scale = gui.Actions:FindFirstChildOfClass("UIScale").Scale
        assert(gui.Actions.Size.X.Offset * scale <= viewport.X - 24 + 0.001)
        local top = viewport.Y - 60 - 22 - gui.Actions.Size.Y.Offset * scale
        assert(gui.Teleport.Position.Y.Offset + gui.Teleport.Size.Y.Offset <= top)
        assert(gui.Guidance.Position.Y.Offset + gui.Guidance.Size.Y.Offset <= top)
        assert(gui.Actions.Click.Size.Y.Offset * scale >= 36)
        eq(gui.Actions.AnchorPoint.X, 0.5); eq(gui.Actions.AnchorPoint.Y, 1)
        eq(gui.Teleport.Position.X.Scale, 0.5)
        assert(gui.Actions.Visible and gui.Teleport.Visible)
    end
end)

test("button and keyboard selling require a full bag at the counter", function()
    local gui = first.PlayerGui.FriesInterface
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    for _, example in ipairs({{19,true,false}, {20,false,false}, {20,true,true}}) do
        state.profile.bag.fries, state.nearStation = example[1], example[2]
        replicated.FriesRemotes.State.OnClientEvent:Fire(state)
        eq(gui.Actions.Sell.Active, example[3])
        remote.lastServerArgs=nil; gui.Actions.Sell.Activated:Fire()
        eq(remote.lastServerArgs ~= nil, example[3])
        remote.lastServerArgs=nil
        inputService.InputBegan:Fire({KeyCode=Enum.KeyCode.R}, false)
        eq(remote.lastServerArgs ~= nil, example[3])
    end
end)

test("click packs while full bags and distance block further client packing", function()
    local gui = first.PlayerGui.FriesInterface
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    local click = {UserInputType=Enum.UserInputType.MouseButton1}
    state.profile.bag.fries, state.nearStation=0,true
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    remote.lastServerArgs=nil; gui.Actions.Click.InputBegan:Fire(click)
    eq(remote.lastServerArgs[1], "Pack"); inputService.InputEnded:Fire(click)
    for _, example in ipairs({{20,true}, {0,false}}) do
        state.profile.bag.fries, state.nearStation=example[1],example[2]
        replicated.FriesRemotes.State.OnClientEvent:Fire(state)
        remote.lastServerArgs=nil; gui.Actions.Click.InputBegan:Fire(click)
        eq(remote.lastServerArgs,nil); inputService.InputEnded:Fire(click)
    end
end)

test("HUD moves rate capacity and full-bag feedback inside the buttons", function()
    local gui = first.PlayerGui.FriesInterface
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    state.hasStation, state.nearStation, state.profile.bag.fries = true, true, 12
    state.profile.cash = 1234567
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.CashCard.Cash.Text, "$1,234,567")
    eq(gui.Actions.Click.Title.Text, "4 clicks/sec")
    eq(gui.Actions.Sell.Title.Text, "12 / 20")
    gui.Actions.Click.MouseEnter:Fire(); eq(gui.Actions.Click.Title.Text, "CLICK")
    gui.Actions.Click.MouseLeave:Fire(); eq(gui.Actions.Click.Title.Text, "4 clicks/sec")
    state.profile.bag.fries = 20
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.Actions.Sell.Title.Text, "SELL BAG"); eq(gui.Actions.Sell.Detail.Text, "+$10 CASH")
    eq(gui.Actions.Sell.Active, true)
    state.hasStation = false
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.Actions.Sell.Active, false); eq(gui.Actions.Click.Active, false); eq(gui.Teleport.Active, false)
    eq(gui.Guidance.Visible, true)
    eq(loadModule("client/ui/Elements").money(1000000000000), "$1,000,000,000,000")
    state.hasStation = true
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    replicated.FriesRemotes.Notice.OnClientEvent:Fire("Sold! +$10", true)
    eq(gui.Guidance.Visible, false)
end)

test("respawn keeps a claimed restaurant and return targets the same plot", function()
    first.Character.HumanoidRootPart.Position = Vector3.zero
    first.CharacterAdded:Fire(first.Character); drain()
    assert((first.Character.HumanoidRootPart.Position - workspace.FriesRestaurant.Station1.Plot.Position).Magnitude < 16)
end)

test("disconnect frees the chosen plot for another player", function()
    players.PlayerRemoving:Fire(first)
    local station = workspace.FriesRestaurant.Station1
    eq(station.RestaurantPlaque.WallArt.TextLabel.Text, "RESTAURANT 1\nAVAILABLE")
    eq(station:GetAttribute("OwnerUserId"), 0); eq(station.ClaimPoint.ClaimRestaurant.Enabled, true)
    local replacement = newPlayer(303)
    activePlayers = {second,replacement}
    players.PlayerAdded:Fire(replacement); drain()
    replacement.Character.HumanoidRootPart.Position=station.ClaimPoint.Position
    serverTime += 1; station.ClaimPoint.ClaimRestaurant.Triggered:Fire(replacement)
    eq(station:GetAttribute("OwnerUserId"), replacement.UserId)
    players.PlayerRemoving:Fire(replacement)
    players.PlayerRemoving:Fire(second); game:closeCallback(); drain()
end)
