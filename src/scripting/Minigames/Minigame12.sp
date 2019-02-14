/**
 * MicroTF2 - Minigame 12
 * 
 * Get on a Platform!
 */

public void Minigame12_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame12_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame12_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Minigame12_OnPlayerTakeDamage);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame12_OnMinigameFinish);
}

public void Minigame12_OnMinigameSelectedPre()
{
	if (MinigameID == 12)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;

		CreateTimer(0.15, Timer_Minigame12_TriggerWater);
	}
}

public void Minigame12_OnMinigameSelected(int client)
{
	if (MinigameID != 12)
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
		switch (player.Class)
		{
			case TFClass_Scout:
			{
				player.Class = TFClass_Pyro;
			}

			case TFClass_Heavy:
			{
				player.Class = TFClass_DemoMan;
			}

			case TFClass_Spy:
			{
				player.Class = TFClass_Sniper;
			}
		}

		ResetWeapon(client, false);

		player.SetGodMode(false);
		player.SetHealth(3000);
	}
}

public void Minigame12_OnPlayerTakeDamage(int victimId, int attackerId, float damage)
{
	if (MinigameID != 12)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
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
}

public void Minigame12_OnMinigameFinish()
{
	if (MinigameID == 12)
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
	int entity = CreateEntityByName("prop_physics");

	if (IsValidEdict(entity))
	{
		DispatchKeyValue(entity, "model", "models/props_farm/wooden_barrel.mdl");
		DispatchSpawn(entity);

		float pos[3] = { -1408.0, -1328.0, 1618.0 };

		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.25, Timer_RemoveEntity, entity);
	}

	return Plugin_Handled;
}