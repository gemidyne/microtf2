/**
 * MicroTF2 - Minigame 22
 *
 * Stay on the ground!
 */

bool Minigame22_CanCheckConditions = false;

public void Minigame22_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame22_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame22_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Minigame22_OnPlayerTakeDamage);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame22_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame22_OnMinigameFinish);
}

public void Minigame22_OnMinigameSelectedPre()
{
	if (MinigameID == 22)
	{
		IsBlockingDamage = false;
		Minigame22_CanCheckConditions = false;
		
		CreateTimer(2.0, Timer_Minigame22_AllowConditions);
	}
}

public Action Timer_Minigame22_AllowConditions(Handle timer)
{
	Minigame22_CanCheckConditions = true;
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

		GiveWeapon(client, 18);
		TF2_AddCondition(client, TFCond_Kritzkrieged, 4.0);
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

	if (attacker.IsValid && victim.IsValid)
	{
		float ang[3];
		float vel[3];

		GetClientEyeAngles(attackerId, ang);
		GetEntPropVector(victimId, Prop_Data, "m_vecVelocity", vel);

		vel[0] -= 300.0 * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[1] -= 300.0 * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[2] += 450.0;

		TeleportEntity(victimId, NULL_VECTOR, ang, vel);
	}
}

public void Minigame22_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 22 && Minigame22_CanCheckConditions)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				if (!(GetEntityFlags(i) & FL_ONGROUND))
				{
					player.Status = PlayerStatus_Failed;
					player.Kill();
				}
			}
		}
	}
}

public void Minigame22_OnMinigameFinish()
{
	if (MinigameID == 22)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && player.IsAlive && (GetEntityFlags(i) & FL_ONGROUND))
			{
				ClientWonMinigame(i);
			}
		}
	}
}

