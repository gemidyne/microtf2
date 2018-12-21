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
	CPrintToChatAll("%sYou're playing MicroTF2! - v%s", PLUGIN_PREFIX, PLUGIN_VERSION);
	CPrintToChatAll("%sBy Stevu (Anarchy Steven), TestingLol & Mario6493!", PLUGIN_PREFIX);
	CPrintToChatAll("%shttps://gemini.software/", PLUGIN_PREFIX);

	return Plugin_Continue;
}

//stock Handle:CreateGameTimer(Float:interval, Timer:func, any:data=INVALID_HANDLE, flags=0)
//{
//	return CreateTimer(interval, func, data, flags);
//}

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
		if (IsClientValid(i) && PlayerScore[i] > threshold)
		{
			threshold = PlayerScore[i];
		}
	}

	return threshold;
}

stock int GetLowestScore()
{
	int threshold = 999;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientValid(i) && PlayerScore[i] < threshold)
		{
			threshold = PlayerScore[i];
		}
	}

	return threshold;
}

stock void ShowPlayerScores(bool showText)
{
	char scoreText[64];

	if (SpecialRoundID == 17)
	{
		scoreText = "Minigames";
	}
	else
	{
		scoreText = "Score";
	}

	if (showText)
	{
		float time = 6.0; // 4 secs with an extra 2 seconds incase of any GameLogic event

		if (BossgameID > 0)
		{
			// If this was called and a Bossgame is selected, it should be displayed for the maximum time
			// that the boss will run for.
			time += BossgameLength[BossgameID];
		}

		char HSSpecialText[64];

		if (GamemodeID == SPR_GAMEMODEID)
		{
			Format(HSSpecialText, sizeof(HSSpecialText), SpecialRounds[SpecialRoundID]);
		}
		else
		{
			Format(HSSpecialText, sizeof(HSSpecialText), "Theme: %s", SystemNames[GamemodeID]);
		}

		for (int i = 1; i <= MaxClients; i++) 
		{
			if (IsClientValid(i)) 
			{
				ClearSyncHud(i, HudSync_Score);
				ClearSyncHud(i, HudSync_Round);
				ClearSyncHud(i, HudSync_Special);

				SetHudTextParamsEx(-1.0, 0.02, time, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
				ShowSyncHudText(i, HudSync_Score, "%s: %d", scoreText, PlayerScore[i]);

				// Prepare Hud Params for Round
				SetHudTextParamsEx(0.01, 0.02, time, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);

				if (MaxRounds == 0)
				{
					// If there is no max rounds, just display what round it is
					ShowSyncHudText(i, HudSync_Round, "Round: %d", RoundsPlayed);
				}
				else
				{
					ShowSyncHudText(i, HudSync_Round, "Round: %d of %d", RoundsPlayed, MaxRounds);
				}

				SetHudTextParamsEx(0.79, 0.02, time, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.01, 0.05, 0.5);
				ShowSyncHudText(i, HudSync_Special, HSSpecialText);
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
		if (IsClientValid(i)) 
		{
			total[i] = PlayerScore[i];
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
	EmitSoundToAll(SYSMUSIC_MAPEND);
}

stock int GetActivePlayers(int team = 0, bool mustbealive = false)
{
    int output = 0;
    for (int i = 1; i <= MaxClients; i++) 
	{
        if (IsClientInGame(i)) 
		{
			int currentTeam = GetClientTeam(i);
			if (((team == 0 && currentTeam >= 2) || (team > 0 && currentTeam == team)) && (!mustbealive || IsPlayerAlive(i)))
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
		if (IsClientValid(i) && (!mustbealive || IsPlayerAlive(i)))
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