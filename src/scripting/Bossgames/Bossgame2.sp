/**
 * MicroTF2 - Bossgame 2
 * 
 * Escape from the Factory
 */

bool g_bBossgame2CanCheckWinArea = false;
bool g_bBossgame2HasAnyPlayerWon = false;

public void Bossgame2_EntryPoint()
{
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame2_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame2_OnSelection);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame2_OnMinigameSelectedPre);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame2_BossCheck);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Bossgame2_OnPlayerDeath);
}

public void Bossgame2_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId == 2)
	{
		Bossgame2_SendInput("logic_relay", "ERBoss_InitRelay", "Trigger");

		g_bIsBlockingKillCommands = true;
		g_eDamageBlockMode = EDamageBlockMode_AllPlayers;

		g_bBossgame2CanCheckWinArea = false;
		g_bBossgame2HasAnyPlayerWon = false;

		CreateTimer(0.75, Bossgame2_HurtTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Bossgame2_OnSelection(int client)
{
	if (g_iActiveBossgameId != 2)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	player.RemoveAllWeapons();
	player.Class = TFClass_Engineer;
	player.SetGodMode(false);
	player.SetCollisionsEnabled(false);
	player.ResetHealth();
	player.ResetWeapon(false);

	float vel[3] = { 0.0, 0.0, 0.0 };
	float ang[3] = { 0.0, 144.0, 0.0 };
	float pos[3];

	int column = client;
	int row = 0;

	while (column > 6)
	{
		column = column - 6;
		row = row + 1;
	}

	pos[0] = 4417.0 + float(row*70); 
	pos[1] = 2164.0 + float(column*70);
	pos[2] = 2.0;

	TeleportEntity(client, pos, ang, vel);
}

public void Bossgame2_OnTfRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Bossgame2_WinArea") == 0)
		{
			SDKHook(entity, SDKHook_StartTouch, Bossgame2_OnTriggerTouched);
			break;
		}
	}
}

public Action Bossgame2_OnTriggerTouched(int entity, int other)
{
	if (!g_bBossgame2CanCheckWinArea || g_iActiveBossgameId != 2 || !g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}

	Player activator = new Player(other);

	if (activator.IsValid && activator.IsAlive && activator.IsParticipating && activator.Status == PlayerStatus_NotWon)
	{
		activator.TriggerSuccess();

		if (!g_bBossgame2HasAnyPlayerWon && Config_BonusPointsEnabled())
		{
			activator.Score++;

			Bossgame2_NotifyPlayerComplete(activator);
			g_bBossgame2HasAnyPlayerWon = true;
		}
	}

	return Plugin_Continue;
}

public void Bossgame2_OnPlayerDeath(int victimId, int attacker)
{
	if (g_iActiveBossgameId != 2)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player victim = new Player(victimId);

	if (victim.IsValid)
	{
		victim.Status = PlayerStatus_Failed;
	}
}

public void Bossgame2_BossCheck()
{
	if (g_iActiveBossgameId != 2)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	g_bBossgame2CanCheckWinArea = true;

	int alivePlayers = 0;
	int successfulPlayers = 0;
	int pendingPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsAlive && player.IsParticipating)
		{
			alivePlayers++;

			if (player.Status == PlayerStatus_NotWon)
			{
				pendingPlayers++;
			}
			else if (player.Status == PlayerStatus_Winner)
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

public void Bossgame2_SendInput(const char[] entityClass, const char[] name, const char[] input)
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, entityClass)) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, name) == 0)
		{
			AcceptEntityInput(entity, input, -1, -1, -1);
			//break;
		}
	}
}

public Action Bossgame2_HurtTimer(Handle timer)
{
	if (g_iActiveBossgameId == 2 && g_bIsMinigameActive && !g_bIsMinigameEnding) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsAlive && player.IsParticipating)
			{
				if (player.Health > 0)
				{
					player.Health--;
				}
				else
				{
					player.Kill();
				}
			}
		}

		return Plugin_Continue;
	}

	return Plugin_Stop; 
}

void Bossgame2_NotifyPlayerComplete(Player invoker)
{
	char name[64];
	
	if (invoker.Team == TFTeam_Red)
	{
		Format(name, sizeof(name), "{red}%N{default}", invoker.ClientId);
	}
	else if (invoker.Team == TFTeam_Blue)
	{
		Format(name, sizeof(name), "{blue}%N{default}", invoker.ClientId);
	}
	else
	{
		Format(name, sizeof(name), "{white}%N{default}", invoker.ClientId);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			player.PrintChatText("%T", "Bossgame2_PlayerReachedEndFirst", i, name);
		}
	}
}