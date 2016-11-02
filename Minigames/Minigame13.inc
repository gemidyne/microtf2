/**
 * MicroTF2 - Minigame 13
 * 
 * Spycrab
 */

new Float:MinigameThirteen_ClientEyePositionAngle[3];

public Minigame13_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameThirteen_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinishPre, INVALID_HANDLE, MinigameThirteen_OnMinigameFinishPre);
}

public MinigameThirteen_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 13 && IsClientValid(client))
	{
		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Spy);

		GiveWeapon(client, 27);
		IsViewModelVisible(client, true);
	}
}

public MinigameThirteen_OnMinigameFinishPre()
{
	if (MinigameID == 13)
	{
		IsBlockingDeaths = false;

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i])
			{
				new button = GetClientButtons(i);
				new Float:min = 45.0 * -1;

				GetClientEyeAngles(i, MinigameThirteen_ClientEyePositionAngle);
				if (MinigameThirteen_ClientEyePositionAngle[0] < min && (button & IN_DUCK) == IN_DUCK)
				{
					ClientWonMinigame(i);
				}

				if (MinigameThirteen_ClientEyePositionAngle[0] > min || (button & IN_DUCK) != IN_DUCK)
				{
					SlapPlayer(i, 5000, false);
					PlayerStatus[i] = PlayerStatus_Failed;
					CPrintToChat(i, "{green}%T", "Minigame13_SpycrabsMustCrouchAndLookup", i);
				}
			}
		}

		IsBlockingDeaths = true;
	}
}