/**
 * MicroTF2 - Minigame 15
 * 
 * Build! 
 */

bool g_bMinigame15ShouldAssertObject = false;
TFObjectType g_oMinigame15ExpectedObjectType;

public void Minigame15_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame15_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame15_OnMinigameSelected);
	AddToForward(g_pfOnBuildObject, INVALID_HANDLE, Minigame15_OnBuildObject);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame15_OnMinigameFinish);
}

public void Minigame15_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 15)
	{
		g_bMinigame15ShouldAssertObject = GetRandomInt(0, 1) == 1;

		if (g_bMinigame15ShouldAssertObject)
		{
			switch (GetRandomInt(0, 2))
			{
				case 0:
				{
					g_oMinigame15ExpectedObjectType = TFObject_Dispenser;
				}

				case 1:
				{
					g_oMinigame15ExpectedObjectType = TFObject_Teleporter;
				}

				case 2:
				{
					g_oMinigame15ExpectedObjectType = TFObject_Sentry;
				}
			}
		}
		else
		{
			g_hConVarTFCheapObjects.BoolValue = true;
		}
	}
}

public void Minigame15_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 15)
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
		player.Class = TFClass_Engineer;
		player.RemoveAllWeapons();
		player.GiveWeapon(28);
		player.GiveWeapon(25);
		player.GiveWeapon(7);
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

public void Minigame15_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		if (g_bMinigame15ShouldAssertObject)
		{
			switch (g_oMinigame15ExpectedObjectType)
			{
				case TFObject_Dispenser:
				{
					Format(text, sizeof(text), "%T", "Minigame15_Caption_Dispenser", client);
				}
				case TFObject_Teleporter:
				{
					Format(text, sizeof(text), "%T", "Minigame15_Caption_Teleporter", client);
				}
				case TFObject_Sentry:
				{
					Format(text, sizeof(text), "%T", "Minigame15_Caption_Sentry", client);
				}
			}
		}
		else
		{
			Format(text, sizeof(text), "%T", "Minigame15_Caption_Any", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame15_OnBuildObject(int client, int entity)
{
	if (g_iActiveMinigameId != 15)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		bool winner = false;

		if (!g_bMinigame15ShouldAssertObject)
		{
			winner = true;
		}
		else
		{
			TFObjectType entityType = TF2_GetObjectType(entity);

			winner = entityType == g_oMinigame15ExpectedObjectType;
		}

		if (winner)
		{
			player.TriggerSuccess();
		}
	}
}

public void Minigame15_OnMinigameFinish()
{
	if (g_iActiveMinigameId == 15)
	{
		g_hConVarTFCheapObjects.BoolValue = false;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.DestroyPlayerBuildings(true);
			}
		}
	}
}

