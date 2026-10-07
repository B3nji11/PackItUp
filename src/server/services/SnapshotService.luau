local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Copy = require(Shared.util.Copy)
local Pricing = require(Shared.domain.Pricing)
local SnapshotService = {}
SnapshotService.__index = SnapshotService
function SnapshotService.new(data, stations, rush, network)
    return setmetatable({ data = data, stations = stations, rush = rush, network = network }, SnapshotService)
end
function SnapshotService:send(player)
    local p, runtime = self.data:get(player)
    if not p or not player.Parent then return end
    self.network.State:FireClient(player, {
        profile = Copy(p), nearStation = self.stations:near(player), volatile = self.data.volatile,
        foldStart = runtime.foldStart, rush = self.rush:snapshot(player.UserId),
        stats = { perClick = Pricing.click(p), perSecond = Pricing.automatic(p),
            clickCost = Pricing.upgrade(p.upgrades.Click), salesCost = Pricing.upgrade(p.upgrades.Sales) },
    })
end
return SnapshotService
