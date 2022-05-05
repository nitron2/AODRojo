local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

local SecondsValue = ServerStorage.GameStages.Seconds

ServerStorage.GameStages.PreGame.Value = true
SecondsValue.Value = 10
Remotes.UpdateClientsGameState:FireAllClients("Pregame")

repeat 
	wait(1/4)
	SecondsValue.Value = SecondsValue.Value - 1 
	Remotes.UpdateClientsTime:FireAllClients(SecondsValue.Value)
until (SecondsValue.Value == 0)

ServerStorage.GameStages.PreGame.Value = false
SecondsValue.Value = 5000
ServerStorage.GameStages.InProg.Value = true
Remotes.UpdateClientsGameState:FireAllClients("InProg")

repeat 
	wait(1/4)
	SecondsValue.Value = SecondsValue.Value - 1 
	Remotes.UpdateClientsTime:FireAllClients(SecondsValue.Value)
until (SecondsValue.Value == 0)

ServerStorage.GameStages.InProg.Value = false
SecondsValue.Value = 60
ServerStorage.GameStages.GameOver.Value = false
Remotes.UpdateClientsGameState:FireAllClients("GameOver")
