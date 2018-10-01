/**
 * MicroTF2 - Minigame 25
 *
 * Jetpack! Get in the air quickly, or else.
 */

public void Minigame25_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame25_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame25_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame25_OnMinigameFinish);
}

public bool Minigame25_OnCheck()
{
	return true;
}

public void Minigame25_OnMinigameSelectedPre()
{
	if (MinigameID == 25)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;

		CreateTimer(0.15, Timer_Minigame25_TriggerWater);
	}
}

public void Minigame25_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 25 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Pyro);
		TF2_RemoveAllWeapons(client);

		GiveWeapon(client, 1179);

		IsGodModeEnabled(client, false);
		SetPlayerHealth(client, 3000);
		IsViewModelVisible(client, true);
	}
}

public void Minigame25_OnMinigameFinish()
{
	if (MinigameID == 25)
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

public Action Timer_Minigame25_TriggerWater(Handle timer) 
{
	int triggerer = CreateEntityByName("prop_physics");

	if (IsValidEdict(triggerer))
	{
		DispatchKeyValue(triggerer, "model", "models/props_farm/wooden_barrel.mdl");
		DispatchSpawn(triggerer);

		float pos[3] = { -1248.0, -1328.0, 1584.0 };

		TeleportEntity(triggerer, pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.25, Timer_RemoveEntity, triggerer);
	}

	return Plugin_Handled;
}