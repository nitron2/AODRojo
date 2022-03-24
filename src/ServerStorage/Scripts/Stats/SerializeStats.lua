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
				Stats = {
					Damage = data.Stats.Damage.Value,
					Points = data.Stats.Points.Value
				},
				AvatarIcon = data.AvatarIcon.Value,
				Color = {data.Color.Value:ToHSV()},
				Player = data.Player.Value
			}
			table.insert(serializedPlayerData, currentPlayerData)
		end
	end

	local function findPlayerData()
		for _, data in pairs(PlayerDataFolder:GetChildren()) do
			appendCurrentPlayerData(data)
		end
	end
	
	findPlayerData()
	return serializedPlayerData, serializedWorldStats
end
