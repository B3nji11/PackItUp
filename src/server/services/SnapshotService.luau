local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Pricing = require(Shared.domain.Pricing)
local Upgrades = require(Shared.domain.Upgrades)
local Rebirth = require(Shared.domain.Rebirth)
local Gacha = require(Shared.domain.Gacha)
local Pets = require(Shared.domain.Pets)
local PetConfig = require(Shared.config.Pets)
local Machines = require(Shared.config.Machines)
local SnapshotService = {}
SnapshotService.__index = SnapshotService
function SnapshotService.new(data, stations, network)
    return setmetatable({ data = data, stations = stations, network = network }, SnapshotService)
end
-- Owned pets for display: name, rarity, bonuses, and equipped state. Server-computed.
local function petRows(p)
    local rows = {}
    for _, owned in ipairs(Pets.list(p)) do
        local kind = PetConfig.Types[owned.type]
        local bonuses = {}
        for _, stat in ipairs(PetConfig.StatOrder) do
            if kind.Bonuses[stat] then table.insert(bonuses, { stat = stat, amount = kind.Bonuses[stat] }) end
        end
        table.insert(rows, { id = owned.id, type = owned.type, name = kind.Name, rarity = kind.Rarity,
            rank = PetConfig.Rarities[kind.Rarity].Rank, bonuses = bonuses, equipped = Pets.isEquipped(p, owned.id) })
    end
    return rows
end
function SnapshotService:send(player, extra)
    local p = self.data:get(player)
    if not p or not player.Parent then return end
    self.network.State:FireClient(player, {
        profile = { cash = p.cash, gems = p.gems or 0, sales = p.sales, bag = { fries = p.bag.fries } },
        hasStation = self.stations:hasStation(player), nearStation = self.stations:near(player), volatile = self.data.volatile,
        stats = { perClick = Pricing.click(p), perSecond = Pricing.automatic(), perFry = Pricing.perFry(p),
            capacity = Pricing.capacity(p), saleValue = Pricing.sale(p) },
        shop = Upgrades.snapshot(p),
        rebirth = Rebirth.snapshot(p),
        machine = Gacha.snapshot(p, Machines.Order[1]),
        pets = { owned = petRows(p), equipped = #Pets.equipped(p), slots = PetConfig.EquipSlots, max = PetConfig.MaxPets },
        spin = extra and extra.spin,
    })
end
return SnapshotService
