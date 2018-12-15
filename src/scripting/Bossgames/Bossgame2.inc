/**
 * MicroTF2 - Bossgame 2
 * 
 * Escape route
 */

bool Bossgame2_CanCheckPosition = false;

public void Bossgame2_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame2_OnSelection);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame2_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame2_BossCheck);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame2_OnPlayerDeath);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame2_OnGameFrame);
}

public bool Bossgame2_OnCheck()
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

public void Bossgame2_OnMinigameSelectedPre()
{
	if (BossgameID == 5)
	{
		float pos[3] = { 5116.0, 2204.0, 503.0 };

		Bossgame2_SpawnTriggerer(pos);

		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		IsOnlyBlockingDamageByPlayers = true;
		Bossgame2_CanCheckPosition = false;
	}
}

public void Bossgame2_OnSelection(int client)
{
	if (IsMinigameActive && BossgameID == 2 && IsClientValid(client))
	{
		float ang[3] = { 0.0, 180.0, 0.0 };
		float vel[3] = { 0.0, 0.0, 0.0 };

		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Engineer);
		ResetWeapon(client, false);

		int column = client;
		int row = 0;
		while (column > 8) 
		{
			column = column - 8;
			row = row + 1;
		}

		float pos[3] = { 4680.5, 2275.0, 1.0 };
		// pos[0] = 6380.0 + float(row*55);
		// pos[1] = 1400.0 + float(column*55);
		// pos[2] = -310.0; 

		IsViewModelVisible(client, true);
		IsGodModeEnabled(client, false);
		IsPlayerCollisionsEnabled(client, false);

		SetPlayerHealth(client, 5000);
		//SetEntProp(client, Prop_Send, "m_iHideHUD", 0);

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Bossgame2_OnGameFrame()
{
	if (BossgameID == 2 && IsMinigameActive && !IsMinigameEnding && Bossgame2_CanCheckPosition) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && IsPlayerAlive(i) && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				float clientPos[3];
				GetClientAbsOrigin(i, clientPos);

				// X: 0
				// Y: 1
				// Z: 2

				if (clientPos[0] < 3960.0)
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public void Bossgame2_OnPlayerDeath(int victim, int attacker)
{
	if (IsMinigameActive && BossgameID == 2 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public void Bossgame2_BossCheck()
{
	if (IsMinigameActive && BossgameID == 2)
	{
		Bossgame2_CanCheckPosition = true;

		int alivePlayers = 0;
		int successfulPlayers = 0;
		int pendingPlayers = 0;

		for (int i = 1; i <= MaxClients; i++)
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

public void Bossgame2_SpawnTriggerer(float pos[3])
{
	int entity = CreateEntityByName("prop_physics");

	if (IsValidEdict(entity))
	{
		DispatchKeyValue(entity, "model", "models/props_farm/wooden_barrel.mdl");
		DispatchSpawn(entity);

		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.25, Timer_RemoveEntity, entity);
	}
}