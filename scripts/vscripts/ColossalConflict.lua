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

Radiant = 0
Dire = 0

Resources = {}

nConnected = 0
availableSpawnIndex = 0
CCGamemode.timers = {}
--Options
USE_LOBBY = false

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
	GameRules:SetTreeRegrowTime( LUMBER_REGENERATE_TIME )

	print('Initializing ColossalConflict')

	--Hooks (Do game event stuff)
	ListenToGameEvent("player_connect_full", Dynamic_Wrap(CCGamemode, 'AssignPlayerToTeam'), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CCGamemode, 'OnUnitSpawn'), self)
	ListenToGameEvent("npc_killed", Dynamic_Wrap(CCGamemode, 'OnUnitKilled'), self)
  ListenToGameEvent("entity_killed", Dynamic_Wrap(CCGamemode, 'OnEntityKilled'), self)

  PrecacheUnitByName('npc_precache_everything')
end
---------------------------------------------------------------------------------	

function CCGamemode:Think()

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then

	end
	  -- If the game's over, it's over.
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return
  end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()
  --print("now: " .. now)
  if CCGamemode.t0 == nil then
    CCGamemode.t0 = now
  end

  local dt = now - CCGamemode.t0
  CCGamemode.t0 = now

  --CCGamemode:thinkState( dt )

  -- Process timers
  for k,v in pairs(CCGamemode.timers) do
    local bUseGameTime = false
    if v.useGameTime and v.useGameTime == true then
      bUseGameTime = true;
    end
    -- Check if the timer has finished
    if (bUseGameTime and GameRules:GetGameTime() > v.endTime) or (not bUseGameTime and Time() > v.endTime) then
      -- Remove from timers list
      CCGamemode.timers[k] = nil

      -- Run the callback
      local status, nextCall = pcall(v.callback, CCGamemode, v)

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall then
          -- Change it's end time
          v.endTime = nextCall
          CCGamemode.timers[k] = v
        end

      else
        -- Nope, handle the error
        CCGamemode:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return THINK_TIME
end

---------------------------------------------------------------------------------

function CCGamemode:AssignPlayerToTeam( keys )
	self:CaptureGameMode()

    local entIndex = keys.index + 1;
    local ply = EntIndexToHScript(entIndex);
    if (Radiant < 5) then
        ply:SetTeam(DOTA_TEAM_GOODGUYS);
        Radiant = Radiant + 1;
    else
        ply:SetTeam(DOTA_TEAM_BADGUYS);
        Dire = self.direPlayers + 1;
    end
    nConnected = nConnected + 1;
    CreateHeroForPlayer("npc_dota_hero_wisp", ply);

    --we must add a delay before we move the hero
    CreateTimer("SpawnPlayer"..entIndex, DURATION, {
        duration = 1,
        player = ply,

        callback = function(timer)
            local hero = ply:GetAssignedHero();
            InitalizeHero(ply:GetPlayerID(), hero);

            playerSpawnIndexes[ply:GetPlayerID()] = ply:GetPlayerID() + 1;
            table.insert(players, ply);
            self.availableSpawnIndex = self.availableSpawnIndex + 1;
        end
    });
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