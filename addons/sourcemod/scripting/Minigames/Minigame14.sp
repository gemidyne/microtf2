/**
 * MicroTF2 - Minigame 14
 * 
 * Sap a building! / Get sapped!
 */

TFTeam Minigame14_SpyTeam;

public void Minigame14_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame14_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame14_OnMinigameSelected);
	AddToForward(GlobalForward_OnBuildObject, INVALID_HANDLE, Minigame14_OnBuildObject);
	AddToForward(GlobalForward_OnPlayerSappedObject, INVALID_HANDLE, Minigame14_OnPlayerSappedObject);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame14_OnMinigameFinish);
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

public void Minigame14_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		char text[64];

		if (player.Team == Minigame14_SpyTeam)
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
	if (MinigameID != 14)
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
		SetEntData(entity, Offset_Collision, 2, 4, true);
	}
}

public void Minigame14_OnPlayerSappedObject(int attackerId, int buildingOwnerId)
{
	if (MinigameID != 14)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	ClientWonMinigame(attackerId);
	ClientWonMinigame(buildingOwnerId);
}

public void Minigame14_OnMinigameFinish()
{
	if (MinigameID == 14)
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