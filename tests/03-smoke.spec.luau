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
    if key == "Cross" then return function(a,b)
        return Vector3.new(a.Y*b.Z-a.Z*b.Y, a.Z*b.X-a.X*b.Z, a.X*b.Y-a.Y*b.X)
    end end
    if key == "Unit" then return Vector3.new(v.X/v.Magnitude, v.Y/v.Magnitude, v.Z/v.Magnitude) end
end
Vector3 = { new = function(x,y,z) return setmetatable({X=x,Y=y,Z=z}, vectorMeta) end }
vectorMeta.__add = function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vectorMeta.__sub = function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vectorMeta.__mul = function(a,b) return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
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
ColorSequence = {new=function(value) return {Value=value} end}
NumberSequence = {new=function(value) return {Value=value} end}
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
            if class == "Attachment" and key == "WorldPosition" then
                return values.Parent.Position + (values.Position or Vector3.zero)
            end
            if instanceMethods[key] then return instanceMethods[key] end
            if values[key] ~= nil then return values[key] end
            if eventNames[key] then values[key]=signal(); return values[key] end
            for _, child in ipairs(values._children or {}) do if child.Name == key then return child end end
            return nil
        end,
        __newindex = function(self,key,value)
            -- Studio/place configuration only; normal game scripts cannot write these.
            if class == "Lighting" and (key == "LightingStyle" or key == "Technology"
                or key == "PrioritizeLightingQuality") then
                error("Cannot write Lighting." .. key .. " from a game script")
            end
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
function players:GetUserThumbnailAsync(id, kind, size)
    eq(kind, Enum.ThumbnailType.HeadShot); eq(size, Enum.ThumbnailSize.Size150x150)
    return "rbxasset://headshot-" .. id, true
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
    local head = makeInstance("Part"); head.Name = "Head"; head.Size=Vector3.new(2,1,1)
    head.Position=Vector3.new(0,2,0); head.Parent=player.Character
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
    local arguments = { Upgrade = "FriesPerClick", Spin = "StarterFryer" }
    for _, action in ipairs({"Pack", "Sell", "Return", "Upgrade", "Rebirth", "Spin"}) do
        serverTime += 1; remote.OnServerEvent:Fire(first, action, arguments[action])
        eq(replicated.FriesRemotes.Notice.lastArgs[2], false)
    end
    eq(first.Character.HumanoidRootPart.Position.Magnitude, 0)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries, 0)
    eq(replicated.FriesRemotes.State.lastArgs[1].shop[1].level, 0)
    eq(replicated.FriesRemotes.State.lastArgs[1].rebirth.count, 0); eq(replicated.FriesRemotes.State.lastArgs[1].profile.gems, 0)
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

test("ceilings cover restaurants and the solid perimeter encloses all plots", function()
    local world = workspace.FriesRestaurant
    local boundary = world.Boundary
    local function low(part, axis) return part.Position[axis] - part.Size[axis] / 2 end
    local function high(part, axis) return part.Position[axis] + part.Size[axis] / 2 end
    for _, side in ipairs({"North", "South", "East", "West"}) do
        local wall = boundary[side]
        assert(wall.Anchored and wall.CanCollide)
        assert(low(wall, "Y") <= high(world.Ground, "Y"))
    end
    -- Adjacent walls overlap at the corners and sit on the ground's outer edges.
    near(low(boundary.West, "X"), low(world.Ground, "X"))
    near(high(boundary.East, "X"), high(world.Ground, "X"))
    near(low(boundary.North, "Z"), low(world.Ground, "Z"))
    near(high(boundary.South, "Z"), high(world.Ground, "Z"))
    for _, side in ipairs({"North", "South"}) do
        assert(low(boundary[side], "X") <= high(boundary.West, "X"))
        assert(high(boundary[side], "X") >= low(boundary.East, "X"))
    end
    for _, side in ipairs({"West", "East"}) do
        assert(low(boundary[side], "Z") <= high(boundary.North, "Z"))
        assert(high(boundary[side], "Z") >= low(boundary.South, "Z"))
    end
    for i=1,6 do
        local station = world["Station"..i]
        local roof, floor = station.Ceiling, station.RestaurantFloor
        for _, axis in ipairs({"X", "Z"}) do
            assert(low(roof, axis) <= low(floor, axis) and high(roof, axis) >= high(floor, axis))
        end
        near(low(roof, "Y"), high(station.BackWall, "Y"))
        near(low(roof, "Y"), high(station.LeftWall, "Y"))
        near(low(roof, "Y"), high(station.RightWall, "Y"))
        assert(low(roof, "Y") - high(floor, "Y") >= 17)
        assert(low(station.Plot, "X") > high(boundary.West, "X"))
        assert(high(station.Plot, "X") < low(boundary.East, "X"))
        assert(low(station.Plot, "Z") > high(boundary.North, "Z"))
        assert(high(station.Plot, "Z") < low(boundary.South, "Z"))
    end
end)

