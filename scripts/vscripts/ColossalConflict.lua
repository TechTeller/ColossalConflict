-- Colossal Conflict
-------------------------------------------------------------------------------
if CCGamemode == nil then
	CCGamemode = {}
	CCGamemode.szEntityClassName = "ColossalConflict"
	CCGamemode.szNativeClassName = "dota_base_game_mode"
	CCGamemode.__index = CCGamemode
end

--------------------------------------------------------------------------------

function CCGamemode:new (o)
	o = o or {}
	setmetatable(o, self)
	return o
end

--------------------------------------------------------------------------------

--Constants
STARTER_CREEPS = 5
LUMBER_REGENERATE_TIME = 120
MAX_LEVEL = 10
MAX_PLAYERS = 2

--------------------------------------------------------------------------------

--User Data
Radiant = nil
Dire = nil
Resources = {}

nConnected = 0

Gamemode = nil

--------------------------------------------------------------------------------
function CCGamemode:InitGameMode()
	--Load main module

	--Create map of buildings
	--self:CreateMapBuildingList()

	--Setup Rules
	GameRules:SetHeroRespawnEnabled( true )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetSameHeroSelectionEnabled( false )
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:SetPreGameTime( 60.0 )
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 999999999.0 )

	print('Initializing ColossalConflict')

	--Hooks (Do game event stuff)
	ListenToGameEvent("player_connect_full", Dynamic_Wrap(CCGamemode, 'AssignPlayerToTeam'), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CCGamemode, 'OnUnitSpawn'), self)
	ListenToGameEvent("npc_killed", Dynamic_Wrap(CCGamemode, 'OnUnitKilled'), self)
  ListenToGameEvent("entity_killed", Dynamic_Wrap(CCGamemode, 'OnEntityKilled'), self)
  ListenToGameEvent("npc_spawned", Dynamic_Wrap(CCGamemode, 'OnEntitySpawned'), self)

  PrecacheUnitByName('npc_precache_everything')
end
---------------------------------------------------------------------------------	

function CCGamemode:Think()
    local gt = GameRules:GetGameTime();
    GAME_IS_PAUSED = (gt == lastGameTime);
    lastGameTime = gt;
    if not GAME_IS_PAUSED then
        UpdateTimers();
    end
end

---------------------------------------------------------------------------------

local treesinit = false;

function CCGamemode:AssignPlayerToTeam( keys )	
  self:CaptureGameMode()

  local entIndex = keys.index + 1;
   local ply = EntIndexToHScript(entIndex);
  if (nConnected < 1) then
      ply:SetTeam(DOTA_TEAM_GOODGUYS);
      Radiant = ply
      local data = GetRadiantResources()
      FireGameEvent('cc_player_resource_details', { playerID = Radiant:GetPlayerID(), lumber = data["Lumber"], gold = data["Gold"], stone = data["Stone"], food = data["Food"]})
  else
      ply:SetTeam(DOTA_TEAM_BADGUYS);
      Dire = ply
      local data  = GetDireResources()
      FireGameEvent('cc_player_resource_details', { playerID = Dire:GetPlayerID(), lumber = data["Lumber"], gold = data["Gold"], stone = data["Stone"], food = data["Food"]})
  end
  nConnected = nConnected + 1;
  local hero = CreateHeroForPlayer("npc_dota_hero_wisp", ply);
  hero:SetAbilityPoints(0)

    if treesinit == false then 
    for k,v in pairs(Entities:FindAllByClassname("ent_dota_tree")) do 
        local u = CreateUnitByName( "npc_tree_dummy", Vector(0,0,0), false, nil, nil, DOTA_TEAM_NEUTRALS)
        u:SetOrigin(v:GetOrigin())
        u:RemoveModifierByName("modifier_invulnerable")
        u:AddNewModifier(u, nil, "modifier_disarmed", {duration = -1})
    end
    treesinit = true

    --Remove invulnerabilities from all buildings on game start
    for k,v in pairs(Entities:FindAllByClassname("npc_dota_building")) do
        v:RemoveModifierByName("modifier_invulnerable")
    end
  end
end

----------------------------------------------------------------------------------

function CCGamemode:CaptureGameMode()
  if GameMode == nil then
    print('Capturing game mode...')
    GameMode = GameRules:GetGameModeEntity()		
    GameMode:SetRecommendedItemsDisabled( true )
    GameMode:SetCameraDistanceOverride( 1400.0 )
    GameMode:SetCustomBuybackCostEnabled( true )
    GameMode:SetCustomBuybackCooldownEnabled( true )
    GameMode:SetBuybackEnabled( false )
    GameMode:SetUseCustomHeroLevels ( true )
    GameMode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    GameMode:SetTopBarTeamValuesOverride ( true )
    GameMode:ClientLoadGridNav()

    InitResources()

    GameRules:SetHeroMinimapIconSize( 300 )

    print( 'Beginning Think' ) 
    GameMode:SetContextThink("CCThink", Dynamic_Wrap( CCGamemode, 'Think' ), 0.1 )
  end
end

function InitResources()
  InitRadiantResources()
  InitDireResources()
end