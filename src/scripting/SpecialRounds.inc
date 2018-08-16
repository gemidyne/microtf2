/**
 * MicroTF2 - SpecialRounds.inc
 * 
 * Contains stuff for Special Round operation
 */

#define SPR_GAMEMODEID 99

#define SPR_MIN 0
#define SPR_MAX 32
#define SPR_NAME_LENGTH 64
#define SPR_DESC_LENGTH 256
#define SPR_FAKECOND_LENGTH 64
#define SPR_FAKECOND_CAPACITY 256

new SpecialRoundsLoaded = 0;

new Float:SpecialRound_StartEffect = 1.0;

new String:SpecialRounds[SPR_MAX+1][SPR_NAME_LENGTH];
new String:SpecialRoundDescriptions[SPR_MAX+1][SPR_DESC_LENGTH];
new bool:SpecialRoundSpeedEventsDisabled[SPR_MAX+1];
new bool:SpecialRoundMultiplePlayersOnly[SPR_MAX+1];
new SpecialRoundBossGameThreshold[SPR_MAX+1];

new String:SpecialRoundFakeConditions[SPR_FAKECOND_CAPACITY][SPR_FAKECOND_LENGTH];
new SpecialRoundFakeConditionsCount = 0;

new bool:IsChoosingSpecialRound = false;

new bool:ForceNextSpecialRound = false;
new ForceSpecialRound = 0;

#define BIRD_MODEL "models/props_forest/dove.mdl"

stock InitializeSpecialRounds()
{
	LogMessage("Initializing Special Rounds...");

	decl String:path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/specialrounds.txt");

	new Handle:kv = CreateKeyValues("SpecialRounds");
	FileToKeyValues(kv, path);
 
	if (KvGotoFirstSubKey(kv))
	{
		new i = 0;

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

public SpecialRound_OnMapStart()
{
	PrecacheModel(BIRD_MODEL);
}

public SpecialRound_OnGameFrame()
{
	if (GamemodeStatus == GameStatus_Playing)
	{
		SpecialRound_PrintRandomNameWhenChoosing();

		if (GamemodeID == SPR_GAMEMODEID)
		{
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsClientValid(i) && IsPlayerParticipant[i] && IsPlayerAlive(i))
				{
					SetEntPropFloat(i, Prop_Send, "m_flHeadScale", (SpecialRoundID == 15) ? 2.0 : 1.0);
				}
			}
		}
	}
}

public SpecialRound_PrintRandomNameWhenChoosing()
{
	if (!IsChoosingSpecialRound)
	{
		return;
	}

	decl String:buffer[128];

	if (GetRandomInt(0, 1) == 1)
	{
		ToUpperString(SpecialRounds[GetRandomInt(SPR_MIN, SpecialRoundsLoaded - 1)], buffer, sizeof(buffer));
	}
	else
	{
		new index = GetRandomInt(0, SpecialRoundFakeConditionsCount);

		strcopy(buffer, sizeof(buffer), SpecialRoundFakeConditions[index]);
	}

	PrintCenterTextAll("NEW CONDITION: %s!", buffer);
}

public SelectNewSpecialRound()
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

stock bool:SpecialRound_IsAvailable()
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

stock PrintSelectedSpecialRound()
{
	EmitSoundToAll(SYSMUSIC_SPECIALROUND_SELECTED);

	decl String:name[SPR_NAME_LENGTH];
	ToUpperString(SpecialRounds[SpecialRoundID], name, sizeof(name));
	PrintCenterTextAll("NEW CONDITION: %s!", name);

	#if defined NEW_HUD

	decl String:objective[64];
	Format(objective, sizeof(objective), "The next Special Round is... %s!", SpecialRounds[SpecialRoundID]);
	DisplayHudMessage(objective, SpecialRoundDescriptions[SpecialRoundID], 5.0);

	#else
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			CPrintToChat(i, "%s%s", PLUGIN_PREFIX, SpecialRounds[SpecialRoundID]);
			CPrintToChat(i, "%s%s", PLUGIN_PREFIX, SpecialRoundDescriptions[SpecialRoundID]);
		}
	}

	#endif

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


