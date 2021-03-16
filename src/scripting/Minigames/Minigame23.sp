/**
 * MicroTF2 - Minigame 23
 *
 * Double jump!
 */

bool Minigame23_CanCheckConditions = false;

public void Minigame23_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame23_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame23_OnMinigameSelected);
	AddToForward(g_pfOnPlayerRunCmd, INVALID_HANDLE, Minigame23_OnPlayerRunCmd);
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
	return Plugin_Handled;
}

public void Minigame23_OnMinigameSelected(int client)
{
	if (MinigameID != 23)
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
		player.Class = TFClass_Scout;
		player.ResetWeapon(false);
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

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	if (!player.IsParticipating)
	{
		return;
	}

	if (player.Status != PlayerStatus_NotWon)
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
			player.TriggerSuccess();
		}
	}
}