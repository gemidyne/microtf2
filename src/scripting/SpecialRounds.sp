/**
 * MicroTF2 - SpecialRounds.inc
 * 
 * Contains stuff for Special Round operation
 */
 
#define SPR_NAME_LENGTH 64
#define SPR_DESC_LENGTH 256
#define SPR_FAKECOND_LENGTH 64
#define SPR_FAKECOND_CAPACITY 256

int g_iLoadedSpecialRoundCount = 0;

bool g_bSpecialRoundSpeedEventsDisabled[SPR_MAX+1];
bool g_bSpecialRoundMultiplePlayersOnly[SPR_MAX+1];
int g_iSpecialRoundBossGameThreshold[SPR_MAX+1];

char g_sSpecialRoundFakeConditionNames[SPR_FAKECOND_CAPACITY][SPR_FAKECOND_LENGTH];
int g_iSpecialRoundFakeConditionCount = 0;

bool g_bIsChoosingSpecialRound = false;
bool g_bForceSpecialRound = false;
int g_iForceSpecialRoundId = 0;

float g_fSpecialRoundScaleEffect = 1.0;

#define SPECIALROUND_SKELETON_MODEL "models/gemidyne/warioware/skeleton.mdl"

void InitializeSpecialRounds()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Special Rounds...");
	#endif

	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/SpecialRounds.txt");

	KeyValues kv = new KeyValues("SpecialRounds");

	if (!kv.ImportFromFile(path))
	{
		SetFailState("Unable to read SpecialRounds.txt from data/microtf2/");
		kv.Close();
		return;
	}
 
	if (kv.GotoFirstSubKey())
	{
		int i = 0;

		do
		{
			g_bSpecialRoundSpeedEventsDisabled[i] = (kv.GetNum("DisableSpeedEvents", 0) == 1);
			g_bSpecialRoundMultiplePlayersOnly[i] = (kv.GetNum("MultiplePlayersOnly", 0) == 1);
			g_iSpecialRoundBossGameThreshold[i] = kv.GetNum("g_iBossGameThreshold", 0);

			i++;
		}
		while (kv.GotoNextKey());

		g_iLoadedSpecialRoundCount = i;
	}
 
	kv.Close();

	Special_LoadFakeConditions();

	AddToForward(g_pfOnMapStart, INVALID_HANDLE, SpecialRound_OnMapStart);
	AddToForward(g_pfOnGameFrame, INVALID_HANDLE, SpecialRound_OnGameFrame);
	AddToForward(g_pfOnMinigameSelectedPost, INVALID_HANDLE, SpecialRound_ApplyEffects);
	AddToForward(g_pfOnGameOverStart, INVALID_HANDLE, SpecialRound_ApplyEffects);

	AddToForward(g_pfOnMinigamePrepare, INVALID_HANDLE, SpecialRound_ApplyPlayerEffects);
	AddToForward(g_pfOnMinigameFinishPost, INVALID_HANDLE, SpecialRound_ApplyPlayerEffects);
	AddToForward(g_pfOnPlayerSpawn, INVALID_HANDLE, SpecialRound_ApplyPlayerEffects);

	AddToForward(g_pfOnMinigamePreparePre, INVALID_HANDLE, SpecialRound_OnMinigamePreparePre);
	AddToForward(g_pfOnPlayerClassChange, INVALID_HANDLE, SpecialRound_OnPlayerClassChange);

	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, SpecialRound_SetupEnv);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, SpecialRound_SetupEnv);

	RegAdminCmd("sm_setnextspecialround", Command_SetNextSpecialRound, ADMFLAG_VOTE, "Forces a specific special round to be selected after the current round completes.");
	RegAdminCmd("sm_changespecialround", Command_ChangeSpecialRound, ADMFLAG_VOTE, "Changes the current special round. If the value is less than 0, or not found, the default gamemode is run.");
}

public void SpecialRound_OnMapStart()
{
	PrecacheModel(SPECIALROUND_SKELETON_MODEL);
	PrecacheModel("models/gemidyne/warioware/scout_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/sniper_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/soldier_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/demo_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/medic_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/heavy_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/pyro_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/spy_lowpoly.mdl");
	PrecacheModel("models/gemidyne/warioware/engineer_lowpoly.mdl");
}

