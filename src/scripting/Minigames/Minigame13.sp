/**
 * MicroTF2 - Minigame 13
 * 
 * Spycrab
 */

float Minigame13_ClientEyePositionAngle[3];

public void Minigame13_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame13_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinishPre, INVALID_HANDLE, Minigame13_OnMinigameFinishPre);
}

public void Minigame13_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 13 && IsClientValid(client))
	{
		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Spy);

		GiveWeapon(client, 27);
		IsViewModelVisible(client, true);
	}
}

public void Minigame13_OnMinigameFinishPre()
{
	if (MinigameID == 13)
	{
		IsBlockingDeathCommands = false;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i])
			{
				int button = GetClientButtons(i);
				float min = 45.0 * -1;

				GetClientEyeAngles(i, Minigame13_ClientEyePositionAngle);
				if (Minigame13_ClientEyePositionAngle[0] < min && (button & IN_DUCK) == IN_DUCK)
				{
					ClientWonMinigame(i);
				}

				if (Minigame13_ClientEyePositionAngle[0] > min || (button & IN_DUCK) != IN_DUCK)
				{
					SlapPlayer(i, 5000, false);
					PlayerStatus[i] = PlayerStatus_Failed;
					CPrintToChat(i, "%s%T", PLUGIN_PREFIX, "Minigame13_SpycrabsMustCrouchAndLookup", i);
				}
			}
		}

		IsBlockingDeathCommands = true;
	}
}