/**
 * MicroTF2 - Minigame 19
 *
 * Change Class!
 */

TFClassType Minigame19_ClassMode = TFClass_Unknown;

public void Minigame19_EntryPoint()
{
	AddToForward(g_pfOnPlayerClassChange, INVALID_HANDLE, Minigame19_OnPlayerClassChange);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame19_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame19_OnMinigameSelected);
}

public void Minigame19_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 19)
	{
		Minigame19_ClassMode = view_as<TFClassType>(GetRandomInt(0, 9));

		g_bIsBlockingKillCommands = false;
	}
}

public void Minigame19_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 19)
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
		TFClassType playerClass = player.Class;

		if (Minigame19_ClassMode != TFClass_Unknown && playerClass == Minigame19_ClassMode)
		{
			while (playerClass == Minigame19_ClassMode)
			{
				player.SetRandomClass();
				playerClass = player.Class;
			}
		}
	}
}

public void Minigame19_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
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

		player.SetCaption(text);
	}
}

public void Minigame19_OnPlayerClassChange(int client, int class)
{
	if (g_iActiveMinigameId != 19)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
	{
		TFClassType playerClass = view_as<TFClassType>(class);

		if (Minigame19_ClassMode == TFClass_Unknown)
		{
			// Any class is acceptable
			player.TriggerSuccess();
		}
		else if (playerClass == Minigame19_ClassMode)
		{
			// Must match expected class.
			player.TriggerSuccess();
		}
		else
		{
			player.Status = PlayerStatus_Failed;
		}
	}
}