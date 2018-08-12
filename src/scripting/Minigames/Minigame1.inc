/**
 * MicroTF2 - Minigame 1
 * 
 * Get to the End
 */

public Minigame1_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameOne_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameOne_OnSelection);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, MinigameOne_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, MinigameOne_OnFinish);
}

public bool:Minigame1_OnCheck()
{
	return true;
}

public MinigameOne_OnSelectionPre()
{
	if (MinigameID == 1)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;
	}
}

public MinigameOne_OnSelection(i)
{
	if (IsMinigameActive && MinigameID == 1 && IsClientValid(i))
	{
		new Float:ang[3] = { 0.0, 90.0, 0.0 };
		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:pos[3];

		TF2_SetPlayerClass(i, TFClass_Scout);
		IsGodModeEnabled(i, false);
		IsPlayerCollisionsEnabled(i, false);
		ResetWeapon(i, false);
		SetPlayerHealth(i, 1000);

		new column = i;
		new row = 0;
		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		pos[0] = -4730.0 + float(column*55);
		pos[1] = 2951.0 - float(row*55);
		pos[2] = -1373.0;  //setpos -4690 2951 -1373

		TeleportEntity(i, pos, ang, vel);
	}
}

public MinigameOne_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 1)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				new Float:pos[3];
				GetClientAbsOrigin(i, pos);
				if (pos[1] > 3755.0)
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public MinigameOne_OnFinish()
{
	if (IsMinigameActive && MinigameID == 1)
	{
		for (new i = 1; i <= MaxClients; i++) 
		{
			if (IsClientValid(i) && IsPlayerParticipant[i]) 
			{
				TF2_RespawnPlayer(i);
			}
		}
	}
}