/**
 * MicroTF2 - Bossgame 3
 * 
 * Heavy Boxing
 */

new Bossgame3_REDIdx;
new Bossgame3_BLUIdx;

public Bossgame3_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame3_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame3_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame3_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame3_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame3_OnBossStopAttempt);
}

public bool:Bossgame3_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}
	
	if (GetTeamClientCount(2) < 1 || GetTeamClientCount(3) < 1)
	{
		return false;
	}

	if (SpecialRoundID == 14)
	{
		// Due to knockback from GRU, cannot run on this SPR.
		return false;
	}

	return true;
}

public Bossgame3_OnMinigameSelectedPre()
{
	if (BossgameID == 3)
	{
		Bossgame3_REDIdx = 1;
		Bossgame3_BLUIdx = 1;
		SetConVarInt(ConVar_FriendlyFire, 0);
	}
}

public Bossgame3_OnMinigameSelected(client)
{
	if (IsMinigameActive && BossgameID == 3 && IsClientValid(client))
	{
		IsBlockingDamage = false;
		IsBlockingDeaths = false;

		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Heavy);
		GiveWeapon(client, 239);

		new Float:pos[3];
		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3];

		new team = GetClientTeam(client);

		if (team == 2)
		{
			Bossgame3_REDIdx++;

			pos[0] = 12366.0;
			pos[1] = 4075.0 + float(Bossgame3_REDIdx*55);

			ang[0] = 0.0;
			ang[1] = 180.0;
			ang[2] = 0.0;
		}
		else
		{
			Bossgame3_BLUIdx++;

			pos[0] = 11608.0;
			pos[1] = 4900.0 - float(Bossgame3_BLUIdx*55);

			ang[0] = 0.0;
			ang[1] = 0.0;
			ang[2] = 0.0;
		}

		pos[2] = -240.0;

		TeleportEntity(client, pos, ang, vel);

		IsGodModeEnabled(client, false);
		IsViewModelVisible(client, true);
		ResetHealth(client);
	}
}

public Bossgame3_OnPlayerDeath(victim, attacker)
{
	if (IsMinigameActive && BossgameID == 3 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;

		if (IsClientValid(attacker))
		{
			SetPlayerHealth(attacker, 300);
		}
	}
}

public Bossgame3_OnMinigameFinish()
{
	if (IsMinigameActive && BossgameID == 3)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerAlive(i) && PlayerStatus[i] != PlayerStatus_Failed)
			{
				PlayerStatus[i] = PlayerStatus_Winner;
			}
		}
	}
}

public Bossgame3_OnBossStopAttempt()
{
	if (IsMinigameActive && BossgameID == 3)
	{
		new aliveBluePlayers = 0;
		new aliveRedPlayers = 0;

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				new team = GetClientTeam(i);
				if (team == 2)
				{
					aliveRedPlayers++;
				}
				else if (team == 3)
				{
					aliveBluePlayers++;
				}
			}
		}

		if (aliveRedPlayers == 0 || aliveBluePlayers == 0)
		{
			EndBoss();
		}
	}
}