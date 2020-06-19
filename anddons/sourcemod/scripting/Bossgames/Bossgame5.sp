/**
 * MicroTF2 - Bossgame 5
 * 
 * BeatBlock Galaxy by Mario6493
 */

bool Bossgame5_CanCheckPosition;
bool Bossgame5_BlockState;
bool Bossgame5_Completed;
float Bossgame5_Step = 4.0;

public void Bossgame5_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Bossgame5_OnMapStart);
	AddToForward(GlobalForward_OnTfRoundStart, INVALID_HANDLE, Bossgame5_OnTfRoundStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame5_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame5_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame5_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame5_OnBossStopAttempt);
}

public void Bossgame5_OnMapStart()
{
	PrecacheSound("gemidyne/warioware/bosses/sfx/beatblock_count.mp3", true);
	PrecacheSound("ui/chime_rd_2base_pos.wav", true);
	PrecacheSound("ui/hitsound_retro1.wav", true);
}

public void Bossgame5_OnMinigameSelectedPre()
{
	if (BossgameID != 5)
	{
		return;
	}

	Bossgame5_SwitchYellow();

	Bossgame5_CanCheckPosition = false;
	Bossgame5_Step = 4.0;
	Bossgame5_Completed = false;

	IsBlockingDamage = false;
	IsOnlyBlockingDamageByPlayers = true;
	IsBlockingDeathCommands = false;

	CreateTimer(0.5, Bossgame5_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void Bossgame5_OnMinigameSelected(int client)
{
	if (BossgameID != 5)
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
		player.Class = TFClass_Engineer;
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);
		player.ResetHealth();
		player.ResetWeapon(true);

		float pos[3];
		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 90.0, 0.0 };

		if (player.Team == TFTeam_Red) // RED
		{
			pos[0] = -13436.6;
			pos[1] = -14211.9;
			pos[2] = 490.0;
		}
		else // BLU
		{
			pos[0] = -13180.6;
			pos[1] = -14211.9;
			pos[2] = 490.0;
		}

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Bossgame5_OnPlayerDeath(int victimId, int attacker)
{
	if (BossgameID != 5)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player victim = new Player(victimId);

	if (victim.IsValid)
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public void Bossgame5_OnBossStopAttempt()
{
	if (BossgameID != 5)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	Bossgame5_CanCheckPosition = true;
	int alivePlayers = 0;
	int successfulPlayers = 0;
	int pendingPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && player.IsAlive && player.IsParticipating)
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

public void Bossgame5_OnTfRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Bossgame5_WinArea") == 0)
		{
			HookSingleEntityOutput(entity, "OnStartTouch", Bossgame5_OnTriggerTouched, false);
			break;
		}
	}
}

public void Bossgame5_OnTriggerTouched(const char[] output, int caller, int activator, float delay)
{
	if (!Bossgame5_CanCheckPosition)
	{
		return;
	}

	Player player = new Player(activator);

	if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status == PlayerStatus_NotWon)
	{
		player.TriggerSuccess();

		if (!Bossgame5_Completed && Config_BonusPointsEnabled())
		{
			player.Score++;
			Bossgame5_NotifyPlayerComplete(player);

			Bossgame5_Completed = true;
		}
	}
}

public Action Bossgame5_SwitchTimer(Handle timer)
{
	if (BossgameID == 5 && IsMinigameActive && !IsMinigameEnding) 
	{
		Bossgame5_Step -= 0.5;

		if (Bossgame5_Step > 1.5)
		{
			// Silent
		}
		else if (Bossgame5_Step > 0)
		{
			EmitSoundToAll("gemidyne/warioware/bosses/sfx/beatblock_count.mp3");
		}
		else 
		{
			PlaySoundToAll("ui/hitsound_retro1.wav");

			Bossgame5_Step = 4.0;
			Bossgame5_BlockState = !Bossgame5_BlockState;

			if (Bossgame5_BlockState)
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
	char name[32];
	GetClientName(invoker.ClientId, name, sizeof(name));

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			CPrintToChat(i, "%T", "Bossgame5_PlayerReachedEndFirst", i, PLUGIN_PREFIX, name);
		}
	}
}