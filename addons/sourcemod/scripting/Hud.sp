#define CUSTOM_HUD_TEXT_LENGTH 32
#define CAPTION_LENGTH 256

#define HUD_RENDER_INTERVAL 10

Handle HudSync_Stats;
Handle HudSync_Caption;

int g_iCenterHudUpdateFrame = 0;
char g_sCustomHudText[MAXPLAYERS][CUSTOM_HUD_TEXT_LENGTH];
char g_sCaptionText[MAXPLAYERS][CAPTION_LENGTH];

stock void InitialiseHud()
{
    #if defined LOGGING_STARTUP
    LogMessage("Initializing HUD...");
    #endif
    
    HudSync_Stats = CreateHudSynchronizer();
    HudSync_Caption = CreateHudSynchronizer();

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
	if (GamemodeStatus != GameStatus_WaitingForPlayers && g_iCenterHudUpdateFrame > HUD_RENDER_INTERVAL)
	{
		PrintHintTextToAll("MinigameID: %i\nBossgameID: %i\nSpecialRoundID: %i\nMinigamesPlayed: %i\nSpeedLevel: %.1f", MinigameID, BossgameID, SpecialRoundID, MinigamesPlayed, SpeedLevel);
	}
	#endif

    g_iCenterHudUpdateFrame++;
	
    if (g_iCenterHudUpdateFrame > HUD_RENDER_INTERVAL)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            Player player = new Player(i);

            if (player.IsInGame && !player.IsBot)
            {
                char buffer[CAPTION_LENGTH];
                Format(buffer, sizeof(buffer), g_sCaptionText[i]);

                if (SpecialRoundID == 19)
                {
                    char rewritten[CAPTION_LENGTH];

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

                DisplayStatsHud(player);
            }
        }

        g_iCenterHudUpdateFrame = 0;
    }
}

public void DisplayStatsHud(Player player)
{
    char buffer[128];

    if (GlobalForward_OnRenderHudFrame != INVALID_HANDLE)
    {
        Call_StartForward(GlobalForward_OnRenderHudFrame);
        Call_PushCell(player.ClientId);
        Call_Finish();
    }

    if (player.HasCustomHudText())
    {
        Format(buffer, sizeof(buffer), "%s%s\n", buffer, g_sCustomHudText[player.ClientId]);
    }

    DisplayScoreHud(player, buffer);
    DisplayRoundHud(player, buffer);
    DisplaySpecialHud(player, buffer);
    
    SetHudTextParamsEx(0.2, 0.9, 1.0, { 255, 255, 255, 255 }, {0, 0, 0, 0}, 2, 0.01, 0.01, 0.01);
    ShowSyncHudText(player.ClientId, HudSync_Stats, buffer);
}

public void DisplayScoreHud(Player player, char buffer[128])
{
    if (!player.IsValid)
    {
        return;
    }

    char scoreText[32];

    switch (SpecialRoundID)
    {
        case 11:
        {
            int score = GetTeamScore(view_as<int>(player.Team));

            Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_TeamScore", player.ClientId, score);
        }

        case 17: 
        {
            Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Minigames", player.ClientId, player.Score);
        }

        default: 
        {
            Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Default", player.ClientId, player.Score);
        }
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

    Format(buffer, sizeof(buffer), "%s%s\n", buffer, scoreText);
}

public void DisplayRoundHud(Player player, char buffer[128])
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

    Format(buffer, sizeof(buffer), "%s%s\n", buffer, roundDisplay);
}

public void DisplaySpecialHud(Player player, char buffer[128])
{
    if (HideHudGamemodeText)
    {
        Format(buffer, sizeof(buffer), "%s??????\n", buffer);
        return;
    }

    char themeSpecialText[32];

    if (GamemodeID == SPR_GAMEMODEID)
    {
        char key[32];
        
        Format(key, sizeof(key), "SpecialRound%i_Name", SpecialRoundID);
        Format(themeSpecialText, sizeof(themeSpecialText), "%T", key, player.ClientId);
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

    Format(buffer, sizeof(buffer), "%s%s\n", buffer, themeSpecialText);
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
    for (int i = 1; i <= MaxClients; i++)
    {
        Player player = new Player(i);

        if (player.IsInGame && !player.IsBot)
        {
            char text[128];

            Format(text, sizeof(text), "%T", "System_Advertisement", player.ClientId, PLUGIN_VERSION);

            CPrintToChat(player.ClientId, "%s%s", PLUGIN_PREFIX, text);
        }
    }

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

void ClearMinigameCaptionForAll()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			player.DisplayOverlay(OVERLAY_BLANK);
			player.SetCaption("");
		}
	}
}

void SetCaption(int client, const char[] text)
{
    strcopy(g_sCaptionText[client], CAPTION_LENGTH, text);
}

bool HasCaption(int client)
{
    return strlen(g_sCaptionText[client]) > 0;
}

void SetCustomHudText(int client, const char[] text)
{
    strcopy(g_sCustomHudText[client], CUSTOM_HUD_TEXT_LENGTH, text);
}

bool HasCustomHudText(int client)
{
    return strlen(g_sCustomHudText[client]) > 0;
}