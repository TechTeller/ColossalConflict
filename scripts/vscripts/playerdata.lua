PlayerData = {};

function InitPlayerData(playerID)
	PlayerData[playerID] = {};
	local data = PlayerData[playerID];
	data["buildings"] = 1;
	return data;
end

function GetPlayerData(playerID)
	return PlayerData[playerID];
end