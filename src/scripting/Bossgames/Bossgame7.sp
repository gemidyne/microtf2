/**
 * MicroTF2 - Bossgame 7
 * 
 * Say the Words
 */

#define BOSSGAME7_SAYTEXTANSWERS_CAPACITY 512

char Bossgame7_BgmFiles[][] = 
{ 
	"gemidyne/warioware/bosses/bgm/danganronpa_hga.mp3",
	"gemidyne/warioware/bosses/bgm/danganronpa_hvd.mp3",
	"gemidyne/warioware/bosses/bgm/danganronpa_lod.mp3",
	"gemidyne/warioware/bosses/bgm/danganronpa_pta.mp3",
	"gemidyne/warioware/bosses/bgm/danganronpa_spc.mp3",
	"gemidyne/warioware/bosses/bgm/danganronpa_tuh.mp3",
};

#define BOSSGAME7_BGM_FINALOVERVIEW_GOOD "gemidyne/warioware/bosses/bgm/danganronpa_goodend.mp3"
#define BOSSGAME7_BGM_FINALOVERVIEW_BAD "gemidyne/warioware/bosses/bgm/danganronpa_badend.mp3"

#define BOSSGAME7_SFX_BOSS_START "gemidyne/warioware/bosses/sfx/drpa_bossstart.mp3"
#define BOSSGAME7_SFX_DESCENT_BEGIN "gemidyne/warioware/bosses/sfx/drpa_descentbegin.mp3"
#define BOSSGAME7_SFX_OVERVIEW "gemidyne/warioware/bosses/sfx/drpa_overviewstart.mp3"
#define BOSSGAME7_SFX_OVERVIEW_SURVIVE "gemidyne/warioware/bosses/sfx/drpa_overviewsurvive.mp3"
#define BOSSGAME7_SFX_OVERVIEW_DEFEAT "gemidyne/warioware/bosses/sfx/drpa_gameover.mp3"
#define BOSSGAME7_SFX_SPIRAL "gemidyne/warioware/bosses/sfx/drpa_spiralinward.mp3"
#define BOSSGAME7_SFX_TYPING_START "gemidyne/warioware/bosses/sfx/drpa_typingstart.mp3"

char Bossgame7_Sfx_WordFail[][] = 
{ 
	"gemidyne/warioware/bosses/sfx/drpa_wordfail_1.mp3",
	"gemidyne/warioware/bosses/sfx/drpa_wordfail_2.mp3",
};

#define BOSSGAME7_SFX_WORDSUCCESS_RELAX "gemidyne/warioware/bosses/sfx/drpa_wordsuccess_relax.mp3"

char Bossgame7_Sfx_WordSuccessPinch[][] = 
{ 
	"gemidyne/warioware/bosses/sfx/drpa_wordsuccess_pinch1.mp3",
	"gemidyne/warioware/bosses/sfx/drpa_wordsuccess_pinch2.mp3",
	"gemidyne/warioware/bosses/sfx/drpa_wordsuccess_pinch3.mp3",
	"gemidyne/warioware/bosses/sfx/drpa_wordsuccess_pinch4.mp3",
};

#define BOSSGAME7_SAYTEXTINDICE_EASY 0
#define BOSSGAME7_SAYTEXTINDICE_MEDIUM 1
#define BOSSGAME7_SAYTEXTINDICE_HARD 2
#define BOSSGAME7_SAYTEXTINDICE_MAX 3

char Bossgame7_SayTextAnswers[BOSSGAME7_SAYTEXTINDICE_MAX][BOSSGAME7_SAYTEXTANSWERS_CAPACITY][64];
int Bossgame7_SayTextAnswerCount[BOSSGAME7_SAYTEXTINDICE_MAX];

// Active boss session
char Bossgame7_ActiveAnswerSet[BOSSGAME7_SAYTEXTANSWERS_CAPACITY][64];
int Bossgame7_ActiveAnswerCount;
int Bossgame7_ActiveSayIndice = BOSSGAME7_SAYTEXTINDICE_EASY;
int Bossgame7_ActiveRound = 0;

