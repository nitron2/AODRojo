local ServerStorage = game:GetService('ServerStorage')
local PlayerData = ServerStorage.PlayerData
local WorldStats = ServerStorage.WorldStats

local statistics = {
	PlayerStats = {
		--[[{Player = nil,
		AvatarIcon = nil,
		Color = nil,
		Damage = nil}]]--
	},
	WorldStats = {
		Health = nil,
		Defecit = nil,
		Max = nil
	}
}

return function(player)
	local playerDataContents = PlayerData:GetChildren()

	if playerDataContents and #playerDataContents > 0 then
		for _, playerData : Folder in pairs(playerDataContents) do
			table.insert(statistics.PlayerStats, {
				Player = playerData.Player.Value,
				AvatarIcon = playerData.AvatarIcon.Value,
				Color = playerData.Color.Value,
				Damage = playerData.Damage.Value
			})
		end 
		table.sort(statistics['PlayerStats']['Damage'], function(a,b) return a[2] > b[2] end)
	end
	
	statistics['WorldStats']['Health'] = WorldStats.Health.Value
	statistics['WorldStats']['Defecit'] = WorldStats.Defecit.Value
	statistics['WorldStats']['Max'] = WorldStats.Max.Value
	
	return statistics
end
