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
local identity = {1,0,0, 0,1,0, 0,0,1}
local function multiplyRotation(a, b)
    local result = {}
    for row=0,2 do
        for col=1,3 do
            result[row*3+col] = a[row*3+1]*b[col] + a[row*3+2]*b[3+col] + a[row*3+3]*b[6+col]
        end
    end
    return result
end
CFrame = { new = function(position) return setmetatable({Position=position, rotation=identity}, cfMeta) end }
function CFrame.Angles(x, y, z)
    local cx,sx,cy,sy,cz,sz = math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
    local rx,ry,rz = {1,0,0, 0,cx,-sx, 0,sx,cx}, {cy,0,sy, 0,1,0, -sy,0,cy}, {cz,-sz,0, sz,cz,0, 0,0,1}
    return setmetatable({Position=Vector3.zero, rotation=multiplyRotation(multiplyRotation(rx,ry),rz)}, cfMeta)
end
cfMeta.__index = {PointToWorldSpace=function(cf, point)
    local r=cf.rotation
    return cf.Position + Vector3.new(r[1]*point.X+r[2]*point.Y+r[3]*point.Z,
        r[4]*point.X+r[5]*point.Y+r[6]*point.Z, r[7]*point.X+r[8]*point.Y+r[9]*point.Z)
end}
cfMeta.__mul = function(a,b)
    return setmetatable({Position=a:PointToWorldSpace(b.Position), rotation=multiplyRotation(a.rotation,b.rotation)}, cfMeta)
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
    if class == "Part" then
        values.CanCollide, values.CanTouch, values.CanQuery, values.CastShadow = true, true, true, true
        values.Transparency, values.Shape = 0, Enum.PartType.Block
    end
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
            -- Roblox couples wrapping/scaling: scaled text always wraps, and turning
            -- wrapping off disables scaling. A plain property bag missed this bug.
            if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
                if key == "TextScaled" and value then values.TextWrapped = true
                elseif key == "TextWrapped" and not value then values.TextScaled = false end
            end
            if key == "CFrame" then values.Position = value.Position end
        end,
    })
    return object
end
function instanceMethods:FindFirstChild(name)
    for _, child in ipairs(self._children or {}) do if child.Name == name then return child end end
    return nil
end
function instanceMethods:GetChildren() return table.clone(self._children or {}) end
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
    for _, action in ipairs({"Pack", "Sell", "Return", "Upgrade"}) do
        serverTime += 1; remote.OnServerEvent:Fire(first, action, if action == "Upgrade" then "FriesPerClick" else nil)
        eq(replicated.FriesRemotes.Notice.lastArgs[2], false)
    end
    eq(first.Character.HumanoidRootPart.Position.Magnitude, 0)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    eq(replicated.FriesRemotes.State.lastArgs[1].profile.bag.fries, 0)
    eq(replicated.FriesRemotes.State.lastArgs[1].shop[1].level, 0)
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

test("all six restaurants share the approved skin and keep their gameplay objects", function()
    local world = workspace.FriesRestaurant
    local count = #world.Station1.RestaurantDecor:GetChildren()
    for i=1,6 do
        local station = world["Station"..i]
        local origin, direction = station.Plot.Position, if i > 3 then -1 else 1
        eq(station:GetAttribute("VisualStyle"), "CoralGold")
        eq(#station.RestaurantDecor:GetChildren(), count)
        near(station.Counter.Position.X, origin.X)
        near(station.Counter.Position.Z, origin.Z - direction)
        near(station.Machine.Position.Y, 4.9); near(station.Bag.Position.Y, 4.65)
        near(station.ClaimPoint.Position.Z, origin.Z + 18 * direction)
        eq(station.ClaimPoint.ClaimRestaurant.MaxActivationDistance, 10)
        for n=1,10 do assert(station:FindFirstChild("Fry"..n)) end
        near(station.RestaurantPlaque.Position.Y, 10.9)
        near(station.RestaurantPlaque.Position.Z, origin.Z + 20.35 * direction)
        assert(station.RestaurantPlaque.WallArt.TextLabel.Text ~= "")
        -- South-facing plots rotate the sign and sloping canopy as one skin.
        local brand=station.RestaurantDecor.BrandFace
        local facing=brand.CFrame:PointToWorldSpace(Vector3.new(0,0,1))-brand.Position
        near(facing.Z, direction)
        local canopy=station.AwningStripe1
        local slope=canopy.CFrame:PointToWorldSpace(Vector3.new(0,0,3))-canopy.Position
        assert(slope.Y < 0 and slope.Z * direction > 0)
    end
end)

local function halfExtents(part)
    local r,s=part.CFrame.rotation,part.Size
    return (math.abs(r[1])*s.X+math.abs(r[2])*s.Y+math.abs(r[3])*s.Z)/2,
        (math.abs(r[4])*s.X+math.abs(r[5])*s.Y+math.abs(r[6])*s.Z)/2,
        (math.abs(r[7])*s.X+math.abs(r[8])*s.Y+math.abs(r[9])*s.Z)/2
end
local function decorative(part)
    eq(part.ClassName, "Part")
    assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery)
    assert(not part.CastShadow)
    eq(part.Material, Enum.Material.SmoothPlastic)
    for _, gui in ipairs(part:GetChildren()) do
        eq(gui.ClassName, "SurfaceGui"); eq(gui.AlwaysOnTop, false)
    end
