/**
 * MicroTF2 - Bossgame 8
 * 
 * Count the Props (unfinished)
 */

#define BOSSGAME8_ENTITYSPAWN_COUNT 32
#define BOSSGAME8_ENTITYSPAWN_GROUPCOUNT 4

int g_iBossgame8Entities[BOSSGAME8_ENTITYSPAWN_COUNT];
int g_iBossgame8ParticipatingPlayerCount;
int g_iBossgame8Timer = 6;
char g_sBossgame8EntityModels[][] =
{
	"models/props_hydro/keg_large.mdl",
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_farm/tractor_tire001.mdl",
	"models/props_farm/spool_rope.mdl",
	"models/props_farm/spool_wire.mdl",
	"models/props_gameplay/haybale.mdl",
	"models/props_2fort/milkjug001.mdl",
	"models/props_spytech/watercooler.mdl",
	"models/props_mvm/clipboard.mdl"
};

//int g_iBossgame8EntityTypeIds[BOSSGAME8_ENTITYSPAWN_GROUPCOUNT];

public void Bossgame8_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame8_OnMapStart);
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame8_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame8_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame8_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Bossgame8_OnMinigameFinish);
}

public void Bossgame8_OnMapStart()
{
	for (int i = 0; i < sizeof(g_sBossgame8EntityModels); i++)
	{
		PrecacheModel(g_sBossgame8EntityModels[i]);
	}
}

public void Bossgame8_OnTfRoundStart()
{
	Bossgame8_SendDoorInput("Close");
}

public void Bossgame8_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId == 8)
	{
		for (int i = 0; i < BOSSGAME8_ENTITYSPAWN_COUNT; i++)
		{
			g_iBossgame8Entities[i] = 0;
		}
		
		g_iBossgame8ParticipatingPlayerCount = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				g_iBossgame8ParticipatingPlayerCount++;
			}
		}
		
		g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
		g_bIsBlockingKillCommands = true;

		Bossgame8_SendDoorInput("Close");

		g_iBossgame8Timer = 5;
		CreateTimer(1.0, Bossgame8_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Bossgame8_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 8)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	player.RemoveAllWeapons();
	player.Class = TFClass_Heavy;
	player.SetGodMode(true);
	player.SetCollisionsEnabled(false);
	player.ResetHealth();
	player.ResetWeapon(false);

	float vel[3] = { 0.0, 0.0, 0.0 };
	int posa = 360 / g_iBossgame8ParticipatingPlayerCount * client;
	float pos[3];
	float ang[3];

	pos[0] = -2943.0 + (Cosine(DegToRad(float(posa))) * 768.0);
	pos[1] = 1791.0 - (Sine(DegToRad(float(posa))) * 768.0);
	pos[2] = -1098.0;

	ang[0] = 0.0;
	ang[1] = float(180 - posa);
	ang[2] = 0.0;

	TeleportEntity(client, pos, ang, vel);
}

public void Bossgame8_OnMinigameFinish()
{
	if (g_iActiveBossgameId == 8 && g_bIsMinigameActive) 
	{
		Bossgame8_SendDoorInput("Close");
		Bossgame8_CleanupEntities();

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && player.IsAlive)
			{
				player.Status = PlayerStatus_Winner;
			}
		}
	}
}

public Action Bossgame8_SwitchTimer(Handle timer)
{
	if (g_iActiveBossgameId == 8 && g_bIsMinigameActive && !g_bIsMinigameEnding) 
	{
		switch (g_iBossgame8Timer)
		{
			case 5: 
			{
				Bossgame8_SendDoorInput("Close");
			}
				
			case 4: 
			{
				Bossgame8_CleanupEntities();
				Bossgame8_DoEntitySpawns();
			}

			case 3: 
			{
				Bossgame8_SendDoorInput("Open");
			}

			case 0:
			{
				g_iBossgame8Timer = 6;
			}
		}

		g_iBossgame8Timer--;
		return Plugin_Continue;
	}

	g_iBossgame8Timer = 6;
	return Plugin_Stop; 
}

public void Bossgame8_DoEntitySpawns()
{
	float positions[BOSSGAME8_ENTITYSPAWN_COUNT][3];
	int barrelCount = 0;
	int minimumBarrelCount = GetRandomInt(1, 3) == 2 && g_iBossgame8ParticipatingPlayerCount < BOSSGAME8_ENTITYSPAWN_COUNT
		? g_iBossgame8ParticipatingPlayerCount
		: g_iBossgame8ParticipatingPlayerCount / 2;

	if (minimumBarrelCount < 1)
	{
		minimumBarrelCount = 1;
	}

	int count = GetRandomInt(minimumBarrelCount, BOSSGAME8_ENTITYSPAWN_COUNT);

	for (int i = 0; i < count; i++)
	{
		bool validPosition = false;
		float position[3];
		float angle[3];
		int calculationAttempts = 0;

		while (!validPosition)
		{
			validPosition = true;
			calculationAttempts++;

			if (calculationAttempts > 32)
			{
				return;
			}

			int posa = 360 / BOSSGAME8_ENTITYSPAWN_COUNT * GetRandomInt(1, 32);
			float outer = GetRandomFloat(64.0, 512.0);

			position[0] = -2943.0 + (Cosine(DegToRad(float(posa))) * outer);
			position[1] = 1791.0 - (Sine(DegToRad(float(posa))) * outer);
			position[2] = -1381.0;

			angle[0] = 0.0;
			angle[1] = float(180 - posa);
			angle[2] = 0.0;

			for (int j = 0; j < BOSSGAME8_ENTITYSPAWN_COUNT; j++)
			{
				if (j == i)
				{
					continue;
				}

				float distance = GetVectorDistance(position, positions[j]);

				if (distance <= 100.0)
				{
					validPosition = false;
				}
			}
		}

		int entity = CreateEntityByName("prop_physics_override");

		if (IsValidEdict(entity))
		{
			char buffer[64];
			
			if (barrelCount < minimumBarrelCount)
			{
				strcopy(buffer, sizeof(buffer), "models/props_farm/wooden_barrel.mdl");
				barrelCount++;
			}
			else
			{
				strcopy(buffer, sizeof(buffer), g_sBossgame8EntityModels[GetRandomInt(0, sizeof(g_sBossgame8EntityModels)-1)]);
			}
			
			DispatchKeyValue(entity, "model", buffer);
			DispatchSpawn(entity);

			TeleportEntity(entity, position, angle, NULL_VECTOR);

			positions[i] = position;
		}

		g_iBossgame8Entities[i] = entity;
	}
}

public void Bossgame8_CleanupEntities()
{
	for (int i = 0; i < BOSSGAME8_ENTITYSPAWN_COUNT; i++)
	{
		int entity = g_iBossgame8Entities[i];

		if (IsValidEdict(entity) && entity > MaxClients)
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
}

public void Bossgame8_SendDoorInput(const char[] input)
{
	int entity = -1;
	char entityName[32];

	while ((entity = FindEntityByClassname(entity, "func_door")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_TPBoss_Door") == 0)
		{
			AcceptEntityInput(entity, input, -1, -1, -1);
		}
	}
}