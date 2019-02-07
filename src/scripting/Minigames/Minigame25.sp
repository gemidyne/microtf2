/**
 * MicroTF2 - Minigame 25
 *
 * Jetpack! Get in the air quickly, or else.
 */

public void Minigame25_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame25_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame25_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame25_OnMinigameFinish);
}

public void Minigame25_OnMinigameSelectedPre()
{
	if (MinigameID == 25)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;

		CreateTimer(0.15, Timer_Minigame25_TriggerWater);
	}
}

public void Minigame25_OnMinigameSelected(int client)
{
	if (MinigameID != 25)
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
		player.Class = TFClass_Pyro;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		player.SetHealth(3000);

		GiveWeapon(client, 1179);
	}
}

public void Minigame25_OnMinigameFinish()
{
	if (MinigameID == 25)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Status = player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed;
				StopSound(i, SNDCHAN_AUTO, "misc/grenade_jump_lp_01.wav");

				player.Respawn();
			}
		}
	}
}

public Action Timer_Minigame25_TriggerWater(Handle timer) 
{
	int triggerer = CreateEntityByName("prop_physics");

	if (IsValidEdict(triggerer))
	{
		DispatchKeyValue(triggerer, "model", "models/props_farm/wooden_barrel.mdl");
		DispatchSpawn(triggerer);

		float pos[3] = { -1248.0, -1328.0, 1584.0 };

		TeleportEntity(triggerer, pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.25, Timer_RemoveEntity, triggerer);
	}

	return Plugin_Handled;
}