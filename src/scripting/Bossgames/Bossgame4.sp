/**
 * MicroTF2 - Bossgame 4
 * 
 * Don't fall off!
 */

float Bossgame4_DamageAccumlated[MAXPLAYERS];

public void Bossgame4_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame4_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame4_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame4_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame4_OnPlayerDeath);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Bossgame4_OnPlayerTakeDamage);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame4_OnBossStopAttempt);
}

public void Bossgame4_OnMinigameSelectedPre()
{
	if (BossgameID != 4)
	{
		return;
	}

	IsBlockingDamage = false;
	IsBlockingDeathCommands = true;
	IsOnlyBlockingDamageByPlayers = true;
}

public void Bossgame4_OnMinigameSelected(int client)
{
	if (BossgameID != 4)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	player.SetRandomClass();

	while (player.Class == TFClass_Scout || player.Class == TFClass_Spy)
	{
		player.SetRandomClass();
	}

	player.SetGodMode(false);
	player.SetHealth(1000);

	ResetWeapon(client, true);

	Bossgame4_DamageAccumlated[player.ClientId] = 100.0;

	float vel[3] = { 0.0, 0.0, 0.0 };
	float pos[3];

	int column = client;
	int row = 0;
	while (column > 6)
	{
		column = column - 6;
		row = row + 1;
	}

	pos[0] = -863.0 + float(row*80);
	pos[1] = 190.0 + float(column*80);
	pos[2] = -1345.0;

	TeleportEntity(client, pos, NULL_VECTOR, vel);

	float center[3] = { -699.0, 440.0, -1275.0 };
	float angle[3];
	float direction[3];

	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, angle);

	MakeVectorFromPoints(pos, center, direction);
	GetVectorAngles(direction, direction);

	angle[0] += NormalizeAngle(direction[0] - angle[0]);
	angle[1] += NormalizeAngle(direction[1] - angle[1]);

	TeleportEntity(client, NULL_VECTOR, angle, NULL_VECTOR);
}

public void Bossgame4_OnPlayerDeath(int victim, int attacker)
{
	if (BossgameID != 4)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(victim);
	
	if (player.IsValid)
	{
		player.Status = PlayerStatus_Failed;

		CreateTimer(0.05, Bossgame4_OnPlayerDeathTimer, victim);
	}
}

public Action Bossgame4_OnPlayerDeathTimer(Handle timer, int client)
{
	if (BossgameID != 4)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.Respawn();
		player.SetGodMode(true);
		player.ResetHealth();

		if (player.Team == TFTeam_Red)
		{
			float pos[3] = { -1354.0, 464.0, -860.0 };
			float ang[3] = { 0.0, 180.0, 0.0 };

			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}
		else 
		{
			float pos[3] = { 10.0, 464.0, -860.0 };
			float ang[3] = { 0.0, 0.0, 0.0 };

			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}
	}

	return Plugin_Handled;
}

public void Bossgame4_OnPlayerTakeDamage(int victimId, int attackerId, float damage)
{
	if (BossgameID != 4)
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
		if (victim.Health >= 1)
		{
			victim.Health -= RoundToFloor(damage);

			if (victim.Health < 1)
			{
				victim.Health = 1;
			}
		}

		Bossgame4_DamageAccumlated[victim.ClientId] += damage * 2.0;

		float ang[3];
		float vel[3];

		GetClientEyeAngles(attackerId, ang);
		GetEntPropVector(victimId, Prop_Data, "m_vecVelocity", vel);

		float baseVelocity = Bossgame4_DamageAccumlated[victim.ClientId];
		float baseVelocityZ = Bossgame4_DamageAccumlated[victim.ClientId];

		vel[0] -= baseVelocity * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[1] -= baseVelocity * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[2] += baseVelocityZ;

		TeleportEntity(victimId, NULL_VECTOR, NULL_VECTOR, vel);
	}
}

public void Bossgame4_OnMinigameFinish()
{
	if (IsMinigameActive && BossgameID == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status != PlayerStatus_Failed)
			{
				player.Status = PlayerStatus_Winner;
			}
		}
	}
}

public void Bossgame4_OnBossStopAttempt()
{
	if (IsMinigameActive && BossgameID == 4)
	{
		int alivePlayers = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status != PlayerStatus_Failed)
			{
				alivePlayers++;
			}
		}

		if (alivePlayers <= 1)
		{
			EndBoss();
		}
	}
}