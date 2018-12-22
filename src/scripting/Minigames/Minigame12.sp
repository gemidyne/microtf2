/**
 * MicroTF2 - Minigame 12
 * 
 * Get on a Platform!
 */

public void Minigame12_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame12_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame12_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame12_OnMinigameFinish);
}

public bool Minigame12_OnCheck()
{
	if (SpecialRoundID == 3)
	{
		// If Low Gravity special round, do not run.
		return false;
	}
	
	return true;
}

public void Minigame12_OnMinigameSelectedPre()
{
	if (MinigameID == 12)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;

		CreateTimer(0.15, Timer_Minigame12_TriggerWater);
	}
}

public void Minigame12_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 12 && IsClientValid(client))
	{
		switch (TF2_GetPlayerClass(client))
		{
			case TFClass_Scout:
			{
				TF2_SetPlayerClass(client, TFClass_Pyro);
			}

			case TFClass_Heavy:
			{
				TF2_SetPlayerClass(client, TFClass_DemoMan);
			}

			case TFClass_Spy:
			{
				TF2_SetPlayerClass(client, TFClass_Sniper);
			}
		}

		ResetWeapon(client, false);

		IsGodModeEnabled(client, false);
		SetPlayerHealth(client, 3000);
		IsViewModelVisible(client, true);

		TF2_AddCondition(client, TFCond_Kritzkrieged, 4.0);
	}
}

public void Minigame12_OnMinigameFinish()
{
	if (MinigameID == 12)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i])
			{
				PlayerStatus[i] = IsPlayerAlive(i) ? PlayerStatus_Winner : PlayerStatus_Failed;
			}
		}
	}
}

public Action Timer_Minigame12_TriggerWater(Handle timer) 
{
	int triggerer = CreateEntityByName("prop_physics");

	if (IsValidEdict(triggerer))
	{
		DispatchKeyValue(triggerer, "model", "models/props_farm/wooden_barrel.mdl");
		DispatchSpawn(triggerer);

		float pos[3] = { -1408.0, -1328.0, 1618.0 };

		TeleportEntity(triggerer, pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.25, Timer_RemoveEntity, triggerer);
	}

	return Plugin_Handled;
}