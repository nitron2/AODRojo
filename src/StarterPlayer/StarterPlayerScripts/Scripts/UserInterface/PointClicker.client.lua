local player = game.Players.LocalPlayer
local Remotes = game:GetService('ReplicatedStorage').Remotes
local PlayerScripts = player.PlayerScripts

local function onMouseEnterPoint()
	local mouseX = PlayerScripts.MousePosition.mouseX.Value
	local mouseY = PlayerScripts.MousePosition.mouseY.Value
	local pointImage = script.Parent
	local point = pointImage.Parent
	local pointFolder = point.Parent
	
	if player.Name == tostring(pointFolder.Name) then	
		local ID = point:FindFirstChild("ID")

		Remotes["PointClickPlayer"]:FireServer(ID.Value)
		local imageSuckIntoHotbar = pointImage:Clone()
		point:Destroy()
		if pointFolder then
			if #pointFolder:GetChildren() == 0 then
				pointFolder:Destroy()
			end
		end
		imageSuckIntoHotbar.Parent = player.PlayerGui.PointsContainer
		imageSuckIntoHotbar.Position = UDim2.new(0,mouseX,0,mouseY)
		imageSuckIntoHotbar:TweenSizeAndPosition(UDim2.new(0, 25, 0, 25), UDim2.new(0.5, 0, 0.95, 0))
		wait(0.8)
		imageSuckIntoHotbar:Destroy()
	end
end

repeat wait() until script.Parent:IsA("ImageButton")
script.Parent.MouseEnter:Connect(onMouseEnterPoint)
