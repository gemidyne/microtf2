/**
 * MicroTF2 - Bossgame 8
 * 
 * Count the Props (unfinished)
 */

#define BOSSGAME8_ENTITYSPAWN_COUNT 10
#define BOSSGAME8_ENTITYSPAWN_GROUPCOUNT 4

#define BOSSGAME8_VO_10SEC "vo/announcer_ends_10sec.mp3"
#define BOSSGAME8_VO_5SEC "vo/announcer_ends_5sec.mp3"
#define BOSSGAME8_VO_4SEC "vo/announcer_ends_4sec.mp3"
#define BOSSGAME8_VO_3SEC "vo/announcer_ends_3sec.mp3"
#define BOSSGAME8_VO_2SEC "vo/announcer_ends_2sec.mp3"
#define BOSSGAME8_VO_1SEC "vo/announcer_ends_1sec.mp3"

int g_iBossgame8ParticipatingPlayerCount;
int g_iBossgame8Timer = 13;

char g_sBossgame8Group1Models[][] = 
{
	"models/buildables/dispenser_light.mdl",
	"models/buildables/dispenser_lvl2_light.mdl",
	"models/buildables/dispenser_lvl3_light.mdl"
};

char g_sBossgame8Group2Models[][] = 
{
	"models/items/ammopack_large.mdl",
	"models/items/ammopack_large_bday.mdl",
	"models/items/ammopack_medium.mdl",
	"models/items/ammopack_medium_bday.mdl"
};

char g_sBossgame8Group3Models[][] = 
{
	"models/props_badlands/barrel01.mdl",
	"models/props_badlands/barrel02.mdl",
	"models/props_badlands/barrel03.mdl",
};

char g_sBossgame8Group4Models[][] = 
{
	"models/props_manor/chair_01.mdl",
	"models/props_spytech/chair.mdl",
	"models/props_spytech/terminal_chair.mdl"
};

int g_iBossgame8Entities[BOSSGAME8_ENTITYSPAWN_COUNT];
int g_iBossgame8EntityCount[BOSSGAME8_ENTITYSPAWN_GROUPCOUNT];
int g_iBossgame8CorrectRoomNumber = 0;
int g_iBossgame8CorrectAnswer = -999999;
int g_iBossgame8CorrectAnswerGroupType;
int g_iBossgame8RoomAnswers[3];

public void Bossgame8_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame8_OnMapStart);
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame8_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame8_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame8_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Bossgame8_OnMinigameFinish);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame8_OnBossStopAttempt);
}

public void Bossgame8_OnMapStart()
{
	for (int i = 0; i < sizeof(g_sBossgame8Group1Models); i++)
	{
		PrecacheModel(g_sBossgame8Group1Models[i]);
	}

	for (int i = 0; i < sizeof(g_sBossgame8Group2Models); i++)
	{
		PrecacheModel(g_sBossgame8Group2Models[i]);
	}
	
	for (int i = 0; i < sizeof(g_sBossgame8Group3Models); i++)
	{
		PrecacheModel(g_sBossgame8Group3Models[i]);
	}
		
	for (int i = 0; i < sizeof(g_sBossgame8Group4Models); i++)
	{
		PrecacheModel(g_sBossgame8Group4Models[i]);
	}

	PrecacheSound(BOSSGAME8_VO_10SEC, true);
	PrecacheSound(BOSSGAME8_VO_5SEC, true);
	PrecacheSound(BOSSGAME8_VO_4SEC, true);
	PrecacheSound(BOSSGAME8_VO_3SEC, true);
	PrecacheSound(BOSSGAME8_VO_2SEC, true);
	PrecacheSound(BOSSGAME8_VO_1SEC, true);
}

public void Bossgame8_OnTfRoundStart()
{
	Bossgame8_ResetAllState();
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

		Bossgame8_ResetAllState();

		g_iBossgame8Timer = 13;
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
	player.SetGodMode(false);
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

public void Bossgame8_OnBossStopAttempt()
{
	if (g_iActiveBossgameId != 8)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	int alivePlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.IsAlive)
		{
			alivePlayers++;
		}
	}

	if (alivePlayers <= 1)
	{
		EndBoss();
	}
}

