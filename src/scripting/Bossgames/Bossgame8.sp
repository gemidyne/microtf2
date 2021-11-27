/**
 * MicroTF2 - Bossgame 8
 * 
 * Inventory Day
 */

#define BOSSGAME8_ENTITYSPAWN_COUNT 16
#define BOSSGAME8_ENTITYSPAWN_GROUPCOUNT 4

#define BOSSGAME8_TIMER_VIEWING_TIME_MAX 5.0
#define BOSSGAME8_TIMER_VIEWING_TIME_MIN 1.5
#define BOSSGAME8_TIMER_VIEWING_TIME_DECAY 0.7

#define BOSSGAME8_TIMER_VIEWING_RESET -7

#define BOSSGAME8_VO_10SEC "vo/announcer_ends_10sec.mp3"
#define BOSSGAME8_VO_5SEC "vo/announcer_ends_5sec.mp3"
#define BOSSGAME8_VO_4SEC "vo/announcer_ends_4sec.mp3"
#define BOSSGAME8_VO_3SEC "vo/announcer_ends_3sec.mp3"
#define BOSSGAME8_VO_2SEC "vo/announcer_ends_2sec.mp3"
#define BOSSGAME8_VO_1SEC "vo/announcer_ends_1sec.mp3"
#define BOSSGAME8_SFX_QUESTION_PROMPT "ui/trade_ready.wav"
#define BOSSGAME8_SFX_ANSWER_ANTICIPATION "ui/vote_started.wav"
#define BOSSGAME8_SFX_ANSWER_REVEAL "ui/trade_success.wav"

// Feature: use outlines on the props
#define BOSSGAME8_USE_OUTLINES

enum EBossgame8_Phases
{
	EBossgame8_Phase_Waiting = 0,
	EBossgame8_Phase_WaitingOnAnswer,
	EBossgame8_Phase_AnswerRevealed,
	EBossgame8_Phase_Viewing,
	EBossgame8_Phase_ViewingRoomsOpen,
}

int g_iBossgame8ParticipatingPlayerCount;
int g_iBossgame8Timer = 10;
EBossgame8_Phases g_eBossgame8CurrentPhase = EBossgame8_Phase_Waiting;

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

#if defined BOSSGAME8_USE_OUTLINES
int g_iBossgame8Group1OutlineColour[] = { 0, 255, 255, 255 };
int g_iBossgame8Group2OutlineColour[] = { 255, 0, 255, 255 };
int g_iBossgame8Group3OutlineColour[] = { 255, 255, 0, 255 };
int g_iBossgame8Group4OutlineColour[] = { 255, 0, 0, 255 };
#endif

int g_iBossgame8Entities[BOSSGAME8_ENTITYSPAWN_COUNT];
int g_iBossgame8EntityCount[BOSSGAME8_ENTITYSPAWN_GROUPCOUNT];
int g_iBossgame8CorrectRoomNumber = 0;
int g_iBossgame8CorrectAnswer = -999999;
int g_iBossgame8CorrectAnswerGroupType;
int g_iBossgame8RoomAnswers[3];
float g_fBossgame8ViewingTime = BOSSGAME8_TIMER_VIEWING_TIME_MAX;

public void Bossgame8_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame8_OnMapStart);
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame8_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame8_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame8_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Bossgame8_OnMinigameFinish);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame8_OnBossStopAttempt);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Bossgame8_OnPlayerDeath);
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

	PreloadSound(BOSSGAME8_VO_10SEC);
	PreloadSound(BOSSGAME8_VO_5SEC);
	PreloadSound(BOSSGAME8_VO_4SEC);
	PreloadSound(BOSSGAME8_VO_3SEC);
	PreloadSound(BOSSGAME8_VO_2SEC);
	PreloadSound(BOSSGAME8_VO_1SEC);
	PreloadSound(BOSSGAME8_SFX_QUESTION_PROMPT);
	PreloadSound(BOSSGAME8_SFX_ANSWER_ANTICIPATION);
	PreloadSound(BOSSGAME8_SFX_ANSWER_REVEAL);
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
		g_eBossgame8CurrentPhase = EBossgame8_Phase_Waiting;

		g_fBossgame8ViewingTime = BOSSGAME8_TIMER_VIEWING_TIME_MAX;
		CreateTimer(1.0, Bossgame8_PrepareForViewing, _, TIMER_FLAG_NO_MAPCHANGE);
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
	player.Class = TFClass_Scout;
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

public void Bossgame8_OnPlayerDeath(int client, int attacker)
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

	player.Status = PlayerStatus_Failed;
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

	if (g_eBossgame8CurrentPhase != EBossgame8_Phase_AnswerRevealed)
	{
		// Only allow the boss to end early when the answer is revealed.
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
		Bossgame8_CleanupEntities(true);
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

			if (player.IsValid && player.IsParticipating && player.Status == PlayerStatus_NotWon)
			{
				player.Status = PlayerStatus_Winner;
			}
		}
	}
}