public void SpecialRound_OnGameFrame()
{
	if (g_eGamemodeStatus == GameStatus_Playing)
	{
		if (g_bIsChoosingSpecialRound)
		{
			SpecialRound_PrintRandomNameWhenChoosing();
		}

		if (g_iActiveGamemodeId == SPR_GAMEMODEID)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				Player player = new Player(i);

				if (player.IsValid && player.IsParticipating && player.IsAlive)
				{
					player.HeadScale = g_iSpecialRoundId == 15 
						? 2.0 
						: 1.0;
				}
			}
		}
	}
}

public void SpecialRound_OnMinigamePreparePre()
{
	if (!g_bIsGameOver)
	{
		SetSpeed_SpecialRound();
	}

	SpecialRound_SetupEnv();
}

public void SpecialRound_PrintRandomNameWhenChoosing()
{
	char buffer[128];
	int index = GetRandomInt(0, g_iSpecialRoundFakeConditionCount);

	strcopy(buffer, sizeof(buffer), g_sSpecialRoundFakeConditionNames[index]);

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			PrintCenterText(player.ClientId, "%T", "Hud_SpecialRound_CenterDisplay", player.ClientId, buffer);
		}
	}
}

public void SelectNewSpecialRound()
{
	g_bIsChoosingSpecialRound = false;
	g_bHideHudGamemodeText = false;

	if (!g_bForceSpecialRound)
	{
		do
		{
			g_iSpecialRoundId = GetRandomInt(SPR_MIN, g_iLoadedSpecialRoundCount - 1);
		}
		while (!SpecialRound_IsAvailable());
	}
	else
	{
		g_iSpecialRoundId = g_iForceSpecialRoundId;
		g_bForceSpecialRound = false;
	}

	PluginForward_SendSpecialRoundSelected(g_iSpecialRoundId);

	// Setup the Boss game threshold.
	if (g_iSpecialRoundBossGameThreshold[g_iSpecialRoundId] > 0)
	{
		g_iBossGameThreshold = g_iSpecialRoundBossGameThreshold[g_iSpecialRoundId];
	}
	else
	{
		g_iBossGameThreshold = GetRandomInt(15, 26);
	}
}

stock bool SpecialRound_IsAvailable()
{
	if (g_bSpecialRoundMultiplePlayersOnly[g_iSpecialRoundId])
	{
		if (GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
		{
			return false;
		}
	}

	// If it falls through to here, all good.
	return true;
}

stock void PrintSelectedSpecialRound()
{
	PlaySoundToAll(SYSFX_SELECTED);

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			char key[32];
			Format(key, sizeof(key), "SpecialRound%i_Name", g_iSpecialRoundId);

			char name[SPR_NAME_LENGTH];
			char description[256];

			Format(name, sizeof(name), "%T", key, i);

			ToUpperString(name, name, sizeof(name));
			PrintCenterText(i, "%T", "Hud_SpecialRound_CenterDisplay", i, name);

			// Restore name to normal casing
			Format(name, sizeof(name), "%T", key, i);

			Format(key, sizeof(key), "SpecialRound%i_Description", g_iSpecialRoundId);
			Format(description, sizeof(description), "%T", key, i);

			player.PrintChatText("%T", "Hud_SpecialRound_ChatDisplay", i, name, description);
		}
	}

	if (g_iSpecialRoundId == 14)
	{
		g_fSpecialRoundScaleEffect = 1.0;
		CreateTimer(0.0, Timer_SpecialRoundSixteenEffect);
	}
	else if (g_iSpecialRoundId == 15)
	{
		g_fSpecialRoundScaleEffect = 1.0;
		CreateTimer(0.0, Timer_SpecialRoundSeventeenEffect);
	}
}

public Action Timer_SpecialRoundSixteenEffect(Handle timer, int client)
{ 
	if (g_fSpecialRoundScaleEffect > 0.3)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && player.IsAlive)
			{
				player.Scale = g_fSpecialRoundScaleEffect;
			}
		}

		g_fSpecialRoundScaleEffect -= 0.1;
		CreateTimer(0.01, Timer_SpecialRoundSixteenEffect);
	}
	else
	{
		g_fSpecialRoundScaleEffect = 1.0;
	}

	return Plugin_Handled;
}

