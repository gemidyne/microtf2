/**
 * MicroTF2 - Minigame 21
 *
 * Stun an Enemy
 */

public void Minigame21_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame21_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerStunned, INVALID_HANDLE, Minigame21_OnPlayerStunned);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame21_OnMinigameFinish);
}

public void Minigame21_OnMinigameSelected(int client)
{
	if (MinigameID != 21)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	player.Class = TFClass_Scout;

	GiveWeapon(client, 44);

	player.SetGodMode(false);
	player.SetHealth(1000);
	player.SetAmmo(5);
}

public void Minigame21_OnPlayerStunned(int stunner, int victim)
{
	if (!IsMinigameActive || MinigameID != 21)
	{
		return;
	}

	Player player = new Player(stunner);

	if (player.IsValid && player.IsParticipating)
	{
		ClientWonMinigame(stunner);
		GiveWeapon(stunner, 0);
	}
}

public void Minigame21_OnMinigameFinish()
{
	if (IsMinigameActive && MinigameID == 21)
	{
		RemoveAllStunballEntities();
	}
}