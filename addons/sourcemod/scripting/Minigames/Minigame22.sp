/**
 * MicroTF2 - Minigame 22
 *
 * Stay on the ground!
 */

public void Minigame22_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame22_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame22_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Minigame22_OnPlayerTakeDamage);
	AddToForward(GlobalForward_OnMinigameFinishPre, INVALID_HANDLE, Minigame22_OnMinigameFinishPre);
}

public void Minigame22_OnMinigameSelectedPre()
{
	if (MinigameID == 22)
	{
		IsBlockingDamage = false;
	}
}

public void Minigame22_OnMinigameSelected(int client)
{
	if (MinigameID != 22)
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
		player.RemoveAllWeapons();
		player.Class = TFClass_Soldier;
		player.SetGodMode(false);
		player.SetHealth(3000);

		player.GiveWeapon(18);
		player.SetWeaponPrimaryAmmoCount(20);
		player.AddCondition(TFCond_Kritzkrieged, 4.0);
	}
}

public void Minigame22_OnPlayerTakeDamage(int victimId, int attackerId, float damage)
{
	if (MinigameID != 22)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
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
}

public void Minigame22_OnMinigameFinishPre()
{
	if (MinigameID == 22)
	{
		IsBlockingDeathCommands = false;

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

		IsBlockingDeathCommands = true;
	}
}