int Bossgame7_ParticipatingPlayerCount;
int Bossgame7_PlayerActiveAnswerIndex[MAXPLAYERS+1] = 0;
int Bossgame7_PlayerActiveAnswerCount[MAXPLAYERS+1];
int Bossgame7_RemainingTime = 20;
int Bossgame7_ActiveCameraEntityId = 0;

public void Bossgame7_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Bossgame7_OnMapStart);
	AddToForward(GlobalForward_OnMapEnd, INVALID_HANDLE, Bossgame7_OnMapEnd);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame7_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame7_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame7_OnMinigameFinish);

	RegConsoleCmd("say", Bossgame7_SayCommand);
	RegConsoleCmd("say_team", Bossgame7_SayCommand);

	Bossgame7_LoadDictionary(BOSSGAME7_SAYTEXTINDICE_EASY, "data/microtf2/Bossgame7.Dictionary.Easy.txt");
	Bossgame7_LoadDictionary(BOSSGAME7_SAYTEXTINDICE_MEDIUM, "data/microtf2/Bossgame7.Dictionary.Medium.txt");
	Bossgame7_LoadDictionary(BOSSGAME7_SAYTEXTINDICE_HARD, "data/microtf2/Bossgame7.Dictionary.Hard.txt");
}

public void Bossgame7_OnMapStart()
{
	for (int i = 0; i < sizeof(Bossgame7_BgmFiles); i++)
	{
		PrecacheSound(Bossgame7_BgmFiles[i], true);
	}

	PrecacheSound(BOSSGAME7_BGM_FINALOVERVIEW_GOOD, true);
	PrecacheSound(BOSSGAME7_BGM_FINALOVERVIEW_BAD, true);

	for (int i = 0; i < sizeof(Bossgame7_Sfx_WordFail); i++)
	{
		PrecacheSound(Bossgame7_Sfx_WordFail[i], true);
	}

	for (int i = 0; i < sizeof(Bossgame7_Sfx_WordSuccessPinch); i++)
	{
		PrecacheSound(Bossgame7_Sfx_WordSuccessPinch[i], true);
	}

	PrecacheSound(BOSSGAME7_SFX_BOSS_START, true);
	PrecacheSound(BOSSGAME7_SFX_DESCENT_BEGIN, true);
	PrecacheSound(BOSSGAME7_SFX_OVERVIEW, true);
	PrecacheSound(BOSSGAME7_SFX_OVERVIEW_SURVIVE, true);
	PrecacheSound(BOSSGAME7_SFX_SPIRAL, true);
	PrecacheSound(BOSSGAME7_SFX_TYPING_START, true);
	PrecacheSound(BOSSGAME7_SFX_WORDSUCCESS_RELAX, true);
}

public void Bossgame7_OnMapEnd()
{
}

