/**
 * MicroTF2 - Minigame 28
 *
 * Explosive Jump - get to the win area
 */

public void Minigame28_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame28_OnMapStart);
	AddToForward(GlobalForward_OnTfRoundStart, INVALID_HANDLE, Minigame28_OnRoundStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame28_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame28_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame28_OnMinigameFinish);
}

public void Minigame28_OnMapStart()
{

}

public void Minigame28_OnRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Minigame28_WinArea") == 0)
		{
			SDKHook(entity, SDKHook_StartTouch, Minigame28_OnTriggerTouched);
			break;
		}
	}
}

public void Minigame28_OnMinigameSelectedPre()
{
	if (MinigameID == 28)
	{
		DamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
	}
}

public void Minigame28_OnMinigameSelected(int client)
{
	if (MinigameID != 28)
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
		if (player.Class != TFClass_DemoMan)
		{
			player.Class = TFClass_DemoMan;
		}

		player.RemoveAllWeapons();
		player.ResetHealth();
		player.GiveWeapon(1151);
		player.SetWeaponPrimaryAmmoCount(4);
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);

		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 137.0, 0.0 };
		float pos[3];

		int column = client;
		int row = 0;

		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		pos[0] = 3650.0 - float(row*60); 
		pos[1] = 1943.0 - float(column*60);
		pos[2] = 937.0;

		TeleportEntity(client, pos, ang, vel);
	}
}

public Action Minigame28_OnTriggerTouched(int entity, int other)
{
	if (MinigameID != 28)
	{
		return Plugin_Continue;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Continue;
	}

	Player activator = new Player(other);

	if (activator.IsValid && activator.IsAlive && activator.IsParticipating && activator.Status == PlayerStatus_NotWon)
	{
		activator.TriggerSuccess();
	}

	return Plugin_Continue;
}

public void Minigame28_OnMinigameFinish()
{
	if (MinigameID != 28)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++) 
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating) 
		{
			player.Respawn();
		}
	}
}