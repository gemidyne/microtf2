/**
 * MicroTF2 - ConVars.sp
 * 
 * Implements functionality for convars.
 */

ConVar g_hConVarServerCheats;
ConVar g_hConVarHostTimescale;
ConVar g_hConVarPhysTimescale;
ConVar g_hConVarServerGravity;
ConVar g_hConVarTFCheapObjects;
ConVar g_hConVarTFFastBuild;
ConVar g_hConVarTFWeaponSpreads;
ConVar g_hConVarFriendlyFire;
ConVar g_hConVarServerTimelimit;
ConVar g_hConVarAntiFloodTime;

// Plugin specific ConVars: 
ConVar g_hConVarPluginBonusPoints;
ConVar g_hConVarPluginAllowCosmetics;
ConVar g_hConVarPluginIntermissionEnabled;
ConVar g_hConVarPluginForceMinigame;
ConVar g_hConVarPluginForceBossgame;
ConVar g_hConVarPluginForceBossgameThreshold;
ConVar g_hConVarPluginMaxRounds;

void InitializeConVars()
{
	AddToForward(g_pfOnConfigsExecuted, INVALID_HANDLE, PrepareConVars);

	g_hConVarServerCheats = FindConVar("sv_cheats");
	g_hConVarHostTimescale = FindConVar("host_timescale");
	g_hConVarPhysTimescale = FindConVar("phys_timescale");

	g_hConVarServerGravity = FindConVar("sv_gravity");
	g_hConVarTFCheapObjects = FindConVar("tf_cheapobjects");
	g_hConVarTFFastBuild = FindConVar("tf_fastbuild");
	g_hConVarTFWeaponSpreads = FindConVar("tf_use_fixed_weaponspreads");
	g_hConVarFriendlyFire = FindConVar("mp_friendlyfire");
	g_hConVarServerTimelimit = FindConVar("mp_timelimit");
	g_hConVarAntiFloodTime = FindConVar("sm_flood_time");

	g_hConVarPluginMaxRounds = CreateConVar("mtf2_maxrounds", "4", "Sets the maximum rounds to be played. 0 = no limit (not recommended).", 0, true, 0.0);
	g_hConVarPluginIntermissionEnabled = CreateConVar("mtf2_intermission_enabled", "1", "Controls whether or not intermission is to be held half way through the maximum round count. Having Intermission enabled assumes you have a intermission integration enabled - for example the SourceMod Mapchooser integration.", 0, true, 0.0, true, 1.0);
	g_hConVarPluginBonusPoints = CreateConVar("mtf2_bonuspoints", "0", "Controls whether or not minigames should have a bonus point.", 0, true, 0.0, true, 1.0);
	g_hConVarPluginAllowCosmetics = CreateConVar("mtf2_cosmetics_enabled", "0", "Allows cosmetics to be worn by players. NOTE: This mode is explicitly not supported and may cause visual bugs and possible server lag spikes.", 0, true, 0.0, true, 1.0);

	if (g_hConVarPluginMaxRounds != INVALID_HANDLE)
	{
		HookConVarChange(g_hConVarPluginMaxRounds, OnMaxRoundsChanged);
	}

	if (g_hConVarPluginAllowCosmetics != INVALID_HANDLE)
	{
		HookConVarChange(g_hConVarPluginAllowCosmetics, OnAllowCosmeticsChanged);
	}

	// Debugging ConVars / Commands. You don't really want these set all the time.
	g_hConVarPluginForceMinigame = CreateConVar("mtf2_debug_forceminigame", "0", "Forces a minigame to always be played. If 0, no minigame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
	g_hConVarPluginForceBossgame = CreateConVar("mtf2_debug_forcebossgame", "0", "Forces a bossgame to always be played. If 0, no bossgame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
	g_hConVarPluginForceBossgameThreshold = CreateConVar("mtf2_debug_forcebossgamethreshold", "0", "Forces a threshold to always be played. If 0, no bossgame will be forced. This cvar is used only when debugging.", 0, true, 0.0);
}

void ResetConVars()
{
	g_hConVarHostTimescale.RestoreDefault();
	g_hConVarPhysTimescale.RestoreDefault();
	g_hConVarServerGravity.RestoreDefault();	
	g_hConVarTFCheapObjects.RestoreDefault();
	g_hConVarTFFastBuild.RestoreDefault();
	g_hConVarTFWeaponSpreads.RestoreDefault();
	g_hConVarFriendlyFire.RestoreDefault();

	// Debugging: 
	g_hConVarPluginForceMinigame.RestoreDefault();
	g_hConVarPluginForceBossgame.RestoreDefault();
	
	// Non-Exclusive ConVars
	// Server ConVars
	SetConVarInt(FindConVar("sv_use_steam_voice"), 0);

	// Multiplayer ConVars
	ResetConVar(FindConVar("mp_stalemate_enable"));
	ResetConVar(FindConVar("mp_waitingforplayers_time"));
	ResetConVar(FindConVar("mp_disable_respawn_times"));
	ResetConVar(FindConVar("mp_respawnwavetime"));
	ResetConVar(FindConVar("mp_forcecamera"));
	ResetConVar(FindConVar("mp_idlemaxtime"));

	// TeamFortress ConVars
	ResetConVar(FindConVar("tf_avoidteammates_pushaway"));
	ResetConVar(FindConVar("tf_max_health_boost"));
	ResetConVar(FindConVar("tf_airblast_cray_ground_minz"));
	ResetConVar(FindConVar("tf_player_movement_restart_freeze"));

	ConVar conVar = FindConVar("sm_mapvote_extend");
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

void PrepareConVars()
{
	// Server ConVars	
	SetConVarInt(FindConVar("sv_use_steam_voice"), 1);

	// Multiplayer ConVars
	SetConVarInt(FindConVar("mp_stalemate_enable"), 0);
	SetConVarInt(FindConVar("mp_friendlyfire"), 1);
	SetConVarInt(FindConVar("mp_waitingforplayers_time"), 90);
	SetConVarInt(FindConVar("mp_disable_respawn_times"), 0);
	SetConVarInt(FindConVar("mp_respawnwavetime"), 9999);
	SetConVarInt(FindConVar("mp_forcecamera"), 0);
	SetConVarInt(FindConVar("mp_idlemaxtime"), 8);
	SetConVarInt(FindConVar("tf_avoidteammates_pushaway"), 0);
	SetConVarFloat(FindConVar("tf_max_health_boost"), 1.0);
	SetConVarFloat(FindConVar("tf_airblast_cray_ground_minz"), 268.3281572999747);
	SetConVarInt(FindConVar("tf_player_movement_restart_freeze"), 0);

	g_hConVarTFFastBuild.BoolValue = false;
	g_hConVarTFWeaponSpreads.BoolValue = true;

	g_hConVarServerGravity.IntValue = 800;
	g_hConVarHostTimescale.FloatValue = 1.0;
	g_hConVarPhysTimescale.FloatValue = 1.0;

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

public void OnMaxRoundsChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	int value = StringToInt(newVal);

	g_iMaxRoundsPlayable = value;
}

public void OnAllowCosmeticsChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	int value = StringToInt(newVal);

	g_bAllowCosmetics = value == 1;
}

public bool Config_BonusPointsEnabled()
{
	return g_hConVarPluginBonusPoints.BoolValue;
}