public Action Timer_SpecialRoundSeventeenEffect(Handle timer, int client)
{
	if (g_fSpecialRoundScaleEffect < 2.0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && player.IsAlive)
			{
				player.HeadScale = g_fSpecialRoundScaleEffect;
			}
		}

		g_fSpecialRoundScaleEffect += 0.1;
		CreateTimer(0.01, Timer_SpecialRoundSeventeenEffect);
	}
	else
	{
		g_fSpecialRoundScaleEffect = 1.0;
	}

	return Plugin_Handled;
}

stock void SpecialRound_SetupEnv()
{
	g_hConVarServerGravity.IntValue = (g_iSpecialRoundId == 3) ? 200 : 800;
}

public void SpecialRound_ApplyEffects()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			SpecialRound_ApplyPlayerEffects(player.ClientId);
		}
	}
}

public void SpecialRound_ApplyPlayerEffects(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		Special_ApplyCustomModel(client);

		player.Scale = g_iSpecialRoundId == 14 
			? 0.3 
			: 1.0;

		if (g_iSpecialRoundId != 15)
		{
			player.HeadScale = 1.0;
		}

		if (g_iActiveGamemodeId == SPR_GAMEMODEID)
		{
			player.SetThirdPersonMode(g_iSpecialRoundId == 0);

			if (g_iSpecialRoundId == 17 && !player.IsParticipating)
			{
				player.SetCollisionsEnabled(false);
				player.SetVisible(false);
				player.SetWeaponVisible(false);
			}
			else if (g_iSpecialRoundId == 12 && !g_bIsGameOver)
			{
				player.SetVisible(false);
				player.SetWeaponVisible(false);
			}
			else
			{
				player.SetVisible(true);
			}
		}
		else
		{
			player.SetVisible(player.IsParticipating);
			player.SetThirdPersonMode(false);
		}
	}
}

public void Special_ApplyCustomModel(int client)
{
	if (!IsValidEntity(client)) 
	{
		return;
	}

	if (g_iActiveMinigameId == 10)
	{
		return;
	}

	switch (g_iSpecialRoundId)
	{
		case 13:
		{
			SetVariantString(SPECIALROUND_SKELETON_MODEL);
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		}

		case 21:
		{
			char model[128];
			char class[16];
			Player player = new Player(client);
			
			switch (player.Class)
			{
				case TFClass_Scout: strcopy(class, sizeof(class), "scout");
				case TFClass_Sniper: strcopy(class, sizeof(class), "sniper");
				case TFClass_Soldier: strcopy(class, sizeof(class), "soldier");
				case TFClass_DemoMan: strcopy(class, sizeof(class), "demo");
				case TFClass_Medic: strcopy(class, sizeof(class), "medic");
				case TFClass_Heavy: strcopy(class, sizeof(class), "heavy");
				case TFClass_Pyro: strcopy(class, sizeof(class), "pyro");
				case TFClass_Spy: strcopy(class, sizeof(class), "spy");
				case TFClass_Engineer: strcopy(class, sizeof(class), "engineer");
			}

			Format(model, sizeof(model), "models/gemidyne/warioware/%s_lowpoly.mdl", class);

			SetVariantString(model);
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		}

		default: 
		{
			SetVariantString("");
			AcceptEntityInput(client, "SetCustomModel");
		}
	}
}

stock void SetSpeed_SpecialRound()
{
	switch (g_iSpecialRoundId)
	{
		case 1:
		{
			if (g_iMinigamesPlayedCount == 0)
			{
				g_fActiveGameSpeed = 2.0;
			}
		}

		case 5: 
		{
			g_fActiveGameSpeed += 0.1;
		}

		case 6:
		{
			g_fActiveGameSpeed = GetRandomFloat(1.0, 2.3);
		}

		case 7:
		{
			g_fActiveGameSpeed -= 0.1;
		}

		case 8:
		{
			if (g_iMinigamesPlayedCount % 2 == 0)
			{
				g_fActiveGameSpeed += 0.2;
			}
		}
	}
}

