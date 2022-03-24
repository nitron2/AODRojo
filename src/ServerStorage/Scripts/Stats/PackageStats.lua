local statistics = {
	['PlayerStats'] = {
		['Points'] = {},
		['Damage'] = {},
		['Color'] = {},
	},
	['WorldStats'] = {
		['Health'] = nil,
		['Defecit'] = nil,
		['Max'] = nil
	}
}

return function(player, ServerStorage, PlayerData)
	local localPlayerDataSetPoints
	local localPlayerDataSetDamage
	local worldStatsInstance = ServerStorage.WorldStats
	
	local playerDataContents = PlayerData:GetChildren()
	if playerDataContents and #playerDataContents > 0 then
		for i, v in pairs(playerDataContents) do
			statistics['PlayerStats']['Points'][i] = {v.Player.Value, v.Stats.Points.Value, v.Color.Value, nil, v.Stats.Damage.Value, v.AvatarIcon.Value} --// Send damage along with points so that the game can display them.
			statistics['PlayerStats']['Damage'][i] = {v.Player.Value, v.Stats.Damage.Value, v.Color.Value, nil} 
			
			if statistics['PlayerStats']['Points'][i][1] == player then
				localPlayerDataSetPoints = statistics['PlayerStats']['Points'][i]
			end
			if statistics['PlayerStats']['Damage'][i][1] == player then
				localPlayerDataSetDamage = statistics['PlayerStats']['Damage'][i]
			end

			--print(i .. ": " .. tostring(stats['PlayerStats']['Damage'][i][1]) .. " | " .. tostring(stats['PlayerStats']['Damage'][i][2])) --players in order
		end 
		
		table.sort(statistics['PlayerStats']['Points'], function(a,b) return a[2] > b[2] end) 
		table.sort(statistics['PlayerStats']['Damage'], function(a,b) return a[2] > b[2] end)
	end
	
	statistics['WorldStats']['Health'] = worldStatsInstance.Health.Value
	statistics['WorldStats']['Defecit'] = worldStatsInstance.Defecit.Value
	statistics['WorldStats']['Max'] = worldStatsInstance.Max.Value
	
	return statistics, localPlayerDataSetPoints, localPlayerDataSetDamage
end