public void Bossgame8_OnMinigameFinish()
{
	if (g_iActiveBossgameId == 8 && g_bIsMinigameActive) 
	{
		Bossgame8_CleanupEntities();
		Bossgame8_DecisionRoom_SetOutsideHurtActive(false);
		Bossgame8_DecisionRoom_SetHurtActive(1, false);
		Bossgame8_DecisionRoom_SetHurtActive(2, false);
		Bossgame8_DecisionRoom_SetHurtActive(3, false);
		Bossgame8_DecisionRoom_SetDoorOpen(1, true);
		Bossgame8_DecisionRoom_SetDoorOpen(2, true);
		Bossgame8_DecisionRoom_SetDoorOpen(3, true);
		Bossgame8_SendHatchDoorOpen(false);

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
			case 12: 
			{
				Bossgame8_SendHatchDoorOpen(false);
			}
				
			case 11: 
			{
				Bossgame8_CleanupEntities();
				Bossgame8_DoEntitySpawns();
			}

			case 10: 
			{
				Bossgame8_SendHatchDoorOpen(true);
			}

			case 5:
			{
				Bossgame8_DecisionRoom_SetOutsideHurtActive(false);
				Bossgame8_DecisionRoom_SetHurtActive(1, false);
				Bossgame8_DecisionRoom_SetHurtActive(2, false);
				Bossgame8_DecisionRoom_SetHurtActive(3, false);
				Bossgame8_DecisionRoom_SetDoorOpen(1, true);
				Bossgame8_DecisionRoom_SetDoorOpen(2, true);
				Bossgame8_DecisionRoom_SetDoorOpen(3, true);
				Bossgame8_SendHatchDoorOpen(false);
				Bossgame8_GenerateQuestionnaire();
			}

			case 0:
			{
				Bossgame8_DecisionRoom_SetDoorOpen(1, false);
				Bossgame8_DecisionRoom_SetDoorOpen(2, false);
				Bossgame8_DecisionRoom_SetDoorOpen(3, false);
			}

			case -3:
			{
				Bossgame8_DecisionRoom_SetOutsideHurtActive(true);
				Bossgame8_DecisionRoom_SetHurtActive(1, g_iBossgame8CorrectRoomNumber != 1);
				Bossgame8_DecisionRoom_SetHurtActive(2, g_iBossgame8CorrectRoomNumber != 2);
				Bossgame8_DecisionRoom_SetHurtActive(3, g_iBossgame8CorrectRoomNumber != 3);
			}

			case -5:
			{
				Bossgame8_DecisionRoom_SetOutsideHurtActive(false);
				Bossgame8_DecisionRoom_SetHurtActive(1, false);
				Bossgame8_DecisionRoom_SetHurtActive(2, false);
				Bossgame8_DecisionRoom_SetHurtActive(3, false);
				Bossgame8_DecisionRoom_SetDoorOpen(1, true);
				Bossgame8_DecisionRoom_SetDoorOpen(2, true);
				Bossgame8_DecisionRoom_SetDoorOpen(3, true);

				g_iBossgame8Timer = 13;
			}
		}

		switch (g_iBossgame8Timer)
		{
			case 10:
				EmitSoundToAll(BOSSGAME7_VO_10SEC);

			case 5:
				EmitSoundToAll(BOSSGAME7_VO_5SEC);

			case 4:
				EmitSoundToAll(BOSSGAME7_VO_4SEC);

			case 3:
				EmitSoundToAll(BOSSGAME7_VO_3SEC);

			case 2:
				EmitSoundToAll(BOSSGAME7_VO_2SEC);

			case 1:
				EmitSoundToAll(BOSSGAME7_VO_1SEC);
		}

		g_iBossgame8Timer--;
		return Plugin_Continue;
	}

	g_iBossgame8Timer = 13;
	return Plugin_Stop; 
}

void Bossgame8_DoEntitySpawns()
{
	float positions[BOSSGAME8_ENTITYSPAWN_COUNT][3];

	int count = GetRandomInt(1, BOSSGAME8_ENTITYSPAWN_COUNT);

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
			int groupType = GetRandomInt(1, 4);

			g_iBossgame8EntityCount[groupType-1]++;

			char buffer[64];

			switch (groupType)
			{
				case 1:
				{
					strcopy(buffer, sizeof(buffer), g_sBossgame8Group1Models[GetRandomInt(0, sizeof(g_sBossgame8Group1Models)-1)]);
				}

				case 2:
				{
					strcopy(buffer, sizeof(buffer), g_sBossgame8Group2Models[GetRandomInt(0, sizeof(g_sBossgame8Group2Models)-1)]);
				}

				case 3:
				{
					strcopy(buffer, sizeof(buffer), g_sBossgame8Group3Models[GetRandomInt(0, sizeof(g_sBossgame8Group3Models)-1)]);
				}

				case 4:
				{
					strcopy(buffer, sizeof(buffer), g_sBossgame8Group4Models[GetRandomInt(0, sizeof(g_sBossgame8Group4Models)-1)]);
				}
			}

			DispatchKeyValue(entity, "model", buffer);
			DispatchSpawn(entity);

			TeleportEntity(entity, position, angle, NULL_VECTOR);

			positions[i] = position;
		}

		g_iBossgame8Entities[i] = entity;
	}
}