public bool Bossgame7_LoadDictionary(int indice, const char[] path)
{
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), path);

	Handle file = OpenFile(manifestPath, "r"); 

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to load dictionary: \"%s\"", path);
		return false;
	}

	char line[64];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (Bossgame7_SayTextAnswerCount[indice] >= BOSSGAME7_SAYTEXTANSWERS_CAPACITY)
		{
			LogError("Hit the hardcoded limit of answers for Bossgame7. If you really want to add more, recompile the plugin with the limit changed.");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		strcopy(Bossgame7_SayTextAnswers[indice][Bossgame7_SayTextAnswerCount[indice]], 64, line);
		Bossgame7_SayTextAnswerCount[indice]++;
	}

	CloseHandle(file);

	#if defined LOGGING_STARTUP
	LogMessage("Bossgame7: Loaded %i items from dictionary \"%s\".", Bossgame7_SayTextAnswerCount[indice], path);
	#endif

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
		Bossgame7_ActiveSayIndice = BOSSGAME7_SAYTEXTINDICE_EASY;
		Bossgame7_ActiveRound = 0;

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
	player.SetRandomClass();
	player.RemoveAllWeapons();
	ResetWeapon(client, false);

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

	Bossgame7_PlaySnd(client, BOSSGAME7_SFX_BOSS_START);
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

		if (player.IsParticipating && Bossgame7_RemainingTime >= 0)
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

				if (Bossgame7_PlayerActiveAnswerIndex[client] >= 5)
				{
					int soundIdx = GetRandomInt(0, sizeof(Bossgame7_Sfx_WordSuccessPinch)-1);

					EmitSoundToClient(client, Bossgame7_Sfx_WordSuccessPinch[soundIdx], Bossgame7_ActiveCameraEntityId);
				}
				else
				{
					EmitSoundToClient(client, BOSSGAME7_SFX_WORDSUCCESS_RELAX, Bossgame7_ActiveCameraEntityId);
				}

				Bossgame7_PlayerActiveAnswerCount[client]++;

				return Plugin_Handled;
			}
			else
			{
				int soundIdx = GetRandomInt(0, sizeof(Bossgame7_Sfx_WordFail)-1);

				EmitSoundToClient(client, Bossgame7_Sfx_WordFail[soundIdx], Bossgame7_ActiveCameraEntityId);
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

	Bossgame7_ActiveCameraEntityId = camera;

	int randomBgmIdx = GetRandomInt(0, sizeof(Bossgame7_BgmFiles)-1);

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			MinigameCaption[player.ClientId] = "";
			SetClientViewEntity(i, camera);

			Bossgame7_PlaySnd(i, Bossgame7_BgmFiles[randomBgmIdx]);
			EmitSoundToClient(i, BOSSGAME7_SFX_DESCENT_BEGIN, Bossgame7_ActiveCameraEntityId);
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

	Bossgame7_ActiveCameraEntityId = camera;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			SetClientViewEntity(i, camera);

			char text[128];
			Format(text, sizeof(text), "%T", "Bossgame7_Caption_Explain", i);

			player.PrintHintBox(text);
			player.DisplayOverlay("gemidyne/warioware/overlays/bossgame_typethewords");

			EmitSoundToClient(i, BOSSGAME7_SFX_SPIRAL, Bossgame7_ActiveCameraEntityId);
		}
	}

	TriggerRelay("DRBoss_SpinInCamera_Start");
	CreateTimer(4.5, Bossgame7_DoCloseupSequence);

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

	Bossgame7_ActiveCameraEntityId = camera;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			SetClientViewEntity(i, camera);

			char text[128];
			Format(text, sizeof(text), "%T", "Bossgame7_Caption_Start", i);

			player.PrintHintBox(text);
			player.DisplayOverlay(OVERLAY_BLANK);

			EmitSoundToClient(i, BOSSGAME7_SFX_TYPING_START, Bossgame7_ActiveCameraEntityId);
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

	Bossgame7_ActiveRound++;

	if (Bossgame7_ActiveRound >= 0 && Bossgame7_ActiveRound <= 1)
	{
		Bossgame7_ActiveSayIndice = BOSSGAME7_SAYTEXTINDICE_EASY;
	}
	else if (Bossgame7_ActiveRound >= 2 && Bossgame7_ActiveRound < 3)
	{
		Bossgame7_ActiveSayIndice = BOSSGAME7_SAYTEXTINDICE_MEDIUM;
	}
	else
	{
		Bossgame7_ActiveSayIndice = BOSSGAME7_SAYTEXTINDICE_HARD;
	}

	// TODO: The upperlength has to change depending on the situation of the boss
	for (int i = 0; i <= 64; i++)
	{
		int answerIdx = GetRandomInt(0, Bossgame7_SayTextAnswerCount[Bossgame7_ActiveSayIndice]-1);

		strcopy(Bossgame7_ActiveAnswerSet[Bossgame7_ActiveAnswerCount], 64, Bossgame7_SayTextAnswers[Bossgame7_ActiveSayIndice][answerIdx]);

		Bossgame7_ActiveAnswerCount++;
	}

	CreateTimer(0.0, Bossgame7_DoTypingTick);
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

	Bossgame7_ActiveCameraEntityId = camera;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			SetClientViewEntity(i, camera);
			MinigameCaption[i] = "";

			player.DisplayOverlay(OVERLAY_BLANK);
			EmitSoundToClient(i, BOSSGAME7_SFX_OVERVIEW, Bossgame7_ActiveCameraEntityId);
		}
	}



	// Get answer count range
	int nbPlayersActive; //I hope you have it

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
		{
			nbPlayersActive++;
		}
	}

	//TODO: HAVE TO TEST THIS
	int medianNbWordsTyped = 0;
	int maxNbWordsTyped = 0;

	int sortedAnswers[MAXPLAYERS+1];

	for (int i = 0; i <= MaxClients; i++)
	{
		sortedAnswers[i] = Bossgame7_PlayerActiveAnswerCount[i];
	}

	// NOTE: SortIntegers modifies the input array and does not return a separate sorted array!!
	SortIntegers(sortedAnswers, MAXPLAYERS+1, Sort_Descending);

	maxNbWordsTyped = sortedAnswers[0];
	if (nbPlayersActive % 2 == 0)
	{
		medianNbWordsTyped = (sortedAnswers[nbPlayersActive/2] + sortedAnswers[nbPlayersActive/2 - 1]) / 2;
	}
	else
	{
		medianNbWordsTyped = sortedAnswers[nbPlayersActive/2];
	}

	bool allWordsAnsweredByAll = maxNbWordsTyped == medianNbWordsTyped;

	if (allWordsAnsweredByAll)
	{
		medianNbWordsTyped = -999;
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

					if (p.IsValid && p.IsParticipating && p.Status != PlayerStatus_Failed && Bossgame7_PlayerActiveAnswerCount[j] <= medianNbWordsTyped)
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

	CreateTimer(3.0, Bossgame7_DoReviewSequencePost, medianNbWordsTyped);
	return Plugin_Handled;
}