public Action Bossgame8_BeginViewing(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Handled;
	}

	Bossgame8_DecisionRoom_SetOutsideHurtActive(false);

	for (int i = 1; i <= 3; i++)
	{
		Bossgame8_DecisionRoom_SetHurtActive(i, false);
		Bossgame8_DecisionRoom_SetDoorOpen(i, true);
	}

	Bossgame8_SendHatchDoorOpen(true);

	g_eBossgame8CurrentPhase = EBossgame8_Phase_Viewing;
	Bossgame8_ShowHudQuestionnaire();

	CreateTimer(g_fBossgame8ViewingTime, Bossgame8_EndViewingOpenAnswerRooms, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public Action Bossgame8_EndViewingOpenAnswerRooms(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Handled;
	}

	g_fBossgame8ViewingTime -= BOSSGAME8_TIMER_VIEWING_TIME_DECAY;

	if (g_fBossgame8ViewingTime < BOSSGAME8_TIMER_VIEWING_TIME_MIN)
	{
		g_fBossgame8ViewingTime = BOSSGAME8_TIMER_VIEWING_TIME_MIN;
	}

	PlaySoundToAll(BOSSGAME8_SFX_QUESTION_PROMPT);
	Bossgame8_SendHatchDoorOpen(false);

	g_eBossgame8CurrentPhase = EBossgame8_Phase_ViewingRoomsOpen;
	Bossgame8_GenerateQuestionnaire();
	Bossgame8_CleanupEntities(false);

	CreateTimer(11.0, Bossgame8_CloseAnswerRooms, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Bossgame8_ViewingTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public Action Bossgame8_CloseAnswerRooms(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Handled;
	}

	for (int i = 1; i <= 3; i++)
	{
		Bossgame8_DecisionRoom_SetDoorOpen(i, false);
	}

	Bossgame8_SendHatchDoorOpen(false);
	PlaySoundToAll(BOSSGAME8_SFX_ANSWER_ANTICIPATION);
	g_eBossgame8CurrentPhase = EBossgame8_Phase_Waiting;

	CreateTimer(2.0, Bossgame8_PrepareAnswer, _, TIMER_FLAG_NO_MAPCHANGE);
	Bossgame8_ShowHudQuestionnaire();

	return Plugin_Handled;
}

public Action Bossgame8_PrepareAnswer(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Handled;
	}

	Bossgame8_CleanupEntities(true);
	Bossgame8_DecisionRoom_SetOutsideHurtActive(true);
	g_eBossgame8CurrentPhase = EBossgame8_Phase_WaitingOnAnswer;

	CreateTimer(3.0, Bossgame8_RevealAnswer, _, TIMER_FLAG_NO_MAPCHANGE);
	Bossgame8_ShowHudQuestionnaire();

	return Plugin_Handled;
}

public Action Bossgame8_RevealAnswer(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Handled;
	}

	PlaySoundToAll(BOSSGAME8_SFX_ANSWER_REVEAL);

	for (int i = 1; i <= 3; i++)
	{
		Bossgame8_DecisionRoom_SetHurtActive(i, g_iBossgame8CorrectRoomNumber != i);
	}

	g_eBossgame8CurrentPhase = EBossgame8_Phase_AnswerRevealed;
	
	CreateTimer(3.0, Bossgame8_PrepareForViewing, _, TIMER_FLAG_NO_MAPCHANGE);
	Bossgame8_ShowHudQuestionnaire();

	return Plugin_Handled;
}

public Action Bossgame8_PrepareForViewing(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Handled;
	}

	Bossgame8_DoEntitySpawns();

	g_iBossgame8Timer = 10;
	g_eBossgame8CurrentPhase = EBossgame8_Phase_Waiting;

	Bossgame8_ShowHudQuestionnaire();

	CreateTimer(1.0, Bossgame8_BeginViewing, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

public Action Bossgame8_ViewingTimer(Handle timer)
{
	if (g_iActiveBossgameId != 8)
	{
		return Plugin_Stop;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Stop;
	}
	
	if (g_bIsMinigameEnding)
	{
		return Plugin_Stop;
	}

	if (g_iBossgame8Timer >= 0)
	{
		switch (g_iBossgame8Timer)
		{
			case 10:
				PlaySoundToAll(BOSSGAME7_VO_10SEC);

			case 5:
				PlaySoundToAll(BOSSGAME7_VO_5SEC);

			case 4:
				PlaySoundToAll(BOSSGAME7_VO_4SEC);

			case 3:
				PlaySoundToAll(BOSSGAME7_VO_3SEC);

			case 2:
				PlaySoundToAll(BOSSGAME7_VO_2SEC);

			case 1:
				PlaySoundToAll(BOSSGAME7_VO_1SEC);
		}

		Bossgame8_ShowHudQuestionnaire();
		g_iBossgame8Timer--;

		return Plugin_Continue;
	}

	return Plugin_Stop;
}

void Bossgame8_DoEntitySpawns()
{
	float positions[BOSSGAME8_ENTITYSPAWN_COUNT][3];

	int count = GetRandomInt(BOSSGAME8_ENTITYSPAWN_COUNT / 2, BOSSGAME8_ENTITYSPAWN_COUNT);

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
			
			#if defined BOSSGAME8_USE_OUTLINES
			int outlineColour[4];

			switch (groupType)
			{
				case 1:
				{
					outlineColour = g_iBossgame8Group1OutlineColour;
				}

				case 2:
				{
					outlineColour = g_iBossgame8Group2OutlineColour;
				}

				case 3:
				{
					outlineColour = g_iBossgame8Group3OutlineColour;
				}

				case 4:
				{
					outlineColour = g_iBossgame8Group4OutlineColour;
				}
			}

			CreateGlow(entity, outlineColour, 5.0);
			#endif

			positions[i] = position;
		}

		g_iBossgame8Entities[i] = entity;
	}
}

