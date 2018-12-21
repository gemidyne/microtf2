/**
 * MicroTF2 - Bossgame 1
 * 
 * Get to the top 
 */

public void Bossgame1_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame1_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame1_OnGameFrame);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame1_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame1_BossCheck);
}

public bool Bossgame1_OnCheck()
{
	return true;
}

public void Bossgame1_OnMinigameSelected(int client)
{
	if (IsMinigameActive && BossgameID == 1 && IsClientValid(client))
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;

		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 180.0, 0.0 };

		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Soldier);
		GiveWeapon(client, 237);

		IsGodModeEnabled(client, false);
		IsViewModelVisible(client, true);
		IsPlayerCollisionsEnabled(client, false);

		SetPlayerHealth(client, 5000);

		int column = client;
		int row = 0;

		while (column > 12)
		{
			column = column - 12;
			row = row + 1;
		}

		float pos[3];
		pos[0] = 1800.0 - float(row*75);
		pos[1] = 8600.0 + float(column*75);
		pos[2] = -140.0; //setpos 1596.3 8702.3 -69.4

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Bossgame1_OnGameFrame()
{
	if (IsMinigameActive && BossgameID == 1 && !IsMinigameEnding)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && IsPlayerAlive(i) && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				float pos[3];
				GetClientAbsOrigin(i, pos);

				if (pos[2] > 2800.0) 
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public void Bossgame1_OnPlayerDeath(int victim, int attacker)
{
	if (IsMinigameActive && BossgameID == 1 && IsClientValid(victim))
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
			if (IsClientInGame(i) && IsPlayerAlive(i) && IsPlayerParticipant[i])
			{
				alivePlayers++;

				if (PlayerStatus[i] == PlayerStatus_Failed || PlayerStatus[i] == PlayerStatus_NotWon)
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