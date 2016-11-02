/**
 * MicroTF2 - Minigame 14
 * 
 * Get into the water
 */

#define FL_ISINWATER (FL_INWATER | FL_FLY | FL_SWIM)

public Minigame14_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameFourteen_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, MinigameFourteen_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, MinigameFourteen_OnMinigameFinish);
}

public bool:Minigame14_OnCheck()
{
	// This minigame is disabled for the time being.
	// Needs an area.
	return false;
}

public MinigameFourteen_OnMinigameSelected(i)
{
	if (IsMinigameActive && MinigameID == 14 && IsClientValid(i))
	{
		TF2_SetPlayerClass(i, TFClass_Scout);
		ResetWeapon(i, false);

		IsGodModeEnabled(i, true);
		IsPlayerCollisionsEnabled(i, false);
		SetPlayerHealth(i, 1000);

		/*
		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3] = { 0.0, 90.0, 0.0 };

		new column = i;
		new row = 0;
		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		new Float:pos[3];
		pos[0] = -5240.4 + float(column*55);
		pos[1] = 2659.9 - float(row*55);
		pos[2] = -293.6;

		TeleportEntity(i, pos, ang, vel);*/

		PrintCenterText(i, "AREA NOT FOUND\n\nUnable to teleport player - automatic win set");
	}
}

public MinigameFourteen_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 14)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && (GetEntityFlags(i) & FL_ISINWATER))
			{
				ClientWonMinigame(i);
			}
		}
	}
}

public MinigameFourteen_OnMinigameFinish()
{
	if (MinigameID == 14)
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i]) 
			{
				ClientWonMinigame(i);
				TF2_RespawnPlayer(i);
			}
		}
	}
}