--[[
ModuleScript Area 
	@nitron2
	@Last Changes: 2020.07.04
	@Description :	
]]--
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Settings = require(script.Parent.Settings)
local AreasFolder = workspace.WorldModel.Areas
local Area = {}
Area.__index = Area

--[[
Area.new()

@description :	
@params : table "areaType" - 
						string "areaName" - 
					string "autoSegmentParameters" -


@usage :
@returns :
]]--

function Area.new(areaType, areaName, autoSegmentParameters)
	local newArea = {
		['Type'] = areaType,
		['Name'] = areaName,
		['WorldInstance'] = nil,
		['SpecialOrGeneral'] = nil,
		['Points'] = {},
		['UpSegments'] = {},
		['DownSegments'] = {},
		['AutoSegmentDirection'] = autoSegmentParameters,
		['LastSegmentCreatedInstance'] = nil
	}
	setmetatable(newArea, Area)
	
	local locationOfNewArea do
		if newArea.Name == "" or newArea.Name == nil then
			newArea.SpecialOrGeneral = "General"
			locationOfNewArea = AreasFolder[areaType]["General"]
		
			-- For purposes of naming only
			local children = locationOfNewArea:GetChildren()
			local numGeneralInType = #children
			
			newArea.Name = "General" .. numGeneralInType + 1
		else
			newArea.SpecialOrGeneral = "Special"
			locationOfNewArea = AreasFolder[areaType]["Special"]
			-- Already has its specific name
		end
	end
	
	local areaContainer do
		areaContainer = Instance.new("Folder")
		areaContainer.Name = newArea['Name']
		if not AreasFolder:FindFirstChild(areaType) then
			local newAreaCategory = Instance.new("Folder")
			newAreaCategory.Name = newArea['Type']
		end
		areaContainer.Parent = locationOfNewArea
		newArea['WorldInstance'] = areaContainer
	end
	
	local segmentsContainer do
		segmentsContainer = Instance.new("Folder")
		segmentsContainer.Name = "Segments"
		segmentsContainer.Parent = areaContainer
	end
	
	return newArea
end
 
local function systemAutoSegmentDirection(newArea, attachment1, attachment0)
	local segmentDirection
	if (
			(newArea['AutoSegmentDirection'] == "CounterClockwiseUp" 
			or newArea['AutoSegmentDirection']  == "CounterClockwiseDown") 
			and attachment1.Position.X > attachment0.Position.X
		)
		or (
			(newArea['AutoSegmentDirection'] == "ClockwiseUp" 
			or newArea['AutoSegmentDirection']  == "ClockwiseDown")
			and attachment0.Position.X > attachment1.Position.X
		)
	then
		segmentDirection = true
	else
		segmentDirection = false
	end
	return segmentDirection
end

local function newSegment(newArea, currentPointIndex)
	if currentPointIndex > 1 then 			
		local currentPointInTerrain = workspace.Terrain:FindFirstChild(tostring(newArea['Points'][currentPointIndex]))
		local lastPointInTerrain		
		if newArea.Points[currentPointIndex - 1] then -- This insures that the "previous point" actaully exists
			lastPointInTerrain = workspace.Terrain:FindFirstChild(tostring(newArea['Points'][currentPointIndex - 1]))
		end
	
		if currentPointInTerrain and lastPointInTerrain then
			local segmentDirection = systemAutoSegmentDirection(newArea, currentPointInTerrain, lastPointInTerrain)-- = the function for autoSegmentDirection
			local beamToCopy  -- instance
			local UpOrDownSegments -- string

			if segmentDirection == true then
				beamToCopy = "BeamUp"
				UpOrDownSegments = "UpSegments"
			elseif segmentDirection == false then
				beamToCopy = "BeamDown"
				UpOrDownSegments = "DownSegments"
			end
			
			local newPhysicalSegment do
				if type(beamToCopy) == "string" then
					newPhysicalSegment = ReplicatedStorage.Systems["CreateAreas"][beamToCopy]:Clone()
				elseif beamToCopy:IsA("Instance") then
					newPhysicalSegment = AreasFolder[newArea['Type']][newArea['SpecialOrGeneral']][newArea['Name']].Segments:FindFirstChild(beamToCopy.Name)
				end
				newPhysicalSegment.Name = ("Segment" .. newArea.Points[currentPointIndex - 1] .. "To" .. tostring(newArea['Points'][currentPointIndex]))
				newPhysicalSegment.Attachment0 = lastPointInTerrain
				newPhysicalSegment.Attachment1 = currentPointInTerrain
				newPhysicalSegment.Parent = AreasFolder[newArea['Type']][newArea['SpecialOrGeneral']][newArea['Name']].Segments
				newPhysicalSegment.Enabled = true
			end

			if newPhysicalSegment:FindFirstChild("PointIndex") then
				newPhysicalSegment:FindFirstChild("PointIndex"):Destroy()
			end
			
			local newSegmentDirectionIndicator do
			 	newSegmentDirectionIndicator = Instance.new("BoolValue")
				newSegmentDirectionIndicator.Name = "Direction"
				newSegmentDirectionIndicator.Value = segmentDirection
				newSegmentDirectionIndicator.Parent = newPhysicalSegment
			end
			
			local newTabularSegment = {
				['Name'] = newPhysicalSegment.Name,
				['SegmentInstance'] = newPhysicalSegment,
				['Direction'] = segmentDirection,
				['FirstPhysicalPoint'] = lastPointInTerrain,
				['SecondPhysicalPoint'] = currentPointInTerrain,
				['Start'] = {
					['X'] = lastPointInTerrain.Position.X,
					['Y'] = lastPointInTerrain.Position.Z * - 1
				},
				['End'] = {
					['X'] = currentPointInTerrain.Position.X,
					['Y'] = currentPointInTerrain.Position.Z * - 1
				},
			}
			newTabularSegment['m'] = ((newTabularSegment['End']['Y'] - newTabularSegment['Start']['Y']) / 
				(newTabularSegment['End']['X'] - newTabularSegment['Start']['X']))
			newTabularSegment['b'] = newTabularSegment['Start']['Y'] - newTabularSegment['m'] * 
				newTabularSegment['Start']['X']
			
			table.insert(newArea[UpOrDownSegments], newTabularSegment)
			newArea['LastSegmentCreatedInstance'] = newPhysicalSegment
		end
	end
