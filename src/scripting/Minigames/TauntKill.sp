/**
 * MicroTF2 - Minigame 23
 *
 * Taunt Kill! 
 */

TFClassType g_eMinigame23AvailableClasses[] = { TFClass_Sniper, TFClass_Heavy, TFClass_Pyro, TFClass_Medic, TFClass_DemoMan, TFClass_Engineer, TFClass_Spy, TFClass_Scout };
TFClassType g_eMinigame23Class;

public void Minigame23_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Minigame23_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Minigame23_OnMinigameSelected);
	g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, Minigame23_OnMinigameFinish);
	g_pfOnPlayerDeath.AddFunction(INVALID_HANDLE, Minigame23_OnPlayerDeath);
}

public void Minigame23_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId != 23)
	{
		return;
	}

	g_bIsBlockingTaunts = false;
	g_bIsBlockingKillCommands = true;
	g_eDamageBlockMode = EDamageBlockMode_Nothing;

	g_eMinigame23Class = g_eMinigame23AvailableClasses[GetRandomInt(0, sizeof(g_eMinigame23AvailableClasses) - 1)];
}

public void Minigame23_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 23)
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
		player.Class = g_eMinigame23Class;
		player.RemoveAllWeapons();

		switch (g_eMinigame23Class)
		{
			case TFClass_Sniper:
				player.GiveWeapon(56);
			
			case TFClass_Heavy:
				player.GiveWeapon(5);

			case TFClass_Pyro:
				player.GiveWeapon(12);

			case TFClass_Medic:
				player.GiveWeapon(37);

			case TFClass_DemoMan:
				player.GiveWeapon(132);

			case TFClass_Engineer:
				player.GiveWeapon(142);

			case TFClass_Spy:
				player.GiveWeapon(4);

			case TFClass_Scout:
				player.GiveWeapon(44);
		}
		
		player.SetGodMode(false);

		SDKHook(client, SDKHook_PreThink, Minigame23_RemoveFireButtons);
	}
}

public void Minigame23_OnPlayerDeath(int victimId, int attackerId, int inflictor, const char[] weapon)
{
	if (g_iActiveMinigameId != 23)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player victim = new Player(victimId);
	Player attacker = new Player(attackerId);

	bool isValid = victim.IsValid && attacker.IsValid && victim.IsParticipating && attacker.IsParticipating;

	if (!isValid)
	{
		return;
	}

	if (strncmp(weapon, "taunt_", 6, false) == 0)
	{
		attacker.TriggerSuccess();
	}
}

public void Minigame23_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 23)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				SDKUnhook(i, SDKHook_PreThink, Minigame23_RemoveFireButtons);
			}
		}
	}
}

public void Minigame23_RemoveFireButtons(int client)
{
	int buttons = GetClientButtons(client);

	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}

	if ((buttons & IN_ATTACK2))
	{
		buttons &= ~IN_ATTACK2;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}