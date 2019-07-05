/**
 * MicroTF2 - PluginForwards.sp
 * 
 * Implements functionality for other SourceMod plugins to interact
 * with the gamemode.
 */

Handle PluginForward_IntermissionStartMapVote;
Handle PluginForward_IntermissionHasMapVoteEnded;
// Handle PluginForward_EventOnPlayerWinMinigame;
// Handle PluginForward_EventOnPlayerFailedMinigame;
// Handle PluginForward_EventOnPlayerWinBossgame;
// Handle PluginForward_EventOnPlayerFailedBossgame;
// Handle PluginForward_EventOnPlayerWinRound;
// Handle PluginForward_EventOnPlayerFailedRound;

stock void InitializePluginForwards()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Plugin Forwards...");
	#endif

	PluginForward_IntermissionStartMapVote = CreateGlobalForward("WarioWare_Intermission_StartMapVote", ET_Ignore);
	PluginForward_IntermissionHasMapVoteEnded = CreateGlobalForward("WarioWare_Intermission_HasMapVoteEnded", ET_Single);
}

stock void RemovePluginForwardsFromMemory()
{
	SafelyRemoveAllFromForward(PluginForward_IntermissionStartMapVote);
	SafelyRemoveAllFromForward(PluginForward_IntermissionHasMapVoteEnded);
}

public void PluginForward_StartMapVote()
{
	Call_StartForward(PluginForward_IntermissionStartMapVote);
	Call_Finish();
}

public bool PluginForward_HasMapVoteEnded()
{
	bool voteIsInProgress = false;

	Call_StartForward(PluginForward_IntermissionHasMapVoteEnded);
	Call_Finish(voteIsInProgress);

	return voteIsInProgress;
}