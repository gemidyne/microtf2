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
	if (MinigameID != 13)
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
		player.RemoveAllWeapons();
		player.Class = TFClass_Spy;

		player.GiveWeapon(27);
	}
}

public void Minigame13_OnMinigameFinishPre()
{
	if (MinigameID == 13)
	{
		IsBlockingDeathCommands = false;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				int button = GetClientButtons(i);
				float min = 45.0 * -1;

				GetClientEyeAngles(i, Minigame13_ClientEyePositionAngle);
				if (Minigame13_ClientEyePositionAngle[0] < min && (button & IN_DUCK) == IN_DUCK)
				{
					player.TriggerSuccess();
				}

				if (Minigame13_ClientEyePositionAngle[0] > min || (button & IN_DUCK) != IN_DUCK)
				{
					SlapPlayer(i, 5000, false);
					player.Status = PlayerStatus_Failed;
					CPrintToChat(i, "%s%T", PLUGIN_PREFIX, "Minigame13_SpycrabsMustCrouchAndLookup", i);
				}
			}
		}

		IsBlockingDeathCommands = true;
	}
}