void Bossgame8_CleanupEntities(bool resetCounts)
{
	if (resetCounts)
	{
		for (int i = 0; i < BOSSGAME8_ENTITYSPAWN_GROUPCOUNT; i++)
		{
			g_iBossgame8EntityCount[i] = 0;
		}
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
	Bossgame8_CleanupEntities(true);
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
			int possibility;
			
			do 
			{
				possibility = GetRandomInt(g_iBossgame8CorrectAnswer - GetRandomInt(1, 5), g_iBossgame8CorrectAnswer + GetRandomInt(1, 5));
			}
			while (possibility == g_iBossgame8CorrectAnswer || possibility < 0 || Bossgame8_PossibilityHasConflict(i, possibility));
			
			g_iBossgame8RoomAnswers[i-1] = possibility;
		}
	}

	Bossgame8_ShowHudQuestionnaire();
	float roomAHintPosition[3] = { -1824.0, 2392.0, -1096.0 };
	float roomBHintPosition[3] = { -1824.0, 1856.0, -1096.0 };
	float roomCHintPosition[3] = { -1824.0, 1312.0, -1096.0 };

	Bossgame8_ShowAnswerRoomAnnotation(roomAHintPosition, "Bossgame8_Annotation_AnswerRoomA", g_iBossgame8RoomAnswers[0]);
	Bossgame8_ShowAnswerRoomAnnotation(roomBHintPosition, "Bossgame8_Annotation_AnswerRoomB", g_iBossgame8RoomAnswers[1]);
	Bossgame8_ShowAnswerRoomAnnotation(roomCHintPosition, "Bossgame8_Annotation_AnswerRoomC", g_iBossgame8RoomAnswers[2]);
}

void Bossgame8_ShowHudQuestionnaire()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			if (g_eBossgame8CurrentPhase == EBossgame8_Phase_Waiting)
			{
				char text[128];
				Format(text, sizeof(text), "%T", "Bossgame8_Caption_GetReady", player.ClientId);
				player.SetCaption(text);
				continue;
			}

			if (g_eBossgame8CurrentPhase == EBossgame8_Phase_Viewing)
			{
				char text[256];
				Format(text, sizeof(text), "%T", "Bossgame8_Caption_CountTheProps", player.ClientId);
				player.SetCaption(text);
				continue;
			}

			if (g_eBossgame8CurrentPhase == EBossgame8_Phase_ViewingRoomsOpen)
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
				continue;
			}
			
			if (g_eBossgame8CurrentPhase == EBossgame8_Phase_WaitingOnAnswer)
			{
				char text[128];
				Format(text, sizeof(text), "%T", "Bossgame8_Caption_CorrectAnswerWas_Hidden", player.ClientId);
				player.SetCaption(text);
				continue;
			}

			if (g_eBossgame8CurrentPhase == EBossgame8_Phase_AnswerRevealed)
			{
				char text[128];
				Format(text, sizeof(text), "%T", "Bossgame8_Caption_CorrectAnswerWas_Visible", player.ClientId, g_iBossgame8CorrectAnswer);
				player.SetCaption(text);
			}
		}
	}
}

void Bossgame8_ShowAnswerRoomAnnotation(float position[3], const char[] translationKey, int answer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			char formatted[32];
			Format(formatted, sizeof(formatted), "%T", translationKey, player.ClientId, answer);
			ShowPositionalAnnotation(player.ClientId, position, 14.0, formatted, true);
		}
	}
}

bool Bossgame8_PossibilityHasConflict(int roomIndex, int possibility)
{
	for (int i = 1; i <= 3; i++)
	{
		if (i == roomIndex)
		{
			// Ignore current room
			continue;
		}
		else if (g_iBossgame8RoomAnswers[i-1] == possibility)
		{
			return true;
		}
	}

	return false;
}