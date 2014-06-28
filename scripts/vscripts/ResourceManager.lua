
LUMBER_PER_TREE = 200

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

--------------------------
------Resource: Food------
--------------------------

function OnEntityKilled( keys )
	local killedentindex = keys.entindex_killed
	local attackerentindex = keys.entindex_attacker
	local deadEntity = Entities:EntIndexToHScript( killedentindex )
	if deadEntity and deadEntity:GetTeam() == DOTA_TEAM_NEUTRALS then
		print ('Entity is in neutrals')
		--Give appropriate amount food resource to appropriate team
	end
end

--[[Ideas

----------------------------
------Resource: Lumber------
----------------------------


Design an ability that replicates quelling blade 
    Can only be used on trees
	Fires custom event called 'tree_chopped'
	Has a channeling effect that when cancelled does not reset
	Any unit can continue to channel from point where it left off
	Unit that gets the last hit will get the wood
	One tree will contain approx 100 wood
]]

function OnPickupLumber( keys )
	local itemname = keys.item_name;
	if itemname == "item_lumber" then
		
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

--------------------------
------Resource: Stone-----
--------------------------
Same as gold, but with stone.

]]