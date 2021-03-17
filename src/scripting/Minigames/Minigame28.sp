/**
 * MicroTF2 - Minigame 28
 *
 * Explosive Jump - get to the win area
 */

int Minigame28_RedIndex = 0;
int Minigame28_BlueIndex = 0;

public void Minigame28_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Minigame28_OnMapStart);
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Minigame28_OnRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame28_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame28_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame28_OnMinigameFinish);
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
	if (g_iActiveMinigameId == 28)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		Minigame28_RedIndex = 0;
		Minigame28_BlueIndex = 0;
	}
}

public void Minigame28_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 28)
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
		float ang[3] = { 0.0, 0.0, 0.0 };
		float pos[3];

		int column;
		int row = 0;

		if (player.Team == TFTeam_Red)
		{
			column = Minigame28_RedIndex;
			Minigame28_RedIndex++;
		}
		else 
		{
			column = Minigame28_BlueIndex;
			Minigame28_BlueIndex++;
		}

		while (column > 8)
		{
			column = column - 8;
			row = row + 1;
		}

		if (player.Team == TFTeam_Red)
		{
			pos[0] = 3600.0 - float(row*70); 
			pos[1] = 1900.0 - float(column*60);
			pos[2] = 890.0;
		}
		else
		{
			pos[0] = 4800.0 + float(row*70); 
			pos[1] = 1404.0 + float(column*60);
			pos[2] = 890.0;
			ang[1] = 180.0;
		}

		TeleportEntity(client, pos, ang, vel);
	}
}

public Action Minigame28_OnTriggerTouched(int entity, int other)
{
	if (g_iActiveMinigameId != 28)
	{
		return Plugin_Continue;
	}

	if (!g_bIsMinigameActive)
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
	if (g_iActiveMinigameId != 28)
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
			player.Respawn();
		}
	}
}