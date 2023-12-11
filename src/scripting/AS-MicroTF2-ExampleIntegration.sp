#pragma semicolon 1
#if !defined REQUIRE_PLUGIN
#define REQUIRE_PLUGIN
#endif

#include <sourcemod>
#include <sdktools>
#include <warioware>
#include <mapchooser>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Microgames in Team Fortress 2: Example Integration plugin",
	author = "gemidyne",
	description = "This is an example plugin to demonstrate integration possibilities.",
	version = "1.0",
	url = "https://www.gemidyne.com/"
}

public void OnMapStart()
{
	int maxRounds = WarioWare_GetMaxRounds();

	PrintToServer("MaxRounds: %i", maxRounds);

	WarioWare_SetMaxRounds(10);
}

public void WarioWare_Intermission_StartMapVote()
{
	PrintToChatAll("Intermission_StartMapVote");
}

public bool WarioWare_Intermission_HasMapVoteEnded()
{
	PrintToChatAll("Intermission_HasMapVoteEnded");
	return true;
}

public void WarioWare_Event_OnMinigameSelected(int minigameId)
{
	PrintToChatAll("OnMinigameSelected: %i", minigameId);
}

public void WarioWare_Event_OnBossgameSelected(int bossgameId)
{
	PrintToChatAll("OnBossgameSelected: %i", bossgameId);
}

public void WarioWare_Event_OnPlayerWinMinigame(int client, int minigameId)
{
	PrintToChatAll("OnPlayerWinMinigame: %i, %i", client, minigameId);
}

public void WarioWare_Event_OnPlayerFailedMinigame(int client, int minigameId)
{
	PrintToChatAll("OnPlayerFailedMinigame: %i, %i", client, minigameId);
}

public void WarioWare_Event_OnPlayerWinBossgame(int client, int bossgameId)
{
	PrintToChatAll("OnPlayerWinBossgame: %i, %i", client, bossgameId);
}

public void WarioWare_Event_OnPlayerFailedBossgame(int client, int bossgameId)
{
	PrintToChatAll("OnPlayerFailedBossgame: %i, %i", client, bossgameId);
}

public void WarioWare_Event_OnPlayerWinRound(int client, int score)
{
	PrintToChatAll("OnPlayerWinRound: %i, score: %i", client, score);
}

public void WarioWare_Event_OnPlayerLoseRound(int client, int score)
{
	PrintToChatAll("OnPlayerLoseRound: %i, score: %i", client, score);
}

public void WarioWare_Event_OnGamemodeChanged(int id)
{
	PrintToChatAll("OnGamemodeChanged: %i", id);
}

public void WarioWare_Event_OnSpeedChange(float speed)
{
	PrintToChatAll("OnSpeedChange: %f", speed);
}

public void WarioWare_Event_OnSpecialRoundSelected(int id)
{
	PrintToChatAll("OnSpecialRoundSelected: %i", id);
}