void Bossgame8_CleanupEntities()
{
	for (int i = 0; i < BOSSGAME8_ENTITYSPAWN_GROUPCOUNT; i++)
	{
		g_iBossgame8EntityCount[i] = 0;
	}

	for (int i = 0; i < BOSSGAME8_ENTITYSPAWN_COUNT; i++)
	{
		int entity = g_iBossgame8Entities[i];

		if (IsValidEdict(entity) && entity > MaxClients)
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
}

void Bossgame8_SendHatchDoorOpen(bool state)
{
	int entity = -1;
	char entityName[32];

	while ((entity = FindEntityByClassname(entity, "func_door")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_TPBoss_Door") == 0)
		{
			AcceptEntityInput(entity, state ? "Open" : "Close", -1, -1, -1);
		}
	}
}

void Bossgame8_DecisionRoom_SetDoorOpen(int roomNumber, bool open)
{
	int entity = -1;
	char entityName[32];

	char expectedEntityName[32];
	Format(expectedEntityName, sizeof(expectedEntityName), "plugin_PCBoss_Door%i", roomNumber);

	while ((entity = FindEntityByClassname(entity, "func_door")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, expectedEntityName) == 0)
		{
			AcceptEntityInput(entity, open ? "Open" : "Close", -1, -1, -1);
		}
	}
}

void Bossgame8_DecisionRoom_SetHurtActive(int roomNumber, bool active)
{
	int entity = -1;
	char entityName[32];

	char expectedEntityName[32];
	Format(expectedEntityName, sizeof(expectedEntityName), "plugin_PCBoss_Hurt%i", roomNumber);

	while ((entity = FindEntityByClassname(entity, "trigger_hurt")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, expectedEntityName) == 0)
		{
			AcceptEntityInput(entity, active ? "Enable" : "Disable", -1, -1, -1);
		}
	}
}

void Bossgame8_DecisionRoom_SetOutsideHurtActive(bool active)
{
	int entity = -1;
	char entityName[32];

	char expectedEntityName[32];
	Format(expectedEntityName, sizeof(expectedEntityName), "plugin_PCBoss_HurtOutside");

	while ((entity = FindEntityByClassname(entity, "trigger_hurt")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, expectedEntityName) == 0)
		{
			AcceptEntityInput(entity, active ? "Enable" : "Disable", -1, -1, -1);
		}
	}
}

void Bossgame8_ResetAllState()
{
	Bossgame8_CleanupEntities();
	Bossgame8_DecisionRoom_SetOutsideHurtActive(false);
	Bossgame8_DecisionRoom_SetHurtActive(1, false);
	Bossgame8_DecisionRoom_SetHurtActive(2, false);
	Bossgame8_DecisionRoom_SetHurtActive(3, false);
	Bossgame8_DecisionRoom_SetDoorOpen(1, true);
	Bossgame8_DecisionRoom_SetDoorOpen(2, true);
	Bossgame8_DecisionRoom_SetDoorOpen(3, true);
	Bossgame8_SendHatchDoorOpen(false);
}

void Bossgame8_GenerateQuestionnaire()
{
	g_iBossgame8CorrectAnswerGroupType = GetRandomInt(1, 4);
	g_iBossgame8CorrectAnswer = g_iBossgame8EntityCount[g_iBossgame8CorrectAnswerGroupType-1];

	// L: 1, M: 2, R: 3
	g_iBossgame8CorrectRoomNumber = GetRandomInt(1, 3);

	for (int i = 1; i <= 3; i++)
	{
		if (i == g_iBossgame8CorrectRoomNumber)
		{
			g_iBossgame8RoomAnswers[i-1] = g_iBossgame8CorrectAnswer;
		}
		else
		{
			g_iBossgame8RoomAnswers[i-1] = GetRandomInt(1, 2) == 2 
				? g_iBossgame8CorrectAnswer - GetRandomInt(1, 4)
				: g_iBossgame8CorrectAnswer + GetRandomInt(1, 4);
		}
	}

	Bossgame8_ShowHudQuestionnaire();
	// TODO: Spawn annotations at a point in each room.
	//float roomAHintPosition[3] = { -1824.0, 2392.0, -1096.0 };
	//float roomBHintPosition[3] = { -1824.0, 1856.0, -1096.0 };
	//float roomBHintPosition[3] = { -1824.0, 1312.0, -1096.0 };
}

void Bossgame8_ShowHudQuestionnaire()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			char typeOfProp[64];

			switch (g_iBossgame8CorrectAnswerGroupType)
			{
				case 1: 
					Format(typeOfProp, sizeof(typeOfProp), "%T", "Bossgame8_PropType_Dispensers", player.ClientId);

				case 2: 
					Format(typeOfProp, sizeof(typeOfProp), "%T", "Bossgame8_PropType_AmmoPacks", player.ClientId);

				case 3: 
					Format(typeOfProp, sizeof(typeOfProp), "%T", "Bossgame8_PropType_Barrels", player.ClientId);

				case 4: 
					Format(typeOfProp, sizeof(typeOfProp), "%T", "Bossgame8_PropType_Chairs", player.ClientId);
			}

			char text[128];
			Format(text, sizeof(text), "%T", "Bossgame8_Caption_ChooseARoom", player.ClientId, typeOfProp, g_iBossgame8RoomAnswers[0], g_iBossgame8RoomAnswers[1], g_iBossgame8RoomAnswers[2], g_iBossgame8Timer);
			player.SetCaption(text);
		}
	}
}