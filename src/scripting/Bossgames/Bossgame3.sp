/**
 * MicroTF2 - Bossgame 3
 * 
 * Heavy Boxing
 */

int Bossgame3_REDIdx;
int Bossgame3_BLUIdx;

public void Bossgame3_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame3_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame3_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame3_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame3_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame3_OnBossStopAttempt);
}

public bool Bossgame3_OnCheck()
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

public void Bossgame3_OnMinigameSelectedPre()
{
	if (BossgameID == 3)
	{
		Bossgame3_REDIdx = 1;
		Bossgame3_BLUIdx = 1;

		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		IsOnlyBlockingDamageByPlayers = false;

		SetConVarInt(ConVar_FriendlyFire, 0);
	}
}

public void Bossgame3_OnMinigameSelected(int client)
{
	if (!IsMinigameActive || BossgameID != 3)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	player.RemoveAllWeapons();
	player.SetClass(TFClass_Heavy);
	player.SetGodMode(false);
	player.ResetHealth();

	GiveWeapon(client, 239);

	float pos[3];
	float vel[3] = { 0.0, 0.0, 0.0 };
	float ang[3];

	if (player.Team == TFTeam_Red)
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
}

public void Bossgame3_OnPlayerDeath(int victimId, int attackerId)
{
	if (!IsMinigameActive || BossgameID != 3)
	{
		return;
	}

	Player victim = new Player(victimId);

	if (!victim.IsValid)
	{
		return;
	}

	PlayerStatus[victimId] = PlayerStatus_Failed;

	Player attacker = new Player(attackerId);

	if (attacker.IsValid)
	{
		attacker.SetHealth(300);
	}
}

public void Bossgame3_OnMinigameFinish()
{
	if (!IsMinigameActive || BossgameID != 3)
	{
		return;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsAlive && PlayerStatus[i] != PlayerStatus_Failed)
		{
			PlayerStatus[i] = PlayerStatus_Winner;
		}
	}
}

public void Bossgame3_OnBossStopAttempt()
{
	if (!IsMinigameActive || BossgameID != 3)
	{
		return;
	}

	int aliveBluePlayers = 0;
	int aliveRedPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsAlive)
		{
			TFTeam team = player.Team;

			if (team == TFTeam_Red)
			{
				aliveRedPlayers++;
			}
			else if (team == TFTeam_Blue)
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