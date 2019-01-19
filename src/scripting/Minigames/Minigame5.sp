/**
 * MicroTF2 - Minigame 5
 * 
 * Sticky Jump!
 */

public void Minigame5_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame5_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame5_OnMinigameSelected);
	AddToForward(GlobalForward_OnStickyJump, INVALID_HANDLE, Minigame5_OnStickyJump);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame5_OnMinigameFinish);
}

public bool Minigame5_OnCheck()
{
	return true;
}

public void Minigame5_OnMinigameSelectedPre()
{
	if (MinigameID == 5)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
	}
}

public void Minigame5_OnMinigameSelected(int client)
{
	if (MinigameID != 5)
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
		player.Class = TFClass_DemoMan;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		player.SetHealth(1000);

		GiveWeapon(client, 265);
	}
}

public void Minigame5_OnStickyJump(int client)
{
	if (MinigameID != 5)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsParticipating)
	{
		ClientWonMinigame(client);

		player.SetGravity(0.5);
	}
}

public void Minigame5_OnMinigameFinish()
{
	if (MinigameID == 5)
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