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
MAX_UNITS_UNDER_CONTROL = 5
LUMBER_REGENERATE_TIME = 120
MAX_LEVEL = 10

--------------------------------------------------------------------------------

--Resources
LUMBER_COUNT = 0
GOLD_COUNT = 0
STONE_COUNT = 0
FOOD_COUNT = 0

--------------------------------------------------------------------------------

--User Data

Radiant = {}
Dire = {}
Players = {}
SteamIDs = {}


nConnected = 0
timers = {}
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

	print('Test Message')

	--Hooks (Do game event stuff)
	--ListenToGameEvent('player_connect_full', Dynamic_Wrap(CCGamemode, 'AssignPlayersToTeam'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(CCGamemode, 'AssignPlayerToTeam'), self)

	  -- Fill server with fake clients
  	Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() or DEBUG then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')
        
      self:CreateTimer('assign_fakes', {
        endTime = Time(),
        callback = function(CC, args)
          for i=0, 9 do
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

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

  --CCGameMode:thinkState( dt )

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
      local status, nextCall = pcall(v.callback, CCGameMode, v)

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

	local plIndex = keys.index + 1
	local player = EntIndexToHScript(plIndex)
	local playerID = player:GetPlayerID()

	nConnected = nConnected + 1

	if PlayerResource:IsBroadcaster(playerID) then
		return
	end

	if #Radiant > #Dire then
		player:SetTeam(DOTA_TEAM_BADGUYS)
		table.insert(Dire, player)
	else
		player:SetTeam(DOTA_TEAM_GOODGUYS)
		table.insert(Radiant, player)
	end
	playerID = player:GetPlayerID()
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

    GameRules:SetHeroMinimapIconSize( 300 )

    print( 'Beginning Think' ) 
    GameMode:SetContextThink("CCThink", Dynamic_Wrap( CCGamemode, 'Think' ), 0.1 )
  end
end