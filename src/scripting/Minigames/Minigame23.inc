/**
 * MicroTF2 - Minigame 23
 *
 * Double jump!
 */

bool Minigame23_CanCheckConditions = false;

public Minigame23_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame23_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame23_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerRunCmd, INVALID_HANDLE, Minigame23_OnPlayerRunCmd);
}

public bool Minigame23_OnCheck()
{
	return true;
}

public void Minigame23_OnMinigameSelectedPre()
{
	if (MinigameID == 23)
	{
		Minigame23_CanCheckConditions = false;
		CreateTimer(1.5, Timer_Minigame23_AllowConditions);
	}
}

public Action Timer_Minigame23_AllowConditions(Handle timer)
{
	Minigame23_CanCheckConditions = true;
}

public void Minigame23_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 23 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Scout);
		ResetWeapon(client, false);
	}
}

public void Minigame23_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!IsMinigameActive)
	{
		return;
	}

	if (MinigameID != 23)
	{
		return;
	}

	if (!Minigame23_CanCheckConditions)
	{
		return;
	}

	if (!IsClientValid(client))
	{
		return;
	}

	if (!IsPlayerParticipant[client])
	{
		return;
	}

	if (PlayerStatus[client] != PlayerStatus_NotWon)
	{
		return;
	}

	int flags = GetEntityFlags(client);

	if (buttons & IN_JUMP)
	{
		if (flags & FL_ONGROUND)
		{
			// First jump
		}
		else
		{
			ClientWonMinigame(client);
		}
	}
}