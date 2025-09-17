/**
 * MicroTF2 - Internal.inc
 * 
 * Contains methods for internal plugin use
 */

stock int FindEntityByClassname2(int startEntityId, const char[] classname)
{
	while (startEntityId > -1 && !IsValidEntity(startEntityId)) 
	{
		startEntityId--;
	}

	return FindEntityByClassname(startEntityId, classname);
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

void EndGame()
{
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
	PlaySoundToAll(SYSBGM_ENDING, true);
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

void ResetGamemode()
{
	g_eGamemodeStatus = GameStatus_WaitingForPlayers;

	PrepareConVars();

	g_iTotalRoundsPlayed = 0;

	g_iActiveBossgameId = 0;
	g_iActiveMinigameId = 0;
	g_iSpecialRoundId = 0;
	g_iLastPlayedMinigameId = 0;
	g_iLastPlayedBossgameId = 0;
	g_iMinigamesPlayedCount = 0;
	g_iNextMinigamePlayedSpeedTestThreshold = 0;
	g_fActiveGameSpeed = 1.0;
	
	g_bIsMinigameActive = false;
	g_bIsGameOver = false;

	g_eDamageBlockMode = EDamageBlockMode_All;
	g_bIsBlockingKillCommands = true;
	g_bIsBlockingTaunts = true;

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
