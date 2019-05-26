/**
 * MicroTF2 - Bossgame 7
 * 
 * Say the Words
 */

#define BOSSGAME7_SAYTEXTANSWERS_CAPACITY 128

char Bossgame7_SayTextAnswers[BOSSGAME7_SAYTEXTANSWERS_CAPACITY][64];
int Bossgame7_SayTextAnswerCount;

char Bossgame7_ActiveAnswerSet[BOSSGAME7_SAYTEXTANSWERS_CAPACITY][64];
int Bossgame7_ActiveAnswerCount;

int Bossgame7_ParticipatingPlayerCount;
int Bossgame7_PlayerActiveAnswerIndex[MAXPLAYERS+1] = 0;
int Bossgame7_PlayerActiveAnswerCount[MAXPLAYERS+1];
int Bossgame7_RemainingTime = 20;

public void Bossgame7_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Bossgame7_OnMapStart);
	AddToForward(GlobalForward_OnMapEnd, INVALID_HANDLE, Bossgame7_OnMapEnd);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame7_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame7_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame7_OnMinigameFinish);

	RegConsoleCmd("say", Bossgame7_SayCommand);
	RegConsoleCmd("say_team", Bossgame7_SayCommand);

	Bossgame7_LoadDictionary();
}

public void Bossgame7_OnMapStart()
{
	PrecacheSound("gemidyne/warioware/bosses/bgm/danganronpa_hvd.mp3", true);
}

public void Bossgame7_OnMapEnd()
{
}

public bool Bossgame7_LoadDictionary()
{
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/Bossgame7.Dictionary.txt");

	Handle file = OpenFile(manifestPath, "r"); 

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open Bossgame7.Dictionary.txt in data/microtf2. This minigame has been disabled.");
		return false;
	}

	char line[64];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (Bossgame7_SayTextAnswerCount >= BOSSGAME7_SAYTEXTANSWERS_CAPACITY)
		{
			LogError("Hit the hardcoded limit of answers for Bossgame7. If you really want to add more, recompile the plugin with the limit changed.");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		Bossgame7_SayTextAnswers[Bossgame7_SayTextAnswerCount] = line;
		Bossgame7_SayTextAnswerCount++;
	}

	CloseHandle(file);

	LogMessage("Bossgame7: Loaded %i items from dictionary", Bossgame7_SayTextAnswerCount);

	return true;
}

public void Bossgame7_OnMinigameSelectedPre()
{
	if (BossgameID == 7)
	{
		IsBlockingDamage = true;
		IsOnlyBlockingDamageByPlayers = true;
		IsBlockingDeathCommands = true;

		Bossgame7_ParticipatingPlayerCount = 0;
		Bossgame7_ActiveAnswerCount = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				Bossgame7_ParticipatingPlayerCount++;
			}
		}

		CreateTimer(3.5, Bossgame7_DoDescentSequence);
	}
}

public void Bossgame7_OnMinigameSelected(int client)
{
	if (BossgameID != 7)
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

	player.SetGodMode(true);

	float vel[3] = { 0.0, 0.0, 0.0 };
	int posa = 360 / Bossgame7_ParticipatingPlayerCount * client;
	float pos[3];
	float ang[3];

	pos[0] = 7192.0 + (Cosine(DegToRad(float(posa)))*355.0);
	pos[1] = 2648.0 - (Sine(DegToRad(float(posa)))*355.0);
	pos[2] = -232.0;

	ang[0] = 0.0;
	ang[1] = float(180-posa);
	ang[2] = 0.0;

	TeleportEntity(client, pos, ang, vel);
	SetEntityMoveType(client, MOVETYPE_NONE);
}

