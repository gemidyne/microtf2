/**
 * MicroTF2 - Minigame 29
 *
 * Don't Touch anyone
 */

bool g_bMinigame29IsCheckingCollisions = false;

public void Minigame29_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame29_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame29_OnMinigameSelected);
	AddToForward(g_pfOnPlayerCollisionWithPlayer, INVALID_HANDLE, Minigame29_OnTouch);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame29_OnMinigameFinish);
}

public void Minigame29_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 29)
	{
		g_eDamageBlockMode = EDamageBlockMode_Nothing;
		g_bMinigame29IsCheckingCollisions = false;
		CreateTimer(1.5, Minigame29_EnableCollisionCheck);
	}
}

public void Minigame29_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 29)
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
		// player.Class = TFClass_Pyro;
		player.Class = TFClass_Scout;
		player.RemoveAllWeapons();
		player.SetHealth(1500);
		player.SetGodMode(false);
		player.SetCollisionsEnabled(true);
		// player.GiveWeapon(21);
		player.GiveWeapon(45);

		player.SetWeaponPrimaryAmmoCount(0);
		player.SetWeaponClipAmmoCount(1);
		// SDKHook(client, SDKHook_PreThink, Minigame29_RemoveLeftClick);
	}
}

public Action Minigame29_EnableCollisionCheck(Handle timer)
{
	g_bMinigame29IsCheckingCollisions = true;
	return Plugin_Handled;
}

public void Minigame29_OnTouch(int entity, int other)
{
	if (g_iActiveMinigameId != 29)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	if (!g_bMinigame29IsCheckingCollisions)
	{
		return;
	}

	Player player1 = new Player(entity);
	Player player2 = new Player(other);

	player1.SetGodMode(false);
	player2.SetGodMode(false);
	
	player1.Status = PlayerStatus_Failed;
	player2.Status = PlayerStatus_Failed;

	SDKHooks_TakeDamage(player1.ClientId, player1.ClientId, player2.ClientId, 999.9, DMG_VEHICLE);
	SDKHooks_TakeDamage(player2.ClientId, player2.ClientId, player1.ClientId, 999.9, DMG_VEHICLE);
}

public void Minigame29_OnPlayerClassChange(int client, int class)
{
	if (g_iActiveMinigameId != 29)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	player.Status = PlayerStatus_Failed;

	if (g_iSpecialRoundId == 9)
	{
		// Prevent players from abusing class change to circumvent the minigame objective
		player.Score++;
		player.PrintChatText("%T", "System_SpecialRoundBlockClassChange", client);
	}
}

public void Minigame29_OnMinigameFinish()
{
	if (g_iActiveMinigameId != 29)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++) 
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			// SDKUnhook(player.ClientId, SDKHook_PreThink, Minigame29_RemoveLeftClick);

			if (player.Status == PlayerStatus_NotWon)
			{
				player.TriggerSuccess();
			}
		}
	}
}

public void Minigame29_RemoveLeftClick(int client)
{
	int buttons = GetClientButtons(client);

	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}