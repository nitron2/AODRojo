return function(model, scalar)
	local PrimaryPart = model.PrimaryPart
	local PrimaryPartCFrame = model:GetPrimaryPartCFrame()
	
	--Scale BaseParts
	for _,object in pairs(model:GetDescendants()) do
		if object:IsA('BasePart') 
			--and object ~= PrimaryPart 
		then	
			object.Size = object.Size * scalar
			
			local distance = (object.Position - PrimaryPartCFrame.p)
			local rotation = (object.CFrame - object.Position)
			object.CFrame = (CFrame.new(PrimaryPartCFrame.p + distance * scalar) * rotation)
		end
	end
	
	local primaryPartPositionY = PrimaryPart.Position.Y
	local distFromTiles = math.abs(PrimaryPart.Position.Y - 16.55)
	local distPosShouldChange = math.abs(distFromTiles - (scalar * distFromTiles))
	--print(distPosShouldChange)
	
	if scalar > 1 then
		model:SetPrimaryPartCFrame(CFrame.new(PrimaryPart.Position.X, primaryPartPositionY + distPosShouldChange, PrimaryPart.Position.Z))
	elseif scalar < 1 then
		model:SetPrimaryPartCFrame(CFrame.new(PrimaryPart.Position.X, primaryPartPositionY - distPosShouldChange, PrimaryPart.Position.Z))
	end
end