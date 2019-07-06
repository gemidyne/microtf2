/**
 * MicroTF2 - Commands.inc
 * 
 * Implements functionality for commands and convars.
 */

#include <sourcemod>

stock void InitializeCommands()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Commands_OnMapStart);

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

	RegAdminCmd("sm_setnextspecialround", CmdSetNextSpecialRound, ADMFLAG_VOTE, "Force a Special Round after this round!");
	
	RegAdminCmd("sm_changespecialround", CmdChangeSpecialRound, ADMFLAG_VOTE, "Changes the current special round. If less than 0, or not found, Normal Gamemode is run. Otherwise, Special Round.");
	RegAdminCmd("sm_changegamemode", CmdSetGamemode, ADMFLAG_VOTE, "Sets the current gamemode.");

	RegAdminCmd("sm_triggerboss", CmdTriggerBoss, ADMFLAG_VOTE, "Triggers the boss round.");

	ConVar_MTF2MaxRounds = CreateConVar("mtf2_maxrounds", "4", "Sets the maximum rounds to be played. 0 = no limit (not recommended).", 0, true, 0.0);
	ConVar_MTF2IntermissionEnabled = CreateConVar("mtf2_intermission_enabled", "1", "Controls whether or not intermission is to be held half way through the maximum round count. Having Intermission enabled assumes you have a intermission integration enabled - for example the SourceMod Mapchooser integration.", 0, true, 0.0, true, 1.0);

	// Debug cvars/cmds
	ConVar_MTF2ForceMinigame = CreateConVar("mtf2_debug_forceminigame", "0", "Forces a minigame to always be played. If 0, no minigame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
	ConVar_MTF2ForceBossgame = CreateConVar("mtf2_debug_forcebossgame", "0", "Forces a bossgame to always be played. If 0, no bossgame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
	ConVar_MTF2ForceBossgameThreshold = CreateConVar("mtf2_debug_forcebossgamethreshold", "0", "Forces a threshold to always be played. If 0, no bossgame will be forced. This cvar is used only when debugging.", 0, true, 0.0);

	if (ConVar_MTF2MaxRounds != INVALID_HANDLE)
	{
		HookConVarChange(ConVar_MTF2MaxRounds, OnMaxRoundsChanged);
	}
}

public void Commands_OnMapStart()
{
	PrepareConVars();
}

stock void ResetConVars()
{
	ResetConVar(ConVar_HostTimescale);
	ResetConVar(ConVar_PhysTimescale);
	ResetConVar(ConVar_ServerGravity);
	ResetConVar(ConVar_TFCheapObjects);
	ResetConVar(ConVar_TFFastBuild);
	ResetConVar(ConVar_MTF2ForceMinigame);
	ResetConVar(ConVar_MTF2ForceBossgame);
	
	// Non-Exclusive ConVars
	// Server ConVars
	ResetConVar(FindConVar("sv_cheats"));
	SetConVarInt(FindConVar("sv_use_steam_voice"), 0);

	// Multiplayer ConVars
	ResetConVar(FindConVar("mp_stalemate_enable"));
	ResetConVar(ConVar_FriendlyFire);
	ResetConVar(FindConVar("mp_waitingforplayers_time"));
	ResetConVar(FindConVar("mp_disable_respawn_times"));
	ResetConVar(FindConVar("mp_respawnwavetime"));
	ResetConVar(FindConVar("mp_timelimit"));
	ResetConVar(FindConVar("mp_forcecamera"));
	ResetConVar(FindConVar("mp_idlemaxtime"));

	// TeamFortress ConVars
	ResetConVar(FindConVar("tf_avoidteammates_pushaway"));
	ResetConVar(FindConVar("tf_max_health_boost"));
	ResetConVar(FindConVar("tf_airblast_cray_ground_minz"));
	ResetConVar(FindConVar("tf_player_movement_restart_freeze"));

	Handle conVar = FindConVar("sm_mapvote_extend");
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

stock void PrepareConVars()
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
	SetConVarInt(FindConVar("mp_idlemaxtime"), 8);

	// TeamFortress ConVars
	SetConVarInt(FindConVar("tf_avoidteammates_pushaway"), 0);
	SetConVarFloat(FindConVar("tf_max_health_boost"), 1.0);
	SetConVarInt(ConVar_TFFastBuild, 0);
	SetConVarFloat(FindConVar("tf_airblast_cray_ground_minz"), 268.3281572999747);
	SetConVarInt(FindConVar("tf_player_movement_restart_freeze"), 0);

	// ConVars with Handles
	SetConVarInt(ConVar_ServerGravity, 800);

	SetConVarFloat(ConVar_HostTimescale, 1.0);
	SetConVarFloat(ConVar_PhysTimescale, 1.0);

	Handle conVar = FindConVar("sm_mapvote_extend");
	if (conVar != INVALID_HANDLE)
	{
		SetConVarInt(conVar, 0);
	}

	conVar = FindConVar("sm_umc_vc_extend");
	if (conVar != INVALID_HANDLE)
	{
		SetConVarInt(conVar, 0);
	}
}

public Action CmdOnPlayerTaunt(int client, const char[] command, int args)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToServer("[WWDBG] Client num #%d CmdOnPlayerTaunt. IsBlockingTaunts: %s", client, IsBlockingTaunts ? "True": "False");
	#endif

	return (IsBlockingTaunts ? Plugin_Handled : Plugin_Continue);
}

public Action CmdOnPlayerKill(int client, const char[] command, int args)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToServer("[WWDBG] Client num #%d CmdOnPlayerKill. IsBlockingTaunts: %s", client, IsBlockingTaunts ? "True": "False");
	#endif

	return (IsBlockingDeathCommands ? Plugin_Handled : Plugin_Continue);
}

public Action CmdSetNextSpecialRound(int client, int args)
{
	char text[10];
	GetCmdArg(1, text, sizeof(text));

	int id = StringToInt(text);

	if (id >= SPR_MIN && id <= SPR_MAX)
	{
		ForceNextSpecialRound = true;
		ForceSpecialRound = id;

		ReplyToCommand(client, "%sThe next special round has been set as #%i.", PLUGIN_PREFIX, id);
	}
	else
	{
		ReplyToCommand(client, "%sError: special round number is outside of min and max range. Specified ID: %i", PLUGIN_PREFIX, id);
	}
}

public Action CmdChangeSpecialRound(int client, int args)
{
	char text[10];
	GetCmdArg(1, text, sizeof(text));

	int id = StringToInt(text);

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

public Action CmdSetGamemode(int client, int args)
{
	char text[10];
	GetCmdArg(1, text, sizeof(text));

	int id = StringToInt(text);

	if (id < TOTAL_GAMEMODES)
	{
		GamemodeID = id;

		ReplyToCommand(client, "[ WarioWare ] Gamemode set to %s.", SystemNames[GamemodeID]);

		PluginForward_SendGamemodeChanged(id);
	}
	else
	{
		ReplyToCommand(client, "[ WarioWare ] Unable to set gamemode, invalid value specified.");
	}
}

public Action CmdTriggerBoss(int client, int args)
{
	MinigamesPlayed = BossGameThreshold-1;

	ReplyToCommand(client, "[ WarioWare ] Triggering boss...");
}

public void OnMaxRoundsChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	int value = StringToInt(newVal);

	MaxRounds = value;
}