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

public void Minigame16_OnMinigameSelected(int client)
{
	if (MinigameID != 16)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.Class = TFClass_Sniper;
		ResetWeapon(client, true);
		GiveWeapon(client, 58);
	}
}

public void Minigame16_OnPlayerJarated(int client, int victimId)
{
	if (MinigameID != 16)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);
	Player victim = new Player(victimId);

	if (player.IsValid && player.IsParticipating && victim.IsValid && victim.IsParticipating)
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