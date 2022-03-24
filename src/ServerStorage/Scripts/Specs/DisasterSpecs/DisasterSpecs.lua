--[[**
	This module houses all of the important disaster-specific settings.
	Importantly, THE MODEL OF EACH DISASTER SHOULD BE ADJUSTED IN SIZE 
	ACCORDING TO THE SIZE OF THE SQUARE KM THAT ITS BASE DAMAGE DOES

 	@usage 
	@returns self DisasterSpecs
**--]]--Description

return {
	
	DamagePercColors = {
		DAMAGE_PERC_RED = Color3.fromRGB(210, 0, 0),
		DAMAGE_PERC_ORANGE = Color3.fromRGB(255, 170, 0),
		DAMAGE_PERC_YELLOW = Color3.fromRGB(255, 255, 0),
		DAMAGE_PERC_WHITE = Color3.fromRGB(255, 255, 255),
		DAMAGE_PERC_GREY = Color3.fromRGB(27, 42, 53)
	},
	
	Fire = {
		['BaseDamage'] = 100000,
		
		['NumberOfPasses'] = 10,
		['TimeBetweenPasses'] = 1,
		
		--['CoolDownTime'] = 1,
		['FatiguePercentToll'] = 10,
		['FatigueResetRate'] = 2,
		['FatigueTimeToReset'] = 1
	},

	Lightning = {
		['BaseDamage'] = 350000,
		
		['NumberOfPasses'] = 5,
		['TimeBetweenPasses'] = {0.1, 0.5},

		--['CoolDownTime'] = 10,
		['FatiguePercentToll'] = 20,
		['FatigueResetRate'] = 2,
		['FatigueTimeToReset'] = 2
	},
	
	TropicalStorm = {
		['BaseDamage'] = 200000,
		
		['NumberOfPasses'] = 10,
		['TimeBetweenPasses'] = 1,
		
		--['CoolDownTime'] = 1,
		['FatiguePercentToll'] = 10,
		['FatigueResetRate'] = 2,
		['FatigueTimeToReset'] = 1
		
--		['EffectiveAreas'] = {
--			"Coast"
--		},
--		['AdverseAreas'] = {
--			"Desert"
--		}		
	},
	
	
	Tsunami = {
		['BaseDamage'] = 100000,

		['NumberOfPasses'] = 5,
		['TimeBetweenPasses'] = 1,

		--['CoolDownTime'] = 1,
		['FatiguePercentToll'] = 10,
		['FatigueResetRate'] = 2,
		['FatigueTimeToReset'] = 1
	},
	
	AcidRain = {
		['BaseDamage'] = 100000,

		['NumberOfPasses'] = 25,
		['TimeBetweenPasses'] = .25,

		--['CoolDownTime'] = 1,
		['FatiguePercentToll'] = 15,
		['FatigueResetRate'] = 2,
		['FatigueTimeToReset'] = 1
	}
}
