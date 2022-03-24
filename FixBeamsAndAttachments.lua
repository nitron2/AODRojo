local ws = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local WorldModel = ws.WorldModel
local Areas = WorldModel.Areas


local pointsInTerrain = ws.Terrain:GetChildren()
local IDsInTerrain = {}

for i, point in pairs(pointsInTerrain) do
	table.insert(IDsInTerrain, point:GetAttribute("ID"))
end

--I'd love to learn how to find the runtime of recursive functions! :)
local function find_segment_rec(current_node)
	if current_node:IsA("Beam") and current_node:GetAttribute("Attachment0_ID") then
		
		local firstPointID = current_node:GetAttribute("Attachment0_ID")
		local secondPointID = current_node:GetAttribute("Attachment1_ID")
		
		local firstPointIdIndex = table.find(IDsInTerrain, firstPointID)
		local secondPointIdIndex = table.find(IDsInTerrain, secondPointID)
		
		local point1ToAttach = pointsInTerrain[firstPointIdIndex]
		local point2ToAttach = pointsInTerrain[secondPointIdIndex]
		
		current_node.Attachment0 = point1ToAttach
		current_node.Attachment1 = point2ToAttach
		
		
		return
	else
		for _,child in ipairs(current_node:GetChildren()) do
			find_segment_rec(child)
		end
		return
	end
end

find_segment_rec(ws)