public Action Bossgame7_DoReviewSequencePost(Handle timer, any data)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	int activePlayers = 0;
	int lastWinnerId = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
		{
			if (Bossgame7_PlayerActiveAnswerCount[i] <= data)
			{
				player.Status = PlayerStatus_Failed;
				ForcePlayerSuicide(i);
				EmitSoundToClient(i, BOSSGAME7_SFX_OVERVIEW_DEFEAT, Bossgame7_ActiveCameraEntityId);
			}
			else
			{
				activePlayers++;
				player.Status = PlayerStatus_Winner;
				EmitSoundToClient(i, BOSSGAME7_SFX_OVERVIEW_SURVIVE, Bossgame7_ActiveCameraEntityId);
				lastWinnerId = i;
			}
		}
	}

	if (activePlayers > 1)
	{
		CreateTimer(2.0, Bossgame7_DoDescentSequence);
	}
	else
	{
		CreateTimer(2.0, Bossgame7_DoFinalReview, lastWinnerId);
	}

	return Plugin_Handled;
}

public Action Bossgame7_DoFinalReview(Handle timer, any winnerId)
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

		if (player.IsValid && player.IsParticipating)
		{
			char text[128];

			Format(text, sizeof(text), "ROUND REVIEW\n\n");
			Format(text, sizeof(text), "%sThe winner is...\n", text);

			Format(text, sizeof(text), "%s%N\n", text, winnerId);

			MinigameCaption[player.ClientId] = text;

			if (i == winnerId)
			{
				EmitSoundToClient(i, BOSSGAME7_BGM_FINALOVERVIEW_GOOD, Bossgame7_ActiveCameraEntityId);
			}
			else
			{
				EmitSoundToClient(i, BOSSGAME7_BGM_FINALOVERVIEW_BAD, Bossgame7_ActiveCameraEntityId);
			}
		}
	}

	CreateTimer(3.0, Bossgame7_DoFinalReviewPost);
	return Plugin_Handled;
}

public Action Bossgame7_DoFinalReviewPost(Handle timer)
{
	if (BossgameID != 7)
	{
		return Plugin_Handled;
	}

	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	EndBoss();
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

public void Bossgame7_PlaySnd(int client, const char[] file)
{
	char path[128];

	Format(path, sizeof(path), "play %s", file);

	ClientCommand(client, path);
}