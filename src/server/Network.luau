-- Transport only. All permissions and game rules are handled by ActionService.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = {}
Network.__index = Network
function Network.new()
    local folder = Instance.new("Folder")
    folder.Name = "FriesRemotes"
    local self = setmetatable({}, Network)
    for _, name in ipairs({ "Action", "State", "Notice" }) do
        local remote = Instance.new("RemoteEvent")
        remote.Name, remote.Parent = name, folder
        self[name] = remote
    end
    folder.Parent = ReplicatedStorage
    return self
end
function Network:notice(player, text, success)
    if player.Parent then self.Notice:FireClient(player, text, success) end
end
return Network
