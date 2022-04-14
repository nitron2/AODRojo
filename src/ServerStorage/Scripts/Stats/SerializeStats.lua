--Why do we need to serialize stats in the first place? Hmm. Question for another day.

local ServerStorage = game:GetService('ServerStorage')
local PlayerDataFolder = ServerStorage.PlayerData
local WorldStats = ServerStorage.WorldStats

return function(player)	
	local serializedPlayerData = {}
	local serializedWorldStats = {
		Defecit = WorldStats.Defecit.Value,
		Health = WorldStats.Health.Value,
		Max = WorldStats.Max.Value
	}

	local function appendCurrentPlayerData(data)
		if data:IsA('Folder') then
			local currentPlayerData = {
				Damage = data.Damage.Value,
				AvatarIcon = data.AvatarIcon.Value,
				Color = {data.Color.Value:ToHSV()},
				Player = data.Player.Value
			}
			table.insert(serializedPlayerData, currentPlayerData)
		end
	end

	--Find All Players' Data
	for _, data in pairs(PlayerDataFolder:GetChildren()) do
		appendCurrentPlayerData(data)
	end
	
	return serializedPlayerData, serializedWorldStats
end
