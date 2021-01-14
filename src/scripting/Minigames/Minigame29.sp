/**
 * MicroTF2 - Minigame 29
 *
 * Don't Touch anyone
 */

bool Minigame29_IsCheckingCollisions = false;

public void Minigame29_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame29_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame29_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerCollisionWithPlayer, INVALID_HANDLE, Minigame29_OnTouch);
}

public void Minigame29_OnMinigameSelectedPre()
{
	if (MinigameID == 29)
	{
		// DamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		Minigame29_IsCheckingCollisions = false;
		CreateTimer(1.5, Minigame29_EnableCollisionCheck);
	}
}

public void Minigame29_OnMinigameSelected(int client)
{
	if (MinigameID != 29)
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
		player.RemoveAllWeapons();
		player.ResetHealth();
		player.SetGodMode(false);
		player.Status = PlayerStatus_Winner;
	}
}

public Action Minigame29_EnableCollisionCheck(Handle timer)
{
	Minigame29_IsCheckingCollisions = true;
	return Plugin_Handled;
}

public void Minigame29_OnTouch(int entity, int other)
{
	if (!Minigame29_IsCheckingCollisions)
	{
		return;
	}

	Player player1 = new Player(entity);
	Player player2 = new Player(other);

	player1.SetGodMode(false);
	player2.SetGodMode(false);
	
	player1.Status = PlayerStatus_Failed;
	player2.Status = PlayerStatus_Failed;

	SDKHooks_TakeDamage(player1.ClientId, player1.ClientId, player2.ClientId, 999.9, DMG_BLAST);
}