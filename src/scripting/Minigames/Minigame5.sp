/**
 * MicroTF2 - Minigame 5
 * 
 * Sticky Jump!
 */

public void Minigame5_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame5_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame5_OnMinigameSelected);
	AddToForward(g_pfOnStickyJump, INVALID_HANDLE, Minigame5_OnStickyJump);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame5_OnMinigameFinish);
}

public void Minigame5_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 5)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		g_bIsBlockingKillCommands = true;
	}
}

public void Minigame5_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 5)
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
		player.Class = TFClass_DemoMan;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		player.SetHealth(1000);
		player.GiveWeapon(265);
		player.SetWeaponPrimaryAmmoCount(72);
	}
}

public void Minigame5_OnStickyJump(int client)
{
	if (g_iActiveMinigameId != 5)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsParticipating)
	{
		player.TriggerSuccess();
		player.SetGravity(0.5);
	}
}

public void Minigame5_OnMinigameFinish()
{
	if (g_iActiveMinigameId == 5)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && !player.IsBot)
			{
				StopSound(i, SNDCHAN_AUTO, "misc/grenade_jump_lp_01.wav");
			}
		}
	}
}