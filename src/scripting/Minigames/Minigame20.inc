/**
 * MicroTF2 - Minigame 20
 *
 * Munch / Drink
 */

new Minigame20_PlayerClass;

public Minigame20_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame20_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame20_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame20_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame20_OnMinigameFinish);
}

public bool:Minigame20_OnCheck()
{
	return true;
}

public Minigame20_OnMinigameSelectedPre()
{
	if (MinigameID == 20)
	{
		Minigame20_PlayerClass = GetRandomInt(0, 3);
	}
}

public Minigame20_OnMinigameSelected(client)
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

public Minigame20_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		decl String:text[64];

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

		DisplayHudMessageToClient(client, text, "", 3.0);
	}
}

public Minigame20_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 20)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && TF2_IsPlayerInCondition(i, TFCond_Taunting))
			{	
				//Credit to Tylerst & Powerlord!
				new activeWeapon = FindSendPropOffs("CTFPlayer", "m_hActiveWeapon");
				new currentWeapon = GetEntDataEnt2(i, activeWeapon);
				if (IsValidEntity(currentWeapon))
				{
					new weaponIndex = GetEntProp(currentWeapon, Prop_Send, "m_iItemDefinitionIndex");
					switch (weaponIndex)
					{
						case 46, 163, 42, 311: ClientWonMinigame(i); //Drink / Munch Minigame!
					}
				}
			}
		}
	}
}

public Minigame20_OnMinigameFinish()
{
	if (IsMinigameActive && MinigameID == 20)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i] && (GetClientTeam(i) == 2 || GetClientTeam(i) == 3))
			{
				TF2_RemoveCondition(i, TFCond_Taunting);
				TF2_RemoveCondition(i, TFCond_CritCola);
			}
		}
	}
}