end

test("both rows keep bounded noncolliding art and clear entrance and counter routes", function()
    for i=1,6 do
        local station = workspace.FriesRestaurant["Station"..i]
        local art, direction = station.RestaurantDecor, if i > 3 then -1 else 1
        local count = 0
        for _, child in ipairs(art:GetChildren()) do
            decorative(child)
            count += 1
            local hx,hy,hz = halfExtents(child)
            local x,y,z = (child.Position.X-station.Plot.Position.X)*direction, child.Position.Y,
                (child.Position.Z-station.Plot.Position.Z)*direction
            assert(math.abs(x)+hx <= 26 and math.abs(z)+hz <= 26, child.Name.." escapes the plot")
            local blocksLane = x+hx > -6 and x-hx < 6 and z+hz > 2 and z-hz < 24 and y+hy > 0.7 and y-hy < 8
            assert(not blocksLane, child.Name.." covers the entrance/counter approach")
        end
        assert(count > 100 and count <= 260, "Keep the repeated skin within its art budget")
        for n=1,10 do
            local stripe=station["AwningStripe"..n]
            assert(not stripe.CanCollide and not stripe.CanTouch and not stripe.CanQuery)
            assert(stripe.Position.Y > 13)
        end
        local top = art.SignFry3Core
        assert(top.Position.Y + top.Size.Y/2 > 30)
        eq(art.BrandFace.WallArt.TextLabel.Text, "FRY DAY!")
        assert(art.BrandFace.Position.Y + art.BrandFace.Size.Y/2 < station.RoofCap.Position.Y)
    end
end)

test("district decoration keeps the original spawn paths boundary and central promenade clear", function()
    local world=workspace.FriesRestaurant
    eq(world:GetAttribute("DistrictStyle"), "CoralGold")
    near(world.PlazaEntrance.Position.X,0); near(world.PlazaEntrance.Position.Z,0)
    eq(world.PlazaEntrance.Neutral, true)
    local count=0
    for _, child in ipairs(world.PlazaDecor:GetChildren()) do
        decorative(child); count += 1
        local hx,hy,hz=halfExtents(child)
        local x,y,z=child.Position.X,child.Position.Y,child.Position.Z
        assert(math.abs(x)+hx <= 111 and math.abs(z)+hz <= 97, child.Name.." escapes district bounds")
        local tall=y+hy > 0.7 and y-hy < 8
        assert(not (tall and x+hx > -98 and x-hx < 98 and z+hz > -5.5 and z-hz < 5.5),
            child.Name.." covers the central promenade")
        for i=1,6 do
            local path=world["PlotPath"..i]
            assert(not (tall and math.abs(x-path.Position.X) < hx+6 and math.abs(z-path.Position.Z) < hz+6),
                child.Name.." covers a restaurant approach")
        end
    end
    assert(count > 150 and count <= 400, "Keep shared decoration within its art budget")
    for _, side in ipairs({"North","South","East","West"}) do
        assert(world.Boundary[side].CanCollide)
    end
    for _, child in ipairs(world:GetChildren()) do
        if child.Name=="Planter" or child.Name=="PlazaBench" then
            eq(child.Transparency,1); assert(child.CanCollide)
        end
    end
end)