test("interior fixtures fit below the taller ceiling and reach the floor and worktop", function()
    for i=1,6 do
        local station = workspace.FriesRestaurant["Station"..i]
        local floor, ceiling = station.RestaurantFloor, station.Ceiling
        local floorTop = floor.Position.Y + floor.Size.Y/2
        local ceilingBottom = ceiling.Position.Y - ceiling.Size.Y/2
        local samples = {station.Worktop.Position, station.Bag.Position, station.Machine.Position}
        for _, x in ipairs({-floor.Size.X/2, floor.Size.X/2}) do
            for _, z in ipairs({-floor.Size.Z/2, floor.Size.Z/2}) do
                table.insert(samples, Vector3.new(floor.Position.X+x, floorTop, floor.Position.Z+z))
            end
        end
        for n=1,4 do
            local panel = station["LightPanel"..n]
            assert(panel.Position.Y + panel.Size.Y/2 <= ceilingBottom)
            assert(panel.Position.Y - panel.Size.Y/2 > station.Machine.Position.Y + station.Machine.Size.Y/2)
            assert(not panel.CanCollide and not panel.CanQuery)
            eq(panel.InteriorLight.ClassName, "SurfaceLight")
            eq(panel.InteriorLight.Face, Enum.NormalId.Bottom)
            assert(panel.InteriorLight.Enabled and panel.InteriorLight.Brightness > 0)
        end
        for _, point in ipairs(samples) do
            local reachable = false
            for n=1,4 do
                local panel = station["LightPanel"..n]
                local light = panel.InteriorLight
                local origin = panel.Position - Vector3.new(0, panel.Size.Y/2, 0)
                local delta = point - origin
                -- Conservative cone/range check from the face center; rendering needs Studio.
                if delta.Magnitude <= light.Range and -delta.Y/delta.Magnitude >= math.cos(math.rad(light.Angle/2)) then
                    reachable = true
                end
            end
            assert(reachable, "Interior sample is outside every ceiling light's range/cone")
        end
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
    for _, forged in ipairs({{id="FriesPerClick"}, 25, "Click", "upgrades", string.rep("x", 30)}) do
        serverTime += 1; actions:handle(first, "Upgrade", forged)
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
    eq(state.stats.capacity, 20); for _, row in ipairs(state.shop) do eq(row.level, 0) end
    state.profile.bag.fries=20; eq(p.bag.fries, 0)
end)

test("available restaurant arrows are personal and owner cards use account usernames", function()
    local Markers = loadModule("client/ui/RestaurantMarkers")
    local choosing = Markers.new(makeInstance("PlayerGui"), 999)
    choosing:update(false); drain()
    for i=1,6 do
        eq(choosing.entries[i].available.Visible, i ~= 1 and i ~= 5)
        eq(choosing.guides.entries[i] ~= nil, i ~= 1 and i ~= 5)
    end
    local claimed = choosing.entries[1]
    eq(claimed.owner.Visible, true)
    eq(claimed.username.Text, "@" .. first.Name)
    eq(claimed.avatar.Image, "rbxasset://headshot-101")
    eq(claimed.gui.Adornee, workspace.FriesRestaurant.Station1.RoofCap)
    local owned = Markers.new(makeInstance("PlayerGui"), first.UserId)
    owned:update(false); drain() -- Ownership can arrive before the private snapshot.
    eq(next(owned.guides.entries), nil)
    for i=1,6 do eq(owned.entries[i].available.Visible, false) end
    choosing:update(true)
    eq(next(choosing.guides.entries), nil)
    for i=1,6 do eq(choosing.entries[i].available.Visible, false) end
    choosing:update(false)
    eq(choosing.entries[2].available.Visible, true)
    eq(choosing.entries[2].gui.Adornee, workspace.FriesRestaurant.Station2.ClaimPoint)
end)

