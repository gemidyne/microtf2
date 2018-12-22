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
			if (IsClientValid(i)) 
			{
				char roundDisplay[32];

				if (MaxRounds > 0)
				{
					Format(roundDisplay, sizeof(roundDisplay), "%T", "Hud_RoundDisplay", i, RoundsPlayed + 1, MaxRounds);
				}
				else
				{
					Format(roundDisplay, sizeof(roundDisplay), "%T", "Hud_RoundDisplayUnlimited", i, RoundsPlayed + 1);
				}

				char scoreText[32];

				if (SpecialRoundID == 17)
				{
					Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Minigames", i, PlayerScore[i]);
				}
				else
				{
					Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Default", i, PlayerScore[i]);
				}

				char themeSpecialText[64];

				if (GamemodeID == SPR_GAMEMODEID)
				{
					Format(themeSpecialText, sizeof(themeSpecialText), SpecialRounds[SpecialRoundID]);
				}
				else
				{
					Format(themeSpecialText, sizeof(themeSpecialText), "%T", "Hud_ThemeDisplay", i, SystemNames[GamemodeID]);
				}

				ClearSyncHud(i, HudSync_Score);
				ClearSyncHud(i, HudSync_Round);
				ClearSyncHud(i, HudSync_Special);

				// SCORE
				SetHudTextParamsEx(-1.0, 0.02, time, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
				ShowSyncHudText(i, HudSync_Score, scoreText);

				// ROUND INFO
				SetHudTextParamsEx(0.01, 0.02, time, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
				ShowSyncHudText(i, HudSync_Round, roundDisplay);
			
				// TOPRIGHT
				SetHudTextParamsEx(0.79, 0.02, time, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.01, 0.05, 0.5);
				ShowSyncHudText(i, HudSync_Special, themeSpecialText);
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