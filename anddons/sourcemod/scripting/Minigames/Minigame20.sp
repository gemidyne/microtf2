/**
 * MicroTF2 - Minigame 20
 *
 * Munch / Drink
 */

int Minigame20_PlayerClass;
bool Minigame20_InvertedMode;

public void Minigame20_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame20_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame20_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerConditionAdded, INVALID_HANDLE, Minigame20_OnPlayerConditionAdded);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame20_OnMinigameFinish);
}

public void Minigame20_OnMinigameSelectedPre()
{
	if (MinigameID == 20)
	{
		Minigame20_PlayerClass = GetRandomInt(0, 3);
		Minigame20_InvertedMode = GetRandomInt(0, 1) == 1;
	}
}

public void Minigame20_OnMinigameSelected(int client)
{
	if (MinigameID != 20)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	switch (Minigame20_PlayerClass)
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

	if (Minigame20_InvertedMode)
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

		if (Minigame20_InvertedMode)
		{
			switch (Minigame20_PlayerClass)
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
			switch (Minigame20_PlayerClass)
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
	if (MinigameID != 20)
	{
		return;
	}

	if (!IsMinigameActive)
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
				if (Minigame20_InvertedMode)
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
	if (IsMinigameActive && MinigameID == 20)
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