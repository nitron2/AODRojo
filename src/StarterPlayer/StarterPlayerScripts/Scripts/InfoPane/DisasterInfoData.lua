local RollingDisasterFact = require(script.Parent.RollingDisasterFact)
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local InfoPane = PlayerGui.InfoPane
local CurrentFrameFolder = InfoPane.CurrentFrame

return {
	Fire = {
		index = 1,
		textCycler = nil,
		frame = CurrentFrameFolder.Fire,
		messages = {
			RollingDisasterFact.new(8, "Wildfire suppression has led to the accumulation of more fuel lying on the ground than normal. As a result, even more catastrophic wildfires have occurred."),
			RollingDisasterFact.new(7, "Wildfires play a role in the reproduction of many plant species; areas where wildfires are frequent are often more biodiverse."),
			RollingDisasterFact.new(6, "Wildfires can travel up to 20 miles per hour."),
			RollingDisasterFact.new(5, "An average of 1.2 million acres of US woodland burns every year.")
		}
	},
	Tsunami = {
		index = 1,
		frame = InfoPane.Tsunami,
		textCycler = nil,
		messages = {
			RollingDisasterFact.new(1, "On December 26, 2004, the deadliest tsunami in history occurred of the coast of Indonesia, and claimed the lives of more than 230,000 people."),
			RollingDisasterFact.new(1, "The 2004 tsunami was caused by a magnitude 9.1 earthquake that occurred on the ocean bed, shifting the seabed by as much as 40 meters."),
			RollingDisasterFact.new(1, "A tsunami is not just one wave but a series of waves, with long wavelengths, growing shorter and more destructive as they reach the shore."),
			RollingDisasterFact.new(1, "Though most commonly caused by earthquakes, causes of tsunamis include earthquakes, landslides, glaciers."),
			RollingDisasterFact.new(1, "Did you know that in the Pacific Ocean, tsunamis travel 500 miles per hour?")
		}
	},
	Lightning = {
		index = 1,
		frame = InfoPane.Lightning,
		textCycler = nil,
		messages = {
			RollingDisasterFact.new(1, "Lightning is the electrostatic discharge that occurs when oppositely charged areas within a cloud or between a cloud and the ground quickly equalize."),
			RollingDisasterFact.new(1, "The charge is held within the water and ice molecules."),
			RollingDisasterFact.new(1, "Though lightning is very hot (50,000 degrees Fahrenheit), burns occurring from lightning strikes are caused by water on the surface of the skin being instantly boiled, rather than the lightning simply burning skin."),
			RollingDisasterFact.new(1, "Lightning flashes 44 times per second on Earth; roughly 1.4 billion times a year."),
			RollingDisasterFact.new(1, "Though rarely observed scientifically, ‘ball’ lightning can occur, lasting several seconds, ranging from the size of a tennis ball to several meters wide.")
		}
	},
	AcidRain = {
		index = 1,
		frame = InfoPane.AcidRain,
		textCycler = nil,
		messages = {
			RollingDisasterFact.new(1, "Acid rain, as the name suggests, is precipitation that is unusually acidic (has low pH). It is mostly caused by human activities that involve burning fossil fuels. It causes damage to plants and animals, and man-made structures as well."),
			RollingDisasterFact.new(1, "In acid rain, the two main chemicals that react with water are sulfur dioxide and nitrogen oxide. In the case of acid rain, water serves as a base."),
			RollingDisasterFact.new(1, "Volcanoes naturally release sulfur dioxide when they interrupt, and lightning strikes release nitrogen oxide."),
			RollingDisasterFact.new(1, "Occasional pH readings in rain and fog of well below 2.4 have been reported in industrialized areas. Distilled water has a pH of 7.0.")
		}
	}
}
