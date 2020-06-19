/**
 * MicroTF2 - Minigame 7
 * 
 * Rocket Jump!
 */

public void Minigame7_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame7_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame7_OnMinigameSelected);
	AddToForward(GlobalForward_OnRocketJump, INVALID_HANDLE, Minigame7_OnRocketJump);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame7_OnMinigameFinish);
}

public void Minigame7_OnMinigameSelectedPre()
{
	if (MinigameID == 7)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
	}
}

public void Minigame7_OnMinigameSelected(int client)
{
	if (MinigameID != 7)
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
		player.Class = TFClass_Soldier;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		player.SetHealth(1000);
		player.GiveWeapon(237);
		player.SetWeaponPrimaryAmmoCount(60);
	}
}

public void Minigame7_OnRocketJump(int client)
{
	if (MinigameID != 7)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		player.TriggerSuccess();
		player.SetGravity(0.5);
	}
}

public void Minigame7_OnMinigameFinish()
{
	if (MinigameID == 7)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && !player.IsBot)
			{
				StopSound(player.ClientId, SNDCHAN_AUTO, "misc/grenade_jump_lp_01.wav");
			}
		}
	}
}