test("bright diner interiors keep both rows clear and playable", function()
    local lighting = services.Lighting
    assert(lighting.Ambient.R >= 150/255)
    assert(lighting.Ambient.G >= 148/255)
    assert(lighting.Ambient.B >= 140/255)
    near(lighting.OutdoorAmbient.R,148/255); near(lighting.Brightness,1.5)
    near(lighting.ClockTime,13.5); near(lighting.ExposureCompensation,-0.25)
    local counts = {}
    for i=1,6 do
        local station=workspace.FriesRestaurant["Station"..i]
        eq(station:GetAttribute("InteriorStyle"),"WarmDiner")
        local art,direction=station.InteriorDecor,if i>3 then -1 else 1
        local lamps,parts=0,0
        for _, child in ipairs(art:GetChildren()) do
            parts += 1
            eq(child.ClassName,"Part")
            assert(child.Anchored and not child.CanCollide and not child.CanTouch and not child.CanQuery and not child.CastShadow)
            eq(child.Material,Enum.Material.SmoothPlastic)
            local hx,hy,hz=halfExtents(child)
            local x,y,z=(child.Position.X-station.Plot.Position.X)*direction,child.Position.Y,
                (child.Position.Z-station.Plot.Position.Z)*direction
            assert(math.abs(x)+hx <= 21 and z-hz >= -20 and z+hz <= 14,child.Name.." leaves the room")
            assert(y+hy <= 18.5,child.Name.." protrudes through the ceiling")
            local blocksRoute=x+hx > -6 and x-hx < 6 and z+hz > 2 and z-hz < 24 and y+hy > 0.7 and y-hy < 8
            assert(not blocksRoute,child.Name.." covers the counter approach")
            for _, detail in ipairs(child:GetChildren()) do
                if detail.ClassName=="SurfaceLight" then
                    lamps += 1
                    assert(detail.Enabled and not detail.Shadows and detail.Brightness >= 0.45 and detail.Brightness <= 0.6)
                    eq(detail.Face,Enum.NormalId.Left)
                    local down=child.CFrame:PointToWorldSpace(Vector3.new(-1,0,0))-child.Position
                    near(down.Y,-1)
                    assert(child.Position.Y-hy >= 13)
                else
                    eq(detail.ClassName,"SurfaceGui"); eq(detail.AlwaysOnTop,false)
                end
            end
        end
        eq(lamps,2)
        assert(parts > 100 and parts <= 260,"Keep the interior detail budget bounded")
        counts[i]=parts; eq(counts[i],counts[1])
        for n=1,4 do
            local light=station["LightPanel"..n].InteriorLight
            near(light.Brightness,1.2)
            assert(light.Color.R > light.Color.B and light.Enabled)
        end
        eq(station.RestaurantDecor.HappyFriesPoster.WallArt.Enabled,false)
        -- The kitchen/booths are visual skins; the original station remains the target.
        assert(station.Counter.CanCollide and station.Bag.CanCollide)
        for n=1,10 do assert(station:FindFirstChild("Fry"..n)) end
    end
end)

test("the shared art helper retains engine-coupled wrapping and automatic text sizing", function()
    local probe=Instance.new("TextLabel")
    probe.TextScaled=true; eq(probe.TextWrapped,true)
    probe.TextWrapped=false; eq(probe.TextScaled,false)
    local art=loadModule("server/world/ArtPrimitives")
    local model=Instance.new("Model")
    local decor=art.new(model)
    local face=decor.piece("CaptionProbe",Vector3.new(17.4,6,0.1),Vector3.zero,Color3.fromRGB(0,0,0))
    local caption=decor.label(face,"GOLDEN\nBITES",Color3.fromRGB(255,255,255))
    eq(caption.TextScaled,true,"The shared art helper must not disable scaling after creating a label")
    eq(caption.TextWrapped,true)
    local replacement=decor.label(face,"REPEAT",Color3.fromRGB(255,255,255))
    eq(replacement.TextScaled,true); eq(replacement.TextWrapped,true)
end)

