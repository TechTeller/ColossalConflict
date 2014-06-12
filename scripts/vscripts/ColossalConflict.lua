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

vPlayers = {}
vRadiant = {}
vDire = {}
vUserIds = {}

nConnected = 0

--Options
USE_LOBBY = false

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
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(CCGamemode, 'AssignPlayersToTeam'), self)

	self.thinkHookStop = completeHack( "CCGamemode", Dynamic_Wrap( CCGamemode, 'Think' ), 0.25, self)
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------

function CCGamemode:Think()
	-- Check for players being connected.
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local bAnyPlayerConnected = false
		for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				-- If a player is connected (2) then we're ok
				if PlayerResource:GetConnectionState( nPlayerID ) == 2 then
					bAnyPlayerConnected = true
				end
			end
		end
		if not bAnyPlayerConnected then
			Msg( "No players are connected, setting the winner to DOTA_TEAM_BADGUYS...\n" )
			GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
		end
	end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
			if PlayerResource:GetNthPlayerIDOnTeam(nPlayerID, DOTA_TEAM_GOODGUYS) then
			end
		end
	end
end

---------------------------------------------------------------------------------

function CCGamemode:AssignPlayersToTeam( keys )

	self:CaptureGameMode()
	local entIndex = keys.index + 1
	local ply = EntIndexToHScript( entIndex )
	local playerID = ply:GetPlayerID()
	nConnected = nConnected + 1

	if PlayerResource:IsBroadcaster(playerID) then
		return
	end

	if vPlayers[playerID] ~= nil then
		vUserIds[playerID] = nil
		vUserIds[keys.userid] = ply
	end

	if not USE_LOBBY and playerID == -1 then
		if #vRadiant > #vDire then
			ply:SetTeam(DOTA_TEAM_BADGUYS)
			ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_BADGUYS)
      		table.insert (vDire, ply)
      	else
      		ply:SetTeam(DOTA_TEAM_GOODGUYS)
      		ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_GOODGUYS)
      		table.insert (vRadiant, ply)
		end
		playerID = ply:GetPlayerID()
	end
end

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
    GameMode:SetContextThink("CCThink", Dynamic_Wrap( CCGamemode, 'Think' ), 0.25 )
  end
end