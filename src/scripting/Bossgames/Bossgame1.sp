/**
 * MicroTF2 - Bossgame 1
 * 
 * Acid Pit Escape
 */

bool g_bBossgame1CanCheckWinArea = false;
bool g_bBossgame1HasAnyPlayerWon;

public void Bossgame1_EntryPoint()
{
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame1_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame1_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame1_OnMinigameSelected);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Bossgame1_OnPlayerDeath);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame1_BossCheck);
}

public void Bossgame1_OnTfRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Bossgame1_WinArea") == 0)
		{
			SDKHook(entity, SDKHook_StartTouch, Bossgame1_OnTriggerTouched);
			break;
		}
	}
}

public Action Bossgame1_OnTriggerTouched(int entity, int other)
{
	if (!g_bBossgame1CanCheckWinArea || g_iActiveBossgameId != 1 || !g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}

	Player activator = new Player(other);

	if (activator.IsValid && activator.IsAlive && activator.IsParticipating && activator.Status == PlayerStatus_NotWon)
	{
		activator.TriggerSuccess();

		if (!g_bBossgame1HasAnyPlayerWon && Config_BonusPointsEnabled())
		{
			activator.Score++;

			Bossgame1_NotifyPlayerComplete(activator);
			g_bBossgame1HasAnyPlayerWon = true;
		}
	}

	return Plugin_Continue;
}

public void Bossgame1_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId == 1)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		g_bIsBlockingKillCommands = true;
		g_bBossgame1HasAnyPlayerWon = false;
		g_bBossgame1CanCheckWinArea = false;
	}
}

public void Bossgame1_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 1)
	{
		return;
	}

	if (!g_bIsMinigameActive)
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

		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		float pos[3];
		pos[0] = 2160.0 - float(row*75);
		pos[1] = 4356.0 + float(column*75);
		pos[2] = -325.0;

		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { -6.0, 180.0, 0.0 };

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Bossgame1_OnPlayerDeath(int victim, int attacker)
{
	if (g_iActiveBossgameId != 1)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(victim);

	if (player.IsValid)
	{
		player.Status = PlayerStatus_Failed;
	}
}

public void Bossgame1_BossCheck()
{
	if (g_bIsMinigameActive && g_iActiveBossgameId == 1)
	{
		g_bBossgame1CanCheckWinArea = true;

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
			player.PrintChatText("%T", "Bossgame1_PlayerReachedEndFirst", i, name);
		}
	}
}