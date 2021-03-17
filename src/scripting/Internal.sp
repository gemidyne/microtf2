/**
 * MicroTF2 - Internal.inc
 * 
 * Contains methods for internal plugin use
 */

stock int FindEntityByClassname2(int startEntityId, const char[] classname)
{
	while (startEntityID > -1 && !IsValidEntity(startEntityId)) 
	{
		startEntityId--;
	}

	return FindEntityByClassname(startEntityId, classname);
}

stock bool IsWarioWareMap()
{
	char map[32];
	GetCurrentMap(map, sizeof(map));
	
	return strncmp(PLUGIN_MAPPREFIX, map, strlen(PLUGIN_MAPPREFIX), false) == 0;
}

stock void UnloadPlugin()
{
	char fileName[244];
	GetPluginFilename(GetMyHandle(), fileName, sizeof(fileName));
	ServerCommand("sm plugins unload %s", fileName);
}

stock int GetHighestScore()
{
	int threshold = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Score > threshold)
		{
			threshold = player.Score;
		}
	}

	return threshold;
}

stock int GetLowestScore()
{
	int threshold = 999;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Score < threshold)
		{
			threshold = player.Score;
		}
	}

	return threshold;
}

stock int CalculateTeamScore(TFTeam team)
{
	int threshold = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Team == team)
		{
			threshold += player.Score;
		}
	}

	return threshold;
}

stock void EndGame()
{
	SetConVarInt(FindConVar("mp_timelimit"), 1);

	int entity = FindEntityByClassname(-1, "game_end");

	if (entity == -1)
	{
		entity = CreateEntityByName("game_end");

		if (entity == -1)
		{
			ThrowError("Unable to find and create entity \"game_end\"");
		}
	}

	AcceptEntityInput(entity, "EndGame");

	ResetConVars();
	EmitSoundToAll(SYSBGM_ENDING);
}

stock int GetActivePlayers(int team = 0, bool mustbealive = false)
{
    int output = 0;
    for (int i = 1; i <= MaxClients; i++) 
	{
		Player player = new Player(i);

		if (player.IsInGame) 
		{
			int currentTeam = view_as<int>(player.Team);
			if (((team == 0 && currentTeam >= 2) || (team > 0 && currentTeam == team)) && (!mustbealive || player.IsAlive))
			{
				output += 1;
			}
        }
    }
    return output;
}

stock void ResetGamemode()
{
	g_eGamemodeStatus = GameStatus_WaitingForPlayers;

	PrepareConVars();

	RoundsPlayed = 0;

	BossgameID = 0;
	MinigameID = 0;
	g_iSpecialRoundId = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	MinigamesPlayed = 0;
	NextMinigamePlayedSpeedTestThreshold = 0;
	
	IsMinigameActive = false;
	g_bIsGameOver = false;

	g_eDamageBlockMode = EDamageBlockMode_All;
	g_bIsBlockingKillCommands = true;
	g_bIsBlockingTaunts = true;
	g_bForceCalculationCritical = false;

	SetTeamScore(view_as<int>(TFTeam_Red), 0);
	SetTeamScore(view_as<int>(TFTeam_Blue), 0);

	for (int i = 1; i <= MaxClients; i++)
	{
		g_iPlayerScore[i] = 0;
		g_ePlayerStatus[i] = PlayerStatus_NotWon;
		g_iPlayerMinigamesWon[i] = 0;
		g_iPlayerMinigamesLost[i] = 0;
	}
}
