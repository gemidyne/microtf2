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