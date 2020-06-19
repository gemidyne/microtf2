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

		player.GiveWeapon(1179);
		player.SetWeaponPrimaryAmmoCount(200);

		player.SetItemChargeMeter(100.0);
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
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "MainRoom_JetpackMinigameStart") == 0)
		{
			AcceptEntityInput(entity, "Trigger", -1, -1, -1);
			break;
		}
	}

	return Plugin_Handled;
}