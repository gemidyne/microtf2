/**
 * MicroTF2 - Bossgame 1
 * 
 * Get to the top 
 */

bool Bossgame1_Completed;

public void Bossgame1_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame1_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame1_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame1_OnGameFrame);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame1_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame1_BossCheck);
}

public void Bossgame1_OnMinigameSelectedPre()
{
	if (BossgameID == 1)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		Bossgame1_Completed = false;
	}
}

public void Bossgame1_OnMinigameSelected(int client)
{
	if (BossgameID != 1)
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
		player.SetCollisionsEnabled(false);
		player.SetHealth(5000);

		player.GiveWeapon(237);
		player.SetWeaponPrimaryAmmoCount(60);

		int column = client;
		int row = 0;

		while (column > 12)
		{
			column = column - 12;
			row = row + 1;
		}

		float pos[3];
		pos[0] = 1821.0 - float(row*75);
		pos[1] = 4397.0 + float(column*75);
		pos[2] = -308.0;

		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 180.0, 0.0 };

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Bossgame1_OnGameFrame()
{
	if (BossgameID != 1)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	if (IsMinigameEnding)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status == PlayerStatus_NotWon)
		{
			float pos[3];
			GetClientAbsOrigin(player.ClientId, pos);

			if (pos[2] > 2656.0) 
			{
				player.TriggerSuccess();

				if (!Bossgame1_Completed && Config_BonusPointsEnabled())
				{
					player.Score++;
					Bossgame1_NotifyPlayerComplete(player);

					Bossgame1_Completed = true;
				}
			}
		}
	}
}

public void Bossgame1_OnPlayerDeath(int victim, int attacker)
{
	if (BossgameID != 1)
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
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public void Bossgame1_BossCheck()
{
	if (IsMinigameActive && BossgameID == 1)
	{
		int alivePlayers = 0;
		int successfulPlayers = 0;
		int pendingPlayers = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsAlive && player.IsParticipating)
			{
				alivePlayers++;

				if (player.Status == PlayerStatus_Failed || player.Status == PlayerStatus_NotWon)
				{
					pendingPlayers++;
				}
				else
				{
					successfulPlayers++;
				}
			}
		}

		if (alivePlayers == 0)
		{
			// If no one's alive - just end it man
			EndBoss();
		}

		if (successfulPlayers > 0 && pendingPlayers == 0)
		{
			EndBoss();
		}
	}
}

void Bossgame1_NotifyPlayerComplete(Player invoker)
{
	char name[32];
	GetClientName(invoker.ClientId, name, sizeof(name));

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			CPrintToChat(i, "%T", "Bossgame1_PlayerReachedEndFirst", i, PLUGIN_PREFIX, name);
		}
	}
}