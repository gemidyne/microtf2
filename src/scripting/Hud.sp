public void DisplayScoreHud(Player player, float time)
{
    if (!player.IsValid)
    {
        return;
    }

    ClearSyncHud(player.ClientId, HudSync_Score);

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
            rewritten[rc] = scoreText[c];
            rc++;
        }

        strcopy(scoreText, sizeof(scoreText), rewritten);
    }

    SetHudTextParamsEx(-1.0, 0.02, time, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
    ShowSyncHudText(player.ClientId, HudSync_Score, scoreText);
}

public void DisplayRoundHud(Player player, float time)
{
    ClearSyncHud(player.ClientId, HudSync_Round);

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
            rewritten[rc] = roundDisplay[c];
            rc++;
        }

        strcopy(roundDisplay, sizeof(roundDisplay), rewritten);
    }

    SetHudTextParamsEx(0.01, 0.02, time, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.05, 0.5);
    ShowSyncHudText(player.ClientId, HudSync_Round, roundDisplay);
}

public void DisplaySpecialHud(Player player, float time)
{
    ClearSyncHud(player.ClientId, HudSync_Special);

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
            rewritten[rc] = themeSpecialText[c];
            rc++;
        }

        strcopy(themeSpecialText, sizeof(themeSpecialText), rewritten);
    }

    // THEME/SPECIAL ROUND INFO
    SetHudTextParamsEx(0.79, 0.02, time, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.01, 0.05, 0.5);
    ShowSyncHudText(player.ClientId, HudSync_Special, themeSpecialText);
}

public void InitialiseHud()
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
	CPrintToChatAll("%sYou're playing WarioWare! v%s\nPresented by Gemidyne Softworks.\nhttps://www.gemidyne.com/", PLUGIN_PREFIX, PLUGIN_VERSION);
	return Plugin_Continue;
}