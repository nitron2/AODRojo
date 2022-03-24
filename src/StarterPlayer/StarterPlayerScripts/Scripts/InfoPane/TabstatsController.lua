--!strict

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DisasterSpecs = require(ReplicatedStorage.Scripts.Specs.DisasterSpecs.DisasterSpecs)

local WorldModel = workspace.WorldModel
local Areas = WorldModel.Areas

local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local InfoPane = PlayerGui.InfoPane
local CurrentFrameFolder = InfoPane.CurrentFrame

local TabstatsController = {}
local currentShowing = "Fire"

local COLOR_EFFECTIVE_AREA = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
})

local COLOR_ADVERSE_AREA = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})

local COLOR_DEFAULT_AREA = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})

-- On click method connecting to hotbar to change out the GUI
-- Each disaster has its own frame

--Methods to iterate through an area and make it visible and color it correctly
local function getEffectiveAndAdverseAreasOfDisaster(disasterString : string)
	local effectiveAreas = nil
	local adverseAreas = nil
	if DisasterSpecs[disasterString] then
		if DisasterSpecs[disasterString]["EffectiveAreas"] ~= nil then
			effectiveAreas = DisasterSpecs[disasterString]["EffectiveAreas"]
		end
		if DisasterSpecs[disasterString]["AdverseAreas"] ~= nil then
			adverseAreas = DisasterSpecs[disasterString]["AdverseAreas"]
		end
	end
	return effectiveAreas, adverseAreas
end

local function editVisualsOfGroupOfAreas(areas, enabled, colorSquence)
	for i, areaName in pairs(areas) do
		local area = Areas:FindFirstChild(areaName)
		if area then
			for i,specialArea in pairs(area.Special:GetChildren()) do
				for i, segment in pairs(specialArea.Segments:GetChildren()) do
					segment.Enabled = enabled
					segment.Color = colorSquence
				end
			end
		end
	end
end

local function showCorrectInfoFrame(hotBarDisasterClickedString)
	local frameTarget = InfoPane:FindFirstChild(hotBarDisasterClickedString)
	local lastAreaFrameShown = nil
	if frameTarget then
		local CurrentFrameFolderChildren = CurrentFrameFolder:GetChildren()
		if #CurrentFrameFolderChildren > 0 then
			for i,v in pairs(CurrentFrameFolderChildren) do
				v.Visible = false
				v.Parent = InfoPane
				lastAreaFrameShown = v
			end
		end
		frameTarget.Parent = CurrentFrameFolder
		frameTarget.Visible = true
	end
	return lastAreaFrameShown
end

function TabstatsController.cleanUpOldShownAreas(lastAreaFrameShown)
	local effectiveAreas, adverseAreas = getEffectiveAndAdverseAreasOfDisaster(lastAreaFrameShown.Name)
	if effectiveAreas then
		editVisualsOfGroupOfAreas(effectiveAreas, false, COLOR_DEFAULT_AREA)
	end
	if adverseAreas then
		editVisualsOfGroupOfAreas(adverseAreas, false, COLOR_DEFAULT_AREA)
	end
end

function TabstatsController.cleanUpAreas()
	local effectiveAreas, adverseAreas = getEffectiveAndAdverseAreasOfDisaster(currentShowing)
	if effectiveAreas then
		editVisualsOfGroupOfAreas(effectiveAreas, false, COLOR_DEFAULT_AREA)
	end
	if adverseAreas then
		editVisualsOfGroupOfAreas(adverseAreas, false, COLOR_DEFAULT_AREA)
	end
end


function TabstatsController.showNewAreas(disasterName)
	currentShowing = disasterName
	local effectiveAreas, adverseAreas = getEffectiveAndAdverseAreasOfDisaster(disasterName)
	if effectiveAreas then
		editVisualsOfGroupOfAreas(effectiveAreas, true, COLOR_EFFECTIVE_AREA)
	end
	if adverseAreas then
		editVisualsOfGroupOfAreas(adverseAreas, true, COLOR_ADVERSE_AREA)
	end
end

function TabstatsController.onHotBarItemClicked(disasterName)
	local lastAreaFrameShown = showCorrectInfoFrame(disasterName)
	if script.Parent.Parent.Parent.GameState.Value == "PreGame" then
		if lastAreaFrameShown then
			TabstatsController.cleanUpOldShownAreas(lastAreaFrameShown)
		end
		TabstatsController.showNewAreas(disasterName)	
	end
end

return TabstatsController
