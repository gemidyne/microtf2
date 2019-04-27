/**
 * MicroTF2 - Bossgame 6
 * 
 * Target Practice
 */

/*
 * HORIZONTAL MIN: -1807 
 * HORIZONTAL MAX: -4063
 * VERTICAL MAX: 2495
 * VERTICAL MIN: 1199
 * (3) -1350  is the floor coord / Z
 * (2) is the Y - forward and back from view 
 * (1) is the X - left and right from view
 */

int Bossgame6_EntityIndexes[32];
int Bossgame6_Timer;
int Bossgame6_PlayerScore[MAXPLAYERS+1] = 0;

public void Bossgame6_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Bossgame6_OnMapStart);
	AddToForward(GlobalForward_OnTfRoundStart, INVALID_HANDLE, Bossgame6_OnTfRoundStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame6_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame6_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame6_OnMinigameFinish);
}

public void Bossgame6_OnMapStart()
{
}

public void Bossgame6_OnTfRoundStart()
{
	Bossgame6_SendDoorInput("Close");
}

public void Bossgame6_OnMinigameSelectedPre()
{
	if (BossgameID == 6)
	{
		for (int i = 0; i < 32; i++)
		{
			Bossgame6_EntityIndexes[i] = 0;
		}

		for (int i = 0; i < MAXPLAYERS; i++)
		{
			Bossgame6_PlayerScore[i] = 0;
		}

		IsBlockingDamage = true;
		IsOnlyBlockingDamageByPlayers = true;
		IsBlockingDeathCommands = true;

		Bossgame6_SendDoorInput("Close");

		Bossgame6_Timer = 9;
		CreateTimer(0.5, Bossgame6_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Bossgame6_OnMinigameSelected(int client)
{
	if (BossgameID != 6)
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
	player.Class = TFClass_Spy;
	player.SetGodMode(true);
	player.SetCollisionsEnabled(false);
	player.ResetHealth();
	GiveWeapon(client, 24);
	player.SetAmmo(2);

	float vel[3] = { 0.0, 0.0, 0.0 };
	float ang[3] = { 0.0, 90.0, 0.0 };
	float pos[3];

	int column = client;
	int row = 0;

	while (column > 24)
	{
		column = column - 24;
		row = row + 1;
	}

	pos[0] = -4015.0 + float(column*60); 
	pos[1] = 959.0 - float(row*100);
	pos[2] = -1093.0;

	TeleportEntity(client, pos, ang, vel);
}

public void Bossgame6_OnMinigameFinish()
{
	if (BossgameID == 6 && IsMinigameActive) 
	{
		Bossgame6_SendDoorInput("Close");
		Bossgame6_CleanupEntities();

		int threshold = 0;
		int winningClient = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && Bossgame6_PlayerScore[player.ClientId] > threshold)
			{
				threshold = Bossgame6_PlayerScore[player.ClientId];
				winningClient = player.ClientId;
			}
		}

		Player winner = new Player(winningClient);
		winner.Status = PlayerStatus_Winner;
	}
}

public Action Bossgame6_SwitchTimer(Handle timer)
{
	if (BossgameID == 6 && IsMinigameActive && !IsMinigameEnding) 
	{
		switch (Bossgame6_Timer)
		{
			case 8: 
				Bossgame6_SendDoorInput("Close");
				
			case 7: 
			{
				Bossgame6_CleanupEntities();
				for (int i = 1; i <= MaxClients; i++)
				{
					Player player = new Player(i);

					if (player.IsValid && player.IsParticipating)
					{
						player.SetAmmo(0, false, true);
						player.SetAmmo(2, true, false);
					}
				}
			}

			case 6: 
				Bossgame6_DoEntitySpawns();

			case 5: 
				Bossgame6_SendDoorInput("Open");

			case 0:
				Bossgame6_Timer = 9;
		}

		Bossgame6_Timer--;
		return Plugin_Continue;
	}

	Bossgame6_Timer = 9;
	return Plugin_Stop; 
}

public void Bossgame6_DoEntitySpawns()
{
	float Bossgame6_SpawnedEntityPositions[32][3];
	int count = GetRandomInt(1, 32);

	for (int i = 0; i < count; i++)
	{
		bool validPosition = false;
		float position[3];
		int calculationAttempts = 0;

		while (!validPosition)
		{
			validPosition = true;
			calculationAttempts++;

			if (calculationAttempts > 32)
			{
				return;
			}

			position[0] = GetRandomFloat(-1807.0, -4063.0);
			position[1] = GetRandomFloat(-2495.0, -1199.0);
			position[2] = -1350.0;

			for (int j = 0; j < 32; j++)
			{
				if (j == i)
				{
					continue;
				}

				float distance = GetVectorDistance(position, Bossgame6_SpawnedEntityPositions[j]);

				if (distance <= 100)
				{
					validPosition = false;
				}
			}
		}

		int entity = CreateEntityByName("prop_physics");

		if (IsValidEdict(entity))
		{
			// TODO: Random model here
			DispatchKeyValue(entity, "model", "models/props_farm/wooden_barrel.mdl");
			DispatchSpawn(entity);

			TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);
			SDKHook(entity, SDKHook_OnTakeDamage, Bossgame6_Barrel_OnTakeDamage);
		}

		Bossgame6_EntityIndexes[i] = entity;
	}
}

public Action Bossgame6_Barrel_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	Player player = new Player(attacker);

	if (player.IsValid)
	{
		Bossgame6_PlayerScore[player.ClientId]++;
		return Plugin_Continue;
	}
	else
	{
		damage = 0.0;
		return Plugin_Changed;
	}
}

public void Bossgame6_CleanupEntities()
{
	for (int i = 0; i < 32; i++)
	{
		int entity = Bossgame6_EntityIndexes[i];

		if (IsValidEdict(entity) && entity > MaxClients)
		{
			CreateTimer(0.0, Timer_RemoveEntity, entity);
		}
	}
}

public void Bossgame6_SendDoorInput(const char[] input)
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "func_door")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_TPBoss_Door") == 0)
		{
			AcceptEntityInput(entity, input, -1, -1, -1);
			break;
		}
	}
}