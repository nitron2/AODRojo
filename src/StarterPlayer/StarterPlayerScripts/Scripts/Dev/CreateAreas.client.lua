script.Disabled = true
local Area = require(script.Parent.Area)
local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local PlayerGui = player:WaitForChild("PlayerGui")

local mouse = player:GetMouse()

local MainGui = PlayerGui:WaitForChild("AreaCreation")
local AreaCreationMonitor = MainGui.AreaCreationMonitor
local MonitorFrame = AreaCreationMonitor.MonitorFrame
local SettingsFrame = AreaCreationMonitor.SettingsFrame

local ColorBox = SettingsFrame.ColorBox
local Cancel = SettingsFrame.Cancel
local AutoSegmentParametersButton = SettingsFrame.AutoSegmentParametersButton
local Finish = SettingsFrame.Finish
local NameBox = SettingsFrame.NameBox
local SnapToggleButton = SettingsFrame.SnapToggleButton
local TypeBox = SettingsFrame.TypeBox

local currentlyWorkingOnArea = false
local lastAreaName
local currentAreaName
local newArea
local segmentDirection
local autoSegmentSetting = "CounterClockwiseUp"

--[[system autoSegmentParameters
Description:...
--Where is the rest of the code found?
]]
local autoSegmentParameters = {
	"CounterClockwiseUp",
	"CounterClockwiseDown",
	"ClockwiseUp",
	"ClockwiseDown"
}

--Add way to be able to cycle through area types

--The area names will now have to be their path instead of just their names...

mouse.Button1Down:Connect(function()
	if currentlyWorkingOnArea == true then
		local positionInWorld = mouse.hit
		if positionInWorld then
			newArea:createGeometryFromClick(positionInWorld)		
		end
	end
end)

local function finalizeOrStartNewArea()
	if currentlyWorkingOnArea == false then
		-- Search for duplicate area
		local SpecialFolder = workspace.WorldModel.Areas[TypeBox.Text].Special
		local specialFolderContents = SpecialFolder:GetChildren()
		if SpecialFolder and specialFolderContents then
			if #specialFolderContents > 0 then
				for i, v in pairs(specialFolderContents) do
					if v.Name == NameBox.Text then
						print("Either delete duplicate area in folder or change area name.")
						return -- Cancel the current action
					end 
				end
			end
		end
		-- Instantiate new area
		currentAreaName = NameBox.Text
		Finish.Text = "DONE"
		
		newArea = Area.new(TypeBox.Text, NameBox.Text, AutoSegmentParametersButton.Text)
		currentlyWorkingOnArea = true
		--
	elseif currentlyWorkingOnArea == true then
		-- Finish an area already being worked on
		lastAreaName = NameBox.Text
		Finish.Text = "NEW AREA"
		currentlyWorkingOnArea = false

		newArea:finish()
		--
	end
end

local function changeAutoSegmentParameters()
	local currentParameter = AutoSegmentParametersButton.Text
	for i, v in pairs(autoSegmentParameters) do
		if v == currentParameter then
			if i < #autoSegmentParameters then 
				AutoSegmentParametersButton.Text = autoSegmentParameters[i+1]
			elseif i == #autoSegmentParameters then
				AutoSegmentParametersButton.Text = autoSegmentParameters[1]
			end
			break
		end
	end
end

local function undoGeometry()
	if currentlyWorkingOnArea then
		newArea:undoGeometry()
	end
end

local function cancel()
	if currentlyWorkingOnArea then
		newArea:remove()
		currentlyWorkingOnArea = false
		Finish.Text = "NEW AREA"
	end
end

Finish.Activated:Connect(function()
	finalizeOrStartNewArea()
end)

Cancel.MouseButton1Click:Connect(function()
	cancel()
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
	--	changeAutoSegmentParameters()
	elseif input.KeyCode == Enum.KeyCode.Z then
		undoGeometry()
	--elseif input.KeyCode == Enum.KeyCode.F then
	--	finalizeOrStartNewArea()
	elseif input.KeyCode == Enum.KeyCode.G then
		cancel()
	end
end)
