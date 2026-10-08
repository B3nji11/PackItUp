local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Pricing = require(Shared.domain.Pricing)
local Upgrades = require(Shared.domain.Upgrades)
local SnapshotService = {}
SnapshotService.__index = SnapshotService
function SnapshotService.new(data, stations, network)
    return setmetatable({ data = data, stations = stations, network = network }, SnapshotService)
end
function SnapshotService:send(player)
    local p = self.data:get(player)
    if not p or not player.Parent then return end
    self.network.State:FireClient(player, {
        profile = { cash = p.cash, sales = p.sales, bag = { fries = p.bag.fries } },
        hasStation = self.stations:hasStation(player), nearStation = self.stations:near(player), volatile = self.data.volatile,
        stats = { perClick = Pricing.click(p), perSecond = Pricing.automatic(), perFry = Pricing.perFry(p),
            capacity = Pricing.capacity(p), saleValue = Pricing.sale(p) },
        shop = Upgrades.snapshot(p),
    })
end
return SnapshotService
