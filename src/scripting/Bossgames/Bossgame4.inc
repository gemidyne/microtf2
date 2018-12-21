/**
 * MicroTF2 - Bossgame 4
 * 
 * Don't fall off!
 */

float Bossgame4_Positions[2][2][3];
float Bossgame4_Angles[2][2][3];

public void Bossgame4_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame4_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame4_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame4_OnPlayerDeath);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Bossgame4_OnPlayerTakeDamage);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame4_OnBossStopAttempt);

	// RED Spawnpoints
	Bossgame4_Positions[0][0][0] = 3470.5;
	Bossgame4_Positions[0][0][1] = -62.1;
	Bossgame4_Positions[0][0][2] = -68.9;

	Bossgame4_Angles[0][0][0] = 0.9;
	Bossgame4_Angles[0][0][1] = -44.8;
	Bossgame4_Angles[0][0][2] = 0.0;

	Bossgame4_Positions[0][1][0] = 3762.5;
	Bossgame4_Positions[0][1][1] = -58.0;
	Bossgame4_Positions[0][1][2] = -68.9;

	Bossgame4_Angles[0][1][0] = 0.7;
	Bossgame4_Angles[0][1][1] = -134.9;
	Bossgame4_Angles[0][1][2] = 0.0;

	// BLU Spawnpoints
	Bossgame4_Positions[1][0][0] = 3766.1;
	Bossgame4_Positions[1][0][1] = -354.7;
	Bossgame4_Positions[1][0][2] = -68.9;

	Bossgame4_Angles[1][0][0] = 0.1;
	Bossgame4_Angles[1][0][1] = 134.8;
	Bossgame4_Angles[1][0][2] = 0.0;

	Bossgame4_Positions[1][1][0] = 3472.9;
	Bossgame4_Positions[1][1][1] = -348.2;
	Bossgame4_Positions[1][1][2] = -68.9;

	Bossgame4_Angles[1][1][0] = -0.3;
	Bossgame4_Angles[1][1][1] = 44.9;
	Bossgame4_Angles[1][1][2] = 0.0;
}

public bool Bossgame4_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}
	
	if (GetTeamClientCount(2) < 1 || GetTeamClientCount(3) < 1)
	{
		return false;
	}
	
	return true;
}

public void Bossgame4_OnMinigameSelected(int client)
{
	if (IsMinigameActive && BossgameID == 4 && IsClientValid(client))
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		IsOnlyBlockingDamageByPlayers = true;

		ChooseRandomClass(client);

		TFClassType classType = TF2_GetPlayerClass(client);

		if (classType == TFClass_Scout || classType == TFClass_Spy)
		{
			switch (GetRandomInt(0, 2))
			{
				case 0:
				{
					TF2_SetPlayerClass(client, TFClass_Pyro);
				}

				case 1:
				{
					TF2_SetPlayerClass(client, TFClass_Engineer);
				}

				default:
				{
					TF2_SetPlayerClass(client, TFClass_Soldier);
				}
			}
		}

		ResetWeapon(client, true);

		float pos[3];
		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3];

		int index = GetRandomInt(0, 1);
		int team = GetClientTeam(client);
		int teamNumber = (team == 2 ? 0 : 1);

		pos = Bossgame4_Positions[teamNumber][index];
		ang = Bossgame4_Angles[teamNumber][index];

		TeleportEntity(client, pos, ang, vel);

		IsGodModeEnabled(client, false);
		ResetHealth(client);
	}
}

public void Bossgame4_OnPlayerDeath(int victim, int attacker)
{
	if (IsMinigameActive && BossgameID == 4 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;

		CreateTimer(0.05, Bossgame4_OnPlayerDeathTimer, victim);
	}
}

public Action Bossgame4_OnPlayerDeathTimer(Handle timer, int client)
{
	if (IsMinigameActive && BossgameID == 4 && IsClientValid(client))
	{
		TF2_RespawnPlayer(client);
		int team = GetClientTeam(client);
		int teamNumber = (team == 2 ? 0 : 1);

		if (teamNumber == 0)
		{
			float pos[3] = { 4372.0, -204.0, 219.0 };
			float ang[3] = { 0.0, 180.0, 0.0 };

			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}
		else 
		{
			float pos[3] = { 2879.0, -204.0, 219.0 };
			float ang[3] = { 0.0, 0.0, 0.0 };

			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}

		IsGodModeEnabled(client, true);
		ResetHealth(client);
	}

	return Plugin_Handled;
}

public void Bossgame4_OnPlayerTakeDamage(int victim, int attacker, float damage)
{
	if (IsMinigameActive && BossgameID == 4)
	{
		if (attacker > 0 && attacker <= MaxClients && IsClientValid(attacker) && IsClientValid(victim))
		{
			float ang[3];
			float vel[3];

			GetClientEyeAngles(attacker, ang);
			GetEntPropVector(victim, Prop_Data, "m_vecVelocity", vel);

			vel[0] -= 300.0 * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
			vel[1] -= 300.0 * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
			vel[2] += 450.0;

			TeleportEntity(victim, NULL_VECTOR, ang, vel);
		}
	}
}

public void Bossgame4_OnMinigameFinish()
{
	if (IsMinigameActive && BossgameID == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && PlayerStatus[i] != PlayerStatus_Failed)
			{
				PlayerStatus[i] = PlayerStatus_Winner;
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
			if (IsClientInGame(i) && IsPlayerAlive(i) && PlayerStatus[i] != PlayerStatus_Failed)
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