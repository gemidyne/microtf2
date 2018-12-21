/**
 * MicroTF2 - Minigame 1
 * 
 * Get to the End
 */

public void Minigame1_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame1_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame1_OnSelection);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame1_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame1_OnFinish);
}

public bool Minigame1_OnCheck()
{
	return true;
}

public void Minigame1_OnSelectionPre()
{
	if (MinigameID == 1)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;
	}
}

public void Minigame1_OnSelection(int client)
{
	if (IsMinigameActive && MinigameID == 1 && IsClientValid(client))
	{
		float ang[3] = { 0.0, 90.0, 0.0 };
		float vel[3] = { 0.0, 0.0, 0.0 };
		float pos[3];

		TF2_SetPlayerClass(client, TFClass_Scout);
		IsGodModeEnabled(client, false);
		IsPlayerCollisionsEnabled(client, false);
		ResetWeapon(client, false);
		SetPlayerHealth(client, 1000);

		int column = client;
		int row = 0;
		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		pos[0] = -4730.0 + float(column*55);
		pos[1] = 2951.0 - float(row*55);
		pos[2] = -1373.0;  //setpos -4690 2951 -1373

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Minigame1_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				float pos[3];
				GetClientAbsOrigin(i, pos);

				if (pos[1] > 3755.0)
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public void Minigame1_OnFinish()
{
	if (IsMinigameActive && MinigameID == 1)
	{
		for (int i = 1; i <= MaxClients; i++) 
		{
			if (IsClientValid(i) && IsPlayerParticipant[i]) 
			{
				TF2_RespawnPlayer(i);
			}
		}
	}
}