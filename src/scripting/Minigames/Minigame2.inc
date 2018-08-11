/**
 * MicroTF2 - Minigame 2
 * 
 * Kill an Enemy
 */

new Minigame2_Class = -1;

public Minigame2_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameTwo_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameTwo_OnSelection);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, MinigameTwo_OnPlayerDeath);
}

public bool:Minigame2_OnCheck()
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

public MinigameTwo_OnSelectionPre()
{
	if (MinigameID == 2)
	{
		SetConVarInt(ConVar_FriendlyFire, 1);

		Minigame2_Class = GetRandomInt(0, 8);
		IsBlockingDamage = false;
		IsBlockingDeaths = false;
	}
}

public MinigameTwo_OnSelection(client)
{
	if (IsMinigameActive && MinigameID == 2 && IsClientValid(client))
	{
		new TFClassType:class;
		new weapon = 0;

		switch (Minigame2_Class)
		{
			case 0:
			{
				class = TFClass_Scout;
				weapon = 13;
			}
			case 1:
			{
				class = TFClass_Soldier;
				weapon = 10;
			}
			case 2: 
			{
				class = TFClass_Pyro;
				weapon = 12;
			}
			case 3:
			{
				class = TFClass_DemoMan;
				weapon = 1;
			}
			case 4:
			{
				class = TFClass_Heavy;
				weapon = 11;
			}
			case 5:
			{
				class = TFClass_Engineer;
				weapon = 9;
			}
			case 6:
			{
				class = TFClass_Medic;
				weapon = 8;
			}
			case 7:
			{
				class = TFClass_Sniper;
				weapon = 16;
			}
			case 8:
			{
				class = TFClass_Spy;
				weapon = 24;
			}
		}

		TF2_SetPlayerClass(client, class);

		ResetWeapon(client, true);
		GiveWeapon(client, weapon);

		SetPlayerHealth(client, 1);
		IsGodModeEnabled(client, false);
		IsViewModelVisible(client, true);
	}
}

public MinigameTwo_OnPlayerDeath(victim, attacker)
{
	if (IsMinigameActive && MinigameID == 2)
	{
		if (IsClientValid(victim) && IsPlayerParticipant[victim] && IsClientValid(attacker) && IsPlayerParticipant[attacker])
		{
			if (PlayerStatus[victim] == PlayerStatus_NotWon)
			{
				PlayerStatus[victim] = PlayerStatus_Failed;
			}

			ClientWonMinigame(attacker);
		}
	}
}