/**
 * MicroTF2 - SpecialRounds.inc
 * 
 * Contains stuff for Special Round operation
 */

#define SPR_NAME_LENGTH 64
#define SPR_DESC_LENGTH 256
#define SPR_FAKECOND_LENGTH 64
#define SPR_FAKECOND_CAPACITY 256

int SpecialRoundsLoaded = 0;

float SpecialRound_StartEffect = 1.0;

char SpecialRounds[SPR_MAX+1][SPR_NAME_LENGTH];
char SpecialRoundDescriptions[SPR_MAX+1][SPR_DESC_LENGTH];
bool SpecialRoundSpeedEventsDisabled[SPR_MAX+1];
bool SpecialRoundMultiplePlayersOnly[SPR_MAX+1];
int SpecialRoundBossGameThreshold[SPR_MAX+1];

char SpecialRoundFakeConditions[SPR_FAKECOND_CAPACITY][SPR_FAKECOND_LENGTH];
int SpecialRoundFakeConditionsCount = 0;

bool IsChoosingSpecialRound = false;

bool ForceNextSpecialRound = false;
int ForceSpecialRound = 0;

#define BIRD_MODEL "models/props_forest/dove.mdl"

stock void InitializeSpecialRounds()
{
	LogMessage("Initializing Special Rounds...");

	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/specialrounds.txt");

	Handle kv = CreateKeyValues("SpecialRounds");
	FileToKeyValues(kv, path);
 
	if (KvGotoFirstSubKey(kv))
	{
		int i = 0;

		do
		{
			KvGetString(kv, "Name", SpecialRounds[i], SPR_NAME_LENGTH);
			KvGetString(kv, "Description", SpecialRoundDescriptions[i], SPR_DESC_LENGTH);

			SpecialRoundSpeedEventsDisabled[i] = (KvGetNum(kv, "DisableSpeedEvents", 0) == 1);
			SpecialRoundMultiplePlayersOnly[i] = (KvGetNum(kv, "MultiplePlayersOnly", 0) == 1);
			SpecialRoundBossGameThreshold[i] = KvGetNum(kv, "BossGameThreshold", 0);

			i++;
		}
		while (KvGotoNextKey(kv));

		SpecialRoundsLoaded = i;
	}
 
	CloseHandle(kv);

	Special_LoadFakeConditions();

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, SpecialRound_OnMapStart);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, SpecialRound_OnGameFrame);
}

public void SpecialRound_OnMapStart()
{
	PrecacheModel(BIRD_MODEL);
}

public void SpecialRound_OnGameFrame()
{
	if (GamemodeStatus == GameStatus_Playing)
	{
		if (IsChoosingSpecialRound)
		{
			SpecialRound_PrintRandomNameWhenChoosing();
		}

		if (GamemodeID == SPR_GAMEMODEID)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				Player player = new Player(i);

				if (player.IsValid && player.IsParticipating && player.IsAlive)
				{
					player.HeadScale = SpecialRoundID == 15 
						? 2.0 
						: 1.0;
				}
			}
		}
	}
}

public void SpecialRound_PrintRandomNameWhenChoosing()
{
	char buffer[128];

	if (GetRandomInt(0, 1) == 1)
	{
		ToUpperString(SpecialRounds[GetRandomInt(SPR_MIN, SpecialRoundsLoaded - 1)], buffer, sizeof(buffer));
	}
	else
	{
		int index = GetRandomInt(0, SpecialRoundFakeConditionsCount);

		strcopy(buffer, sizeof(buffer), SpecialRoundFakeConditions[index]);
	}

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
	IsChoosingSpecialRound = false;

	if (!ForceNextSpecialRound)
	{
		do
		{
			SpecialRoundID = GetRandomInt(SPR_MIN, SpecialRoundsLoaded - 1);
		}
		while (!SpecialRound_IsAvailable());
	}
	else
	{
		SpecialRoundID = ForceSpecialRound;
		ForceNextSpecialRound = false;
	}

	// Setup the Boss game threshold.
	if (SpecialRoundBossGameThreshold[SpecialRoundID] > 0)
	{
		BossGameThreshold = SpecialRoundBossGameThreshold[SpecialRoundID];
	}
	else
	{
		BossGameThreshold = GetRandomInt(15, 26);
	}
}

stock bool SpecialRound_IsAvailable()
{
	if (SpecialRoundMultiplePlayersOnly[SpecialRoundID])
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
	EmitSoundToAll(SYSFX_SELECTED);

	char name[SPR_NAME_LENGTH];
	ToUpperString(SpecialRounds[SpecialRoundID], name, sizeof(name));

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			PrintCenterText(i, "%T", "Hud_SpecialRound_CenterDisplay", i, name);
			CPrintToChat(i, "%s%s", PLUGIN_PREFIX, SpecialRounds[SpecialRoundID]);
			CPrintToChat(i, "%s%s", PLUGIN_PREFIX, SpecialRoundDescriptions[SpecialRoundID]);
		}
	}

	if (SpecialRoundID == 14)
	{
		SpecialRound_StartEffect = 1.0;
		CreateTimer(0.0, Timer_SpecialRoundSixteenEffect);
	}
	else if (SpecialRoundID == 15)
	{
		SpecialRound_StartEffect = 1.0;
		CreateTimer(0.0, Timer_SpecialRoundSeventeenEffect);
	}
}