test("restaurant guides extend above the moving player's head toward the entrance", function()
    local guides = loadModule("client/ui/RestaurantGuides").new()
    local viewer = newPlayer(9001)
    local entrance = workspace.FriesRestaurant.Station2.ClaimPoint
    guides:setTarget(2, entrance)
    guides:step(viewer.Character)
    local entry = guides.entries[2]
    eq(guides.origin.Parent, viewer.Character.Head)
    assert(guides.origin.WorldPosition.Y > viewer.Character.Head.Position.Y + viewer.Character.Head.Size.Y/2)
    eq(entry.finish.Parent, entrance)
    assert(#entry.chevrons >= 3)
    local direction = (entry.finish.WorldPosition-guides.origin.WorldPosition).Unit
    local function along(point) return point.X*direction.X + point.Y*direction.Y + point.Z*direction.Z end
    local previousTip = 0
    for _, mark in ipairs(entry.chevrons) do
        assert(mark.leftArm.Enabled and mark.rightArm.Enabled)
        eq(mark.leftArm.Attachment0, mark.Left); eq(mark.leftArm.Attachment1, mark.Tip)
        eq(mark.rightArm.Attachment0, mark.Right); eq(mark.rightArm.Attachment1, mark.Tip)
        assert(along(mark.Left.Position) > previousTip) -- Spacing between > shapes.
        assert(along(mark.Tip.Position) > along(mark.Left.Position)) -- Points toward the restaurant.
        previousTip = along(mark.Tip.Position)
    end
    assert(not entry.base.CanCollide and not entry.base.CanTouch and not entry.base.CanQuery)
    local before = entry.base.Position
    viewer.Character.Head.Position = Vector3.new(25, 5, 10)
    guides:step(viewer.Character)
    assert((before-entry.base.Position).Magnitude > 0.1)
    near((guides.origin.WorldPosition-entry.base.Position).Magnitude, 0)
    viewer.Character.Head.Position = Vector3.new(1000, 5, 10)
    guides:step(viewer.Character)
    eq(#entry.chevrons, 24)
    guides:step(viewer.Character); eq(#entry.chevrons, 24) -- Reuse the bounded pool.
    local oldOrigin = guides.origin
    guides:setTarget(2, nil); guides:step(viewer.Character)
    eq(entry.base.Parent, nil); eq(entry.finish.Parent, nil); eq(oldOrigin.Parent, nil)
end)

test("chevrons flow toward restaurants at the same speed across frame rates and loop cleanly", function()
    local Guides = loadModule("client/ui/RestaurantGuides")
    local viewer = newPlayer(9010)
    local slow, fast = Guides.new(), Guides.new()
    local entrance = workspace.FriesRestaurant.Station2.ClaimPoint
    slow:setTarget(2, entrance); fast:setTarget(2, entrance)
    slow:step(viewer.Character, 0); fast:step(viewer.Character, 0)
    local first = slow.entries[2].chevrons[1]
    local before = first.Tip.WorldPosition
    local destination = slow.entries[2].finish.WorldPosition
    for _=1,15 do slow:step(viewer.Character, 1/30) end
    for _=1,30 do fast:step(viewer.Character, 1/60) end
    assert((destination-first.Tip.WorldPosition).Magnitude < (destination-before).Magnitude)
    near((first.Tip.Position-fast.entries[2].chevrons[1].Tip.Position).Magnitude, 0)
    slow:step(viewer.Character, 0.125) -- Half a pattern step puts the last chevron at the origin.
    local entry = slow.entries[2]
    local last = entry.chevrons[#entry.chevrons]
    near(last.leftArm.Transparency.Value, 1)
    near(last.Tip.Position.Magnitude, 0)
    local count = #entry.chevrons
    slow:step(viewer.Character, 0.625) -- One complete cycle reproduces the initial pattern.
    near((first.Tip.WorldPosition-before).Magnitude, 0)
    eq(#entry.chevrons, count)
    slow:setTarget(2, nil); fast:setTarget(2, nil)
    slow:step(nil, 1/60); fast:step(nil, 1/60)
end)

test("restaurant guides handle death respawn missing characters and very short distances", function()
    local guides = loadModule("client/ui/RestaurantGuides").new()
    local viewer = newPlayer(9002)
    guides:setTarget(2, workspace.FriesRestaurant.Station2.ClaimPoint)
    local entry = guides.entries[2]
    guides:step(nil); eq(#entry.chevrons, 0)
    guides:step(viewer.Character)
    local oldOrigin = guides.origin
    viewer.Character.Humanoid.Health = 0
    guides:step(viewer.Character)
    for _, mark in ipairs(entry.chevrons) do
        eq(mark.leftArm.Enabled, false); eq(mark.rightArm.Enabled, false)
    end; eq(oldOrigin.Parent, nil)
    local replacement = newPlayer(9003)
    guides:step(replacement.Character)
    eq(guides.origin.Parent, replacement.Character.Head)
    eq(entry.chevrons[1].leftArm.Enabled, true)
    replacement.Character.Head.Position = entry.finish.WorldPosition - guides.origin.Position
    guides:step(replacement.Character)
    for _, mark in ipairs(entry.chevrons) do
        eq(mark.leftArm.Enabled, false); eq(mark.rightArm.Enabled, false)
    end
    guides:setTarget(2, nil); guides:step(nil)
end)

test("restaurant markers clear on release and ignore late portraits from the previous owner", function()
    local markers = loadModule("client/ui/RestaurantMarkers").new(makeInstance("PlayerGui"), 999)
    markers:update(false); drain()
    local station = workspace.FriesRestaurant.Station2
    local owner = newPlayer(303)
    owner.DisplayName = "A different display name"
    players.PlayerAdded:Fire(owner); drain()
    owner.Character.HumanoidRootPart.Position = station.ClaimPoint.Position
    serverTime += 1; station.ClaimPoint.ClaimRestaurant.Triggered:Fire(owner)
    markers:update(false)
    local entry = markers.entries[2]
    local oldPortrait = table.remove(scheduled)
    eq(entry.username.Text, "@Tester303")
    eq(entry.available.Visible, false); eq(entry.owner.Visible, true)
    eq(markers.guides.entries[2], nil)
    players.PlayerRemoving:Fire(owner)
    markers:update(false)
    eq(entry.owner.Visible, false); eq(entry.available.Visible, true)
    assert(markers.guides.entries[2])
    eq(station:GetAttribute("OwnerUsername"), nil)
    eq(entry.avatar.Image, "")
    -- Complete the replacement's request before the old owner's delayed response.
    local replacement = newPlayer(404)
    players.PlayerAdded:Fire(replacement); drain()
    replacement.Character.HumanoidRootPart.Position = station.ClaimPoint.Position
    serverTime += 1; station.ClaimPoint.ClaimRestaurant.Triggered:Fire(replacement)
    markers:update(false)
    eq(entry.username.Text, "@Tester404")
    drain()
    oldPortrait.fn(table.unpack(oldPortrait.args))
    eq(entry.avatar.Image, "rbxasset://headshot-404")
    players.PlayerRemoving:Fire(replacement)
    markers:update(false)
    eq(entry.avatar.Visible, false); eq(entry.available.Visible, true)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
end)

test("unavailable avatars retain a username fallback with bounded background retries", function()
    local original = players.GetUserThumbnailAsync
    players.GetUserThumbnailAsync = function() error("Thumbnail service unavailable") end
    local markers = loadModule("client/ui/RestaurantMarkers").new(makeInstance("PlayerGui"), 999)
    markers:update(false); drain()
    local entry = markers.entries[1]
    eq(entry.avatar.Visible, false); eq(entry.fallback.Visible, true)
    eq(entry.username.Text, "@" .. first.Name)
    markers:update(false); eq(entry.attempts, 1)
    for _=1,4 do
        entry.nextAttempt = 0
        markers:update(false); drain()
    end
    eq(entry.attempts, 3)
    eq(entry.owner.Visible, true)
    players.GetUserThumbnailAsync = original
end)

test("client has click sell teleport and the upgrade rebirth spin and pets menus only", function()
    players.LocalPlayer=first
    loadModule("client/Main")
    local gui = first.PlayerGui:FindFirstChild("FriesInterface")
    assert(gui and gui.Actions.Click and gui.Actions.Sell and gui.Teleport and gui.UpgradesButton and gui.RebirthButton and gui.SpinButton and gui.PetsButton)
    eq(gui.UpgradeShop.Visible, false); eq(gui.RebirthPanel.Visible, false)
    eq(gui.GachaPanel.Visible, false); eq(gui.PetsPanel.Visible, false)
    eq(gui:FindFirstChild("Panel"), nil); eq(gui:FindFirstChild("Navigation"), nil)
    local count = 0
    local function visit(node)
        if node.ClassName == "TextButton" then count += 1 end
        for _, child in ipairs(node._children or {}) do visit(child) end
    end
    visit(gui); eq(count, 16) -- Click, Sell, Teleport, four menu buttons, four Close, Confirm, three Buy, and Spin
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
        local cash = gui.CashCard
        eq(cash.AnchorPoint.Y, 0.5); eq(cash.Position.Y.Scale, 0.5); eq(cash.Position.X.Offset, 16)
        -- Middle left; tall phones may lift it slightly to fit the menu grid below it.
        assert(cash.Position.Y.Offset <= 0)
        if viewport.Y >= 500 then assert(cash.Position.Y.Offset >= -40) end
        if viewport.Y >= 700 then eq(cash.Position.Y.Offset, 0) end
        local cashBottom = (viewport.Y - 60) / 2 + cash.Position.Y.Offset + cash.Size.Y.Offset / 2
        assert(cashBottom + 12 <= top + 0.001)
        assert(gui.Actions.Click.Size.Y.Offset * scale >= 36)
        eq(gui.Actions.AnchorPoint.X, 0.5); eq(gui.Actions.AnchorPoint.Y, 1)
        eq(gui.Teleport.Position.X.Scale, 0.5)
        assert(gui.Actions.Visible and gui.Teleport.Visible)
        -- The UPGRADES button stays on screen and clear of every other control.
        local height = viewport.Y - 60
        local function rect(object, scale)
            local w, h = object.Size.X.Offset * (scale or 1), object.Size.Y.Offset * (scale or 1)
            local anchor = object.AnchorPoint or Vector2.new(0, 0)
            local x = object.Position.X.Scale * viewport.X + object.Position.X.Offset - anchor.X * w
            local y = object.Position.Y.Scale * height + object.Position.Y.Offset - anchor.Y * h
            return { x, y, x + w, y + h }
        end
        local function apart(a, b) return a[3] <= b[1] or b[3] <= a[1] or a[4] <= b[2] or b[4] <= a[2] end
        local menuButtons = {gui.UpgradesButton, gui.RebirthButton, gui.SpinButton, gui.PetsButton}
        for _, button in ipairs(menuButtons) do
            local box = rect(button)
            assert(box[1] >= 0 and box[2] >= 0 and box[3] <= viewport.X and box[4] <= height, button.Name)
            assert(box[4] + 12 <= top + 0.001 or apart(box, rect(gui.Actions, scale)), button.Name)
            for _, other in ipairs({gui.Teleport, gui.Guidance, cash}) do assert(apart(box, rect(other)), button.Name .. "/" .. other.Name) end
            assert(button.Size.Y.Offset >= 36 and button.Size.X.Offset >= 56)
        end
        for i = 1, #menuButtons do
            for j = i + 1, #menuButtons do assert(apart(rect(menuButtons[i]), rect(menuButtons[j])), menuButtons[i].Name .. "/" .. menuButtons[j].Name) end
        end
        for _, other in ipairs({gui.UpgradesButton, gui.RebirthButton, gui.SpinButton, gui.PetsButton, gui.Teleport, cash}) do
            assert(apart(rect(gui.Mode), rect(other)), "Mode/" .. other.Name)
        end
        assert(apart(rect(gui.Mode), rect(gui.Actions, scale)), "Mode/Actions")
        for _, panel in ipairs({gui.UpgradeShop, gui.RebirthPanel, gui.GachaPanel, gui.PetsPanel}) do
            eq(panel.ZIndex, 5)
            local panelScale = panel:FindFirstChildOfClass("UIScale").Scale
            assert(panel.Size.X.Offset * panelScale <= viewport.X - 32 + 0.001)
            assert(panel.Size.Y.Offset * panelScale <= height - 24 + 0.001)
        end
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

test("HUD highlights fries per click capacity and full-bag feedback inside the buttons", function()
    local gui = first.PlayerGui.FriesInterface
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    state.hasStation, state.nearStation, state.profile.bag.fries = true, true, 12
    state.profile.cash = 1234567
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.CashCard.Cash.Text, "$1,234,567")
    eq(gui.Actions.Click.Title.Text, "+1 fry/click")
    eq(gui.Actions.Sell.Title.Text, "12 / 20")
    gui.Actions.Click.MouseEnter:Fire(); eq(gui.Actions.Click.Title.Text, "CLICK")
    eq(gui.Actions.Click.Detail.Text, "+1 FRY/CLICK")
    gui.Actions.Click.MouseLeave:Fire(); eq(gui.Actions.Click.Title.Text, "+1 fry/click")
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

test("server rebirth needs the threshold resets Cash and the bag and awards gems once", function()
    local State, Notice = replicated.FriesRemotes.State, replicated.FriesRemotes.Notice
    local function sync() serverTime += 1; remote.OnServerEvent:Fire(first, "Sync"); return State.lastArgs[1] end
    local function fill(capacity)
        local state = sync()
        while state.profile.bag.fries < capacity do
            serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack"); state = sync()
        end
        return state
    end
    local s = sync()
    eq(s.profile.cash, 20); eq(s.profile.bag.fries, 20); eq(s.profile.gems, 0)
    eq(s.rebirth.threshold, 1000); eq(s.rebirth.reward, 10); eq(s.rebirth.ready, false); eq(s.rebirth.count, 0)
    eq(#s.shop, 3); eq(s.shop[1].id, "FriesPerClick"); eq(s.shop[1].cost, 3)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "FriesPerClick")
    eq(Notice.lastArgs[1], "Not enough gems for this upgrade."); eq(State.lastArgs[1].shop[1].level, 0)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Rebirth")
    eq(Notice.lastArgs[1], "Reach the rebirth threshold first."); eq(sync().profile.cash, 20)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
    for _ = 1, 97 do fill(20); serverTime += 1; remote.OnServerEvent:Fire(first, "Sell") end
    s = sync(); eq(s.profile.cash, 1000); eq(s.rebirth.ready, true)
    for _ = 1, 3 do serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack") end
    eq(sync().profile.bag.fries, 3)
    -- A second request inside the rebirth cooldown is ignored.
    serverTime += 1; remote.OnServerEvent:Fire(first, "Rebirth"); remote.OnServerEvent:Fire(first, "Rebirth")
    s = sync()
    eq(s.profile.cash, 0); eq(s.profile.bag.fries, 0); eq(s.profile.gems, 10)
    eq(s.rebirth.count, 1); eq(s.rebirth.threshold, 1600); eq(s.rebirth.reward, 15); eq(s.rebirth.ready, false)
    eq(s.profile.sales, 100) -- sales are kept through rebirth
    -- Gems buy upgrades; a rapid second purchase is ignored.
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "FriesPerClick"); remote.OnServerEvent:Fire(first, "Upgrade", "FriesPerClick")
    s = State.lastArgs[1]; eq(s.profile.gems, 7); eq(s.shop[1].level, 1); eq(s.stats.perClick, 2)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "FriesPerClick")
    s = State.lastArgs[1]; eq(s.profile.gems, 3); eq(s.shop[1].level, 2); eq(s.shop[1].cost, 5); eq(s.stats.perClick, 3)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "MoneyPerFry")
    eq(Notice.lastArgs[1], "Not enough gems for this upgrade."); eq(sync().profile.gems, 3)
    -- Forged arguments are dropped before dispatch.
    for _, forged in ipairs({ {id="FriesPerClick"}, 25, "Click", "upgrades" }) do
        serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", forged)
    end
    for _, forged in ipairs({ {gems=99}, 1, "now" }) do
        serverTime += 3; remote.OnServerEvent:Fire(first, "Rebirth", forged)
    end
    s = sync(); eq(s.profile.gems, 3); eq(s.rebirth.count, 1)
    serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack"); eq(sync().profile.bag.fries, 3)
    -- The other player's Cash, gems, and levels are untouched.
    serverTime += 1; remote.OnServerEvent:Fire(second, "Sync")
    local other = State.lastArgs[1]
    eq(other.profile.gems, 0); eq(other.rebirth.count, 0); eq(other.shop[1].level, 0); eq(other.stats.capacity, 20)
end)

test("wallet shop and rebirth panel show server values and send only allowed requests", function()
    local gui = first.PlayerGui.FriesInterface
    local shop, panel = gui.UpgradeShop, gui.RebirthPanel
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.CashCard.Cash.Text, "$0"); eq(gui.CashCard.Gems.Text, "3")
    eq(shop.Visible, false); eq(panel.Visible, false)
    gui.UpgradesButton.Activated:Fire(); eq(shop.Visible, true)
    eq(shop.FriesPerClick.Level.Text, "LEVEL 2"); eq(shop.FriesPerClick.Value.Text, "3 → 4 fries/click")
    eq(shop.MoneyPerFry.Value.Text, "$0.50 → $0.55 per fry"); eq(shop.BagCapacity.Value.Text, "20 → 25 fries per bag")
    eq(shop.FriesPerClick.Buy.Text, "5 GEMS"); eq(shop.MoneyPerFry.Buy.Text, "4 GEMS"); eq(shop.BagCapacity.Buy.Text, "5 GEMS")
    eq(gui.Actions.Click.Title.Text, "+3 fries/click"); eq(gui.Actions.Sell.Title.Text, "3 / 20")
    -- 3 gems affords nothing; plenty of Cash does not help.
    state.profile.cash = 99999
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    for _, id in ipairs({"FriesPerClick", "MoneyPerFry", "BagCapacity"}) do
        eq(shop[id].Buy.Active, false)
        remote.lastServerArgs = nil; shop[id].Buy.Activated:Fire(); eq(remote.lastServerArgs, nil)
    end
    state.profile.cash, state.profile.gems = 0, 4
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.CashCard.Gems.Text, "4")
    eq(shop.MoneyPerFry.Buy.Active, true); eq(shop.FriesPerClick.Buy.Active, false)
    remote.lastServerArgs = nil; shop.MoneyPerFry.Buy.Activated:Fire()
    eq(remote.lastServerArgs[1], "Upgrade"); eq(remote.lastServerArgs[2], "MoneyPerFry"); eq(remote.lastServerArgs[3], nil)
    -- Opening the rebirth panel closes the shop.
    gui.RebirthButton.Activated:Fire(); eq(panel.Visible, true); eq(shop.Visible, false)
    eq(panel.Details.Reward.Text, "+15 GEMS"); eq(panel.Details.Need.Text, "Needs $1,600 Cash  (you have $0)")
    eq(panel.Details.Count.Text, "REBIRTHS: 1")
    eq(panel.Confirm.Active, false); eq(panel.Confirm.Text, "NEED $1,600")
    remote.lastServerArgs = nil; panel.Confirm.Activated:Fire(); eq(remote.lastServerArgs, nil)
    state.profile.cash = 1600
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(panel.Confirm.Active, true); eq(panel.Confirm.Text, "REBIRTH NOW")
    remote.lastServerArgs = nil; panel.Confirm.Activated:Fire()
    eq(remote.lastServerArgs[1], "Rebirth"); eq(remote.lastServerArgs[2], nil)
    -- A completed rebirth closes the panel.
    state.profile.cash, state.rebirth.count = 0, 2
    replicated.FriesRemotes.State.OnClientEvent:Fire(state); eq(panel.Visible, false)
    gui.RebirthButton.Activated:Fire(); eq(panel.Visible, true)
    gui.UpgradesButton.Activated:Fire(); eq(shop.Visible, true); eq(panel.Visible, false)
    shop.Close.Activated:Fire(); eq(shop.Visible, false)
    gui.RebirthButton.Activated:Fire(); panel.Close.Activated:Fire(); eq(panel.Visible, false)
    -- Unclaimed players cannot open either panel.
    state.hasStation = false
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    gui.UpgradesButton.Activated:Fire(); gui.RebirthButton.Activated:Fire()
    eq(shop.Visible, false); eq(panel.Visible, false)
    eq(gui.UpgradesButton.Active, false); eq(gui.RebirthButton.Active, false)
    state.hasStation = true
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    gui.RebirthButton.Activated:Fire(); eq(panel.Visible, true)
    state.hasStation = false
    replicated.FriesRemotes.State.OnClientEvent:Fire(state); eq(panel.Visible, false)
    replicated.FriesRemotes.State.OnClientEvent:Fire(replicated.FriesRemotes.State.lastArgs[1])
end)

test("server spins charge Cash roll on the server and equip unequip and delete owned pets", function()
    local State, Notice = replicated.FriesRemotes.State, replicated.FriesRemotes.Notice
    local function sync() serverTime += 1; remote.OnServerEvent:Fire(first, "Sync"); return State.lastArgs[1] end
    local function fill(capacity)
        local state = sync()
        while state.profile.bag.fries < capacity do
            serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack"); state = sync()
        end
        return state
    end
    local function act(name, argument) serverTime += 1; remote.OnServerEvent:Fire(first, name, argument); return State.lastArgs[1] end
    local s = sync()
    eq(s.machine.id, "StarterFryer"); eq(s.machine.price, 100); eq(#s.pets.owned, 0); eq(s.pets.slots, 3); eq(s.pets.max, 50)
    eq(s.spin, nil)
    act("Spin", "StarterFryer"); eq(Notice.lastArgs[1], "Not enough Cash to spin."); eq(#sync().pets.owned, 0)
    for _ = 1, 21 do fill(20); serverTime += 1; remote.OnServerEvent:Fire(first, "Sell") end
    eq(sync().profile.cash, 210)
    -- A second spin inside the cooldown is ignored.
    serverTime += 1; remote.OnServerEvent:Fire(first, "Spin", "StarterFryer"); remote.OnServerEvent:Fire(first, "Spin", "StarterFryer")
    s = State.lastArgs[1]
    eq(s.profile.cash, 110); eq(#s.pets.owned, 1); eq(s.spin.id, "P1"); eq(s.pets.owned[1].name, "Crinkle Fry")
    eq(s.machine.pity, 1)
    local serial = s.spin.serial
    s = act("Spin", "StarterFryer"); eq(s.profile.cash, 10); eq(s.spin.id, "P2"); assert(s.spin.serial > serial)
    act("Spin", "StarterFryer"); eq(Notice.lastArgs[1], "Not enough Cash to spin.")
    eq(sync().spin, nil) -- only the spin's own snapshot carries a result
    s = act("Equip", "P1"); eq(s.pets.equipped, 1); eq(s.pets.owned[1].equipped, true); near(s.stats.perClick, 3.15)
    act("Equip", "P1"); eq(Notice.lastArgs[1], "That pet is already equipped.")
    act("Equip", "P99"); eq(Notice.lastArgs[1], "You do not own that pet.")
    act("DeletePet", "P1"); eq(Notice.lastArgs[1], "Unequip this pet before deleting it.")
    s = act("Unequip", "P1"); eq(s.pets.equipped, 0); eq(s.stats.perClick, 3)
    s = act("DeletePet", "P1"); eq(#s.pets.owned, 1); eq(s.pets.owned[1].id, "P2")
    -- Forged arguments are dropped before dispatch.
    for _, forged in ipairs({ "Nope", {}, 5, true }) do act("Spin", forged) end
    for _, forged in ipairs({ "P2;", {id="P2"}, 2, "2" }) do act("Equip", forged); act("DeletePet", forged) end
    act("Spin"); act("Equip")
    s = sync(); eq(s.profile.cash, 10); eq(#s.pets.owned, 1); eq(s.pets.equipped, 0)
    serverTime += 1; remote.OnServerEvent:Fire(second, "Sync")
    eq(#State.lastArgs[1].pets.owned, 0); eq(State.lastArgs[1].machine.pity, 0)
end)

test("machine and pets panels show server data and send only spin equip and delete requests", function()
    local gui = first.PlayerGui.FriesInterface
    local machine, petsPanel = gui.GachaPanel, gui.PetsPanel
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    local function show() replicated.FriesRemotes.State.OnClientEvent:Fire(state) end
    show()
    gui.PetsButton.Activated:Fire(); eq(petsPanel.Visible, true)
    gui.SpinButton.Activated:Fire(); eq(machine.Visible, true); eq(petsPanel.Visible, false)
    eq(machine.Title.Text, "STARTER FRYER")
    eq(machine.Caption.Text, "$100 per spin  ·  Epic or better within 48 spins")
    eq(machine.Odds.Common.Text, "COMMON  60%"); eq(machine.Odds.CommonPets.Text, "Crinkle Fry, Salt Shaker, Paper Cup")
    eq(machine.Odds.Legendary.Text, "LEGENDARY  1%"); eq(machine.Odds.LegendaryPets.Text, "Fry King")
    eq(machine.Count.Text, "PETS 1 / 50")
    eq(machine.Spin.Text, "NEED $100"); eq(machine.Spin.Active, false)
    remote.lastServerArgs = nil; machine.Spin.Activated:Fire(); eq(remote.lastServerArgs, nil)
    state.profile.cash = 500; show()
    eq(machine.Spin.Text, "SPIN  $100"); eq(machine.Spin.Active, true)
    remote.lastServerArgs = nil; machine.Spin.Activated:Fire()
    eq(remote.lastServerArgs[1], "Spin"); eq(remote.lastServerArgs[2], "StarterFryer")
    state.spin = { serial = 999, id = "P2", type = "CrinkleFry" }; show()
    eq(machine.Result.PetName.Text, "You got Crinkle Fry!"); eq(machine.Result.Bonus.Text, "COMMON  ·  +5% fries per click")
    state.spin = nil
    local owned = state.pets.owned
    local many = {}
    for n = 1, 50 do local copy = table.clone(owned[1]); copy.id = "P" .. (100 + n); table.insert(many, copy) end
    state.pets.owned = many; show()
    eq(machine.Spin.Text, "INVENTORY FULL"); eq(machine.Spin.Active, false); eq(machine.Count.Text, "PETS 50 / 50  ·  inventory full")
    state.pets.owned = owned; show()
    -- Fractional stats from pet bonuses display cleanly.
    state.stats.perClick = 3.15; show(); eq(gui.Actions.Click.Title.Text, "+3.15 fries/click")
    eq(loadModule("client/ui/Elements").number(2.1), "2.1"); eq(loadModule("client/ui/Elements").number(20), "20")
    -- Pets panel: equip, two-tap delete, unequip.
    gui.PetsButton.Activated:Fire(); eq(petsPanel.Visible, true); eq(machine.Visible, false)
    eq(petsPanel.Caption.Text, "Equipped 0 / 3  ·  1 / 50 pets"); eq(petsPanel.ListArea.Empty.Visible, false)
    local row = petsPanel.ListArea.List.P2
    eq(row.PetName.Text, "Crinkle Fry"); eq(row.Bonus.Text, "+5% fries/click"); eq(row.Equip.Text, "EQUIP")
    remote.lastServerArgs = nil; row.Equip.Activated:Fire(); eq(remote.lastServerArgs[1], "Equip"); eq(remote.lastServerArgs[2], "P2")
    remote.lastServerArgs = nil; row.Delete.Activated:Fire(); eq(remote.lastServerArgs, nil)
    row = petsPanel.ListArea.List.P2; eq(row.Delete.Text, "SURE?")
    row.Delete.Activated:Fire(); eq(remote.lastServerArgs[1], "DeletePet"); eq(remote.lastServerArgs[2], "P2")
    owned[1].equipped = true; state.pets.equipped = 1; show()
    row = petsPanel.ListArea.List.P2
    eq(row.Equip.Text, "UNEQUIP"); eq(row:FindFirstChild("Delete"), nil)
    remote.lastServerArgs = nil; row.Equip.Activated:Fire(); eq(remote.lastServerArgs[1], "Unequip")
    -- With all slots full, unequipped pets cannot be equipped.
    owned[1].equipped = false
    local function equippedCopy(id) local copy = table.clone(owned[1]); copy.id = id; copy.equipped = true; return copy end
    state.pets.owned = { owned[1], equippedCopy("P7"), equippedCopy("P8"), equippedCopy("P9") }; state.pets.equipped = 3; show()
    row = petsPanel.ListArea.List.P2
    eq(row.Equip.Active, false); remote.lastServerArgs = nil; row.Equip.Activated:Fire(); eq(remote.lastServerArgs, nil)
    eq(petsPanel.Caption.Text, "Equipped 3 / 3  ·  4 / 50 pets")
    state.pets.owned, state.pets.equipped = {}, 0; show(); eq(petsPanel.ListArea.Empty.Visible, true)
    eq(petsPanel.ListArea.List:FindFirstChild("P2"), nil)
    -- Unclaimed players cannot open either panel.
    state.hasStation = false; show()
    eq(petsPanel.Visible, false)
    gui.SpinButton.Activated:Fire(); gui.PetsButton.Activated:Fire()
    eq(machine.Visible, false); eq(petsPanel.Visible, false); eq(gui.SpinButton.Active, false); eq(gui.PetsButton.Active, false)
    replicated.FriesRemotes.State.OnClientEvent:Fire(replicated.FriesRemotes.State.lastArgs[1])
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
