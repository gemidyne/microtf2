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

public bool:Minigame20_OnCheck()
{
	// TODO: Fix usage of lunchbox items
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
	if (IsMinigameActive && MinigameID == 20 && IsClientValid(client))
	{
		switch (Minigame20_PlayerClass)
		{
			case 0:
			{
				TF2_SetPlayerClass(client, TFClass_Scout);
				ResetWeapon(client, true);
				GiveWeapon(client, 163);
			}
			case 1:
			{
				TF2_SetPlayerClass(client, TFClass_Scout);
				ResetWeapon(client, true);
				GiveWeapon(client, 46);
			}
			case 2:
			{
				TF2_SetPlayerClass(client, TFClass_Heavy);
				ResetWeapon(client, true);
				GiveWeapon(client, 42);
			}	
			case 3:
			{	
				TF2_SetPlayerClass(client, TFClass_Heavy);
				ResetWeapon(client, true);
				GiveWeapon(client, 311);
			}
		}
		
		IsViewModelVisible(client, true);
	}
}

public void Minigame20_GetDynamicCaption(int client)
{
	if (IsClientValid(client))
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		switch (Minigame20_PlayerClass)
		{
			case 0:
			{
				text = "DRINK!";
			}
			case 1:
			{
				text = "DRINK!";
			}
			case 2:
			{
				text = "EAT!";
			}	
			case 3:
			{	
				text = "EAT!";
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
			if (IsClientValid(i) && IsPlayerParticipant[i] && TF2_IsPlayerInCondition(i, TFCond_Taunting))
			{	
				//Credit to Tylerst & Powerlord!
				int activeWeapon = FindSendPropInfo("CTFPlayer", "m_hActiveWeapon");

				if (activeWeapon <= 0)
				{
					SetFailState("Unable to find m_hActiveWeapon offset on CTFPlayer.");
				}

				int currentWeapon = GetEntDataEnt2(i, activeWeapon);

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
			if (IsClientInGame(i) && IsPlayerParticipant[i] && (GetClientTeam(i) == 2 || GetClientTeam(i) == 3))
			{
				TF2_RemoveCondition(i, TFCond_Taunting);
				TF2_RemoveCondition(i, TFCond_CritCola);
			}
		}
	}
}