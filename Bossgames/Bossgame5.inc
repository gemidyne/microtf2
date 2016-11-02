/**
 * MicroTF2 - Bossgame 5
 * 
 * BeatBlock Galaxy by Mario6493
 */

new bool:Bossgame5_CanCheckPosition;

public Bossgame5_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame5_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame5_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame5_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame5_OnBossStopAttempt);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame5_OnGameFrame);
}

public bool:Bossgame5_OnCheck()
{
	switch (SpecialRoundID)
	{
		case 1, 5, 6, 7:
		{
			// Due to BGM syncing issues, this boss cannot be run on the above special rounds.
			return false;
		}
	}

	return true;
}

public Bossgame5_OnMinigameSelectedPre()
{
	if (BossgameID == 5)
	{
		Bossgame5_CanCheckPosition = false;
		IsBlockingDamage = false;
		IsOnlyBlockingDamageByPlayers = true;
		IsBlockingDeaths = false;
	}
}

public Bossgame5_OnMinigameSelected(client)
{
	if (IsMinigameActive && BossgameID == 5 && IsClientValid(client))
	{
		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Engineer);
		ResetWeapon(client, true);

		new Float:pos[3];
		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3] = { 0.0, 90.0, 0.0 };

		new team = GetClientTeam(client);

		if (team == 2) // RED
		{
			pos[0] = -13436.606445;
			pos[1] = -14211.976563;
			pos[2] = 490.0;
		}
		else // BLU
		{
			pos[0] = -13180.606445;
			pos[1] = -14211.976563;
			pos[2] = 490.0;
		}

		TeleportEntity(client, pos, ang, vel);

		IsGodModeEnabled(client, false);
		IsPlayerCollisionsEnabled(client, false);
		ResetHealth(client);
	}
}

public Bossgame5_OnPlayerDeath(victim, attacker)
{
	if (IsMinigameActive && BossgameID == 5 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public Bossgame5_OnBossStopAttempt()
{
	if (IsMinigameActive && BossgameID == 5)
	{
		Bossgame5_CanCheckPosition = true;
		new alivePlayers = 0;
		new successfulPlayers = 0;
		new pendingPlayers = 0;

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
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

		if (alivePlayers < 1)
		{
			EndBoss();
		}

		if (successfulPlayers > 0 && pendingPlayers == 0)
		{
			EndBoss();
		}
	}
}

public Bossgame5_OnGameFrame()
{
	if (BossgameID == 5 && IsMinigameActive && !IsMinigameEnding && Bossgame5_CanCheckPosition) 
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && IsPlayerAlive(i) && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				new Float:clientPos[3];
				GetClientAbsOrigin(i, clientPos);

				if (clientPos[1] > -1790.0)
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}