end

local function newPointPhysical(positionInWorld, newPhysicalPointName, pointIndex)
	local newPointInstance do
		newPointInstance = Instance.new("Attachment")
		newPointInstance.Name = newPhysicalPointName
		newPointInstance.Position = Vector3.new(positionInWorld.X, Settings.WORLD_HEIGHT, positionInWorld.Z)
		newPointInstance.Visible = true
		newPointInstance.Parent = workspace.Terrain
	end
	
	local pointIndexValue do
		pointIndexValue = Instance.new("IntValue")
		pointIndexValue.Name = "PointIndex"
		pointIndexValue.Value = pointIndex
		pointIndexValue.Parent = newPointInstance
	end
end

local function newPointTabular(newArea, newPhysicalPointName)
	table.insert(newArea['Points'], newPhysicalPointName) 
end

function Area:createGeometryFromClick(positionInWorld)	
	local numPoints = #self['Points']
	local newPhysicalPointName = (self['Type'] .. self['SpecialOrGeneral'] .. self['Name'] .. numPoints + 1)
	
	newPointTabular(self, newPhysicalPointName)
	newPointPhysical(positionInWorld, newPhysicalPointName, numPoints + 1)
	
	-- An updated number of points in the table
	local currentPointIndex = #self.Points
	

	newSegment(self, currentPointIndex)	-- Seg dir is either true or false
	
	--MonitorFrame.NumberPointsTotal.Text = numPoints + 1 --Fix lateer
end

function Area:undoGeometry()
	if #self.Points > 1 then
		-- If we cannot find the instance of the segment (It has been deleted by this function already,
		-- then we must assign an instance to the table member inuitively
		local function searchForBeamInSegmentsFolder()
			for i, v in pairs(self['WorldInstance'].Segments:GetChildren()) do
				 if v == self['LastSegmentCreatedInstance'].Name then
					return true
				else 
					return false
				end
			end
		end
		
		if not self['LastSegmentCreatedInstance'] or searchForBeamInSegmentsFolder() == false then
			for i, v in pairs(self['WorldInstance'].Segments:GetChildren()) do
				self['LastSegmentCreatedInstance'] = v
			end
		end

		--print("self['LastSegmentCreatedInstance']: " .. tostring(self['LastSegmentCreatedInstance']))
		
		local beamInstanceDirection = self['LastSegmentCreatedInstance'].Direction.Value
		
		self['LastSegmentCreatedInstance'].Attachment1:Destroy()
		self['LastSegmentCreatedInstance']:Destroy()
		self['LastSegmentCreatedInstance'] = nil
		table.remove(self.Points, #self.Points)
		
	end
end

function Area:finish()
	local firstPoint = self['Points'][1]
	local lastSegment = self['LastSegmentCreatedInstance'] 
	local lastPointInLastSegment = lastSegment.Attachment1
	
	if lastSegment and lastPointInLastSegment then
		lastPointInLastSegment:Destroy()
		lastSegment.Attachment1 = workspace.Terrain:FindFirstChild(firstPoint)
	end
	
	local function removeVisualAidsFromArea(segmentTableType)
		for i, tabularSegment in pairs(segmentTableType) do
			tabularSegment['SegmentInstance'].Attachment0.Visible = false
			tabularSegment['SegmentInstance'].Attachment1.Visible = false
			tabularSegment['SegmentInstance'].Color = Settings.DEFUALT_AREA_SEGMENTS_COLOR
			tabularSegment['SegmentInstance'].Transparency = Settings.INITIAL_AREA_SEGMENTS_TRANSPARENCY
			local indicatorItems = tabularSegment['SegmentInstance']:GetChildren()
			for i, indicatorItem in pairs(indicatorItems) do
				if not indicatorItem:IsA("BoolValue") then
					indicatorItem:Destroy()
				end
			end
		end
	end
	
	removeVisualAidsFromArea(self['UpSegments'])
	removeVisualAidsFromArea(self['DownSegments'])
	
	self = nil
end

function Area:remove()
	local areaItems = self['WorldInstance']:GetChildren()
	for i, areaItem in pairs(areaItems) do
		areaItem:Destroy()
	end
	
	for i, areaPoint in pairs(self['Points']) do
		local itemToRemove = workspace.Terrain:FindFirstChild(areaPoint)
		if itemToRemove then
			itemToRemove:Destroy()
		end
	end
	
	self['WorldInstance']:Destroy()
	self = nil
end

return Area

