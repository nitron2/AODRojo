--[[**
	This module contains all necessary code in order to handle the area data made by the developer
	while the game is running. The module is used by both the client and the server.

 	@usage: client AreaCheck, server ValidateDisaster
	@returns self
**--]]--Description

local WorldModel = workspace.WorldModel
local Areas = WorldModel.Areas
local Grid = WorldModel.Grid
local AreasTable = {}
AreasTable.__index = AreasTable

--[[**
	Create a new area table which will house all of the areas created which are physically
	housed in the workspace. The steps are as follows:
		
	-Make empty table
	-Iterate through area category folders, then all the segments (Beam instances) which are inside
	-So for each segments folder found, do the followng...
	-Each area table will have two sub-tables, up-facing segments and down-facing segments,
	which is important to define the way that areas will be detected in the game
	
	-Set each area's properties: 
		-UpSegments, DownSegments
		-ID: the index of the disaster (position of area in this area table) 
		-Name: string
		-ObjInde: Folder of the disaster
		-Type: string
	
	-Based on the porperties/location of the segment in workspace, figure out which
	subtable to place each segment. 
	
	-Each segment has the following properties; together they form a slope-intercept equation of each line segment:
		-Start.X: 
		-Start.Y: This actually corresponds to Z value of mouse, but we are treating the "gameboard" as a top-down
		coordinate plane.
		-End.X
		-End.Y
		-m: slope
		-b: Y-int, or rarther the AbsValue Z intercept of the line.
	
	-While still iterating through each segment check to see what grid part either point of the segment
	is touching, and add a int value instance into the physical grid part with the number index of the area 
	it corresponds to. Use area.ID to accomplish this. This will be used later by getTargetTile to figure 
	out what areas to attempt to search for when the game is running. 
	
	-Also check that the instance index value does not already exist.
	
	@returns [t:table] newAreasTable The table which holds in memort all of the areas created
**--]]

local function isContent(folderContent)
	if #folderContent > 0 then 
		return true 
	end
	return false 
end

local function createNewAreaTable(newAreasTable, Area, Type)			
	local newAreaTable = {}
	newAreaTable.ID = #newAreasTable + 1
	newAreaTable.Name = Area.Name
	newAreaTable.ObjIndex = Area
	newAreaTable.Type = Type.Name
	newAreaTable.UpSegments = {}
	newAreaTable.DownSegments = {}
	return newAreaTable
end

local function createNewSegmentTable(Segment)
	local newSegmentTable = {}
	newSegmentTable.Name = Segment.Name
	newSegmentTable.Direction = Segment.Direction.Value
	newSegmentTable.Start = {}
	return newSegmentTable
end

local function isSegmentHaveAttachments(Segment)
	if Segment.Attachment0 and Segment.Attachment1 then
		return true 
	end		
	return false
end

local function setSegmentTableLineEquation(newSegmentTable, Segment)
	newSegmentTable.Start.X = Segment.Attachment0.Position.X
	newSegmentTable.Start.Y = math.abs(Segment.Attachment0.Position.Z)
	newSegmentTable.End = {}
	newSegmentTable.End.X = Segment.Attachment1.Position.X
	newSegmentTable.End.Y = math.abs(Segment.Attachment1.Position.Z)
	newSegmentTable.m = (newSegmentTable.End.Y - newSegmentTable.Start.Y) / 
		(newSegmentTable.End.X - newSegmentTable.Start.X)
	newSegmentTable.b = newSegmentTable.Start.Y -
		newSegmentTable.m * newSegmentTable.Start.X
end

local function isSegmentFacingUp(newSegmentTable)
	if newSegmentTable.Direction == true then
		return true
	end
	return false
end

local function isSegmentFacingDown(newSegmentTable)
	if newSegmentTable.Direction == false then
		return true
	end
	return false
end

local function insertSegmentIntoTable(newAreaTable, newSegmentTable)
	if isSegmentFacingUp(newSegmentTable) then
		table.insert(newAreaTable.UpSegments, newSegmentTable)
	elseif isSegmentFacingDown(newSegmentTable) then
		table.insert(newAreaTable.DownSegments, newSegmentTable)
	end
end

local function isTilePartExtents(TilePartExtents)
	if TilePartExtents.XEnd 
		and TilePartExtents.XStart 
		and TilePartExtents.ZEnd 
		and TilePartExtents.ZStart 
	then
		return true
	end
	return false
end

