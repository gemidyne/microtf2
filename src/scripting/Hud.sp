int g_iCenterHudUpdateInterval = 10;
int g_iCenterHudUpdateFrame = 0;

stock void InitialiseHud()
{
    LogMessage("Initializing HUD...");
    AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Hud_OnMapStart);
    AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Hud_OnGameFrame);

    RegConsoleCmd("sm_credits", Command_ViewGamemodeCredits);
}

public void Hud_OnMapStart()
{
    int playerManagerEntity = FindEntityByClassname(MaxClients+1, "tf_player_manager");

    if (playerManagerEntity == -1)
    {
        SetFailState("Unable to find tf_player_manager entity");
    }
    else
    {
        SDKHook(playerManagerEntity, SDKHook_ThinkPost, Hook_Scoreboard);
    }

    CreateTimer(120.0, Timer_Advertise, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public void Hud_OnGameFrame()
{
    if (MaxRounds > 0 && RoundsPlayed >= MaxRounds)
    {
        return;
    }

    #if defined DEBUG
	if (GamemodeStatus != GameStatus_WaitingForPlayers && g_iCenterHudUpdateFrame > g_iCenterHudUpdateInterval)
	{
		PrintHintTextToAll("MinigameID: %i\nBossgameID: %i\nSpecialRoundID: %i\nMinigamesPlayed: %i\nSpeedLevel: %.1f", MinigameID, BossgameID, SpecialRoundID, MinigamesPlayed, SpeedLevel);
	}
	#endif

    g_iCenterHudUpdateFrame++;
	
    if (g_iCenterHudUpdateFrame > g_iCenterHudUpdateInterval)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            Player player = new Player(i);

            if (player.IsInGame && !player.IsBot)
            {
                char buffer[MINIGAME_CAPTION_LENGTH];
                Format(buffer, sizeof(buffer), MinigameCaption[i]);

                if (SpecialRoundID == 19)
                {
                    char rewritten[MINIGAME_CAPTION_LENGTH];

                    int rc = 0;
                    int len = strlen(buffer);

                    for (int c = len - 1; c >= 0; c--)
                    {
                        if (buffer[c] == '\0')
                        {
                            continue;
                        }

                        rewritten[rc] = buffer[c];
                        rc++;
                    }

                    strcopy(buffer, sizeof(buffer), rewritten);
                }

                SetHudTextParamsEx(-1.0, 0.2, 1.0, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.0, 0.0, 0.0);
                ShowSyncHudText(i, HudSync_Caption, buffer);

                DisplayScoreHud(player);
                DisplayRoundHud(player);
                DisplaySpecialHud(player);
            }
        }

        g_iCenterHudUpdateFrame = 0;
    }
}

public void DisplayScoreHud(Player player)
{
    if (!player.IsValid)
    {
        return;
    }

    char scoreText[32];

    if (SpecialRoundID == 17)
    {
        Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Minigames", player.ClientId, player.Score);
    }
    else
    {
        Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Default", player.ClientId, player.Score);
    }

    if (SpecialRoundID == 19)
    {
        char rewritten[32];
        int rc = 0;
        int len = strlen(scoreText);

        for (int c = len - 1; c >= 0; c--)
        {
            if (scoreText[c] == '\0')
            {
                continue;
            }

            rewritten[rc] = scoreText[c];
            rc++;
        }

        strcopy(scoreText, sizeof(scoreText), rewritten);
    }

    SetHudTextParamsEx(0.25, 0.94, 1.0, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
    ShowSyncHudText(player.ClientId, HudSync_Score, scoreText);
}

public void DisplayRoundHud(Player player)
{
    char roundDisplay[32];

    if (MaxRounds > 0)
    {
        Format(roundDisplay, sizeof(roundDisplay), "%T", "Hud_RoundDisplay", player.ClientId, RoundsPlayed + 1, MaxRounds);
    }
    else
    {
        Format(roundDisplay, sizeof(roundDisplay), "%T", "Hud_RoundDisplayUnlimited", player.ClientId, RoundsPlayed + 1);
    }

    if (SpecialRoundID == 19)
    {
        char rewritten[32];
        int rc = 0;
        int len = strlen(roundDisplay);

        for (int c = len - 1; c >= 0; c--)
        {
            if (roundDisplay[c] == '\0')
            {
                continue;
            }

            rewritten[rc] = roundDisplay[c];
            rc++;
        }

        strcopy(roundDisplay, sizeof(roundDisplay), rewritten);
    }

    SetHudTextParamsEx(0.01, 0.02, 1.0, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
    ShowSyncHudText(player.ClientId, HudSync_Round, roundDisplay);
}

public void DisplaySpecialHud(Player player)
{
    char themeSpecialText[32];

    if (GamemodeID == SPR_GAMEMODEID)
    {
        Format(themeSpecialText, sizeof(themeSpecialText), SpecialRounds[SpecialRoundID]);
    }
    else
    {
        Format(themeSpecialText, sizeof(themeSpecialText), "%T", "Hud_ThemeDisplay", player.ClientId, SystemNames[GamemodeID]);
    }

    if (SpecialRoundID == 19)
    {
        char rewritten[32];
        int rc = 0;
        int len = strlen(themeSpecialText);

        for (int c = len - 1; c >= 0; c--)
        {
            if (themeSpecialText[c] == '\0')
            {
                continue;
            }

            rewritten[rc] = themeSpecialText[c];
            rc++;
        }
        strcopy(themeSpecialText, sizeof(themeSpecialText), rewritten);
    }

    // THEME/SPECIAL ROUND INFO
    SetHudTextParamsEx(0.79, 0.02, 1.0, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.01, 0.05, 0.5);
    ShowSyncHudText(player.ClientId, HudSync_Special, themeSpecialText);
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

public Action Timer_Advertise(Handle timer)
{
	CPrintToChatAll("%sYou're playing WarioWare! Version %s. Say !credits in chat to view gamemode credits.", PLUGIN_PREFIX, PLUGIN_VERSION);
	return Plugin_Continue;
}

public Action Command_ViewGamemodeCredits(int client, int args)
{
    if (!IsPluginEnabled)
    {
        return Plugin_Handled;
    }

    ShowMOTDPanel(client, "WarioWare Credits", "https://www.gemidyne.com/projects/warioware/credits", MOTDPANEL_TYPE_URL);

    return Plugin_Handled;
}