stock bool Special_AreSpeedEventsEnabled()
{
	if (g_iSpecialRoundId <= 0)
	{
		return true;
	}

	if (g_iSpecialRoundId > SPR_MAX)
	{
		return true;
	}

	return !g_bSpecialRoundSpeedEventsDisabled[g_iSpecialRoundId];
}

stock void Special_LoadFakeConditions()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Special Round random non-existant conditions");
	#endif

	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/SpecialRoundFakeConditions.txt");

	File file = OpenFile(manifestPath, "r"); // Only need r for read

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open SpecialRoundFakeConditions.txt in data/microtf2! Lagspikes may occur during the game.");
		return;
	}

	char line[SPR_FAKECOND_LENGTH];

	while (file.ReadLine(line, sizeof(line)))
	{
		if (g_iSpecialRoundFakeConditionCount >= SPR_FAKECOND_CAPACITY)
		{
			LogError("Hit the hardcoded limit of Special Round fake conditions. If you really want to add more, recompile the plugin with the limit changed.");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		g_sSpecialRoundFakeConditionNames[g_iSpecialRoundFakeConditionCount] = line;
		g_iSpecialRoundFakeConditionCount++;
	}

	file.Close();
}

public Action Timer_GameLogic_SpecialRoundSelectionStart(Handle timer)
{
	PlaySoundToAll(SYSBGM_SPECIAL);
	CreateTimer(0.8, Timer_GameLogic_SpecialRoundChoosingStartSelection, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosingStartSelection(Handle timer)
{
	g_bIsChoosingSpecialRound = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			if (player.IsUsingLegacyDirectX)
			{
				player.DisplayOverlay(OVERLAY_BLANK);

				char text[64];
				Format(text, sizeof(text), "%T", "General_SpecialRound", player.ClientId);
				player.SetCaption(text);
			}
			else
			{
				player.DisplayOverlay(OVERLAY_SPECIALROUND);
			}
		}
	}

	CreateTimer(6.8, Timer_GameLogic_SpecialRoundChoosingDoSelect, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosingDoSelect(Handle timer)
{
	SelectNewSpecialRound();
	PrintSelectedSpecialRound();

	CreateTimer(5.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public void SpecialRound_OnPlayerClassChange(int client, int class)
{
	if (g_iSpecialRoundId != 9)
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
		player.Score++;
		player.PrintChatText("%T", "System_SpecialRoundBlockClassChange", client);
	}
}

public Action Command_SetNextSpecialRound(int client, int args)
{
	int id;

	if (args == 1)
	{
		char text[10];
		GetCmdArg(1, text, sizeof(text));

		id = StringToInt(text);
	}
	else if (args > 1)
	{
		ReplyToCommand(client, "[WWR] Usage: sm_setnextspecialround <specialroundid>");
		return Plugin_Handled;
	}
	else
	{
		id = GetRandomInt(SPR_MIN, g_iLoadedSpecialRoundCount - 1);
	}

	if (id >= SPR_MIN && id < g_iLoadedSpecialRoundCount)
	{
		g_bForceSpecialRound = true;
		g_iForceSpecialRoundId = id;

		ReplyToCommand(client, "[WWR] The next special round has been set to %i", id);

		return Plugin_Handled;
	}

	ReplyToCommand(client, "[WWR] Error: specified special round ID is invalid.");

	return Plugin_Handled;
}

public Action Command_ChangeSpecialRound(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[WWR] Usage: sm_changespecialround <specialroundid>");
		return Plugin_Handled;
	}

	char text[10];
	GetCmdArg(1, text, sizeof(text));

	int id = StringToInt(text);

	if (id >= SPR_MIN && id <= SPR_MAX)
	{
		g_iActiveGamemodeId = SPR_GAMEMODEID;
		g_iSpecialRoundId = id;

		return Plugin_Handled;
	}

	ReplyToCommand(client, "[WWR] Error: specified special round ID is invalid.");

	return Plugin_Handled;
}
