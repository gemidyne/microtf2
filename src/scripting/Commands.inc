/**
 * MicroTF2 - Commands.inc
 * 
 * Implements functionality for commands and convars.
 */

stock InitializeCommands()
{
	// Command Listeners
	AddCommandListener(CmdOnPlayerTaunt, "taunt");
	AddCommandListener(CmdOnPlayerTaunt, "+taunt");
	AddCommandListener(CmdOnPlayerTaunt, "use_action_slot_item_server");
	AddCommandListener(CmdOnPlayerTaunt, "+use_action_slot_item_server");

	AddCommandListener(CmdOnPlayerKill, "kill");
	AddCommandListener(CmdOnPlayerKill, "explode");

	ConVar_HostTimescale = FindConVar("host_timescale");
	ConVar_PhysTimescale = FindConVar("phys_timescale");
	ConVar_ServerGravity = FindConVar("sv_gravity");
	ConVar_TFCheapObjects = FindConVar("tf_cheapobjects");
	ConVar_TFFastBuild = FindConVar("tf_fastbuild");
	ConVar_FriendlyFire = FindConVar("mp_friendlyfire");

	RegAdminCmd("mtf2_setnextspr", CmdSetNextSpecialRound, ADMFLAG_VOTE, "Force a Special Round after this round!");
	RegAdminCmd("mtf2_changespr", CmdChangeSpecialRound, ADMFLAG_VOTE, "Changes the current special round. If less than 0, or not found, Normal Gamemode is run. Otherwise, Special Round.");

	RegAdminCmd("mtf2_setgamemode", CmdSetGamemode, ADMFLAG_VOTE, "Sets the current gamemode.");

	ConVar_MTF2MaxRounds = CreateConVar("mtf2_maxrounds", "4", "Sets the maximum rounds to be played. 0 = no limit (not recommended).", FCVAR_PLUGIN, true, 0.0);

	if (ConVar_MTF2MaxRounds != INVALID_HANDLE)
	{
		HookConVarChange(ConVar_MTF2MaxRounds, OnMaxRoundsChanged);
	}
}

stock ResetConVars()
{
	ResetConVar(ConVar_HostTimescale);
	ResetConVar(ConVar_PhysTimescale);
	ResetConVar(ConVar_ServerGravity);
	ResetConVar(ConVar_TFCheapObjects);
	ResetConVar(ConVar_TFFastBuild);
	
	// Non-Exclusive ConVars
	// Server ConVars
	ResetConVar(FindConVar("sv_cheats"));
	SetConVarInt(FindConVar("sv_use_steam_voice"), 0);

#if defined NEW_HUD
	ResetConVar(FindConVar("sv_parallel_packentities"));
#endif

	// Multiplayer ConVars
	ResetConVar(FindConVar("mp_stalemate_enable"));
	ResetConVar(ConVar_FriendlyFire);
	ResetConVar(FindConVar("mp_waitingforplayers_time"));
	ResetConVar(FindConVar("mp_disable_respawn_times"));
	ResetConVar(FindConVar("mp_respawnwavetime"));
	ResetConVar(FindConVar("mp_timelimit"));
	ResetConVar(FindConVar("mp_forcecamera"));

	// TeamFortress ConVars
	ResetConVar(FindConVar("tf_avoidteammates_pushaway"));
	ResetConVar(FindConVar("tf_max_health_boost"));

	new Handle:conVar = FindConVar("sm_mapvote_extend");
	if (conVar != INVALID_HANDLE)
	{
		ResetConVar(conVar);
	}

	conVar = FindConVar("sm_umc_vc_extend");
	if (conVar != INVALID_HANDLE)
	{
		ResetConVar(conVar);
	}
}

stock PrepareConVars()
{
	// Server ConVars	
	SetConVarInt(FindConVar("sv_cheats"), 1);
	SetConVarInt(FindConVar("sv_use_steam_voice"), 1);

	// Multiplayer ConVars
	SetConVarInt(FindConVar("mp_stalemate_enable"), 0);
	SetConVarInt(FindConVar("mp_friendlyfire"), 1);
	SetConVarInt(FindConVar("mp_waitingforplayers_time"), 90);
	SetConVarInt(FindConVar("mp_disable_respawn_times"), 0);
	SetConVarInt(FindConVar("mp_respawnwavetime"), 9999);
	SetConVarInt(FindConVar("mp_timelimit"), 0);
	SetConVarInt(FindConVar("mp_forcecamera"), 0);

	// TeamFortress ConVars
	SetConVarInt(FindConVar("tf_avoidteammates_pushaway"), 0);
	SetConVarFloat(FindConVar("tf_max_health_boost"), 1.0);

	// ConVars with Handles
	SetConVarInt(ConVar_ServerGravity, 800);

	SetConVarFloat(ConVar_HostTimescale, 1.0);
	SetConVarFloat(ConVar_PhysTimescale, 1.0);

	new Handle:conVar = FindConVar("sm_mapvote_extend");
	if (conVar != INVALID_HANDLE)
	{
		SetConVarInt(conVar, 0);
	}

	conVar = FindConVar("sm_umc_vc_extend");
	if (conVar != INVALID_HANDLE)
	{
		SetConVarInt(conVar, 0);
	}

#if defined NEW_HUD
	SetConVarInt(FindConVar("sv_parallel_packentities"), 0);
#endif
}

public Action:CmdOnPlayerTaunt(client, const String:command[], args)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Client num #%d CmdOnPlayerTaunt. IsBlockingTaunts: %s", client, IsBlockingTaunts ? "True": "False");
	#endif

	return (IsBlockingTaunts ? Plugin_Handled : Plugin_Continue);
}

public Action:CmdOnPlayerKill(client, const String:command[], args)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Client num #%d CmdOnPlayerKill. IsBlockingTaunts: %s", client, IsBlockingTaunts ? "True": "False");
	#endif

	return (IsBlockingDeaths ? Plugin_Handled : Plugin_Continue);
}

public Action:CmdSetNextSpecialRound(client, args)
{
	decl String:text[10];
	GetCmdArg(1, text, sizeof(text));

	new id = StringToInt(text);

	if (id >= SPR_MIN && id <= SPR_MAX)
	{
		ForceNextSpecialRound = true;
		ForceSpecialRound = id;

		ReplyToCommand(client, "Next Special Round set.");
	}
	else
	{
		ReplyToCommand(client, "Unable to set Next Special Round.");
	}
}

public Action:CmdChangeSpecialRound(client, args)
{
	decl String:text[10];
	GetCmdArg(1, text, sizeof(text));

	new id = StringToInt(text);

	if (id >= SPR_MIN && id <= SPR_MAX)
	{
		GamemodeID = SPR_GAMEMODEID;
		SpecialRoundID = id;
	}
	else
	{
		GamemodeID = 0;
	}
}

public Action:CmdSetGamemode(client, args)
{
	decl String:text[10];
	GetCmdArg(1, text, sizeof(text));

	new id = StringToInt(text);

	if (id < TOTAL_GAMEMODES)
	{
		GamemodeID = id;

		ReplyToCommand(client, "Gamemode set to %s.", SystemNames[GamemodeID]);
	}
	else
	{
		ReplyToCommand(client, "Unable to set gamemode.");
	}
}


public OnMaxRoundsChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new value = StringToInt(newVal);

	MaxRounds = value;
}