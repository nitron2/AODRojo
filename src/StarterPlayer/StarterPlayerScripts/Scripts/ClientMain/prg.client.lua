--!strict
local Player = game.Players.LocalPlayer
Player.CharacterAdded:wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientMain = require(script.Parent.ClientMain)
local CameraController = require(script.Parent.Parent.CameraController.CameraController)
local Tabstats = require(script.Parent.Parent.Tabstats.Tabstats)
local Reticle = require(script.Parent.Parent.Reticle.Reticle)
local TabstatsController = require(script.Parent.Parent.InfoPane.TabstatsController)
local WorldHealth = require(script.Parent.Parent.WorldHealth.WorldHealth)
local Remotes = ReplicatedStorage.Remotes
local Character = Player.Character
local PlayerGui = Player.PlayerGui
local Message = PlayerGui.Message.Message
local GameStage = Message.GameStage
local Time = Message.Time

local mouse = game.Players.LocalPlayer:GetMouse()
game:GetService("UserInputService").MouseIconEnabled = false
--mouse.Icon = 'http://www.roblox.com/asset/?id=950896037'


local newReticle = Reticle.new(mouse)


local frame = 0
local FREQUENCY_OF_CHECKS = 2 -- Run program every __ frames

if not Character or not Character.Parent then 
	Character = Player.CharacterAdded:wait() 
end

Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

coroutine.wrap(function()
	newReticle:rotate()
end)()

local newCameraController = CameraController.new()
_G.CurrentCameraController = newCameraController

script.Parent.Parent.Parent.ClientMainLoaded.Value = true

local function updateMousePositionNumberValues()
	script.Parent.Parent.Parent.MousePosition.mouseX.Value = mouse.X
	script.Parent.Parent.Parent.MousePosition.mouseY.Value = mouse.Y
end

local function updateColorOfTabstats()
	Tabstats.updateTileActivationStatus()
end

local function main()
	updateMousePositionNumberValues()
	newCameraController:updatePosition()
	newReticle:updatePosition(mouse)
	Tabstats.update()
	WorldHealth.updateGui()
	frame = frame + 1
	if frame == FREQUENCY_OF_CHECKS then
		frame = 0
		ClientMain.run()
	end
end

local GameState = script.Parent.Parent.Parent.GameState

local function formatTime(secondsServer : number)
	local minutes = math.floor(secondsServer/60)
	local seconds = (secondsServer % 60)
	local minutesString
	local secondsString
	minutesString = tostring(minutes)
	if seconds < 10 then
		secondsString = "0" .. tostring(seconds)
	else 
		secondsString = tostring(seconds)
	end
	return minutesString, secondsString
end

Remotes.UpdateClientsTime.OnClientEvent:Connect(function(secondsServer : number)
	local m, s = formatTime(secondsServer)
	Time.Text = m .. ":" .. s
end)

Remotes.UpdateClientsGameState.OnClientEvent:Connect(function(gameStateServer)
	GameState.Value = gameStateServer
	GameStage.Text = GameState.Value
	if gameStateServer == "InProg" then
		TabstatsController.cleanUpAreas()
	end
end)

--script.Parent.Parent.Parent.ReticleStatus.CurrentDisaster.Changed:Connect(updateColorOfTabstats)
game:GetService('RunService').RenderStepped:Connect(main)