public Action:Timer_SpecialRoundSixteenEffect(Handle:timer, any:client)
{ 
	if (SpecialRound_StartEffect > 0.3)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				ResizePlayer(i, SpecialRound_StartEffect);
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

public Action:Timer_SpecialRoundSeventeenEffect(Handle:timer, any:client)
{
	if (SpecialRound_StartEffect < 2.0)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))
			{
				SetEntPropFloat(i, Prop_Send, "m_flHeadScale", SpecialRound_StartEffect);
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

public Special_NoTouch(entity, other) 
{
    if (SpecialRoundID != 11 || MinigameID == 17) 
	{
		return;
	}

    decl String:classname[64];
    decl String:classname2[64];
    GetEdictClassname(entity, classname, sizeof(classname));
    GetEdictClassname(other, classname2, sizeof(classname2));

    if (StrEqual(classname, "player") && StrEqual(classname2, "player") && IsClientValid(entity) && IsClientValid(other) && IsMinigameActive && IsPlayerAlive(entity) && IsPlayerAlive(other) && GetClientTeam(entity) != GetClientTeam(other)) 
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

stock SpecialRound_SetupEnv()
{
	SetConVarInt(ConVar_ServerGravity, (SpecialRoundID == 3) ? 200 : 800);
}

SetupSPR(i)
{
	if (IsClientInGame(i))
	{
		Special_Bird(i);

		ResizePlayer(i, (SpecialRoundID == 14) ? 0.3 : 1.0);

		if (SpecialRoundID != 15)
		{
			SetEntPropFloat(i, Prop_Send, "m_flHeadScale", 1.0);
		}

		if (GamemodeID == SPR_GAMEMODEID)
		{
			switch (SpecialRoundID)
			{	
				case 0:
				{
					SetCommandFlags("thirdperson", GetCommandFlags("thirdperson") & (~FCVAR_CHEAT));
					ClientCommand(i, "thirdperson");
					SetCommandFlags("thirdperson", GetCommandFlags("thirdperson") & (FCVAR_CHEAT));
				}

				default:
				{
					SetCommandFlags("firstperson", GetCommandFlags("firstperson") & (~FCVAR_CHEAT));
					ClientCommand(i, "firstperson");
					SetCommandFlags("firstperson", GetCommandFlags("firstperson") & (FCVAR_CHEAT));
				}
			}

			if (SpecialRoundID == 17 && !IsPlayerParticipant[i])
			{
				IsPlayerCollisionsEnabled(i, false);

				SetEntityRenderFx(i, RENDERFX_DISTORT);
				SetEntityRenderMode(i, RENDER_TRANSALPHA);
				SetEntityRenderColor(i, _, _, _, 70);
			}
			else if (SpecialRoundID == 12 && !IsBonusRound)
			{
				SetEntityRenderFx(i, RENDERFX_NONE);
				SetEntityRenderMode(i, RENDER_NONE);
				SetEntityRenderColor(i, 255, 255, 255, 0);
			}
			else
			{
				SetEntityRenderFx(i, RENDERFX_NONE);
				SetEntityRenderMode(i, RENDER_NORMAL);
				SetEntityRenderColor(i, 255, 255, 255, 255);
			}
		}
		else
		{
			if (IsPlayerParticipant[i])
			{
				SetEntityRenderFx(i, RENDERFX_NONE);
				SetEntityRenderMode(i, RENDER_NORMAL);
				SetEntityRenderColor(i, 255, 255, 255, 255);
			}
			else
			{
				SetEntityRenderFx(i, RENDERFX_DISTORT);
				SetEntityRenderMode(i, RENDER_TRANSALPHA);
				SetEntityRenderColor(i, _, _, _, 70);
			}

			SetCommandFlags("firstperson", GetCommandFlags("firstperson") & (~FCVAR_CHEAT));
			ClientCommand(i, "firstperson");
			SetCommandFlags("firstperson", GetCommandFlags("firstperson") & (FCVAR_CHEAT));
		}
	}
}

public Special_Bird(client)
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

stock SetSpeed_SpecialRound()
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

stock bool:Special_AreSpeedEventsEnabled()
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

stock Special_LoadFakeConditions()
{
	LogMessage("Initializing Special Round random non-existant conditions");

	decl String:manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/specialroundfakeconditions.txt");

	new Handle:file = OpenFile(manifestPath, "r"); // Only need r for read

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open SpecialRoundFakeConditions.txt in data/microtf2! Lagspikes may occur during the game.");
		return;
	}

	decl String:line[SPR_FAKECOND_LENGTH];

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