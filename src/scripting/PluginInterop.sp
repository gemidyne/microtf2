/**
 * MicroTF2 - PluginInterop.sp
 * 
 * Implements functionality for other SourceMod plugins to interact
 * with the gamemode.
 */

GlobalForward g_nfIntermissionStartMapVote;
GlobalForward g_nfIntermissionHasMapVoteEnded;
GlobalForward g_nfEventOnMinigameSelected;
GlobalForward g_nfEventOnBossgameSelected;
GlobalForward g_nfEventOnPlayerWinMinigame;
GlobalForward g_nfEventOnPlayerFailedMinigame;
GlobalForward g_nfEventOnPlayerWinBossgame;
GlobalForward g_nfEventOnPlayerFailedBossgame;
GlobalForward g_nfEventOnPlayerWinRound;
GlobalForward g_nfEventOnPlayerLoseRound;
GlobalForward g_nfEventOnGamemodeChanged;
GlobalForward g_nfEventOnSpeedChange;
GlobalForward g_nfEventOnSpecialRoundSelected;

void InitializePluginForwards()
{
	g_nfIntermissionStartMapVote = new GlobalForward("WarioWare_Intermission_StartMapVote", ET_Ignore);
	g_nfIntermissionHasMapVoteEnded = new GlobalForward("WarioWare_Intermission_HasMapVoteEnded", ET_Single);
	g_nfEventOnMinigameSelected = new GlobalForward("WarioWare_Event_OnMinigameSelected", ET_Ignore, Param_Any);
	g_nfEventOnBossgameSelected = new GlobalForward("WarioWare_Event_OnBossgameSelected", ET_Ignore, Param_Any);
	g_nfEventOnPlayerWinMinigame = new GlobalForward("WarioWare_Event_OnPlayerWinMinigame", ET_Ignore, Param_Any, Param_Any);
	g_nfEventOnPlayerFailedMinigame = new GlobalForward("WarioWare_Event_OnPlayerFailedMinigame", ET_Ignore, Param_Any, Param_Any);
	g_nfEventOnPlayerWinBossgame = new GlobalForward("WarioWare_Event_OnPlayerWinBossgame", ET_Ignore, Param_Any, Param_Any);
	g_nfEventOnPlayerFailedBossgame = new GlobalForward("WarioWare_Event_OnPlayerFailedBossgame", ET_Ignore, Param_Any, Param_Any);
	g_nfEventOnPlayerWinRound = new GlobalForward("WarioWare_Event_OnPlayerWinRound", ET_Ignore, Param_Any, Param_Any);
	g_nfEventOnPlayerLoseRound = new GlobalForward("WarioWare_Event_OnPlayerLoseRound", ET_Ignore, Param_Any, Param_Any);
	g_nfEventOnGamemodeChanged = new GlobalForward("WarioWare_Event_OnGamemodeChanged", ET_Ignore, Param_Any);
	g_nfEventOnSpeedChange = new GlobalForward("WarioWare_Event_OnSpeedChange", ET_Ignore, Param_Float);
	g_nfEventOnSpecialRoundSelected = new GlobalForward("WarioWare_Event_OnSpecialRoundSelected", ET_Ignore, Param_Any);
}

void InitializePluginNatives()
{
	CreateNative("WarioWare_GetMaxRounds", Native_WarioWare_GetMaxRounds);
	CreateNative("WarioWare_SetMaxRounds", Native_WarioWare_SetMaxRounds);
}

public bool PluginForward_HasMapIntegrationLoaded()
{
	return GetForwardFunctionCount(g_nfIntermissionStartMapVote) > 0 && GetForwardFunctionCount(g_nfIntermissionHasMapVoteEnded) > 0;
}

public void PluginForward_StartMapVote()
{
	if (GetForwardFunctionCount(g_nfIntermissionStartMapVote) == 0)
	{
		return;
	}

	Call_StartForward(g_nfIntermissionStartMapVote);
	Call_Finish();
}

public bool PluginForward_HasMapVoteEnded()
{
	if (GetForwardFunctionCount(g_nfIntermissionHasMapVoteEnded) > 0)
	{
		bool voteIsInProgress = false;

		Call_StartForward(g_nfIntermissionHasMapVoteEnded);
		Call_Finish(voteIsInProgress);

		return voteIsInProgress;
	}
	
	return true;
}

public void PluginForward_SendMinigameSelected(int minigameId)
{
	Call_StartForward(g_nfEventOnMinigameSelected);
	Call_PushCell(minigameId);
	Call_Finish();
}

public void PluginForward_SendBossgameSelected(int bossgameId)
{
	Call_StartForward(g_nfEventOnBossgameSelected);
	Call_PushCell(bossgameId);
	Call_Finish();
}

public void PluginForward_SendPlayerWinMinigame(int client, int minigameId)
{
	Call_StartForward(g_nfEventOnPlayerWinMinigame);
	Call_PushCell(client);
	Call_PushCell(minigameId);
	Call_Finish();
}

public void PluginForward_SendPlayerFailedMinigame(int client, int minigameId)
{
	Call_StartForward(g_nfEventOnPlayerFailedMinigame);
	Call_PushCell(client);
	Call_PushCell(minigameId);
	Call_Finish();
}

public void PluginForward_SendPlayerWinBossgame(int client, int bossgameId)
{
	Call_StartForward(g_nfEventOnPlayerWinBossgame);
	Call_PushCell(client);
	Call_PushCell(bossgameId);
	Call_Finish();
}

public void PluginForward_SendPlayerFailedBossgame(int client, int bossgameId)
{
	Call_StartForward(g_nfEventOnPlayerFailedBossgame);
	Call_PushCell(client);
	Call_PushCell(bossgameId);
	Call_Finish();
}

public void PluginForward_SendPlayerWinRound(int client, int score)
{
	Call_StartForward(g_nfEventOnPlayerWinRound);
	Call_PushCell(client);
	Call_PushCell(score);
	Call_Finish();
}

public void PluginForward_SendPlayerLoseRound(int client, int score)
{
	Call_StartForward(g_nfEventOnPlayerLoseRound);
	Call_PushCell(client);
	Call_PushCell(score);
	Call_Finish();
}

public void PluginForward_SendGamemodeChanged(int gamemodeId)
{
	Call_StartForward(g_nfEventOnGamemodeChanged);
	Call_PushCell(gamemodeId);
	Call_Finish();
}

public void PluginForward_SendSpeedChange(float speed)
{
	Call_StartForward(g_nfEventOnSpeedChange);
	Call_PushFloat(speed);
	Call_Finish();
}

public void PluginForward_SendSpecialRoundSelected(int id)
{
	Call_StartForward(g_nfEventOnSpecialRoundSelected);
	Call_PushCell(id);
	Call_Finish();
}

public int Native_WarioWare_GetMaxRounds(Handle plugin, int numParams)
{
	return g_iMaxRoundsPlayable;
}

public int Native_WarioWare_SetMaxRounds(Handle plugin, int numParams)
{
	int value = GetNativeCell(1);

	if (value < 0)
	{
		value = 0;
	}

	g_hConVarPluginMaxRounds.IntValue = value;

	return 0;
}