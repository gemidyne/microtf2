/**
 * MicroTF2 - Minigame 20
 *
 * Munch / Drink
 */

int g_iMinigame20PlayerClass;
bool g_bMinigame20InvertConditions;

public void Minigame20_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame20_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame20_OnMinigameSelected);
	AddToForward(g_pfOnPlayerConditionAdded, INVALID_HANDLE, Minigame20_OnPlayerConditionAdded);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame20_OnMinigameFinish);
}

public void Minigame20_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 20)
	{
		g_iMinigame20PlayerClass = GetRandomInt(0, 3);
		g_bMinigame20InvertConditions = GetRandomInt(0, 1) == 1;
	}
}

public void Minigame20_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 20)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	switch (g_iMinigame20PlayerClass)
	{
		case 0:
		{
			player.Class = TFClass_Scout;
			player.ResetWeapon(true);
			player.GiveWeapon(163);
		}
		case 1:
		{
			player.Class = TFClass_Scout;
			player.ResetWeapon(true);
			player.GiveWeapon(46);
		}
		case 2:
		{
			player.Class = TFClass_Heavy;
			player.ResetWeapon(true);
			player.GiveWeapon(42);
		}	
		case 3:
		{	
			player.Class = TFClass_Heavy;
			player.ResetWeapon(true);
			player.GiveWeapon(311);
		}
	}

	player.SetWeaponPrimaryAmmoCount(1);

	if (g_bMinigame20InvertConditions)
	{
		player.Status = PlayerStatus_Winner;
	}
}

public void Minigame20_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		if (g_bMinigame20InvertConditions)
		{
			switch (g_iMinigame20PlayerClass)
			{
				case 0, 1:
				{
					Format(text, sizeof(text), "%T", "Minigame20_Caption_DontDrink", client);
				}
				
				case 2, 3:
				{	
					Format(text, sizeof(text), "%T", "Minigame20_Caption_DontEat", client);
				}
			}
		}
		else
		{
			switch (g_iMinigame20PlayerClass)
			{
				case 0, 1:
				{
					Format(text, sizeof(text), "%T", "Minigame20_Caption_Drink", client);
				}
				
				case 2, 3:
				{	
					Format(text, sizeof(text), "%T", "Minigame20_Caption_Eat", client);
				}
			}
		}

		player.SetCaption(text);
	}
}

public void Minigame20_OnPlayerConditionAdded(int client, int conditionId)
{
	if (g_iActiveMinigameId != 20)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	if (!player.IsParticipating)
	{
		return;
	}

	TFCond condition = view_as<TFCond>(conditionId);

	if (condition == TFCond_Taunting)
	{
		switch (player.ActiveWeaponItemIndex)
		{
			case 46, 163, 42, 311:
			{
				if (g_bMinigame20InvertConditions)
				{
					player.Status = PlayerStatus_Failed;
				}
				else
				{
					player.TriggerSuccess();
				}
			}
		}
	}
}

public void Minigame20_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 20)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.RemoveCondition(TFCond_Taunting);
				player.RemoveCondition(TFCond_CritCola);
			}
		}
	}
}