test("world lettering fills an aspect-correct canvas below the native font cap", function()
    local world=workspace.FriesRestaurant
    local labels=0
    local function visit(node)
        if node.ClassName=="SurfaceGui" then
            local label=assert(node:FindFirstChildOfClass("TextLabel"))
            local limit=assert(label:FindFirstChildOfClass("UITextSizeConstraint"),"World text needs an explicit scale limit")
            eq(label.TextScaled,true); eq(label.TextWrapped,true); eq(limit.MinTextSize,1)
            near(node.CanvasSize.Y,96); eq(limit.MaxTextSize,96)
            eq(node.SizingMode,Enum.SurfaceGuiSizingMode.FixedSize)
            local size,face=node.Parent.Size,node.Face
            local width,height=size.X,size.Y
            if face==Enum.NormalId.Left or face==Enum.NormalId.Right then width=size.Z
            elseif face==Enum.NormalId.Top or face==Enum.NormalId.Bottom then height=size.Z end
            near(node.CanvasSize.X/node.CanvasSize.Y,width/height)
            eq(node.LightInfluence,0); eq(node.AlwaysOnTop,false)
            near(label.Size.X.Scale,1); near(label.Size.Y.Scale,1)
            labels += 1
        end
        for _,child in ipairs(node:GetChildren()) do visit(child) end
    end
    visit(world)
    assert(labels >= 100)
    -- Large murals and resized live plaques use the same full-face layout as small labels.
    local mural=world.MuralWall
    near(mural.WallArt.CanvasSize.X/mural.WallArt.CanvasSize.Y,38/14)
    for i=1,6 do
        local station=world["Station"..i]
        near(station.RestaurantPlaque.Size.Y,2.5)
        near(station.RestaurantDecor.BagBadge.Size.Y,1.15)
        near(station.RestaurantDecor.WelcomeMat.Size.Z,4.6)
        eq(station.RestaurantDecor.WelcomeMat.WallArt.TextLabel.Text,"HELLO,\nFRY FRIEND!")
        near(station.InteriorDecor.HouseSubtitle.Size.Y,0.95)
        eq(station.InteriorDecor.HouseSubtitle.WallArt.TextLabel.Text,"HOT & CRISPY")
        near(station.InteriorDecor.GoldenCaption.Size.Y,2)
        near(station.InteriorDecor.HappyCaption.Size.Y,1.05)
    end
end)

test("restored sign proportions keep scaled text without the triple-size enlargement", function()
    for i=1,6 do
        local station=workspace.FriesRestaurant["Station"..i]
        local art=station.InteriorDecor
        near(art.HouseTitle.Size.Y,1.45)
        near(art.HouseSubtitle.Size.Y,0.95)
        near(art.HouseMenuFace.Size.X,15); near(art.HouseMenuFace.Size.Y,4.4)
        near(station.RestaurantDecor.BrandFace.Size.X,24.5)
        near(station.RestaurantDecor.BrandFace.Size.Y,2.9)
        local titleBottom=art.HouseTitle.Position.Y-art.HouseTitle.Size.Y/2
        local subtitleTop=art.HouseSubtitle.Position.Y+art.HouseSubtitle.Size.Y/2
        assert(titleBottom > subtitleTop)
        for _,child in ipairs(art:GetChildren()) do
            if child.Name=="HouseStep" then
                near(child.Size.Y,0.98); near(child.Size.X,3.9)
                assert(child.Position.Y+child.Size.Y/2 < art.HouseSubtitle.Position.Y-art.HouseSubtitle.Size.Y/2)
                assert(child.Position.Y-child.Size.Y/2 > art.PrepJarLid.Position.Y+art.PrepJarLid.Size.X/2)
            end
        end
        local plaque=station.RestaurantDecor.PlaqueBorderCore
        assert(plaque.Position.Y-plaque.Size.Y/2 > 8)
        assert(plaque.Position.Y+plaque.Size.Y/2 < 12.425)
        assert(station.RestaurantDecor.BagBadge.Position.Y+station.RestaurantDecor.BagBadge.Size.Y/2 < station.Fry1.Position.Y)
        assert(station.Ceiling.Color.R > 0.85 and station.Ceiling.Color.G > 0.85)
    end
end)

