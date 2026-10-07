local Store = loadModule("server/storage/ProfileStore")
local Profile = loadModule("shared/domain/Profile")
local Copy = loadModule("shared/util/Copy")
local function fixture()
    local clock = { now = 100 }
    local db = { records = {}, errors = 0, loseResponse = false }
    function db:UpdateAsync(key, fn)
        if self.errors > 0 then self.errors -= 1; error("Transient network error") end
        local result = fn(Copy(self.records[key]))
        if result == nil then return nil end
        self.records[key] = Copy(result)
        if self.loseResponse then self.loseResponse = false; error("Response lost after commit") end
        return Copy(result)
    end
    local repository = Store.new(db, { validate = Profile.validate, copy = Copy, newProfile = Profile.new,
        now = function() return clock.now end, wait = function() end, attempts = 3, leaseSeconds = 180 })
    return repository, db, clock
end
test("save/load round trip retains cash inventory full bag and pity", function()
    local store = fixture()
    local p = store:load("1", "A")
    p.cash = 100; p.owned.ufo = true; p.equipped.Machine = "ufo"; p.pity.Bag = 9
    loadModule("shared/domain/Packing").add(p, 20, function() return 0.99 end)
    eq(store:save("1", "A", p, true), true)
    local restored = store:load("1", "B")
    eq(restored.cash, 100); eq(restored.owned.ufo, true); eq(restored.pity.Bag, 9)
    eq(restored.bag.variant, "golden"); assert(Profile.validate(restored))
end)
test("second live session cannot acquire active lease", function()
    local store, db = fixture()
    store:load("1", "A")
    eq(store:load("1", "B"), nil)
    eq(db.records["1"].lease.token, "A")
end)
test("expired lease can be recovered but stale writer cannot save", function()
    local store, db, clock = fixture()
    local old = store:load("1", "A")
    clock.now = 281
    local fresh = store:load("1", "B"); assert(fresh)
    old.cash = 999; eq(store:save("1", "A", old, true), false)
    eq(db.records["1"].data.cash, 0); eq(db.records["1"].lease.token, "B")
end)
test("transient storage failures retry successfully", function()
    local store, db = fixture(); db.errors = 2
    local p = store:load("1", "A"); assert(p)
    db.errors = 2; p.cash = 25
    eq(store:save("1", "A", p, false), true); eq(db.records["1"].data.cash, 25)
end)
test("exhausted load failures do not create fallback data", function()
    local store, db = fixture(); db.errors = 3
    eq(store:load("1", "A"), nil); eq(db.records["1"], nil)
end)
test("corrupt and future records are not overwritten", function()
    local store, db = fixture()
    db.records["1"] = { data = { version = 2, cash = 777 } }
    eq(store:load("1", "A"), nil)
    eq(db.records["1"].data.cash, 777); eq(db.records["1"].data.version, 2)
end)
test("failed writes preserve last committed data", function()
    local store, db = fixture(); local p = store:load("1", "A")
    p.cash = 100; db.errors = 3
    eq(store:save("1", "A", p, false), false); eq(db.records["1"].data.cash, 0)
end)
test("lost response after final save is recovered idempotently", function()
    local store, db = fixture(); local p = store:load("1", "A"); p.cash = 42
    db.loseResponse = true
    eq(store:save("1", "A", p, true), true)
    eq(db.records["1"].data.cash, 42); eq(db.records["1"].lease, nil)
end)
test("lease renewal does not mutate the caller or saved snapshots", function()
    local store, db, clock = fixture(); local p, expires = store:load("1", "A")
    eq(expires, 280); clock.now = 145
    local ok, renewed = store:save("1", "A", p, false)
    eq(ok, true); eq(renewed, 325)
    p.cash = 999; eq(db.records["1"].data.cash, 0)
end)
test("invalid in-memory profiles cannot overwrite a valid save", function()
    local store, db = fixture(); local p = store:load("1", "A")
    p.tickets = -100; eq(store:save("1", "A", p, false), false)
    eq(db.records["1"].data.tickets, 0)
end)
