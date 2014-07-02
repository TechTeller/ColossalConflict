
----------------------------------------------------------------------------------------------------
MineFirstSpawn = true
LUMBER_PER_TREE = 100
GOLD_PER_MINE = 1500
STONE_PER_MINE = 1000
MineLocs = {}
MineLocs["radiant1"] = Vector(3088.82, -9.75, 65)
MineFirstSpawn = true

-----Initialize and write getters and setters for each team's resources------

function InitRadiantResources()
	Resources[DOTA_TEAM_GOODGUYS] = {}
	local data = Resources[DOTA_TEAM_GOODGUYS]
	data["Lumber"] = 0
	data["Gold"] = 0
	data["Stone"] = 0
	data["Food"] = 0
	return data;
end

function GetRadiantResources()
	return Resources[DOTA_TEAM_GOODGUYS]
end

function InitDireResources()
	Resources[DOTA_TEAM_BADGUYS] = {}
	local data = Resources[DOTA_TEAM_BADGUYS]
	data["Lumber"] = 0
	data["Gold"] = 0
	data["Stone"] = 0
	data["Food"] = 0
	return data;
end

function GetDireResources()
	return Resources[DOTA_TEAM_BADGUYS]
end

-------Event Handler functions for each resource------------

--------------------------/----------------------------
------Resource: Food------/------Resource: Lumber------
--------------------------/----------------------------

function CCGamemode:OnEntityKilled( keys )
	local killedEntity = EntIndexToHScript( keys.entindex_killed )
	local killerEntity = EntIndexToHScript( keys.entindex_attacker )
	local data  = nil
	if killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
		data = GetRadiantResources()
	elseif killerEntity:GetTeam() == DOTA_TEAM_BADGUYS then
		data = GetDireResources()
	end
	if killedEntity:GetUnitName() == 'npc_tree_dummy' then
		local ab = killerEntity:FindAbilityByName("ability_destroytree")
		ab:SetLevel(1)
		killerEntity:CastAbilityOnPosition( killedEntity:GetOrigin(), ab, 0 )

		data["Lumber"] = data["Lumber"] + LUMBER_PER_TREE
		print ('Added '..LUMBER_PER_TREE..' to wood stockpile ('..data["Lumber"]..')')
	end
	if killedEntity:GetUnitName() == 'npc_gold_mine' then
		local emptyMine = CreateUnitByName('npc_mine_empty', killedEntity:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
		--Change model to empty mine
		data["Gold"] = data["Gold"] + GOLD_PER_MINE
		print ('Added '..GOLD_PER_MINE..' to gold stockpile ('..data["Gold"]..')')
	end
	if killedEntity:GetUnitName() == 'npc_stone_mine' then
		local emptyMine = CreateUnitByName('npc_mine_empty', killedEntity:GetOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
		--Change model to empty mine
		data["Stone"] = data["Stone"] + STONE_PER_MINE
		print ('Added '..STONE_PER_MINE..' to stone stockpile ('..data["Stone"]..')')
	end
	--else if it is a normal neutral creep
		--Give appropriate amount food resource to appropriate team
	if killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
		FireGameEvent('cc_player_resource_details', { playerID = Radiant:GetPlayerID(), lumber = data["Lumber"], gold = data["Gold"], stone = data["Stone"], food = data["Food"]})
	elseif killerEntity:GetTeam() == DOTA_TEAM_BADGUYS then
		FireGameEvent('cc_player_resource_details', { playerID = Dire:GetPlayerID(), lumber = data["Lumber"], gold = data["Gold"], stone = data["Stone"], food = data["Food"]})
	end
end

--[[
--------------------------
------Resource: Gold------
--------------------------
Mining ability
	Can only be used on mines in resource pits
	Fires custom event 'ore_mined'
	Has a channeling effect that when cancelled does not reset
	Any unit can continue to channel from point where it left off
	Unit that gets the last hit will get the gold
	One mine will contain 75-100 gold
]]

--[[
--------------------------
------Resource: Stone-----
--------------------------
Same as gold, but with stone.

]]