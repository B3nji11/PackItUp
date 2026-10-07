-- Persistence transaction rules. No Roblox globals; the store/clock are injected.
local ProfileStore = {}
ProfileStore.__index = ProfileStore
function ProfileStore.new(store, options)
    return setmetatable({ store = store, options = options, serial = 0 }, ProfileStore)
end
function ProfileStore:load(key, token)
    local o = self.options
    local lastError = "Could not load saved progress."
    for attempt = 1, o.attempts do
        local reason = nil
        local ok, result = pcall(function()
            return self.store:UpdateAsync(key, function(old)
                reason = nil
                local now = o.now()
                if old ~= nil and (type(old) ~= "table" or not o.validate(old.data)) then
                    reason = "Saved profile is invalid or uses a newer version."
                    return nil
                end
                if old and old.lease then
                    if type(old.lease) ~= "table" or type(old.lease.expires) ~= "number"
                        or old.lease.expires ~= old.lease.expires or old.lease.expires == math.huge
                        or old.lease.expires < 0 or type(old.lease.token) ~= "string" then
                        reason = "Invalid saved session lock."
                        return nil
                    end
                    if old.lease.token ~= token and old.lease.expires > now then
                        reason = "Your previous session is still saving. Please rejoin shortly."
                        return nil
                    end
                end
                return { data = if old then o.copy(old.data) else o.newProfile(),
                    lease = { token = token, expires = now + o.leaseSeconds }, writeId = "load:" .. token }
            end)
        end)
        if ok and result and result.lease and result.lease.token == token then
            return o.copy(result.data), result.lease.expires
        end
        lastError = reason or (if ok then "Session acquisition was cancelled." else tostring(result))
        if reason and string.find(reason, "invalid") then break end
        if attempt < o.attempts then o.wait(2 ^ (attempt - 1)) end
    end
    return nil, lastError
end
function ProfileStore:save(key, token, data, release)
    local o = self.options
    if not o.validate(data) then return false, "Refusing to save invalid profile." end
    local snapshot = o.copy(data)
    self.serial += 1
    local writeId = token .. ":" .. tostring(self.serial)
    local lastError = "Could not save progress."
    for attempt = 1, o.attempts do
        local reason = nil
        local ok, result = pcall(function()
            return self.store:UpdateAsync(key, function(old)
                reason = nil
                -- A request may have committed even if its response was lost.
                if type(old) == "table" and old.writeId == writeId then return old end
                if type(old) ~= "table" or type(old.lease) ~= "table"
                    or old.lease.token ~= token or type(old.lease.expires) ~= "number"
                    or old.lease.expires <= o.now() then
                    reason = "Lost session lock."
                    return nil
                end
                return { data = o.copy(snapshot), writeId = writeId,
                    lease = if release then nil else { token = token, expires = o.now() + o.leaseSeconds } }
            end)
        end)
        if ok and result and result.writeId == writeId then
            return true, if result.lease then result.lease.expires else 0
        end
        lastError = reason or tostring(result)
        if reason then break end
        if attempt < o.attempts then o.wait(2 ^ (attempt - 1)) end
    end
    return false, lastError
end
return ProfileStore
