local ServerStorage = game:GetService('ServerStorage')

--[[**
	This module is a single function which is called from Hotbar when the 
	user selects or shuffles through disasters for potential placement.
	It finds the correct player stats folder and changes the CurrentDisaster string value
	accordingly.
	
	@param player [t:instance] Player who wants to change their selected disaster in their own
	PlayerData folder.

	@usage Hotbar LocalScript
**--]]

return function(player, disaster)
	if disaster and type(disaster) == "string" then
		local playerData = ServerStorage.PlayerData:FindFirstChild(player.Name)
		if playerData and playerData.Player.Value == player then
			playerData.WorldModelInteraction.CurrentDisaster.Value = disaster
			--print("Changed " .. player.Name .. "'s Current Disaster to " .. disaster)
		--else
			--print("Attempted to change current disaster value: FAILED")
		end
	end
end