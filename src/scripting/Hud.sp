#define CUSTOM_HUD_TEXT_LENGTH 32
#define CAPTION_LENGTH 256

#define HUD_RENDER_INTERVAL 10

Handle g_hHudSyncStats;
Handle g_hHudSyncCaption;

int g_iCenterHudUpdateFrame = 0;
char g_sCustomHudText[MAXPLAYERS][CUSTOM_HUD_TEXT_LENGTH];
char g_sCaptionText[MAXPLAYERS][CAPTION_LENGTH];

stock void InitialiseHud()
{
    #if defined LOGGING_STARTUP
    LogMessage("Initializing HUD...");
    #endif
    
    g_hHudSyncStats = CreateHudSynchronizer();
    g_hHudSyncCaption = CreateHudSynchronizer();

    AddToForward(g_pfOnMapStart, INVALID_HANDLE, Hud_OnMapStart);
    AddToForward(g_pfOnGameFrame, INVALID_HANDLE, Hud_OnGameFrame);

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
    if (!TimelimitManager_HasTimeLimit() && g_iMaxRoundsPlayable > 0 && g_iTotalRoundsPlayed >= g_iMaxRoundsPlayable)
    {
        return;
    }

    #if defined DEBUG
	if (g_eGamemodeStatus != GameStatus_WaitingForPlayers && g_iCenterHudUpdateFrame > HUD_RENDER_INTERVAL)
	{
		PrintHintTextToAll("g_iActiveMinigameId: %i\nBossgameID: %i\nSpecialRoundID: %i\nMinigamesPlayed: %i\nSpeedLevel: %.1f", g_iActiveMinigameId, g_iActiveBossgameId, g_iSpecialRoundId, g_iMinigamesPlayedCount, g_fActiveGameSpeed);
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

                if (g_iSpecialRoundId == 19)
                {
                    char rewritten[CAPTION_LENGTH];
                    ReverseString(buffer, sizeof(buffer), rewritten);
                    strcopy(buffer, sizeof(buffer), rewritten);
                }

                SetHudTextParamsEx(-1.0, 0.2, 1.0, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.0, 0.0, 0.0);
                ShowSyncHudText(i, g_hHudSyncCaption, buffer);

                DisplayStatsHud(player);
            }
        }

        g_iCenterHudUpdateFrame = 0;
    }
}

public void DisplayStatsHud(Player player)
{
    char buffer[128];

    if (g_pfOnRenderHudFrame != INVALID_HANDLE)
    {
        Call_StartForward(g_pfOnRenderHudFrame);
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
    ShowSyncHudText(player.ClientId, g_hHudSyncStats, buffer);
}

public void DisplayScoreHud(Player player, char buffer[128])
{
    if (!player.IsValid)
    {
        return;
    }

    char scoreText[32];

    switch (g_iSpecialRoundId)
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

    if (g_iSpecialRoundId == 19)
    {
        char rewritten[32];
        ReverseString(scoreText, sizeof(scoreText), rewritten);
        strcopy(scoreText, sizeof(scoreText), rewritten);
    }

    Format(buffer, sizeof(buffer), "%s%s\n", buffer, scoreText);
}

public void DisplayRoundHud(Player player, char buffer[128])
{
    char roundDisplay[32];

    if (TimelimitManager_HasTimeLimit() || g_iMaxRoundsPlayable <= 0)
    {
        Format(roundDisplay, sizeof(roundDisplay), "%T", "Hud_RoundDisplayUnlimited", player.ClientId, g_iTotalRoundsPlayed + 1);
    }
    else
    {
        Format(roundDisplay, sizeof(roundDisplay), "%T", "Hud_RoundDisplay", player.ClientId, g_iTotalRoundsPlayed + 1, g_iMaxRoundsPlayable);
    }

    if (g_iSpecialRoundId == 19)
    {
        char rewritten[32];
        ReverseString(roundDisplay, sizeof(roundDisplay), rewritten);
        strcopy(roundDisplay, sizeof(roundDisplay), rewritten);
    }

    Format(buffer, sizeof(buffer), "%s%s\n", buffer, roundDisplay);
}

public void DisplaySpecialHud(Player player, char buffer[128])
{
    if (g_bHideHudGamemodeText)
    {
        Format(buffer, sizeof(buffer), "%s??????\n", buffer);
        return;
    }

    char themeSpecialText[32];

    if (g_iActiveGamemodeId == SPR_GAMEMODEID)
    {
        char key[32];
        
        Format(key, sizeof(key), "SpecialRound%i_Name", g_iSpecialRoundId);
        Format(themeSpecialText, sizeof(themeSpecialText), "%T", key, player.ClientId);
    }
    else
    {
        Format(themeSpecialText, sizeof(themeSpecialText), "%T", "Hud_ThemeDisplay", player.ClientId, g_sGamemodeThemeName[g_iActiveGamemodeId]);
    }

    if (g_iSpecialRoundId == 19)
    {
        char rewritten[32];
        ReverseString(themeSpecialText, sizeof(themeSpecialText), rewritten);
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
            player.PrintChatText("%T", "System_Advertisement", player.ClientId, PLUGIN_VERSION);
        }
    }

    return Plugin_Continue;
}

public Action Command_ViewGamemodeCredits(int client, int args)
{
    if (!g_bIsPluginEnabled)
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