local function isSegmentOnTile(TilePartExtents, newSegmentTable)
	if TilePartExtents.XStart.Value < newSegmentTable.Start.X 
		and newSegmentTable.Start.X < TilePartExtents.XEnd.Value 
		and math.abs(TilePartExtents.ZStart.Value) < newSegmentTable.Start.Y 
		and newSegmentTable.Start.Y < math.abs(TilePartExtents.ZEnd.Value)
	then
		return true
	end
	return false
end

local function isExistingAreaIDPresentTile(TilePart, newAreaTable)
	if TilePart.Areas:FindFirstChild(tostring(newAreaTable['ID'])) then
		return true
	end
	return false
end

local function addAreaToAreaFolder(numNewAreasTable, tilePart)
	local newAreaIndexValueTable = Instance.new("IntValue")
	newAreaIndexValueTable.Name = numNewAreasTable -- Same as area id
	newAreaIndexValueTable.Value = numNewAreasTable -- Same as area id
	newAreaIndexValueTable.Parent = tilePart.Areas
end


function AreasTable.new()
	print("Start")
	local count = 0
	local newAreasTable = {}
	setmetatable(newAreasTable, AreasTable)
	
	local Areas = Areas:GetChildren()	
	if isContent(Areas) then
		for i, Type in pairs(Areas) do
			--print(Type.Name)
			local TypeSpecOrGen = Type:GetChildren()
			if isContent(TypeSpecOrGen) then
				for i, TypeSpecOrGenSubFolders in pairs(TypeSpecOrGen) do	
					local SpecificAreas = TypeSpecOrGenSubFolders:GetChildren()
					if isContent(SpecificAreas) then
						for i, Area in pairs(SpecificAreas) do
							--print("        ".. Area.Name)
							local newAreaTable = createNewAreaTable(newAreasTable, Area, Type)
							local Segments = Area.Segments:GetChildren()
							table.insert(newAreasTable, newAreaTable)
							if isContent(Segments) then
								for i, Segment in pairs(Segments) do
									count = count + 1
									local newSegmentTable = createNewSegmentTable(Segment)
									if isSegmentHaveAttachments(Segment) then
										setSegmentTableLineEquation(newSegmentTable, Segment)
										insertSegmentIntoTable(newAreaTable, newSegmentTable)
										local TileParts = Grid:GetChildren()
										if TileParts then
											for i, TilePart in pairs(TileParts) do
												if TilePart.Extents and TilePart.Areas then
													local TilePartExtents = TilePart.Extents
													if isTilePartExtents(TilePartExtents) 
														and isSegmentOnTile(TilePartExtents, newSegmentTable) 
													then
														if not isExistingAreaIDPresentTile(TilePart, newAreaTable) then
															addAreaToAreaFolder(#newAreasTable, TilePart)
															--print("Added cuase found no existing")
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	print("End")
	return newAreasTable
end

--[[**
	Given mouse position in workspace, cast a ray UNDER the grid which will hit a certain tile.
	Figure out if the ray is touching a tile or not, and if result, then return that tile instance.
	The ray is cast under the grid because onthing is expected to be going on down there anyway, unlike 
	above the grid.

  @param [t:number] mouseX 
	@param [t:number] mouseZActual Actual, because we've been using the abs value a lot lately.

	@returns [t:table] newAreasTable The table which holds in memort all of the areas created
**--]]

function AreasTable:getTargetTile(mouseX, mouseZActual)
	local rayOrigin = Vector3.new(mouseX, 0.5, mouseZActual)
	local rayDirection = Vector3.new(0,1,0)
	local rayCastResult = workspace:Raycast(rayOrigin, rayDirection)
	if rayCastResult then
		local targetTile = rayCastResult.Instance
		if targetTile.Parent == Grid then
			return targetTile
		end
	end
end

--[[**
	Given targetTile instance, create a list of areas to search for in the form of indices.
	Look for each areaIndexValueTable in the tile part, and insert that into the table to return.

  @param [t:instance] targetTile The tile mouse is hovering over 
	@returns [t:table] areasToSearchFor The table which holds the area queury Only returns if raycast result.
**--]]

function AreasTable:getAreasToSearchForFromTargetTile(targetTile)
	local areasToSearchFor = {}
	local areasInTargetTile = targetTile.Areas:GetChildren()
	if targetTile.Areas and #areasInTargetTile > 0 then
		for i, areaIndexValueTable in pairs(areasInTargetTile) do
			table.insert(areasToSearchFor, areaIndexValueTable.Value)
		end
	end
	return areasToSearchFor
end

--[[**
Given parameters, and a list of areas to attempt a search for, do the following:
- iterate each area and each area's up segments table.
 

  @param [t:number] mouseX The x vlaue of the mouse in the workspace
	@param [t:number] mouseZAbs Absolute value, because this is the all-important moment when we use basic linear functions
	to determine if moue is above or below a line in the areas. Higher Z values in roblox are downward on our "Game board".
	That is why we need to get the absolute value of mouse.Hit.Z

	@returns [t:table] activatedAreas A list of all activated areas found. Always returns this.
**--]]

function AreasTable:checkAreaQuery(mouseX, mouseZAbs, areasToSearchFor)
	local activatedAreas = {}
	for i, areaQuery in pairs(areasToSearchFor) do

		local areaTable = self[areaQuery]

		if areaTable then
			local allSegmentsTouched = 0
			local allSegmentsActivated = 0
			if areaTable.UpSegments and areaTable.DownSegments then
				for i, segmentTableUp in pairs(areaTable.UpSegments) do
					if segmentTableUp.Start.X < mouseX and mouseX < segmentTableUp.End.X then
						allSegmentsTouched = allSegmentsTouched + 1 
						if mouseZAbs > (mouseX * segmentTableUp.m + segmentTableUp.b) then -- Mouse is above line
							allSegmentsActivated = allSegmentsActivated + 1 
							for i, segmentTableDown in pairs(areaTable.DownSegments) do 
								-- Remember! Down segments have switched end and start points!
								if segmentTableDown.Start.X > mouseX and mouseX > segmentTableDown.End.X then
									allSegmentsTouched = allSegmentsTouched + 1 
									if mouseZAbs < (mouseX * segmentTableDown.m + segmentTableDown.b) then
										allSegmentsActivated = allSegmentsActivated + 1 
									end
								end
							end
						end
					end
				end
			end
			
			

			--// TESTING PURPOSES // ----------------------------------------------
			--Within the areasTable there is a number index to each disaster.
			--Canada is giving issues. Its index is 111.
			
			local NAME_OF_COUNTRY_TO_SHOW_TOUCHED_AND_ACTIVATED = "Chile"
			local indexOfQueryInSelf

			for k, v in pairs(self) do
				if v.Name == NAME_OF_COUNTRY_TO_SHOW_TOUCHED_AND_ACTIVATED then
					indexOfQueryInSelf = k
					break
				end
			end

			if indexOfQueryInSelf == areaQuery then
				if allSegmentsTouched ~= 0 and allSegmentsActivated ~= 0 then
					print("--------------------------")
					print('allSegmentsTouched: ' .. allSegmentsTouched)
					print('allSegmentsActivated' .. allSegmentsActivated)
					print("--------------------------")
				end
			end

			-----------------------------------------------------------------------
			--We could think about storing these in just two comma sep arrays,
			--Would be better for storage

			if (allSegmentsTouched == 2 and allSegmentsActivated == 2) 
				or (allSegmentsTouched == 4 and allSegmentsActivated == 3)
				or (allSegmentsTouched == 6 and allSegmentsActivated == 4)
				or (allSegmentsTouched == 9 and allSegmentsActivated == 6)
				or (allSegmentsTouched == 12 and allSegmentsActivated == 6)
				or (allSegmentsTouched == 18 and allSegmentsActivated == 10)
				or (allSegmentsTouched == 6 and allSegmentsActivated == 4)
				or (allSegmentsTouched == 18 and allSegmentsActivated == 12)
				or (allSegmentsTouched == 14 and allSegmentsActivated == 8)
				or (allSegmentsTouched == 12 and allSegmentsActivated == 6)
				or (allSegmentsTouched == 16 and allSegmentsActivated == 9)
				or (allSegmentsTouched == 9 and allSegmentsActivated == 6)
				or (allSegmentsTouched == 15 and allSegmentsActivated == 10)
				or (allSegmentsTouched == 10 and allSegmentsActivated == 6)
				or (allSegmentsTouched == 8 and allSegmentsActivated == 5)
				or (allSegmentsTouched == 12 and allSegmentsActivated == 7)
				or (allSegmentsTouched == 20 and allSegmentsActivated == 8)
				or (allSegmentsTouched == 25 and allSegmentsActivated == 12)
				or (allSegmentsTouched == 48 and allSegmentsActivated == 20)
				or (allSegmentsTouched == 20 and allSegmentsActivated == 12)
			then
				table.insert(activatedAreas, areaTable.ObjIndex)
				--else 
				--print("no")
			end
		end
	end
	return activatedAreas
end

return AreasTable