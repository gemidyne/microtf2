/**
 * MicroTF2 - Minigame 16
 * 
 * Jarate an Enemy!
 */

public void Minigame16_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame16_OnMinigameSelected);
	AddToForward(g_pfOnPlayerJarated, INVALID_HANDLE, Minigame16_OnPlayerJarated);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame16_OnMinigameFinish);
}

public void Minigame16_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 16)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.Class = TFClass_Sniper;
		player.ResetWeapon(true);
		player.GiveWeapon(58);
		player.SetWeaponPrimaryAmmoCount(1);
	}
}

public void Minigame16_OnPlayerJarated(int client, int victimId)
{
	if (g_iActiveMinigameId != 16)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);
	Player victim = new Player(victimId);

	if (player.IsValid && player.IsParticipating && victim.IsValid && victim.IsParticipating)
	{
		player.TriggerSuccess();
	}
}

public void Minigame16_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 16)
	{
		RemoveAllJarateEntities();
	}
}