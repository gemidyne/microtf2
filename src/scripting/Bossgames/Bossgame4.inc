/**
 * MicroTF2 - Bossgame 4
 * 
 * Don't fall off!
 */

new Float:Bossgame4_Positions[2][2][3];
new Float:Bossgame4_Angles[2][2][3];

public Bossgame4_EntryPoint()
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

public bool:Bossgame4_OnCheck()
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

public Bossgame4_OnMinigameSelected(client)
{
	if (IsMinigameActive && BossgameID == 4 && IsClientValid(client))
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		IsOnlyBlockingDamageByPlayers = true;

		ChooseRandomClass(client);

		if (TF2_GetPlayerClass(client) == TFClass_Scout || TF2_GetPlayerClass(client) == TFClass_Spy)
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

		new Float:pos[3];
		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3];

		new index = GetRandomInt(0, 1);
		new team = GetClientTeam(client);
		new teamNumber = (team == 2 ? 0 : 1);

		pos = Bossgame4_Positions[teamNumber][index];
		ang = Bossgame4_Angles[teamNumber][index];

		TeleportEntity(client, pos, ang, vel);

		IsGodModeEnabled(client, false);
		ResetHealth(client);
	}
}

public Bossgame4_OnPlayerDeath(victim, attacker)
{
	if (IsMinigameActive && BossgameID == 4 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public Bossgame4_OnPlayerTakeDamage(victim, attacker, Float:damage)
{
	if (IsMinigameActive && BossgameID == 4)
	{
		if (attacker > 0 && attacker <= MaxClients && IsClientValid(attacker) && IsClientValid(victim))
		{
			new Float:ang[3];
			new Float:vel[3];

			GetClientEyeAngles(attacker, ang);
			GetEntPropVector(victim, Prop_Data, "m_vecVelocity", vel);

			vel[0] -= 300.0 * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
			vel[1] -= 300.0 * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
			vel[2] += 450.0;

			TeleportEntity(victim, NULL_VECTOR, ang, vel);
		}
	}
}

public Bossgame4_OnMinigameFinish()
{
	if (IsMinigameActive && BossgameID == 4)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && PlayerStatus[i] != PlayerStatus_Failed)
			{
				PlayerStatus[i] = PlayerStatus_Winner;
			}
		}
	}
}

public Bossgame4_OnBossStopAttempt()
{
	if (IsMinigameActive && BossgameID == 4)
	{
		new alivePlayers = 0;

		for (new i = 1; i <= MaxClients; i++)
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