public Action Bossgame7_SayCommand(int client, int args)
{
	if (IsMinigameActive && BossgameID == 7)
	{
		char text[192];
		if (GetCmdArgString(text, sizeof(text)) < 1)
		{
			return Plugin_Continue;
		}

		Player player = new Player(client);

		if (player.IsParticipating)
		{
			int startidx;
			if (text[strlen(text)-1] == '"') 
			{
				text[strlen(text)-1] = '\0';
			}

			startidx = 1;
			char message[192];
			BreakString(text[startidx], message, sizeof(message));

			if (strcmp(message, Bossgame7_ActiveAnswerSet[Bossgame7_PlayerActiveAnswerIndex[client]], false) == 0)
			{
				Bossgame7_PlayerActiveAnswerIndex[client]++;
				PrintAnswerDisplay(player);

				char sfx[128];
				Format(sfx, sizeof(sfx), "play %s", SYSFX_WINNER);
				ClientCommand(client, sfx);

				Bossgame7_PlayerActiveAnswerCount[client]++;

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void Bossgame7_OnMinigameFinish()
{
	if (BossgameID == 7 && IsMinigameActive) 
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame)
			{
				SetClientViewEntity(i, i);
			}

			if (player.IsValid && player.IsParticipating)
			{
				// TODO win logic
			}
		}
	}
}

public Action Bossgame7_DoDescentSequence(Handle timer)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	int camera = GetCameraEntity("DRBoss_DescentCamera_Point");

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			MinigameCaption[player.ClientId] = "";
			SetClientViewEntity(i, camera);
			ClientCommand(i, "play gemidyne/warioware/bosses/bgm/danganronpa_hvd.mp3");
		}
	}

	TriggerRelay("DRBoss_DescentSequence_Start");
	CreateTimer(3.5, Bossgame7_DoSpinSequence);

	return Plugin_Handled;
}

public Action Bossgame7_DoSpinSequence(Handle timer)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	int camera = GetCameraEntity("DRBoss_SpiralCamera_Point");

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			SetClientViewEntity(i, camera);

			char text[128];
			Format(text, sizeof(text), "%T", "Bossgame7_Caption_Explain", i);

			player.PrintHintBox(text);
		}
	}

	TriggerRelay("DRBoss_SpinInCamera_Start");
	CreateTimer(5.0, Bossgame7_DoCloseupSequence);

	return Plugin_Handled;
}

public Action Bossgame7_DoCloseupSequence(Handle timer)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	int camera = GetCameraEntity("DRBoss_CloseupCamera_Point");

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			SetClientViewEntity(i, camera);

			char text[128];
			Format(text, sizeof(text), "%T", "Bossgame7_Caption_Start", i);

			player.PrintHintBox(text);
		}
	}

	TriggerRelay("DRBoss_CloseupCamera_Start");
	Bossgame7_DoTypingSequence();

	return Plugin_Handled;
}

public void Bossgame7_DoTypingSequence()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Bossgame7_PlayerActiveAnswerIndex[i] = 0;
		Bossgame7_PlayerActiveAnswerCount[i] = 0;
	}

	Bossgame7_ActiveAnswerCount = 0;
	Bossgame7_RemainingTime = 20;

	// TODO: The upperlength has to change depending on the situation of the boss
	for (int i = 0; i <= 64; i++)
	{
		int answerIdx = GetRandomInt(0, Bossgame7_SayTextAnswerCount);

		strcopy(Bossgame7_ActiveAnswerSet[Bossgame7_ActiveAnswerCount], 64, Bossgame7_SayTextAnswers[answerIdx]);

		Bossgame7_ActiveAnswerCount++;
	}

	CreateTimer(1.0, Bossgame7_DoTypingTick);
}

public Action Bossgame7_DoTypingTick(Handle timer)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
		{
			PrintAnswerDisplay(player);
		}
	}

	Bossgame7_RemainingTime--;

	if (Bossgame7_RemainingTime >= 0)
	{
		CreateTimer(1.0, Bossgame7_DoTypingTick);
	}
	else
	{
		CreateTimer(1.0, Bossgame7_DoReviewSequence);
	}

	return Plugin_Handled;
}

