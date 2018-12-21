/**
 * MicroTF2 - Minigame 19
 *
 * Change Class!
 */

TFClassType Minigame19_ClassMode = TFClass_Unknown;

public void Minigame19_EntryPoint()
{
	AddToForward(GlobalForward_OnPlayerClassChange, INVALID_HANDLE, Minigame19_OnPlayerClassChange);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame19_OnMinigameSelectedPre);
}

public bool Minigame19_OnCheck()
{
	return true;
}

public void Minigame19_OnMinigameSelectedPre()
{
	if (MinigameID == 19)
	{
		Minigame19_ClassMode = view_as<TFClassType>(GetRandomInt(0, 9));

		IsBlockingDeathCommands = false;
	}
}

public void Minigame19_GetDynamicCaption(int client)
{
	if (IsClientValid(client))
	{
		char text[64];

		switch (Minigame19_ClassMode)
		{
			case TFClass_Unknown:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassAny", client);
			}

			case TFClass_Scout:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassScout", client);
			}

			case TFClass_Soldier:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassSoldier", client);
			}

			case TFClass_Pyro:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassPyro", client);
			}

			case TFClass_DemoMan:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassDemoman", client);
			}

			case TFClass_Heavy:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassHeavy", client);
			}

			case TFClass_Engineer:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassEngineer", client);
			}

			case TFClass_Medic:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassMedic", client);
			}

			case TFClass_Sniper:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassSniper", client);
			}

			case TFClass_Spy:
			{
				Format(text, sizeof(text), "%T", "Minigame19_Caption_ChangeClassSpy", client);
			}
		}

		MinigameCaption[client] = text;
	}
}

public void Minigame19_OnPlayerClassChange(int client, int class)
{
	if (IsMinigameActive && MinigameID == 19 && IsClientValid(client) && IsPlayerParticipant[client])
	{
		TFClassType playerClass = TF2_GetPlayerClass(class);

		if (Minigame19_ClassMode == TFClass_Unknown)
		{
			// Any class is acceptable
			ClientWonMinigame(client);
		}
		else if (playerClass == Minigame19_ClassMode)
		{
			// Must match expected class.
			ClientWonMinigame(client);
		}
	}
}