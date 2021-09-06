/**
 * MicroTF2 - Minigame 14
 * 
 * Sap a building! / Get sapped!
 */

TFTeam g_tMinigame14SpyTeam;

public void Minigame14_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame14_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame14_OnMinigameSelected);
	AddToForward(g_pfOnBuildObject, INVALID_HANDLE, Minigame14_OnBuildObject);
	AddToForward(g_pfOnPlayerSappedObject, INVALID_HANDLE, Minigame14_OnPlayerSappedObject);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame14_OnMinigameFinish);
}

public void Minigame14_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId != 14)
	{
		return;
	}
	
	g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
	g_tMinigame14SpyTeam = view_as<TFTeam>(GetRandomInt(2, 3));
}

public void Minigame14_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		char text[64];

		if (player.Team == g_tMinigame14SpyTeam)
		{
			Format(text, sizeof(text), "%T", "Minigame14_Caption_Spies", client);
		}
		else
		{
			Format(text, sizeof(text), "%T", "Minigame14_Caption_Engineers", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame14_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 14)
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
		if (player.Team == g_tMinigame14SpyTeam)
		{
			player.Class = TFClass_Spy;
			player.RemoveAllWeapons();
			player.GiveWeapon(735);
			player.SetViewModelVisible(true);
			player.SetWeaponVisible(true);
		}
		else
		{
			player.Class = TFClass_Engineer;
			player.RemoveAllWeapons();
			player.GiveWeapon(28);
			player.GiveWeapon(25);
			player.GiveWeapon(7);
			player.SetViewModelVisible(true);
			player.SetWeaponVisible(true);

			player.Metal = 200;
		}
	}
}

public void Minigame14_OnBuildObject(int client, int entity)
{
	if (g_iActiveMinigameId != 14)
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
		SetEntData(entity, g_oCollisionGroup, 2, 4, true);
	}
}

public void Minigame14_OnPlayerSappedObject(int attackerId, int buildingOwnerId)
{
	if (g_iActiveMinigameId != 14)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player attacker = new Player(attackerId);
	Player owner = new Player(buildingOwnerId);

	attacker.TriggerSuccess();
	owner.TriggerSuccess();
}

public void Minigame14_OnMinigameFinish()
{
	if (g_iActiveMinigameId == 14)
	{
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