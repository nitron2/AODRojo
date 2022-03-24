--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TabstatsSpecs = require(ReplicatedStorage.Scripts.Tabstats.TabstatsSpecs)
local DisasterColors = require(ReplicatedStorage.Scripts.Disasters.Specs.Colors)
local DisasterAreasOfEffectiveness = require(ReplicatedStorage.Scripts.Disasters.Specs.AreasOfEffectiveness)
local Tabstats = {}

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local TabstatsFrame = PlayerGui.Tabstats.Tabstats
local ExistingFolder = TabstatsFrame.Existing
local listingTemplate = TabstatsFrame.Template.Template

local MouseViewportPositionXValue = script.Parent.Parent.Parent.MousePosition.mouseX
local MouseViewportPositionYValue = script.Parent.Parent.Parent.MousePosition.mouseY
local currentDisasterValue = script.Parent.Parent.Parent.ReticleStatus.CurrentDisaster

local LAYOUT_ORDER = {
	Country = 2, 
	Forest = 3
}

local DEFAULT_COLOR_COLOR = Color3.fromRGB(0, 0, 0)
local DEFAULT_COLOR_IMAGE_TRANSPARENCY = 0.3
local DEFAULT_ACCENT_IMAGE_TRANSPARENCY = 1

local ACTIVE_COLOR_IMAGE_TRANSPARENCY = 0
local ACTIVE_ACCENT_IMAGE_TRANSPARENCY = 0.5

local function isQueryAlreadyBeingDisplayed(areaTabularData)
	if TabstatsFrame:FindFirstChild(areaTabularData.areaContainerIndex) then
		return true
	end
	return false
end

local function isCurrentDisaster()
	if currentDisasterValue.Value ~= "" then 
		return true
	end
	return false
end

local function isTileAreaMatchingDisasterAOF(tile)
	for i, v in pairs(DisasterAreasOfEffectiveness) do
		if i == currentDisasterValue.Value then
			if v[1] == tile.SpecificArea.Value.Parent.Parent then
				return true
			end
		end
	end
	return false
end

local function isCurrentQueryTypeHasTabstatsDataWritten(query)
	if TabstatsSpecs[query.Parent.Parent.Name] then
		return true
	end
	return false
end

local function getDisasterColor()
	for i, v in pairs(DisasterColors) do
		if i == currentDisasterValue.Value then
			return v
		end
	end
	return nil
end

local function getQueryStoredInExistingFolder(areaTabularData)
	local queryFrame = ExistingFolder:FindFirstChild(areaTabularData.query.Name)
	if queryFrame then
		return queryFrame
	else
		for i, frame in pairs(ExistingFolder:GetChildren()) do
			if frame.SpecificArea.Value == areaTabularData.query then
				return frame
			end
		end
		return nil
	end
end

local function activateTile(frame)
	frame.Color.ImageTransparency = ACTIVE_COLOR_IMAGE_TRANSPARENCY
	frame.Color.ImageColor3 = getDisasterColor()
	frame.Color.Accent.ImageTransparency = ACTIVE_ACCENT_IMAGE_TRANSPARENCY
end

local function deactivateTile(frame)
	frame.Color.ImageTransparency = DEFAULT_COLOR_IMAGE_TRANSPARENCY
	frame.Color.ImageColor3 = DEFAULT_COLOR_COLOR
	frame.Color.Accent.ImageTransparency = DEFAULT_ACCENT_IMAGE_TRANSPARENCY
end

local function validateAndDisplayArea(query, areaTabularData)
	local newListing
	if not isQueryAlreadyBeingDisplayed(areaTabularData) then
		newListing = getQueryStoredInExistingFolder(areaTabularData)
		if not newListing then
			newListing = listingTemplate:Clone()
			local areaImage : string | nil = areaTabularData.areaContainer.image
			if areaImage == nil or areaImage == "" then
				newListing.Color.Accent.Icon.Image = TabstatsSpecs[areaTabularData.queryType].defualtImage
			elseif areaTabularData.areaContainer.image ~= nil then
				newListing.Color.Accent.Icon.Image = areaTabularData.areaContainer.image
			end
			newListing.Name = areaTabularData.areaContainerIndex
			newListing.SpecificArea.Value = query
			newListing.Area.Text = areaTabularData.areaContainer.displayName
			newListing.LayoutOrder = LAYOUT_ORDER[areaTabularData.queryType]
		end
		newListing.Parent = TabstatsFrame
		if isCurrentDisaster() then
			if isTileAreaMatchingDisasterAOF(newListing) then
				activateTile(newListing)
			end
		end
		newListing.Visible = true
	end
end

local function removeOldAreaTiles(activatedAreas)
	for i, frame in pairs(TabstatsFrame:GetChildren()) do
		if frame:IsA('Frame') then
			if frame:FindFirstChild('SpecificArea') then
				local specificAreaOfListing : ObjectValue = frame.SpecificArea.Value
				if specificAreaOfListing then
					if not table.find(activatedAreas, specificAreaOfListing) then
						frame.Visible = false
						deactivateTile(frame)
						frame.Parent = ExistingFolder
					end
				end
			end
		end
	end
end

local function searchTable(query)
	local areaTabularData = {}
	if isCurrentQueryTypeHasTabstatsDataWritten(query) then
		local queryType = tostring(query.Parent.Parent.Name) --// This is referencing folder itself
		local querySpecialOrGeneral = tostring(query.Parent.Name)
		local tbleSubFolder = TabstatsSpecs[queryType][querySpecialOrGeneral]
		for areaContainerIndex, areaContainer in pairs(tbleSubFolder) do
			for aliasIndex, areaSpecificWorldName in pairs(areaContainer.alias) do
				if tostring(areaSpecificWorldName) == tostring(query.Name) then
					areaTabularData.query = query
					areaTabularData.areaSpecificWorldName = areaSpecificWorldName
					areaTabularData.areaContainer = areaContainer
					areaTabularData.areaContainerIndex = areaContainerIndex
					areaTabularData.queryType = queryType
					break
				end
			end
		end
	end
	return areaTabularData
end

function Tabstats.updateTileActivationStatus()
	if not isCurrentDisaster() then 
		for i, frame in pairs(TabstatsFrame:GetChildren()) do
			if frame:IsA("Frame") then
				deactivateTile(frame)
			end
		end
	else
		for i, frame in pairs(TabstatsFrame:GetChildren()) do
			if frame:IsA("Frame") then
				if isTileAreaMatchingDisasterAOF(frame) then
					activateTile(frame)
				end
			end
		end
	end
end

--// Remember this runs every frame or so. Very fast
function Tabstats.update()
	TabstatsFrame.Position = UDim2.new(0, MouseViewportPositionXValue.Value + 25, 0, MouseViewportPositionYValue.Value - 25)
	local activatedAreas = _G.ActivatedAreas
	if activatedAreas then
		removeOldAreaTiles(activatedAreas)
		for i, query in pairs(activatedAreas) do
			local areaTabularData = searchTable(query)
			if areaTabularData.query then
				validateAndDisplayArea(query, areaTabularData)
			end
		end
	end
end

return Tabstats
