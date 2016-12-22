/**
 * MicroTF2 - Bossgame 1
 * 
 * Get to the End
 */

public Bossgame1_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame1_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame1_OnGameFrame);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame1_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame1_BossCheck);
}

public bool:Bossgame1_OnCheck()
{
	return true;
}

public Bossgame1_OnMinigameSelected(client)
{
	if (IsMinigameActive && BossgameID == 1 && IsClientValid(client))
	{
		IsBlockingDamage = false;
		IsBlockingDeaths = false;

		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3] = { 0.0, 180.0, 0.0 };

		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Soldier);
		GiveWeapon(client, 237);

		IsGodModeEnabled(client, false);
		IsViewModelVisible(client, true);
		IsPlayerCollisionsEnabled(client, false);

		SetPlayerHealth(client, 5000);
		SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_MISCSTATUS);

		new column = client;
		new row = 0;
		while (column > 12)
		{
			column = column - 12;
			row = row + 1;
		}

		new Float:pos[3];
		pos[0] = 1800.0 - float(row*75);
		pos[1] = 8600.0 + float(column*75);
		pos[2] = -140.0; //setpos 1596.3 8702.3 -69.4
		TeleportEntity(client, pos, ang, vel);
	}
}

public Bossgame1_OnGameFrame()
{
	if (IsMinigameActive && BossgameID == 1 && !IsMinigameEnding)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && IsPlayerAlive(i) && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				new Float:pos[3];
				GetClientAbsOrigin(i, pos);

				if (pos[2] > 2800.0) 
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public Bossgame1_OnPlayerDeath(victim, attacker)
{
	if (IsMinigameActive && BossgameID == 1 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public Bossgame1_BossCheck()
{
	if (IsMinigameActive && BossgameID == 1)
	{
		new alivePlayers = 0;
		new successfulPlayers = 0;
		new pendingPlayers = 0;
		for (new i = 1; i <= MaxClients; i++)
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