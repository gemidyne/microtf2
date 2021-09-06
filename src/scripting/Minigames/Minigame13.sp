/**
 * MicroTF2 - Minigame 13
 * 
 * Spycrab
 */

public void Minigame13_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame13_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinishPre, INVALID_HANDLE, Minigame13_OnMinigameFinishPre);
}

public void Minigame13_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 13)
	{
		return;
	}

	if (!g_bIsMinigameActive)
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
	if (g_iActiveMinigameId == 13)
	{
		g_bIsBlockingKillCommands = false;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				int button = GetClientButtons(i);
				float min = 45.0 * -1;
				float angle[3];

				GetClientEyeAngles(i, angle);
				
				if (angle[0] < min && (button & IN_DUCK) == IN_DUCK)
				{
					player.TriggerSuccess();
					continue;
				}

				player.SetGodMode(false);

				SDKHooks_TakeDamage(player.ClientId, player.ClientId, player.ClientId, 5000.0, DMG_CLUB);
				player.Status = PlayerStatus_Failed;
				player.PrintChatText("%T", "Minigame13_SpycrabsMustCrouchAndLookup", i);
			}
		}

		g_bIsBlockingKillCommands = true;
	}
}