/**
 * MicroTF2 - Minigame 17
 * 
 * Hit a Heavy / Get Hit by a Medic
 */

new Minigame17_Selected[MAXPLAYERS+1];
new Minigame17_ClientTeam;

public Minigame17_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame17_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame17_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Minigame17_OnPlayerTakeDamage);
}

public bool:Minigame17_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}

	if (GetTeamClientCount(2) < 1 || GetTeamClientCount(3) < 1)
	{
		return false;
	}

	return false; // Currently disabled due to TakeDamage issues.
}

public Minigame17_OnMinigameSelectedPre()
{
	if (MinigameID == 17)
	{
		Minigame17_ClientTeam = GetRandomInt(2, 3);

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i))
			{
				Minigame17_Selected[i] = 0;
			}
		}
	}
}

public Minigame17_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 17 && IsClientValid(client))
	{
		if (GetClientTeam(client) == Minigame17_ClientTeam)	//Selected Team Has to Hit 
		{
			TF2_SetPlayerClass(client, TFClass_Medic);
			IsGodModeEnabled(client, true);
			ResetWeapon(client, true);
			Minigame17_Selected[client] = 1;
		}
		else
		{
			TF2_SetPlayerClass(client, TFClass_Heavy);
			IsGodModeEnabled(client, false);
			ResetWeapon(client, false);
			//Don't need to show an overlay, its already default
			SetPlayerHealth(client, 1000);
			Minigame17_Selected[client] = 0;
		}
	}
}

public Minigame17_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		if (GetClientTeam(client) == Minigame17_ClientTeam)
		{
			MinigameCaption[client] = "HIT A HEAVY!";
		}
		else
		{
			MinigameCaption[client] = "GET HIT BY A MEDIC!";
		}
	}
}

public void Minigame17_OnPlayerTakeDamage(int victim, int attacker, float damage)
{
	if (IsMinigameActive && MinigameID == 17)
	{
		if (IsClientValid(attacker) && IsClientValid(victim) && IsPlayerParticipant[attacker] && IsPlayerParticipant[victim])
		{
			if (Minigame17_Selected[attacker] == 1 && Minigame17_Selected[victim] == 0)
			{
				ClientWonMinigame(attacker);
				ClientWonMinigame(victim);
			}
		}
	}
}
