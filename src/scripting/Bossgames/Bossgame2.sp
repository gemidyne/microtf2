/**
 * MicroTF2 - Bossgame 2
 * 
 * Escape route
 */

bool Bossgame2_CanCheckPosition = false;

public void Bossgame2_EntryPoint()
{
	AddToForward(GlobalForward_OnTfRoundStart, INVALID_HANDLE, Bossgame2_OnTfRoundStart);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame2_OnSelection);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame2_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame2_BossCheck);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame2_OnPlayerDeath);
}

public void Bossgame2_OnMinigameSelectedPre()
{
	if (BossgameID == 2)
	{
		float pos[3] = { 5116.0, 2204.0, 503.0 };

		Bossgame2_SpawnTriggerer(pos);

		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
		IsOnlyBlockingDamageByPlayers = true;
		Bossgame2_CanCheckPosition = false;
	}
}

public void Bossgame2_OnSelection(int client)
{
	if (BossgameID != 2)
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

	player.RemoveAllWeapons();
	player.Class = TFClass_Engineer;
	player.SetGodMode(false);
	player.SetCollisionsEnabled(false);
	player.ResetHealth();

	ResetWeapon(client, false);

	float vel[3] = { 0.0, 0.0, 0.0 };
	float ang[3] = { 0.0, 0.0, 0.0 };
	float pos[3];

	int column = client;
	int row = 0;
	while (column > 6)
	{
		column = column - 6;
		row = row + 1;
	}

	pos[0] = 4250.0 + float(row*70);
	pos[1] = 2700.0 - float(column*70);
	pos[2] = 0.0;

	TeleportEntity(client, pos, ang, vel);
}

public void Bossgame2_OnTfRoundStart()
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_Bossgame2_WinArea") == 0)
		{
			HookSingleEntityOutput(entity, "OnStartTouch", Bossgame2_OnTriggerTouched, false);
			break;
		}
	}
}

public void Bossgame2_OnTriggerTouched(const char[] output, int caller, int activatorId, float delay)
{
	if (!Bossgame2_CanCheckPosition)
	{
		return;
	}

	Player activator = new Player(activatorId);

	if (activator.IsValid && activator.IsAlive && activator.IsParticipating && activator.Status == PlayerStatus_NotWon)
	{
		ClientWonMinigame(activatorId);
	}
}

public void Bossgame2_OnPlayerDeath(int victimId, int attacker)
{
	if (BossgameID != 2)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	Player victim = new Player(victimId);

	if (victim.IsValid)
	{
		victim.Status = PlayerStatus_Failed;
	}
}

public void Bossgame2_BossCheck()
{
	if (BossgameID != 2)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	Bossgame2_CanCheckPosition = true;

	int alivePlayers = 0;
	int successfulPlayers = 0;
	int pendingPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsAlive && player.IsParticipating)
		{
			alivePlayers++;

			if (player.Status == PlayerStatus_NotWon)
			{
				pendingPlayers++;
			}
			else if (player.Status == PlayerStatus_Winner)
			{
				successfulPlayers++;
			}
		}
	}

	if (alivePlayers == 0)
	{
		// If no one's alive - just end it.
		EndBoss();
	}

	if (successfulPlayers > 0 && pendingPlayers == 0)
	{
		EndBoss();
	}
}

public void Bossgame2_SpawnTriggerer(float pos[3])
{
	int entity = CreateEntityByName("prop_physics");

	if (IsValidEdict(entity))
	{
		DispatchKeyValue(entity, "model", "models/props_farm/wooden_barrel.mdl");
		DispatchSpawn(entity);

		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(0.25, Timer_RemoveEntity, entity);
	}
}