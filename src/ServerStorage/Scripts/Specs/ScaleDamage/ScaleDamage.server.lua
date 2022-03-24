local DamageScalar = script.Parent.Parent:WaitForChild("DamageScalar")

local function onPlayersChanged()
	local numPlayers = #game.Players:GetPlayers()
	if numPlayers == 4 then
		DamageScalar.Value = 1
	elseif numPlayers == 3 then
		DamageScalar.Value = 3/2
	elseif numPlayers == 2 then
		DamageScalar.Value = 2
	elseif numPlayers == 1 then
		DamageScalar.Value = 4
	end
end

game.Players.Changed:Connect(onPlayersChanged)