test("cute details decorate every plot without blocking play or increasing light intensity", function()
    local firstCount
    for i=1,6 do
        local station=workspace.FriesRestaurant["Station"..i]
        local art,direction=station.CuteDecor,if i>3 then -1 else 1
        eq(station:GetAttribute("DetailStyle"),"FryFriends")
        local count,clouds,flowers,pennants,bows=0,0,0,0,0
        for _,child in ipairs(art:GetChildren()) do
            decorative(child); count+=1
            local hx,hy,hz=halfExtents(child)
            local x,y,z=(child.Position.X-station.Plot.Position.X)*direction,child.Position.Y,
                (child.Position.Z-station.Plot.Position.Z)*direction
            assert(math.abs(x)+hx<=26 and math.abs(z)+hz<=26,child.Name.." leaves its plot")
            assert(y-hy>=0.6 and y+hy<=18.5,child.Name.." breaks floor/ceiling clearance")
            local blocksRoute=x+hx > -6 and x-hx < 6 and z+hz > 2 and z-hz < 24 and y+hy > 0.7 and y-hy < 8
            assert(not blocksRoute,child.Name.." covers the entrance/counter approach")
            local bag=station.Bag
            assert(not (math.abs(child.Position.X-bag.Position.X)<hx+1 and math.abs(child.Position.Z-bag.Position.Z)<hz+0.7 and y-hy<6.1 and y+hy>3.8),child.Name.." covers the live bag")
            if child.Name=="CloudPuff" then clouds+=1 end
            if child.Name=="TableFlowerCentre" then flowers+=1 end
            if child.Name=="CandyPennant" then pennants+=1; assert(y-hy>12) end
            if child.Name=="PillarBowKnot" then bows+=1 end
        end
        assert(count>=120 and count<=180,"Keep repeated props within a small fixed budget")
        if not firstCount then firstCount=count end; eq(count,firstCount)
        eq(clouds,6); eq(flowers,2); eq(pennants,9); eq(bows,2)
        assert(art.BunBuddy and art.MascotMedallion and art.CornerPlantLeaf and art.BoothPillow)
        local smile=art.TopiarySmile
        local outward=smile.CFrame:PointToWorldSpace(Vector3.new(0,0,1))-smile.Position
        near(outward.Z,direction)
        near(station.LightPanel1.InteriorLight.Brightness,1.2)
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

test("client has click sell teleport and the upgrade shop with no other feature panels", function()
    players.LocalPlayer=first
    loadModule("client/Main")
    local gui = first.PlayerGui:FindFirstChild("FriesInterface")
    assert(gui and gui.Actions.Click and gui.Actions.Sell and gui.Teleport and gui.UpgradesButton)
    eq(gui.UpgradeShop.Visible, false)
    eq(gui:FindFirstChild("Panel"), nil); eq(gui:FindFirstChild("Navigation"), nil)
    local count = 0
    local function visit(node)
        if node.ClassName == "TextButton" then count += 1 end
        for _, child in ipairs(node._children or {}) do visit(child) end
    end
    visit(gui); eq(count, 8) -- Click, Sell, Teleport, Upgrades, Close, and three Buy buttons
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
        if viewport.Y >= 500 then eq(cash.Position.Y.Offset, 0) end
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
        local upgrades = rect(gui.UpgradesButton)
        assert(upgrades[1] >= 0 and upgrades[2] >= 0 and upgrades[3] <= viewport.X and upgrades[4] <= height)
        assert(upgrades[4] + 12 <= top + 0.001 or apart(upgrades, rect(gui.Actions, scale)))
        for _, other in ipairs({gui.Teleport, gui.Guidance, cash}) do assert(apart(upgrades, rect(other)), other.Name) end
        assert(gui.UpgradesButton.Size.Y.Offset >= 36)
        local panelScale = gui.UpgradeShop:FindFirstChildOfClass("UIScale").Scale
        assert(gui.UpgradeShop.Size.X.Offset * panelScale <= viewport.X - 32 + 0.001)
        assert(gui.UpgradeShop.Size.Y.Offset * panelScale <= height - 24 + 0.001)
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

test("server upgrade purchases check claim cash and cooldown and apply each level once", function()
    local State, Notice = replicated.FriesRemotes.State, replicated.FriesRemotes.Notice
    local function sync() serverTime += 1; remote.OnServerEvent:Fire(first, "Sync"); return State.lastArgs[1] end
    local function fill(capacity)
        local state = sync()
        while state.profile.bag.fries < capacity do
            serverTime += 0.3; remote.OnServerEvent:Fire(first, "Pack"); state = sync()
        end
        return state
    end
    local function sellRound(capacity) fill(capacity); serverTime += 1; remote.OnServerEvent:Fire(first, "Sell") end
    local s = sync()
    eq(s.profile.cash, 20); eq(s.profile.bag.fries, 20)
    eq(#s.shop, 3); eq(s.shop[1].id, "FriesPerClick"); eq(s.shop[1].cost, 25); eq(s.stats.capacity, 20)
    Notice.lastArgs = nil
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "FriesPerClick")
    eq(Notice.lastArgs[2], false); s = State.lastArgs[1]; eq(s.profile.cash, 20); eq(s.shop[1].level, 0)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "FriesPerClick")
    s = State.lastArgs[1]; eq(s.profile.cash, 5); eq(s.shop[1].level, 1); eq(s.stats.perClick, 2); eq(s.shop[1].cost, 30)
    -- Forged arguments are dropped before dispatch.
    for _, forged in ipairs({ {id="FriesPerClick"}, 25, "Click", "upgrades" }) do
        serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", forged)
    end
    for _ = 1, 5 do sellRound(20) end
    s = sync(); eq(s.profile.cash, 55)
    -- A second request inside the purchase cooldown is ignored.
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "MoneyPerFry")
    remote.OnServerEvent:Fire(first, "Upgrade", "MoneyPerFry")
    s = sync(); eq(s.profile.cash, 15); eq(s.shop[2].level, 1); near(s.stats.perFry, 0.55); eq(s.stats.saleValue, 11)
    for _ = 1, 3 do sellRound(20) end
    s = fill(20); eq(s.profile.cash, 48); eq(s.profile.bag.fries, 20)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sell") -- 59 Cash
    s = fill(20)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Upgrade", "BagCapacity")
    s = State.lastArgs[1]; eq(s.profile.cash, 9); eq(s.stats.capacity, 25); eq(s.profile.bag.fries, 20)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
    eq(Notice.lastArgs[1], "Fill your bag first."); eq(sync().profile.cash, 9)
    s = fill(25); eq(s.profile.bag.fries, 25)
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sell")
    s = State.lastArgs[1]; eq(s.profile.cash, 22); eq(s.profile.bag.fries, 0) -- 25 x $0.55 = $13.75 -> $13
    -- The other player's Cash and levels are untouched.
    serverTime += 1; remote.OnServerEvent:Fire(second, "Sync")
    eq(State.lastArgs[1].shop[1].level, 0); eq(State.lastArgs[1].stats.capacity, 20)
end)

