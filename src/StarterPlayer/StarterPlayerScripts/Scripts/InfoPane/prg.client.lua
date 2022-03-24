repeat wait() until script.Parent.Parent.Parent.ClientMainLoaded.Value == true
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage.Remotes
local TabstatsController = require(script.Parent.TabstatsController)
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local InfoPane = PlayerGui.InfoPane
local CurrentFrameFolder = InfoPane.CurrentFrame
local disasterInfoData = require(script.Parent.DisasterInfoData)
local TextCycler = require(script.Parent.TextCycler)
local CurrentDisaster = script.Parent.Parent.Parent.ReticleStatus.CurrentDisaster

coroutine.wrap(function()
	CurrentDisaster.Value = "Fire"
	Remotes["UpdateCurrentDisaster"]:FireServer("Fire")
	TabstatsController.showNewAreas("Fire")
	disasterInfoData.Fire.textCycler = TextCycler.new("Fire")
	disasterInfoData.Fire.textCycler:run()
end)()

CurrentFrameFolder.ChildAdded:Connect(function(frame)
	disasterInfoData[frame.Name].textCycler = TextCycler.new(frame.Name)
	disasterInfoData[frame.Name].textCycler:run()
end)

CurrentFrameFolder.ChildRemoved:Connect(function(frame)
	local currentDisasterTextCycler = disasterInfoData[frame.Name].textCycler
	currentDisasterTextCycler.continueToRun = false
end)

