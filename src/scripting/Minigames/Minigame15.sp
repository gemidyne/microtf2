/**
 * MicroTF2 - Minigame 15
 * 
 * Build! 
 */

bool Minigame15_AssertObject = false;
TFObjectType Minigame15_ExpectedObject;

public void Minigame15_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame15_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame15_OnMinigameSelected);
	AddToForward(GlobalForward_OnBuildObject, INVALID_HANDLE, Minigame15_OnBuildObject);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame15_OnMinigameFinish);
}

public void Minigame15_OnMinigameSelectedPre()
{
	if (MinigameID == 15)
	{
		Minigame15_AssertObject = GetRandomInt(0, 1) == 1;

		if (Minigame15_AssertObject)
		{
			switch (GetRandomInt(0, 2))
			{
				case 0:
				{
					Minigame15_ExpectedObject = TFObject_Dispenser;
				}

				case 1:
				{
					Minigame15_ExpectedObject = TFObject_Teleporter;
				}

				case 2:
				{
					Minigame15_ExpectedObject = TFObject_Sentry;
				}
			}
		}
		else
		{
			SetConVarInt(ConVar_TFCheapObjects, 1); // Buildings dont cost metal to build. 
		}
	}
}

public void Minigame15_OnMinigameSelected(int client)
{
	if (MinigameID != 15)
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
		player.Class = TFClass_Engineer;
		player.Regenerate();
		
		int ammoOffset = FindDataMapInfo(client, "m_iAmmo");

		if (ammoOffset == -1)
		{
			SetFailState("Failed to find m_iAmmo offset on CTFPlayer.");
		}

		SetEntData(client, ammoOffset + (3 * 4), 200, 4);
	}
}

public void Minigame15_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		if (Minigame15_AssertObject)
		{
			switch (Minigame15_ExpectedObject)
			{
				case TFObject_Dispenser:
				{
					text = "BUILD A DISPENSER!";
				}
				case TFObject_Teleporter:
				{
					text = "BUILD A TELEPORTER!";
				}
				case TFObject_Sentry:
				{
					text = "BUILD A SENTRY!";
				}
			}
		}
		else
		{
			text = "BUILD SOMETHING!";
		}

		MinigameCaption[client] = text;
	}
}

public void Minigame15_OnBuildObject(int client, int entity)
{
	if (MinigameID != 15)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		bool winner = false;

		if (!Minigame15_AssertObject)
		{
			winner = true;
		}
		else
		{
			TFObjectType entityType = TF2_GetObjectType(entity);

			winner = entityType == Minigame15_ExpectedObject;
		}

		if (winner)
		{
			ClientWonMinigame(client);
		}
	}
}

public void Minigame15_OnMinigameFinish()
{
	if (MinigameID == 15)
	{
		SetConVarInt(ConVar_TFCheapObjects, 0);

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && IsPlayerParticipant[i])
			{
				player.DestroyPlayerBuildings(true);
			}
		}
	}
}

