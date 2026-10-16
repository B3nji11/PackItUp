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
-- Total equipped bonus for a stat, as a fraction (0.15 = +15%).
function Pets.bonus(p, stat)
    local total = 0
    for _, id in ipairs(Pets.equipped(p)) do
        local owned = Pets.find(p, id)
        local kind = owned and Config.Types[owned.type]
        if kind then total += kind.Bonuses[stat] or 0 end
    end
    return total
end
function Pets.full(p) return #Pets.list(p) >= Config.MaxPets end
-- Adds a new pet with the next unique ID and returns it.
function Pets.add(p, petType, machine)
    if type(p.pets) ~= "table" then p.pets = {} end
    local number = (if type(p.nextPetId) == "number" then p.nextPetId else 0) + 1
    p.nextPetId = number
    local owned = { id = "P" .. number, type = petType, machine = machine }
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
return Pets
