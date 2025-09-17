/**
 * MicroTF2 - Minigame 12
 * 
 * Get on a Platform!
 */

public void Minigame12_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame12_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame12_OnMinigameSelected);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Minigame12_OnPlayerTakeDamage);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame12_OnMinigameFinish);
}

public void Minigame12_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 12)
	{
		g_eDamageBlockMode = EDamageBlockMode_Nothing;
		g_bIsBlockingKillCommands = false;

		CreateTimer(0.15, Timer_Minigame12_TriggerWater);
	}
}

public void Minigame12_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 12)
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
		switch (player.Class)
		{
			case TFClass_Scout:
			{
				player.Class = TFClass_Pyro;
			}

			case TFClass_Soldier:
			{
				player.Class = TFClass_Pyro;
			}

			case TFClass_DemoMan:
			{
				player.Class = TFClass_Engineer;
			}

			case TFClass_Heavy:
			{
				player.Class = TFClass_Engineer;
			}

			case TFClass_Medic:
			{
				player.Class = TFClass_Sniper;
			}

			case TFClass_Spy:
			{
				player.Class = TFClass_Sniper;
			}
		}

		player.ResetWeapon(false);
		player.SetGodMode(false);
		player.SetHealth(1000);
	}
}

public DamageBlockResults Minigame12_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_iActiveMinigameId != 12)
	{
		return EDamageBlockResult_DoNothing;
	}

	if (!g_bIsMinigameActive)
	{
		return EDamageBlockResult_DoNothing;
	}

	Player attacker = new Player(attackerId);
	Player victim = new Player(victimId);

	if (attacker.IsValid && victim.IsValid)
	{
		float ang[3];
		float vel[3];

		GetClientEyeAngles(attackerId, ang);
		GetEntPropVector(victimId, Prop_Data, "m_vecVelocity", vel);

		vel[0] -= 100.0 * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[1] -= 100.0 * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[2] += 250.0;

		TeleportEntity(victimId, NULL_VECTOR, NULL_VECTOR, vel);
	}

	return EDamageBlockResult_DoNothing;
}

public void Minigame12_OnMinigameFinish()
{
	if (g_iActiveMinigameId == 12)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Status = player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed;
			}
		}
	}
}

public Action Timer_Minigame12_TriggerWater(Handle timer) 
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "MainRoom_WaterMinigameStart") == 0)
		{
			AcceptEntityInput(entity, "Trigger", -1, -1, -1);
			break;
		}
	}

	return Plugin_Handled;
}