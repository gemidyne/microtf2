/**
 * MicroTF2 - Minigame 19
 *
 * Change Class!
 */

public void Minigame19_EntryPoint()
{
	AddToForward(GlobalForward_OnPlayerClassChange, INVALID_HANDLE, Minigame19_OnPlayerClassChange);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame19_OnMinigameSelectedPre);
}

public bool Minigame19_OnCheck()
{
	return true;
}

public void Minigame19_OnMinigameSelectedPre()
{
	if (MinigameID == 19)
	{
		IsBlockingDeathCommands = false;
	}
}

public void Minigame19_OnPlayerClassChange(int client)
{
	if (IsMinigameActive && MinigameID == 19 && IsClientValid(client) && IsPlayerParticipant[client])
	{
		ClientWonMinigame(client);
	}
}