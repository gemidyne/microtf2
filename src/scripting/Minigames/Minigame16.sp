/**
 * MicroTF2 - Minigame 16
 * 
 * Jarate an Enemy!
 */

public void Minigame16_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame16_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerJarated, INVALID_HANDLE, Minigame16_OnPlayerJarated);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame16_OnMinigameFinish);
}

public bool Minigame16_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}

	if (GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
	{
		return false;
	}

	return true;
}

public void Minigame16_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 16 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Sniper);
		ResetWeapon(client, true);
		GiveWeapon(client, 58);
		IsViewModelVisible(client, true);
	}
}

public void Minigame16_OnPlayerJarated(int client, int victim)
{
	if (IsMinigameActive && MinigameID == 16 && IsClientValid(client) && IsClientValid(victim) && IsPlayerParticipant[client] && IsPlayerParticipant[victim])
	{
		ClientWonMinigame(client);
	}
}

public void Minigame16_OnMinigameFinish()
{
	if (IsMinigameActive && MinigameID == 16)
	{
		RemoveAllJarateEntities();
	}
}