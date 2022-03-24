

--[[**
	This LocalScript handles all player interactions with the hotbar
	inlcuding placing a disaster. It uses remotes and modules to
	outsource all other jobs, which mostly are server-sided. 
	For placing disaster, the ValidateDisaster module is used, and 
	_G.ActivatedAreas is passed to it to compare with what the server
	says. Might be totally stupid. Maybe I'll think about indoing that.

 	@usage:	While the game is in progress. References many RemoteEvents.
	@returns: nil
**--]]--Description

repeat wait() until script.Parent.Parent.Parent.ClientMainLoaded.Value == true

local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Remotes = ReplicatedStorage["Remotes"]
local mouse = player:GetMouse()

local TweenService = game:GetService("TweenService")

local PlayerGui = player.PlayerGui
local HotbarGui = PlayerGui:WaitForChild("Hotbar", 20)
local HotbarFrame = HotbarGui.Hotbar

local ClientMain = require(script.Parent.Parent.ClientMain.ClientMain)

local Fire = HotbarFrame.CurrentRow.Buttons.Fire
local Lightning = HotbarFrame.CurrentRow.Buttons.Lightning
local Tsunami = HotbarFrame.CurrentRow.Buttons.Tsunami
local TropicalStorm = HotbarFrame.CurrentRow.Buttons.TropicalStorm
local AcidRain = HotbarFrame.CurrentRow.Buttons.AcidRain

local Marker = Fire.Marker

local MarkerLeft = Marker.Left
local MerkerRight = Marker.Right

local leftInitalPos = UDim2.new(-0.05,0,-0.05,0)
local leftTargetPos = UDim2.new(-0.1,0,-0.05,0)

local rightInitalPos = UDim2.new(1.075,0,-0.05,0)
local rightTargetPos = UDim2.new(1.125,0,-0.05,0)

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local tweenRightOut = TweenService:Create(MerkerRight, tweenInfo, {Position = rightTargetPos})
local tweenRightIn = TweenService:Create(MerkerRight, tweenInfo, {Position = rightInitalPos})

local tweenLeftOut = TweenService:Create(MarkerLeft, tweenInfo, {Position = leftTargetPos})
local tweenLeftIn = TweenService:Create(MarkerLeft, tweenInfo, {Position = leftInitalPos})

local CurrentDisaster = script.Parent.Parent.Parent.ReticleStatus.CurrentDisaster

local TabstatsController = require(script.Parent.Parent.InfoPane.TabstatsController)

local remoteUpdateCurrentDisaster = ReplicatedStorage.Remotes["UpdateCurrentDisaster"]

local function hotbarItemClicked(buttonPressed)
	CurrentDisaster.Value = buttonPressed.Name
	Remotes["UpdateCurrentDisaster"]:FireServer(buttonPressed.Name)
	TabstatsController.onHotBarItemClicked(buttonPressed.Name)
	Marker.Parent = buttonPressed	
end

local function correctReticleColor()
	script.Parent.Parent.Parent.ReticleStatus.IsInsideActivatedFootprint.Value = true
	_G.currentReticle:changeColorToDisabled()
	ClientMain.run()
end

function animateMarker()
	while true do
		coroutine.wrap(function()
			tweenLeftOut:Play()
			tweenRightOut:Play()
		end)()
		wait(0.3)
		coroutine.wrap(function()
			tweenLeftIn:Play()
			tweenRightIn:Play()
		end)()
		wait(0.25)
	end
end

coroutine.wrap(function() animateMarker() end)()
	
Fire.Click.Activated:Connect(function() hotbarItemClicked(Fire) end)

Lightning.Click.Activated:Connect(function() hotbarItemClicked(Lightning) end)

Tsunami.Click.Activated:Connect(function() hotbarItemClicked(Tsunami) end)

AcidRain.Click.Activated:Connect(function() hotbarItemClicked(AcidRain) end)

TropicalStorm.Click.Activated:Connect(function() hotbarItemClicked(TropicalStorm) end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and script.Parent.Parent.Parent.GameState.Value == "InProg" then
		local ActivatedAreas = _G.ActivatedAreas
		Remotes["ValidateDisaster"]:FireServer(mouse.hit, ActivatedAreas)
		correctReticleColor()
	end
end)
