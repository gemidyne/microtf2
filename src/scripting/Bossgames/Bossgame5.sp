/**
 * MicroTF2 - Bossgame 5
 * 
 * BeatBlock Galaxy by Mario6493
 */

bool g_bBossgame5CanCheckWinArea;
bool g_bBossgame5BlockState;
bool g_bBossgame5HasAnyPlayerWon;
float g_fBossgame5Timer = 4.0;

public void Bossgame5_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame5_OnMapStart);
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame5_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame5_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame5_OnMinigameSelected);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Bossgame5_OnPlayerDeath);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame5_OnBossStopAttempt);
}

public void Bossgame5_OnMapStart()
{
	PreloadSound(BOSSGAME_SFX_BBCOUNT);
	PreloadSound("ui/chime_rd_2base_pos.wav");
	PreloadSound("ui/hitsound_retro1.wav");
}

public void Bossgame5_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId != 5)
	{
		return;
	}

	Bossgame5_SwitchYellow();

	g_bBossgame5CanCheckWinArea = false;
	g_fBossgame5Timer = 4.0;
	g_bBossgame5HasAnyPlayerWon = false;

	g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
	g_bIsBlockingKillCommands = false;

	CreateTimer(0.5, Bossgame5_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void Bossgame5_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 5)
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
		player.Class = TFClass_Engineer;
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);
		player.ResetHealth();
		player.ResetWeapon(true);

		int column = player.ClientId;
		int row = 0;

		while (column > 3)
		{
			column = column - 3;
			row = row + 1;
		}

		float pos[3];
		pos[0] = -13495.0 + float(column*90);
		pos[1] = -14510.0 + float(row*85);
		pos[2] = 490.0;

		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 90.0, 0.0 };

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Bossgame5_OnPlayerDeath(int victimId, int attacker)
{
	if (g_iActiveBossgameId != 5)
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

public void Bossgame5_OnBossStopAttempt()
{
	if (g_iActiveBossgameId != 5)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	g_bBossgame5CanCheckWinArea = true;
	int alivePlayers = 0;
	int successfulPlayers = 0;
	int pendingPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && player.IsAlive && player.IsParticipating)
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

	if (alivePlayers < 1)
	{
		EndBoss();
	}

	if (successfulPlayers > 0 && pendingPlayers == 0)
	{
		EndBoss();
	}
}

public void Bossgame5_OnTfRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Bossgame5_WinArea") == 0)
		{
			SDKHook(entity, SDKHook_StartTouch, Bossgame5_OnTriggerTouched);
			break;
		}
	}
}

public Action Bossgame5_OnTriggerTouched(int entity, int other)
{
	if (!g_bBossgame5CanCheckWinArea)
	{
		return Plugin_Continue;
	}

	Player player = new Player(other);

	if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status == PlayerStatus_NotWon)
	{
		player.TriggerSuccess();

		if (!g_bBossgame5HasAnyPlayerWon && Config_BonusPointsEnabled())
		{
			player.Score++;
			Bossgame5_NotifyPlayerComplete(player);

			g_bBossgame5HasAnyPlayerWon = true;
		}
	}

	return Plugin_Continue;
}

public Action Bossgame5_SwitchTimer(Handle timer)
{
	if (g_iActiveBossgameId == 5 && g_bIsMinigameActive && !g_bIsMinigameEnding) 
	{
		g_fBossgame5Timer -= 0.5;

		if (g_fBossgame5Timer > 1.5)
		{
			// Silent
		}
		else if (g_fBossgame5Timer > 0)
		{
			PlaySoundToAll(BOSSGAME_SFX_BBCOUNT);
		}
		else 
		{
			PlaySoundToAll("ui/hitsound_retro1.wav");

			g_fBossgame5Timer = 4.0;
			g_bBossgame5BlockState = !g_bBossgame5BlockState;

			if (g_bBossgame5BlockState)
			{
				Bossgame5_SwitchGreen();
			}
			else
			{
				Bossgame5_SwitchYellow();
			}
		}

		return Plugin_Continue;
	}

	return Plugin_Stop; 
}

public void Bossgame5_SwitchGreen() 
{
	Bossgame5_SendEntityInput("beatblock_yellow", true);
	Bossgame5_SendEntityInput("beatblock_green", false);
}

public void Bossgame5_SwitchYellow() 
{
	Bossgame5_SendEntityInput("beatblock_yellow", false);
	Bossgame5_SendEntityInput("beatblock_green", true);
}

public void Bossgame5_SendEntityInput(const char[] relayName, bool state)
{
	int entity = -1;
	char entityName[32];
	char input[16];

	input = state ? "Enable" : "Disable";

	while ((entity = FindEntityByClassname(entity, "func_brush")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, relayName) == 0)
		{
			AcceptEntityInput(entity, input, -1, -1, -1);
			break;
		}
	}
}

void Bossgame5_NotifyPlayerComplete(Player invoker)
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
			player.PrintChatText("%T", "Bossgame5_PlayerReachedEndFirst", i, name);
		}
	}
}