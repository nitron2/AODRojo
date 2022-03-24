local Settings = {}

--s.AreaTypes = {"Forest", "City", "Coast", "Country", "Desert", "Faultline"} 
Settings.WORLD_HEIGHT = 16.55

Settings.PointsContainerSize = Vector3.new(0.05, 0.05, 0.05)
Settings.PointsContainerLocation = CFrame.new(251.95, 0.5, 251.97)

Settings.INITIAL_AREA_SEGMENTS_TRANSPARENCY = NumberSequence.new({ -- beam fades out at the end
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(1, 0.75)
	}
)
Settings.DEFUALT_AREA_SEGMENTS_TRANSPARENCY = NumberSequence.new({ -- beam fades out at the end
		NumberSequenceKeypoint.new(0, .75),
		NumberSequenceKeypoint.new(1, .75)
	}
)
Settings.DEFUALT_AREA_SEGMENTS_COLOR = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}
)

return Settings