public Action Timer_SpecialRoundSixteenEffect(Handle timer, int client)
{ 
	if (SpecialRound_StartEffect > 0.3)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && player.IsAlive)
			{
				player.Scale = SpecialRound_StartEffect;
			}
		}

		SpecialRound_StartEffect -= 0.1;
		CreateTimer(0.01, Timer_SpecialRoundSixteenEffect);
	}
	else
	{
		SpecialRound_StartEffect = 1.0;
	}
}

public Action Timer_SpecialRoundSeventeenEffect(Handle timer, int client)
{
	if (SpecialRound_StartEffect < 2.0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && player.IsAlive)
			{
				player.HeadScale = SpecialRound_StartEffect;
			}
		}

		SpecialRound_StartEffect += 0.1;
		CreateTimer(0.01, Timer_SpecialRoundSeventeenEffect);
	}
	else
	{
		SpecialRound_StartEffect = 1.0;
	}
}

public void Special_NoTouch(int entity, int other) 
{
	if (SpecialRoundID != 11 || MinigameID == 17) 
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	char classname[64];
	char classname2[64];
	GetEdictClassname(entity, classname, sizeof(classname));
	GetEdictClassname(other, classname2, sizeof(classname2));

	Player player1 = new Player(entity);
	Player player2 = new Player(other);

	if (StrEqual(classname, "player") && StrEqual(classname2, "player") && player1.IsValid && player2.IsValid && player1.IsAlive && player2.IsAlive && player1.Team != player2.Team) 
	{
		PlayerStatus[entity] = PlayerStatus_Failed;
		PlayerStatus[other] = PlayerStatus_Failed;

		ForcePlayerSuicide(entity);
		ForcePlayerSuicide(other);

		CPrintToChatEx(entity, other, "%s You touched: {teamcolor}%N{default}!", PLUGIN_PREFIX, other);
		CPrintToChat(entity, "You are {red}not allowed to touch anyone{default} in this Special Round!");

		CPrintToChatEx(other, entity, "%s You touched: {teamcolor}%N{default}!", PLUGIN_PREFIX, entity);
		CPrintToChat(other, "You are {red}not allowed to touch anyone{default} in this Special Round!");
	}
}

stock void SpecialRound_SetupEnv()
{
	SetConVarInt(ConVar_ServerGravity, (SpecialRoundID == 3) ? 200 : 800);
}

stock void SetupSPR(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		Special_Bird(client);

		player.Scale = SpecialRoundID == 14 
			? 0.3 
			: 1.0;

		if (SpecialRoundID != 15)
		{
			player.HeadScale = 1.0;
		}

		if (GamemodeID == SPR_GAMEMODEID)
		{
			player.SetThirdPersonMode(SpecialRoundID == 0);

			if (SpecialRoundID == 17 && !player.IsParticipating)
			{
				player.SetCollisionsEnabled(false);
				player.SetVisible(false);
			}
			else if (SpecialRoundID == 12 && !IsBonusRound)
			{
				player.SetVisible(false);
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

public void Special_Bird(int client)
{
	if (!IsValidEntity(client)) 
	{
		return;
	}

	if (SpecialRoundID != 13) 
	{
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
	}
	else
	{
		SetVariantString(BIRD_MODEL);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
		SetEntProp(client, Prop_Send, "m_nBody", 0);
	}
}

stock void SetSpeed_SpecialRound()
{
	switch (SpecialRoundID)
	{
		case 1:
		{
			if (MinigamesPlayed == 0)
			{
				SpeedLevel = 2.0;
			}
		}

		case 5: 
		{
			SpeedLevel += 0.1;
		}

		case 6:
		{
			SpeedLevel = GetRandomFloat(1.0, 2.5);
		}

		case 7:
		{
			SpeedLevel -= 0.1;
		}

		case 8:
		{
			if (MinigamesPlayed % 2 == 0)
			{
				SpeedLevel += 0.2;
			}
		}
	}
}

stock bool Special_AreSpeedEventsEnabled()
{
	if (SpecialRoundID <= 0)
	{
		return true;
	}

	if (SpecialRoundID > SPR_MAX)
	{
		return true;
	}

	return !SpecialRoundSpeedEventsDisabled[SpecialRoundID];
}

stock void Special_LoadFakeConditions()
{
	LogMessage("Initializing Special Round random non-existant conditions");

	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/specialroundfakeconditions.txt");

	Handle file = OpenFile(manifestPath, "r"); // Only need r for read

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open SpecialRoundFakeConditions.txt in data/microtf2! Lagspikes may occur during the game.");
		return;
	}

	char line[SPR_FAKECOND_LENGTH];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (SpecialRoundFakeConditionsCount >= SPR_FAKECOND_CAPACITY)
		{
			LogError("Hit the hardcoded limit of Special Round fake conditions. If you really want to add more, recompile the plugin with the limit changed.");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		SpecialRoundFakeConditions[SpecialRoundFakeConditionsCount] = line;
		SpecialRoundFakeConditionsCount++;
	}

	CloseHandle(file);
}

public Action Timer_GameLogic_SpecialRoundSelectionStart(Handle timer)
{
	if (SpeedLevel == 1.0)
	{
		EmitSoundToAll(SYSBGM_SPECIAL);
	}
	else
	{
		PlaySoundToAll(SYSBGM_SPECIAL);
	}
	
	CreateTimer(0.8, Timer_GameLogic_SpecialRoundChoosingStartSelection, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosingStartSelection(Handle timer)
{
	IsChoosingSpecialRound = true;

	DisplayOverlayToAll(OVERLAY_SPECIALROUND);

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