public Action Bossgame7_DoReviewSequence(Handle timer)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	TriggerRelay("DRBoss_OverviewSequence_Start");

	int camera = GetCameraEntity("DRBoss_DescentCamera_Point");

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			SetClientViewEntity(i, camera);
		}
	}

	// Get answer count range
	int minThreshold = 999;
	int maxThreshold = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
		{
			if (Bossgame7_PlayerActiveAnswerCount[i] < minThreshold)
			{
				minThreshold = Bossgame7_PlayerActiveAnswerCount[i];
			}

			if (Bossgame7_PlayerActiveAnswerCount[i] > maxThreshold)
			{
				maxThreshold = Bossgame7_PlayerActiveAnswerCount[i];
			}
		}
	}

	bool allWordsAnsweredByAll = minThreshold == maxThreshold;

	if (allWordsAnsweredByAll)
	{
		minThreshold = -999;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			char text[128];

			Format(text, sizeof(text), "ROUND REVIEW\n\n");
			Format(text, sizeof(text), "%sThe players with the lowest number of words typed were...\n", text);

			if (!allWordsAnsweredByAll)
			{
				int namesDisplayed = 0;

				for (int j = 1; j <= MaxClients; j++)
				{
					Player p = new Player(j);

					if (p.IsValid && p.IsParticipating && p.Status != PlayerStatus_Failed && Bossgame7_PlayerActiveAnswerCount[j] == minThreshold)
					{
						if (namesDisplayed < 6)
						{
							Format(text, sizeof(text), "%s%N\n", text, j);
						}
						
						namesDisplayed++;
					}
				}

				if (namesDisplayed >= 6)
				{
					Format(text, sizeof(text), "%sand %d more...", text, namesDisplayed-6);
				}
			}
			else
			{
				Format(text, sizeof(text), "%sOh! Everyone typed the same amount of words!", text);
			}

			MinigameCaption[player.ClientId] = text;
		}
	}

	CreateTimer(3.0, Bossgame7_DoReviewSequencePost, minThreshold);
	return Plugin_Handled;
}

public Action Bossgame7_DoReviewSequencePost(Handle timer, any data)
{
	int activePlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
		{
			if (Bossgame7_PlayerActiveAnswerCount[i] == data)
			{
				player.Status = PlayerStatus_Failed;
				ForcePlayerSuicide(i);
			}
			else
			{
				activePlayers++;
				player.Status = PlayerStatus_Winner;
			}
		}
	}

	if (activePlayers > 1)
	{
		CreateTimer(2.0, Bossgame7_DoDescentSequence);
	}
	else
	{
		EndBoss();
	}

	return Plugin_Handled;
}

public void PrintAnswerDisplay(Player player)
{
	char text[128];

	int answerIdx = Bossgame7_PlayerActiveAnswerIndex[player.ClientId];

	if (answerIdx < Bossgame7_ActiveAnswerCount)
	{
		Format(text, sizeof(text), "Say the words!\n");
		Format(text, sizeof(text), "%s%s\n", text, Bossgame7_ActiveAnswerSet[answerIdx]);
		Format(text, sizeof(text), "\n%sTime remaining: %i seconds", text, Bossgame7_RemainingTime);
	}
	else
	{
		Format(text, sizeof(text), "Time remaining: %i seconds", Bossgame7_RemainingTime);
	}

	MinigameCaption[player.ClientId] = text;
}

public int GetCameraEntity(const char[] name)
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "info_observer_point")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, name) == 0)
		{
			return entity;
		}
	}

	return -1;
}

public void TriggerRelay(const char[] name)
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "logic_relay")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, name) == 0)
		{
			AcceptEntityInput(entity, "Trigger", -1, -1, -1);
			break;
		}
	}
}

public int GetEntityId(const char[] entityType, const char[] name)
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, entityType)) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, name) == 0)
		{
			return entity;
		}
	}

	return entity;
}