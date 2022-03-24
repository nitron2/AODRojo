local Validations = {}

local WorldModel = workspace.WorldModel
local Areas = WorldModel.Areas
local City = Areas.City
local CoastEast = Areas.CoastEast
local CoastNorth = Areas.CoastNorth
local CoastSouth = Areas.CoastSouth
local CoastWest = Areas.CoastWest
local Country = Areas.Country
local Desert = Areas.Desert
local Forest = Areas.Forest
local FualtLine = Areas.FualtLine
local TsunamiHZ = Areas.TsunamiHZ

local function checkForArea(areaTable, areaTypeFolder)
	if areaTable then
		for i, v in pairs(areaTable) do
			if v:IsDescendantOf(areaTypeFolder) then
				return true
			end
		end
	end
	return false
end

function Validations.isAreas(areaTable)
	if areaTable then
		if #areaTable > 0 then
			return true
		else
			return false
		end
	else 
		return false
	end
end

function Validations.isMouseInActivatedFootprint(activatedFootprints)
	if activatedFootprints then
		for i, footprint in pairs(activatedFootprints) do
			if footprint['Activated'] == true then
				return true
			end
		end
	end
	return false
end

function Validations.isCity(areaTable)
	return checkForArea(areaTable, City)
end

function Validations.isCoastEast(areaTable)
	return checkForArea(areaTable, CoastEast)
end

function Validations.isCoastNorth(areaTable)
	return checkForArea(areaTable, CoastNorth)
end

function Validations.isCoastSouth(areaTable)
	return checkForArea(areaTable, CoastSouth)
end

function Validations.isCoastWest(areaTable)
	return checkForArea(areaTable, CoastWest)
end

function Validations.isCountry(areaTable)
	return checkForArea(areaTable, Country)
end

function Validations.isDesert(areaTable)
	return checkForArea(areaTable, Desert)
end

function Validations.isForest(areaTable)
	return checkForArea(areaTable, Forest)
end

function Validations.isFualtLine(areaTable)
	return checkForArea(areaTable, FualtLine)
end

function Validations.isTsunamiHZ(areaTable)
return checkForArea(areaTable, TsunamiHZ)
end

function Validations.isCoast(areaTable)
	if areaTable then
		for i, v in pairs(areaTable) do
			--	if v.Parent then
			--		if v.Parent.Parent then
			if v.Parent.Parent == CoastNorth 
				or v.Parent.Parent == CoastSouth
				or v.Parent.Parent == CoastEast
				or v.Parent.Parent == CoastWest
			then
				return true
			end
		end
			--	end
		--	end
	end
	return false
end

return Validations
