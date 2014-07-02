firstSpawn = true

RadiantUnits = {}
nRadiant = 0
DireUnits = {}
nDire = 0

function CCGamemode:OnUnitSpawn( keys )
	local spawnedUnit = EntIndexToHScript( keys.entindex )

	if spawnedUnit:GetUnitName() == "npc_cc_good_villager" then
		--Do something on spawn
	end
	--local vSpawnLocation = spawner:GetOrigin()


	--Check if spawned unit is a hero
	if spawnedUnit:IsHero() then
		local spawner = Entities:CreateByClassname('npc_dota_spawner')
		spawner:SetOrigin(Vector(-368.79, -731.49, 1))
		if not spawner then
			print ( "Failed to find spawner" )
		end
		if firstSpawn == true then
			for i=0,4 do
				CCGamemode:CreateControlledUnit("npc_cc_good_villager",spawnedUnit, spawner)
			end
			firstSpawn = false;
		end
	end
end

function CCGamemode:CreateControlledUnit( name , caster, spawner)
	local playerID = caster:GetPlayerID()
	local vSpawnLocation = spawner:GetOrigin()
	vSpawnLocation = vSpawnLocation + RandomVector(400)
	local unit = CreateUnitByName( name, vSpawnLocation, true, nil, nil, caster:GetTeam())
	unit:SetControllableByPlayer( playerID, true )
	unit:SetOwner(caster)

	if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
		nRadiant = nRadiant + 1
		RadiantUnits[nRadiant] = unit
	elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then
		nDire = nDire + 1
		DireUnits[nDire] = unit
	end
end

function CCGamemode:OnUnitKilled( keys )
	local spawnedUnit = EntIndexToHScript( keys.entindex )

	if spawnedUnit:GetUnitName() == "npc_cc_good_villager" then
		if spawnedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
			RadiantUnits[nRadiant] = nil
			nRadiant = nRadiant - 1
		elseif spawnedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
			DireUnits[nRadiant] = nil
			nDire = nDire - 1
		end
	end
end