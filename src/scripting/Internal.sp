/**
 * MicroTF2 - Internal.inc
 * 
 * Contains methods for internal plugin use
 */

stock int FindEntityByClassname2(int startEntityID, const char[] classname)
{
	while (startEntityID > -1 && !IsValidEntity(startEntityID)) 
	{
		startEntityID--;
	}

	return FindEntityByClassname(startEntityID, classname);
}

stock bool IsWarioWareMap()
{
	char curMap[32];
	GetCurrentMap(curMap, sizeof(curMap));
	return strncmp("MicroTF2_", curMap, 6, false) == 0 || strncmp("warioware_", curMap, 11, false) == 0;
}

stock void UnloadPlugin()
{
	SecuritySystem_IgnoreServerCmdCheckOnce = true;

	char fileName[244];
	GetPluginFilename(GetMyHandle(), fileName, sizeof(fileName));
	ServerCommand("sm plugins unload %s", fileName);
}

stock void PreloadSound(const char[] sound)
{
	if (strlen(sound) == 0)
	{
		return;
	}

	char fileName[128];
	
	PrecacheSound(sound, true);
	Format(fileName, sizeof(fileName), "sound/%s", sound);
	
	AddFileToDownloadsTable(fileName);
}

public Action GamemodeAdvertisement(Handle timer)
{
	CPrintToChatAll("%sYou're playing WarioWare! - v%s", PLUGIN_PREFIX, PLUGIN_VERSION);
	CPrintToChatAll("%sBy Stevu (Anarchy Steven), TestingLol & Mario6493!", PLUGIN_PREFIX);
	CPrintToChatAll("%shttps://gemini.software/", PLUGIN_PREFIX);

	return Plugin_Continue;
}

stock int GetSoundMultiplier()
{
	return SNDPITCH_NORMAL + RoundToCeil(((SpeedLevel-1.0) * 10)*8.0);
}

stock void SetSpeed()
{
	// Boundary Checks
	if (SpeedLevel > 2.5)
	{
		SpeedLevel = 2.5;
	}

	if (SpeedLevel < 0.4)
	{
		SpeedLevel = 0.4;
	}

	SetConVarFloat(ConVar_HostTimescale, SpeedLevel);
	SetConVarFloat(ConVar_PhysTimescale, SpeedLevel);
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

stock void ShowPlayerScores(bool showText)
{
	if (showText)
	{
		float time = 6.0; // 4 secs with an extra 2 seconds incase of any GameLogic event

		if (BossgameID > 0)
		{
			// If this was called and a Bossgame is selected, it should be displayed for the maximum time
			// that the boss will run for.
			time += BossgameLength[BossgameID];
		}

		for (int i = 1; i <= MaxClients; i++) 
		{
			Player player = new Player(i);

			if (player.IsInGame)
			{
				DisplayScoreHud(player, time);
				DisplayRoundHud(player, time);
				DisplaySpecialHud(player, time);
			}
		}
	}
}

public void Hook_Scoreboard(int entity)
{
	static int totalScoreOffset = -1;
	int total[MAXPLAYERS+1];

	if (totalScoreOffset == -1) 
	{
		totalScoreOffset = FindSendPropInfo("CTFPlayerResource", "m_iTotalScore");
	}
    
	GetEntDataArray(entity, totalScoreOffset, total, MaxClients+1);

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid)
		{
			total[i] = player.Score;
		}
	}

	SetEntDataArray(entity, totalScoreOffset, total, MaxClients+1);
}

stock void EndGame()
{
	SetConVarInt(FindConVar("mp_timelimit"), 1);
	ShowPlayerScores(true);

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

stock void UpdatePlayerIndexes(bool mustbealive = false)
{
	int id = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && (!mustbealive || player.IsAlive))
		{
			id += 1;
			PlayerIndex[i] = id;
		}
	}
}

stock void ResetGamemode()
{
	GamemodeStatus = GameStatus_WaitingForPlayers;

	PrepareConVars();

	RoundsPlayed = 1;

	BossgameID = 0;
	MinigameID = 0;
	SpecialRoundID = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	MinigamesPlayed = 0;
	
	IsMinigameActive = false;
	IsBonusRound = false;

	IsBlockingDamage = true;
	IsOnlyBlockingDamageByPlayers = false;
	IsBlockingDeathCommands = true;
	IsBlockingTaunts = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		PlayerScore[i] = 0;
		PlayerStatus[i] = PlayerStatus_NotWon;
		PlayerMinigamesWon[i] = 0;
		PlayerMinigamesLost[i] = 0;
	}
}

stock void ReverseString(const char[] input, char[] buffer, int size)
{
	new String:rewritten[size];
	new rc = 0;
	new len = strlen(input);

	for (new c = len - 1; c >= 0; c--)
	{
		rewritten[rc] = input[c];
		rc++;
	}

	strcopy(buffer, size, rewritten);
}