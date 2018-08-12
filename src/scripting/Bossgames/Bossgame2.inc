/**
 * MicroTF2 - Bossgame 2
 * 
 * Run the Course (Heavy Ver)
 */

new bool:Bossgame2_CanCheckPosition = false;

public Bossgame2_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame2_OnSelection);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame2_BossCheck);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame2_OnPlayerDeath);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame2_OnGameFrame);
}

public bool:Bossgame2_OnCheck()
{
	if (SpecialRoundID == 12)
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

public Bossgame2_OnSelection(client)
{
	if (IsMinigameActive && BossgameID == 2 && IsClientValid(client))
	{
		Bossgame2_CanCheckPosition = false;
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		IsOnlyBlockingDamageByPlayers = true;

		new Float:ang[3] = { 0.0, 180.0, 0.0 };
		new Float:vel[3] = { 0.0, 0.0, 0.0 };

		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Heavy);
		GiveWeapon(client, 239);

		new column = client;
		new row = 0;
		while (column > 8) 
		{
			column = column - 8;
			row = row + 1;
		}

		new Float:pos[3];
		pos[0] = 6380.0 + float(row*55);
		pos[1] = 1400.0 + float(column*55);
		pos[2] = -310.0; 

		IsViewModelVisible(client, true);
		IsGodModeEnabled(client, false);
		IsPlayerCollisionsEnabled(client, false);

		SetPlayerHealth(client, 5000);
		//SetEntProp(client, Prop_Send, "m_iHideHUD", 0);

		TeleportEntity(client, pos, ang, vel);
	}
}

public Bossgame2_OnGameFrame()
{
	if (BossgameID == 2 && IsMinigameActive && !IsMinigameEnding && Bossgame2_CanCheckPosition) 
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && IsPlayerAlive(i) && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				new Float:clientPos[3];
				GetClientAbsOrigin(i, clientPos);

				// X: 0
				// Y: 1
				// Z: 2

				if (clientPos[1] > 1970.4 && clientPos[0] > 3680.0)
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public Bossgame2_OnPlayerDeath(victim, attacker)
{
	if (IsMinigameActive && BossgameID == 2 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public Bossgame2_BossCheck()
{
	if (IsMinigameActive && BossgameID == 2)
	{
		Bossgame2_CanCheckPosition = true;

		new alivePlayers = 0;
		new successfulPlayers = 0;
		new pendingPlayers = 0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && IsPlayerParticipant[i])
			{
				alivePlayers++;

				if (PlayerStatus[i] == PlayerStatus_NotWon)
				{
					pendingPlayers++;
				}
				else if (PlayerStatus[i] == PlayerStatus_Winner)
				{
					successfulPlayers++;
				}
			}
		}

		if (alivePlayers == 0)
		{
			// If no one's alive - just end it.
			EndBoss();
		}

		if (successfulPlayers > 0 && pendingPlayers == 0)
		{
			EndBoss();
		}
	}
}