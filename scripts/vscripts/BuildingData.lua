BuildingData = {};

function InitBuildingData(tower, class)
	local entindex = tower:entindex();
	BuildingData[entindex] = {};
	local data =  BuildingData[entindex];

	data["class"] = class;
	data["cost"] = GetUnitKeyValue(class, "Cost");
	return data;
end

function GetBuildingData()
	return BuildingData[entindex];
end

function DeleteBuildingData()
	BuildingData[entindex] = nil;
end

function GetCostForBuilding(class)
	return GetUnitKeyValue(class, "Cost");
end