test("upgrade shop shows server rows greys unaffordable upgrades and sends only track names", function()
    local gui = first.PlayerGui.FriesInterface
    local shop = gui.UpgradeShop
    serverTime += 1; remote.OnServerEvent:Fire(first, "Sync")
    local state = loadModule("shared/util/Copy")(replicated.FriesRemotes.State.lastArgs[1])
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(shop.Visible, false)
    gui.UpgradesButton.Activated:Fire(); eq(shop.Visible, true)
    eq(shop.FriesPerClick.Level.Text, "LEVEL 1"); eq(shop.FriesPerClick.Value.Text, "2 → 3 fries/click")
    eq(shop.MoneyPerFry.Value.Text, "$0.55 → $0.60 per fry"); eq(shop.BagCapacity.Value.Text, "25 → 30 fries per bag")
    eq(shop.FriesPerClick.Buy.Text, "$30"); eq(shop.MoneyPerFry.Buy.Text, "$48"); eq(shop.BagCapacity.Buy.Text, "$63")
    eq(gui.Actions.Sell.Title.Text, "0 / 25"); eq(gui.Actions.Click.Title.Text, "+2 fries/click")
    -- $22 affords nothing: every Buy button is inactive and sends nothing.
    for _, id in ipairs({"FriesPerClick", "MoneyPerFry", "BagCapacity"}) do
        eq(shop[id].Buy.Active, false)
        remote.lastServerArgs = nil; shop[id].Buy.Activated:Fire(); eq(remote.lastServerArgs, nil)
    end
    state.profile.cash = 30
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(shop.FriesPerClick.Buy.Active, true); eq(shop.MoneyPerFry.Buy.Active, false)
    remote.lastServerArgs = nil; shop.FriesPerClick.Buy.Activated:Fire()
    eq(remote.lastServerArgs[1], "Upgrade"); eq(remote.lastServerArgs[2], "FriesPerClick"); eq(remote.lastServerArgs[3], nil)
    shop.Close.Activated:Fire(); eq(shop.Visible, false)
    state.profile.bag.fries = 25
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    eq(gui.Actions.Sell.Title.Text, "SELL BAG"); eq(gui.Actions.Sell.Detail.Text, "+$13 CASH")
    -- Unclaimed players cannot open the shop.
    state.hasStation = false
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    gui.UpgradesButton.Activated:Fire(); eq(shop.Visible, false); eq(gui.UpgradesButton.Active, false)
    state.hasStation = true
    replicated.FriesRemotes.State.OnClientEvent:Fire(state)
    gui.UpgradesButton.Activated:Fire(); eq(shop.Visible, true)
    state.hasStation = false
    replicated.FriesRemotes.State.OnClientEvent:Fire(state); eq(shop.Visible, false)
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
