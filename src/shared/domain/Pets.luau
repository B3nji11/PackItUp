-- Owned pets, equipping, deleting, and equipped stat bonuses. Pure rules.
local Config = require(script.Parent.Parent.config.Pets)
local Pets = {}
function Pets.list(p) return if type(p) == "table" and type(p.pets) == "table" then p.pets else {} end
function Pets.equipped(p) return if type(p) == "table" and type(p.equippedPets) == "table" then p.equippedPets else {} end
function Pets.find(p, id)
    for index, owned in ipairs(Pets.list(p)) do if owned.id == id then return owned, index end end
    return nil
end
function Pets.isEquipped(p, id)
    for index, equippedId in ipairs(Pets.equipped(p)) do if equippedId == id then return true, index end end
    return false
end
function Pets.isPetId(id) return type(id) == "string" and #id <= 16 and string.match(id, "^P%d+$") ~= nil end
-- Golden pets give GoldenMultiplier x their normal bonus.
function Pets.multiplier(owned) return if owned.golden then Config.GoldenMultiplier else 1 end
function Pets.petBonus(owned, stat)
    local kind = Config.Types[owned.type]
    return if kind then (kind.Bonuses[stat] or 0) * Pets.multiplier(owned) else 0
end
-- Total equipped bonus for a stat, as a fraction (0.15 = +15%).
function Pets.bonus(p, stat)
    local total = 0
    for _, id in ipairs(Pets.equipped(p)) do
        local owned = Pets.find(p, id)
        if owned then total += Pets.petBonus(owned, stat) end
    end
    return total
end
function Pets.full(p) return #Pets.list(p) >= Config.MaxPets end
-- Adds a new pet with the next unique ID and returns it.
function Pets.add(p, petType, machine, golden)
    if type(p.pets) ~= "table" then p.pets = {} end
    local number = (if type(p.nextPetId) == "number" then p.nextPetId else 0) + 1
    p.nextPetId = number
    local owned = { id = "P" .. number, type = petType, machine = machine }
    if golden then owned.golden = true end
    table.insert(p.pets, owned)
    return owned
end
function Pets.equip(p, id)
    if not Pets.find(p, id) then return false, "You do not own that pet." end
    if Pets.isEquipped(p, id) then return false, "That pet is already equipped." end
    if #Pets.equipped(p) >= Config.EquipSlots then return false, "All pet slots are full. Unequip a pet first." end
    if type(p.equippedPets) ~= "table" then p.equippedPets = {} end
    table.insert(p.equippedPets, id)
    return true
end
function Pets.unequip(p, id)
    local equipped, index = Pets.isEquipped(p, id)
    if not equipped then return false, "That pet is not equipped." end
    table.remove(p.equippedPets, index)
    return true
end
function Pets.delete(p, id)
    local owned, index = Pets.find(p, id)
    if not owned then return false, "You do not own that pet." end
    if Pets.isEquipped(p, id) then return false, "Unequip this pet before deleting it." end
    table.remove(p.pets, index)
    return true, owned
end
local function isBulkRarity(rarity)
    return type(rarity) == "string" and table.find(Config.BulkRarities, rarity) ~= nil
end
Pets.isBulkRarity = isBulkRarity
function Pets.isPetType(petType) return type(petType) == "string" and Config.Types[petType] ~= nil end
-- Unequipped, non-golden copies of a pet type, oldest first.
local function mergeCandidates(p, petType)
    local list = {}
    for _, owned in ipairs(Pets.list(p)) do
        if owned.type == petType and not owned.golden and not Pets.isEquipped(p, owned.id) then table.insert(list, owned) end
    end
    return list
end
-- Pet types that can be merged now, rarest first.
function Pets.mergeable(p)
    local rows = {}
    for petType, kind in pairs(Config.Types) do
        local count = #mergeCandidates(p, petType)
        if count >= Config.MergeCount then
            table.insert(rows, { type = petType, name = kind.Name, count = count, rank = Config.Rarities[kind.Rarity].Rank })
        end
    end
    table.sort(rows, function(a, b) if a.rank ~= b.rank then return a.rank > b.rank end return a.name < b.name end)
    return rows
end
-- MergeCount unequipped copies become one Golden pet with a new ID.
function Pets.merge(p, petType)
    local candidates = mergeCandidates(p, petType)
    if #candidates < Config.MergeCount then
        return false, "You need " .. Config.MergeCount .. " unequipped copies of that pet to merge."
    end
    local machine = candidates[1].machine
    for n = 1, Config.MergeCount do
        local _, index = Pets.find(p, candidates[n].id)
        table.remove(p.pets, index)
    end
    return true, Pets.add(p, petType, machine, true)
end
-- Deletes every unequipped, non-golden pet of a bulk rarity. Returns how many.
function Pets.deleteRarity(p, rarity)
    if not isBulkRarity(rarity) then return false, "That rarity cannot be bulk deleted." end
    local kept, removed = {}, 0
    for _, owned in ipairs(Pets.list(p)) do
        local kind = Config.Types[owned.type]
        if kind.Rarity == rarity and not owned.golden and not Pets.isEquipped(p, owned.id) then removed += 1
        else table.insert(kept, owned) end
    end
    if removed == 0 then return false, "No unequipped " .. rarity .. " pets to delete." end
    p.pets = kept
    return true, removed
end
function Pets.autoDeletes(p, rarity) return type(p.autoDelete) == "table" and p.autoDelete[rarity] == true end
function Pets.toggleAutoDelete(p, rarity)
    if not isBulkRarity(rarity) then return false, "That rarity cannot be auto-deleted." end
    if type(p.autoDelete) ~= "table" then p.autoDelete = {} end
    p.autoDelete[rarity] = if Pets.autoDeletes(p, rarity) then nil else true
    return true, p.autoDelete[rarity] == true
end
return Pets
