/**
 * MicroTF2 - Bossgame 6
 * 
 * Target Practice
 */

public void Bossgame6_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Bossgame5_OnMapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame5_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame5_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame5_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame5_OnBossStopAttempt);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Bossgame5_OnGameFrame);
}

public void Bossgame6_OnMapStart()
{
}

public bool:Bossgame6_OnCheck()
{
	return true;
}

public Bossgame6_OnMinigameSelectedPre()
{
	if (BossgameID == 6)
	{
		IsBlockingDamage = true;
		IsOnlyBlockingDamageByPlayers = true;
		IsBlockingDeathCommands = true;

		//CreateTimer(0.5, Bossgame5_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Bossgame6_OnMinigameSelected(client)
{
	if (IsMinigameActive && BossgameID == 6 && IsClientValid(client))
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

public Action Bossgame5_SwitchTimer(Handle timer)
{
	if (BossgameID == 5 && IsMinigameActive && !IsMinigameEnding) 
	{
		Bossgame5_Step -= 0.5;
		PrintToChatAll("DBG: %f", Bossgame5_Step);

		if (Bossgame5_Step > 1.5)
		{
			// Silent
		}
		else if (Bossgame5_Step > 0)
		{
			// TODO: Needs a sound
			EmitSoundToAll("ui/chime_rd_2base_pos.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, 150);
		}
		else 
		{
			PlaySoundToAll("ui/hitsound_retro1.wav");
			PrintToChatAll("DBG: SWITCH");

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