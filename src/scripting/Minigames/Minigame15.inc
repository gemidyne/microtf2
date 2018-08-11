/**
 * MicroTF2 - Minigame 15
 * 
 * Build! 
 */

new bool:Minigame15_AssertObject = false;
new TFObjectType:Minigame15_ExpectedObject;

public Minigame15_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame15_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame15_OnMinigameSelected);
	AddToForward(GlobalForward_OnBuildObject, INVALID_HANDLE, Minigame15_OnBuildObject);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame15_OnMinigameFinish);
}

public bool:Minigame15_OnCheck()
{
	if (GetTeamClientCount(2) > 5)
	{
		return false;
	}

	return true;
}

public Minigame15_OnMinigameSelectedPre()
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

public Minigame15_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 15 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Engineer);
		TF2_RegeneratePlayer(client);
		IsViewModelVisible(client, true);

		int ammoOffset = FindDataMapInfo(client, "m_iAmmo");

		if (ammoOffset == -1)
		{
			SetFailState("Failed to find m_iAmmo offset on CTFPlayer.");
		}

		SetEntData(client, ammoOffset + (3 * 4), 200, 4);
	}
}

public Minigame15_GetDynamicCaption(client)
{
	if (IsClientValid(client))
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

public Minigame15_OnBuildObject(client, entity)
{
	if (IsMinigameActive && MinigameID == 15 && IsClientValid(client) && IsPlayerParticipant[client]) 
	{
		new bool:winner = false;

		if (!Minigame15_AssertObject)
		{
			winner = true;
		}
		else
		{
			new TFObjectType:entityType = TF2_GetObjectType(entity);

			winner = entityType == Minigame15_ExpectedObject;
		}

		if (winner)
		{
			ClientWonMinigame(client);
		}
	}
}

public Minigame15_OnMinigameFinish()
{
	if (MinigameID == 15)
	{
		SetConVarInt(ConVar_TFCheapObjects, 0);

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i])
			{
				DestroyPlayerBuildings(i, true);
			}
		}
	}
}

