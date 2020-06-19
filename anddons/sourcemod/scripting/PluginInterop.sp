/**
 * MicroTF2 - PluginInterop.sp
 * 
 * Implements functionality for other SourceMod plugins to interact
 * with the gamemode.
 */

Handle PluginForward_IntermissionStartMapVote;
Handle PluginForward_IntermissionHasMapVoteEnded;
Handle PluginForward_EventOnMinigameSelected;
Handle PluginForward_EventOnBossgameSelected;
Handle PluginForward_EventOnPlayerWinMinigame;
Handle PluginForward_EventOnPlayerFailedMinigame;
Handle PluginForward_EventOnPlayerWinBossgame;
Handle PluginForward_EventOnPlayerFailedBossgame;
Handle PluginForward_EventOnPlayerWinRound;
Handle PluginForward_EventOnPlayerLoseRound;
Handle PluginForward_EventOnGamemodeChanged;
Handle PluginForward_EventOnSpeedChange;
Handle PluginForward_EventOnSpecialRoundSelected;

stock void InitializePluginForwards()
{
	PluginForward_IntermissionStartMapVote = CreateGlobalForward("WarioWare_Intermission_StartMapVote", ET_Ignore);
	PluginForward_IntermissionHasMapVoteEnded = CreateGlobalForward("WarioWare_Intermission_HasMapVoteEnded", ET_Single);
	PluginForward_EventOnMinigameSelected = CreateGlobalForward("WarioWare_Event_OnMinigameSelected", ET_Ignore, Param_Any);
	PluginForward_EventOnBossgameSelected = CreateGlobalForward("WarioWare_Event_OnBossgameSelected", ET_Ignore, Param_Any);
	PluginForward_EventOnPlayerWinMinigame = CreateGlobalForward("WarioWare_Event_OnPlayerWinMinigame", ET_Ignore, Param_Any, Param_Any);
	PluginForward_EventOnPlayerFailedMinigame = CreateGlobalForward("WarioWare_Event_OnPlayerFailedMinigame", ET_Ignore, Param_Any, Param_Any);
	PluginForward_EventOnPlayerWinBossgame = CreateGlobalForward("WarioWare_Event_OnPlayerWinBossgame", ET_Ignore, Param_Any, Param_Any);
	PluginForward_EventOnPlayerFailedBossgame = CreateGlobalForward("WarioWare_Event_OnPlayerFailedBossgame", ET_Ignore, Param_Any, Param_Any);
	PluginForward_EventOnPlayerWinRound = CreateGlobalForward("WarioWare_Event_OnPlayerWinRound", ET_Ignore, Param_Any, Param_Any);
	PluginForward_EventOnPlayerLoseRound = CreateGlobalForward("WarioWare_Event_OnPlayerLoseRound", ET_Ignore, Param_Any, Param_Any);
	PluginForward_EventOnGamemodeChanged = CreateGlobalForward("WarioWare_Event_OnGamemodeChanged", ET_Ignore, Param_Any);
	PluginForward_EventOnSpeedChange = CreateGlobalForward("WarioWare_Event_OnSpeedChange", ET_Ignore, Param_Float);
	PluginForward_EventOnSpecialRoundSelected = CreateGlobalForward("WarioWare_Event_OnSpecialRoundSelected", ET_Ignore, Param_Any);
}

stock void InitializePluginNatives()
{
	CreateNative("WarioWare_GetMaxRounds", Native_WarioWare_GetMaxRounds);
	CreateNative("WarioWare_SetMaxRounds", Native_WarioWare_SetMaxRounds);
}

stock void RemovePluginForwardsFromMemory()
{
	SafelyRemoveAllFromForward(PluginForward_IntermissionStartMapVote);
	SafelyRemoveAllFromForward(PluginForward_IntermissionHasMapVoteEnded);
}

public bool PluginForward_HasMapIntegrationLoaded()
{
	return GetForwardFunctionCount(PluginForward_IntermissionStartMapVote) > 0 && GetForwardFunctionCount(PluginForward_IntermissionHasMapVoteEnded) > 0;
}

public void PluginForward_StartMapVote()
{
	if (GetForwardFunctionCount(PluginForward_IntermissionStartMapVote) == 0)
	{
		return;
	}

	Call_StartForward(PluginForward_IntermissionStartMapVote);
	Call_Finish();
}

public bool PluginForward_HasMapVoteEnded()
{
	if (GetForwardFunctionCount(PluginForward_IntermissionHasMapVoteEnded) > 0)
	{
		bool voteIsInProgress = false;

		Call_StartForward(PluginForward_IntermissionHasMapVoteEnded);
		Call_Finish(voteIsInProgress);

		return voteIsInProgress;
	}
	
	return true;
}

public void PluginForward_SendMinigameSelected(int minigameId)
{
	Call_StartForward(PluginForward_EventOnMinigameSelected);
	Call_PushCell(minigameId);
	Call_Finish();
}

public void PluginForward_SendBossgameSelected(int bossgameId)
{
	Call_StartForward(PluginForward_EventOnBossgameSelected);
	Call_PushCell(bossgameId);
	Call_Finish();
}

public void PluginForward_SendPlayerWinMinigame(int client, int minigameId)
{
	Call_StartForward(PluginForward_EventOnPlayerWinMinigame);
	Call_PushCell(client);
	Call_PushCell(minigameId);
	Call_Finish();
}

public void PluginForward_SendPlayerFailedMinigame(int client, int minigameId)
{
	Call_StartForward(PluginForward_EventOnPlayerFailedMinigame);
	Call_PushCell(client);
	Call_PushCell(minigameId);
	Call_Finish();
}

public void PluginForward_SendPlayerWinBossgame(int client, int bossgameId)
{
	Call_StartForward(PluginForward_EventOnPlayerWinBossgame);
	Call_PushCell(client);
	Call_PushCell(bossgameId);
	Call_Finish();
}

public void PluginForward_SendPlayerFailedBossgame(int client, int bossgameId)
{
	Call_StartForward(PluginForward_EventOnPlayerFailedBossgame);
	Call_PushCell(client);
	Call_PushCell(bossgameId);
	Call_Finish();
}

public void PluginForward_SendPlayerWinRound(int client, int score)
{
	Call_StartForward(PluginForward_EventOnPlayerWinRound);
	Call_PushCell(client);
	Call_PushCell(score);
	Call_Finish();
}

public void PluginForward_SendPlayerLoseRound(int client, int score)
{
	Call_StartForward(PluginForward_EventOnPlayerLoseRound);
	Call_PushCell(client);
	Call_PushCell(score);
	Call_Finish();
}

public void PluginForward_SendGamemodeChanged(int gamemodeId)
{
	Call_StartForward(PluginForward_EventOnGamemodeChanged);
	Call_PushCell(gamemodeId);
	Call_Finish();
}

public void PluginForward_SendSpeedChange(float speed)
{
	Call_StartForward(PluginForward_EventOnSpeedChange);
	Call_PushFloat(speed);
	Call_Finish();
}

public void PluginForward_SendSpecialRoundSelected(int id)
{
	Call_StartForward(PluginForward_EventOnSpecialRoundSelected);
	Call_PushCell(id);
	Call_Finish();
}

public int Native_WarioWare_GetMaxRounds(Handle plugin, int numParams)
{
	return MaxRounds;
}

public int Native_WarioWare_SetMaxRounds(Handle plugin, int numParams)
{
	int value = GetNativeCell(1);

	SetConVarInt(ConVar_MTF2MaxRounds, value);

	return 0;
}