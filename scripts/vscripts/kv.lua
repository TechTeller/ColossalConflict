-- script that loads and stores KV data from npc_units_custom.txt and npc_abilities_custom.txt
-- these values are read-only

NPC_UNITS_CUSTOM = LoadKeyValues("scripts/npc/npc_units_custom.txt");
NPC_ABILITIES_CUSTOM = LoadKeyValues("scripts/npc/npc_abilities_custom.txt");

function GetUnitKeyValue(unitName, key)
	return NPC_UNITS_CUSTOM[unitName][key];
end

function GetAbilityKeyValue(abilityName, key)
	return NPC_ABILITIES_CUSTOM[abilityName][key];
end