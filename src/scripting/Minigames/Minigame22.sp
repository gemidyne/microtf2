/**
 * MicroTF2 - Minigame 22
 *
 * Stay on the ground!
 */

bool Minigame22_CanCheckConditions = false;

public void Minigame22_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame22_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame22_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame22_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame22_OnMinigameFinish);
}

public bool Minigame22_OnCheck()
{
	return true;
}

public void Minigame22_OnMinigameSelectedPre()
{
	if (MinigameID == 22)
	{
		IsBlockingDamage = false;
		Minigame22_CanCheckConditions = false;
		
		CreateTimer(2.0, Timer_Minigame22_AllowConditions);
	}
}

public Action Timer_Minigame22_AllowConditions(Handle timer)
{
	Minigame22_CanCheckConditions = true;
}

public void Minigame22_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 22 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Soldier);
		GiveWeapon(client, 18);

		IsViewModelVisible(client, true);
		IsGodModeEnabled(client, false);

		SetPlayerHealth(client, 3000);
		TF2_AddCondition(client, TFCond_Kritzkrieged, 4.0);
	}
}

public void Minigame22_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 22 && Minigame22_CanCheckConditions)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i])
			{
				if (!(GetEntityFlags(i) & FL_ONGROUND))
				{
					PlayerStatus[i] = PlayerStatus_Failed;
					ForcePlayerSuicide(i);
				}
			}
		}
	}
}

public void Minigame22_OnMinigameFinish()
{
	if (MinigameID == 22)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && (GetEntityFlags(i) & FL_ONGROUND) && IsPlayerAlive(i))
			{
				ClientWonMinigame(i);
			}
		}
	}
}

