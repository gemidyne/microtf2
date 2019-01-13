/**
 * MicroTF2 - Bossgame 5
 * 
 * BeatBlock Galaxy by Mario6493
 */

bool Bossgame5_CanCheckPosition;
bool Bossgame5_BlockState;
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
	PrecacheSound("ui/hitsound_retro1.wav", true);
	PrecacheSound("ui/chime_rd_2base_pos.wav", true);
}

public bool Bossgame5_OnCheck()
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

public void Bossgame5_OnMinigameSelectedPre()
{
	if (BossgameID == 5)
	{
		Bossgame5_SwitchYellow();

		Bossgame5_CanCheckPosition = false;
		Bossgame5_Step = 4.0;

		IsBlockingDamage = false;
		IsOnlyBlockingDamageByPlayers = true;
		IsBlockingDeathCommands = false;

		CreateTimer(0.5, Bossgame5_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Bossgame5_OnMinigameSelected(int client)
{
	if (IsMinigameActive && BossgameID == 5 && IsClientValid(client))
	{
		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Engineer);
		ResetWeapon(client, true);

		float pos[3];
		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 90.0, 0.0 };

		int team = GetClientTeam(client);

		if (team == 2) // RED
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

		IsGodModeEnabled(client, false);
		IsPlayerCollisionsEnabled(client, false);
		ResetHealth(client);
	}
}

public void Bossgame5_OnPlayerDeath(int victim, int attacker)
{
	if (IsMinigameActive && BossgameID == 5 && IsClientValid(victim))
	{
		PlayerStatus[victim] = PlayerStatus_Failed;
	}
}

public void Bossgame5_OnBossStopAttempt()
{
	if (IsMinigameActive && BossgameID == 5)
	{
		Bossgame5_CanCheckPosition = true;
		int alivePlayers = 0;
		int successfulPlayers = 0;
		int pendingPlayers = 0;

		for (int i = 1; i <= MaxClients; i++)
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

public void Bossgame5_OnTfRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Bossgame5_WinArea") == 0)
		{
			HookSingleEntityOutput(entity, "OnTrigger", Bossgame5_OnTriggerTouched, false);
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

	if (IsClientValid(activator) && IsPlayerParticipant[activator] && IsPlayerAlive(activator) && PlayerStatus[activator] == PlayerStatus_NotWon)
	{
		ClientWonMinigame(activator);
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
			EmitSoundToAll("ui/chime_rd_2base_pos.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, 150);
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
	float pos[3] = { -15000.0, -912.0, 2656.0 };

	Bossgame5_DoSwitch(pos);
}

public void Bossgame5_SwitchYellow() 
{
	float pos[3] = { -14840.0, -912.0, 2656.0 };

	Bossgame5_DoSwitch(pos);
}

public void Bossgame5_DoSwitch(float pos[3])
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