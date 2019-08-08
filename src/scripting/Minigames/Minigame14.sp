/**
 * MicroTF2 - Minigame 14
 * 
 * Sap a building! / Get sapped!
 */

TFTeam Minigame14_SpyTeam;

public void Minigame14_EntryPoint()
{
	// AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame14_OnMinigameSelectedPre);
	// AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame14_OnMinigameSelected);
	// AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame14_OnGameFrame);
	// AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame14_OnMinigameFinish);
}

public void Minigame14_OnMinigameSelectedPre()
{
	if (MinigameID != 14)
	{
		return;
	}
	
	IsBlockingDamage = false;
	IsOnlyBlockingDamageByPlayers = true;

	Minigame14_SpyTeam = view_as<TFTeam>(GetRandomInt(2, 3));
}

public void Minigame14_OnMinigameSelected(int client)
{
	if (MinigameID != 14)
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
		if (player.Team == Minigame14_SpyTeam)
		{
			player.Class = TFClass_Spy;
			ResetWeapon(client, false);
		}
		else
		{
			player.Class = TFClass_Engineer;
			player.Regenerate();
			player.SetViewModelVisible(true);
			player.SetWeaponVisible(true);
			
			int ammoOffset = FindDataMapInfo(client, "m_iAmmo");

			if (ammoOffset == -1)
			{
				SetFailState("Failed to find m_iAmmo offset on CTFPlayer.");
			}

			SetEntData(client, ammoOffset + (3 * 4), 200, 4);
		}
	}
}