/**
 * MicroTF2 - Minigame 4
 * 
 * Airblast!
 */

new MinigameFour_TotalPlayers;

public Minigame4_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameFour_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameFour_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, MinigameFour_OnPlayerDeath);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, MinigameFour_OnMinigameFinish);
}

public bool:Minigame4_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}

	if (GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
	{
		return false;
	}

	// If we get here, the minigame can run! 
	return true;
}

public MinigameFour_OnMinigameSelectedPre()
{
	if (MinigameID == 4)
	{
		IsBlockingDamage = false;
		IsBlockingDeaths = false;
		MinigameFour_TotalPlayers = GetActivePlayers();
	}
}

public MinigameFour_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 4 && IsClientValid(client))
	{
		IsGodModeEnabled(client, false);
		SetPlayerHealth(client, 1000);

		TF2_SetPlayerClass(client, TFClass_Pyro);
		TF2_RemoveAllWeapons(client);

		GiveWeapon(client, 21);
		IsViewModelVisible(client, true);
		PlayerStatus[client] = PlayerStatus_Winner;

		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new posa = 360 / MinigameFour_TotalPlayers * (PlayerIndex[client]-1);
		new Float:pos[3];
		new Float:ang[3];

		// new map
		pos[0] = -7567.6 + (Cosine(DegToRad(float(posa)))*220.0);
		pos[1] = 3168.0 - (Sine(DegToRad(float(posa)))*220.0);
		pos[2] = -282.0;
		
		// OLD maps
		//pos[0] = -4833.0 + (Cosine(DegToRad(float(posa)))*220.0);
		//pos[1] = 1711.4 - (Sine(DegToRad(float(posa)))*220.0);
		//pos[2] = -1877.0;

		// 

		ang[0] = 0.0;
		ang[1] = float(180-posa);
		ang[2] = 0.0;

		TeleportEntity(client, pos, ang, vel);
		SDKHook(client, SDKHook_PreThink, MinigameFour_RemoveLeftClick);
	}
}

public MinigameFour_OnPlayerDeath(client, attacker)
{
	if (IsMinigameActive && MinigameID == 4 && IsClientInGame(client) && IsPlayerParticipant[client] && GetClientTeam(client) > 1)
	{
		PlayerStatus[client] = PlayerStatus_Failed;

		if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
		{
			PlayerStatus[attacker] = PlayerStatus_Winner;
		}
	}
}

public MinigameFour_OnMinigameFinish()
{
	if (IsMinigameActive && MinigameID == 4)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i] && GetClientTeam(i) > 1)
			{
				PlayerStatus[i] = (IsPlayerAlive(i) ? PlayerStatus_Winner : PlayerStatus_Failed);

				SDKUnhook(i, SDKHook_PreThink, MinigameFour_RemoveLeftClick);
				TF2_RespawnPlayer(i);
			}
		}
	}
}

public MinigameFour_RemoveLeftClick(client)
{
	new buttons = GetClientButtons(client);
	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}