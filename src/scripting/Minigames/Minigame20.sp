/**
 * MicroTF2 - Minigame 20
 *
 * Munch / Drink
 */

int Minigame20_PlayerClass;

public void Minigame20_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame20_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame20_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame20_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame20_OnMinigameFinish);
}

public bool Minigame20_OnCheck()
{
	return true;
}

public void Minigame20_OnMinigameSelectedPre()
{
	if (MinigameID == 20)
	{
		Minigame20_PlayerClass = GetRandomInt(0, 3);
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

	if (player.IsValid)
	{
		switch (Minigame20_PlayerClass)
		{
			case 0:
			{
				player.Class = TFClass_Scout;
				ResetWeapon(client, true);
				GiveWeapon(client, 163);
			}
			case 1:
			{
				player.Class = TFClass_Scout;
				ResetWeapon(client, true);
				GiveWeapon(client, 46);
			}
			case 2:
			{
				player.Class = TFClass_Heavy;
				ResetWeapon(client, true);
				GiveWeapon(client, 42);
			}	
			case 3:
			{	
				player.Class = TFClass_Heavy;
				ResetWeapon(client, true);
				GiveWeapon(client, 311);
			}
		}
	}
}

public void Minigame20_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		switch (Minigame20_PlayerClass)
		{
			case 0:
			{
				Format(text, sizeof(text), "%T", "Minigame20_Caption_Drink", client);
			}
			case 1:
			{
				Format(text, sizeof(text), "%T", "Minigame20_Caption_Drink", client);
			}
			case 2:
			{
				Format(text, sizeof(text), "%T", "Minigame20_Caption_Eat", client);
			}	
			case 3:
			{	
				Format(text, sizeof(text), "%T", "Minigame20_Caption_Eat", client);
			}
		}

		MinigameCaption[client] = text;
	}
}

public void Minigame20_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 20)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && TF2_IsPlayerInCondition(i, TFCond_Taunting))
			{	
				//Credit to Tylerst & Powerlord!
				int currentWeapon = GetEntDataEnt2(i, Offset_PlayerActiveWeapon);

				if (IsValidEntity(currentWeapon))
				{
					int weaponIndex = GetEntProp(currentWeapon, Prop_Send, "m_iItemDefinitionIndex");
					switch (weaponIndex)
					{
						case 46, 163, 42, 311: ClientWonMinigame(i); //Drink / Munch Minigame!
					}
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
				TF2_RemoveCondition(i, TFCond_Taunting);
				TF2_RemoveCondition(i, TFCond_CritCola);
			}
		}
	}
}