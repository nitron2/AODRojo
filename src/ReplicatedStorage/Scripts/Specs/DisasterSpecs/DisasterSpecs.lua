--[[**
	This module houses all of the important disaster-specific settings.
	Importantly, THE MODEL OF EACH DISASTER SHOULD BE ADJUSTED IN SIZE 
	ACCORDING TO THE SIZE OF THE SQUARE KM THAT ITS BASE DAMAGE DOES

 	@usage 
	@returns self DisasterSpecs
**--]]--Description

return {
	
	
	Fire = {
		['EffectiveAreas'] = {"Forest"},
		['AdverseAreas'] = {"City"}		
	},

	Lightning = {
		['EffectiveAreas'] = nil,
		['AdverseAreas'] = nil	
	},
	
	TropicalStorm = {
		['EffectiveAreas'] = {"Coast"},
		['AdverseAreas'] = {"Desert"}		
	},
	
	Tsunami = {
		['EffectiveAreas'] = {"TsunamiHZ"},
		['AdverseAreas'] = nil
	},
	
	AcidRain = {
		['EffectiveAreas'] = {"City"},
		['AdverseAreas'] = nil	
	}
}
