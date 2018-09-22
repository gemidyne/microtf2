/**
 * MicroTF2 - Minigame 4
 * 
 * Airblast!
 */

int Minigame4_TotalPlayers;

public void Minigame4_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame4_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame4_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Minigame4_OnPlayerDeath);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame4_OnMinigameFinish);
}

public bool Minigame4_OnCheck()
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

public void Minigame4_OnMinigameSelectedPre()
{
	if (MinigameID == 4)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;
		Minigame4_TotalPlayers = GetActivePlayers();
	}
}

public void Minigame4_OnMinigameSelected(int client)
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

		float vel[3] = { 0.0, 0.0, 0.0 };
		int posa = 360 / Minigame4_TotalPlayers * (PlayerIndex[client]-1);
		float pos[3];
		float ang[3];

		pos[0] = -7567.6 + (Cosine(DegToRad(float(posa)))*220.0);
		pos[1] = 3168.0 - (Sine(DegToRad(float(posa)))*220.0);
		pos[2] = -282.0;

		ang[0] = 0.0;
		ang[1] = float(180-posa);
		ang[2] = 0.0;

		TeleportEntity(client, pos, ang, vel);
		SDKHook(client, SDKHook_PreThink, Minigame4_RemoveLeftClick);
	}
}

public void Minigame4_OnPlayerDeath(int client, int attacker)
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

public void Minigame4_OnMinigameFinish()
{
	if (IsMinigameActive && MinigameID == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i] && GetClientTeam(i) > 1)
			{
				PlayerStatus[i] = (IsPlayerAlive(i) ? PlayerStatus_Winner : PlayerStatus_Failed);

				SDKUnhook(i, SDKHook_PreThink, Minigame4_RemoveLeftClick);
				TF2_RespawnPlayer(i);
			}
		}
	}
}

public void Minigame4_RemoveLeftClick(int client)
{
	int buttons = GetClientButtons(client);

	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}