/**
 * MicroTF2 - Minigame 22
 *
 * Stay on the ground!
 */

public void Minigame22_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame22_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame22_OnMinigameSelected);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Minigame22_OnPlayerTakeDamage);
	AddToForward(g_pfOnMinigameFinishPre, INVALID_HANDLE, Minigame22_OnMinigameFinishPre);
}

public void Minigame22_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 22)
	{
		g_eDamageBlockMode = EDamageBlockMode_Nothing;
	}
}

public void Minigame22_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 22)
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
		player.RemoveAllWeapons();
		player.Class = TFClass_Soldier;
		player.SetGodMode(false);
		player.SetHealth(3000);

		player.GiveWeapon(18);
		player.SetWeaponPrimaryAmmoCount(20);
		player.AddCondition(TFCond_Kritzkrieged, 4.0);
	}
}

public DamageBlockResults Minigame22_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_iActiveMinigameId != 22)
	{
		return EDamageBlockResult_DoNothing;
	}

	if (!g_bIsMinigameActive)
	{
		return EDamageBlockResult_DoNothing;
	}

	Player attacker = new Player(attackerId);
	Player victim = new Player(victimId);

	if (attacker.IsValid && victim.IsValid && attacker.IsParticipating && victim.IsParticipating)
	{
		float ang[3];
		float vel[3];

		GetClientEyeAngles(attackerId, ang);
		GetEntPropVector(victimId, Prop_Data, "m_vecVelocity", vel);

		vel[0] -= 150.0 * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[1] -= 150.0 * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[2] += 275.0;

		TeleportEntity(victimId, NULL_VECTOR, ang, vel);
	}

	return EDamageBlockResult_DoNothing;
}

public void Minigame22_OnMinigameFinishPre()
{
	if (g_iActiveMinigameId == 22)
	{
		g_bIsBlockingKillCommands = false;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				if (!(GetEntityFlags(i) & FL_ONGROUND))
				{
					SlapPlayer(i, 5000, false);
					player.Status = PlayerStatus_Failed;
				}
				else
				{
					player.TriggerSuccess();
				}
			}
		}

		g_bIsBlockingKillCommands = true;
	}
}
