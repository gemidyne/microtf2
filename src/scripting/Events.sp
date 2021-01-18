/**
 * MicroTF2 - Events.inc
 * 
 * Implements event functionality for the gamemode & minigames
 */

public void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (event != INVALID_HANDLE)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));

		Player player = new Player(client);
		
		if (player.IsValid)
		{
			CreateTimer(0.2, Timer_PlayerSpawn, client);
		}
	}
}

public Action Timer_PlayerSpawn(Handle timer, int client)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Handled;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.RemoveWearables();

		if (IsBonusRound)
		{
			player.SetThirdPersonMode(true);
							
			TF2_StunPlayer(player.ClientId, 8.0, 0.0, TF_STUNFLAGS_LOSERSTATE, 0);
			player.SetHealth(1);
		}
		else if (!IsBonusRound)
		{
			player.SetGodMode(true);
		}
		else if (MinigamesPlayed == 999 || !IsPlayerParticipant[client])
		{
			player.SetGodMode(false);
		}

		player.ResetWeapon(false);

		if (GlobalForward_OnPlayerSpawn != INVALID_HANDLE)
		{
			Call_StartForward(GlobalForward_OnPlayerSpawn);
			Call_PushCell(client);
			Call_Finish();
		}

		if (IsMinigameActive && !player.IsParticipating && SpecialRoundID != 17)
		{
			//Someone joined during a Minigame, & isn't a Participant, so lets notify them.
			CPrintToChat(client, "%s%T", PLUGIN_PREFIX, "System_PlayerSpawn_RespawnNotice", client);
		}
	}

	return Plugin_Continue;
}

public void Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsClientInGame(client))
	{
		IsPlayerParticipant[client] = false;
		PlayerStatus[client] = PlayerStatus_NotWon;
	}
}

public Action Event_Regenerate(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Handled;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, Timer_LockerWeaponReset, GetClientUserId(client));

	return Plugin_Handled;
}

public Action Timer_LockerWeaponReset(Handle timer, int userid)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Handled;
	}

	int client = GetClientOfUserId(userid);
	Player player = new Player(client);

	if (player.IsValid && !IsMinigameActive && !IsBonusRound)
	{
		player.RemoveWearables();
		player.ResetWeapon(false);
	}

	return Plugin_Handled;
}

public void Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client))
	{
		if (IsMinigameActive)
		{
			if (IsPlayerParticipant[client])
			{
				if (GlobalForward_OnPlayerDeath != INVALID_HANDLE)
				{
					int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

					Call_StartForward(GlobalForward_OnPlayerDeath);
					Call_PushCell(client);
					Call_PushCell(attacker);
					Call_Finish();
				}
			}
		}
		else
		{
			CreateTimer(0.05, Timer_Respawn, client);
		}
	}
}

public void Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (GlobalForward_OnPlayerHurt != INVALID_HANDLE && IsPlayerParticipant[client] && IsPlayerParticipant[attacker])
	{
		Call_StartForward(GlobalForward_OnPlayerHurt);
		Call_PushCell(client);
		Call_PushCell(attacker);
		Call_Finish();
	}
}

public void Event_PlayerBuiltObject(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int entity = GetEventInt(event, "index");

	if (GlobalForward_OnBuildObject != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnBuildObject);
		Call_PushCell(client);
		Call_PushCell(entity);
		Call_Finish();
	}
}

public void Event_PlayerStickyJump(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (GlobalForward_OnStickyJump != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnStickyJump);
		Call_PushCell(client);
		Call_Finish();
	}
}

public Action Event_PlayerJarated(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	int client = BfReadByte(bf);
	int victim = BfReadByte(bf);

	if (GlobalForward_OnPlayerJarated != INVALID_HANDLE && IsPlayerParticipant[client] && IsPlayerParticipant[victim])
	{
		Call_StartForward(GlobalForward_OnPlayerJarated);
		Call_PushCell(client);
		Call_PushCell(victim);
		Call_Finish();
	}

	return Plugin_Continue;
}

public void Event_PlayerRocketJump(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (GlobalForward_OnRocketJump != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnRocketJump);
		Call_PushCell(client);
		Call_Finish();
	}
}

public void Event_PropBroken(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (GlobalForward_OnPropBroken != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnPropBroken);
		Call_PushCell(client);
		Call_Finish();
	}
}

public void Event_PlayerChangeClass(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int newClass = GetEventInt(event, "class");

	if (GlobalForward_OnPlayerClassChange != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnPlayerClassChange);
		Call_PushCell(client);
		Call_PushCell(newClass);
		Call_Finish();
	}
}

public void Event_PlayerStunned(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	int stunner = GetClientOfUserId(GetEventInt(event, "stunner"));
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));

	if (GlobalForward_OnPlayerStunned != INVALID_HANDLE && IsPlayerParticipant[stunner] && IsPlayerParticipant[victim])
	{
		Call_StartForward(GlobalForward_OnPlayerStunned);
		Call_PushCell(stunner);
		Call_PushCell(victim);
		Call_Finish();
	}
}

public void Event_PlayerSappedObject(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	Player attacker = new Player(GetClientOfUserId(GetEventInt(event, "userid")));
	Player buildingOwner = new Player(GetClientOfUserId(GetEventInt(event, "ownerid")));

	if (GlobalForward_OnPlayerSappedObject != INVALID_HANDLE && attacker.IsParticipating && buildingOwner.IsParticipating)
	{
		Call_StartForward(GlobalForward_OnPlayerSappedObject);
		Call_PushCell(attacker.ClientId);
		Call_PushCell(buildingOwner.ClientId);
		Call_Finish();
	}
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (GlobalForward_OnPlayerCalculateCritical != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnPlayerCalculateCritical);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushString(weaponname);
		Call_Finish();
	}
	
	result = ForceCalculationCritical;
	return Plugin_Changed;
}


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	Player player = new Player(client);

	if (impulse != 0)
	{
		bool isSpray = impulse == 201;
		bool isCustomSnd = impulse == 202;
		bool isSpyDisguise = impulse >= 221 && impulse <= 239;

		if (!isSpray && !isCustomSnd && !isSpyDisguise)
		{
			impulse = 0;
		}
	}

	if (GlobalForward_OnPlayerRunCmd != INVALID_HANDLE && player.IsValid && player.IsParticipating)
	{
		Call_StartForward(GlobalForward_OnPlayerRunCmd);
		Call_PushCell(client);
		Call_PushCellRef(buttons);
		Call_PushCellRef(impulse);
		Call_PushArray(vel, 3);
		Call_PushArray(angles, 3);
		Call_PushCellRef(weapon);
		Call_Finish();
	}

	return Plugin_Continue;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (GlobalForward_OnTfRoundStart != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnTfRoundStart);
		Call_Finish();
	}

	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (GamemodeStatus != GameStatus_WaitingForPlayers)
	{
		IsMapEnding = true;
		SpeedLevel = 1.0;
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (!AllowCosmetics && StrEqual(classname, "tf_wearable"))
	{
		// Delay is present so m_ModelName is set 
		CreateTimer(0.1, Timer_HatRemove, entity);
	}
	else
	{
		if (GlobalForward_OnEntityCreated != INVALID_HANDLE)
		{
			Call_StartForward(GlobalForward_OnEntityCreated);
			Call_PushCell(entity);
			Call_PushString(classname);
			Call_Finish();
		}
	}
}

public Action Timer_HatRemove(Handle timer, int entity)
{
	if (!IsPluginEnabled || AllowCosmetics)
	{
		return Plugin_Handled;
	}

	if (IsValidEdict(entity))
	{
		//Hook transmit
		//Unless it's a The Razorback, Darwin's Danger Shield or Gunboats
		char model[256];

		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));

		bool excluded = StrContains(model, "croc_shield") != -1 
			|| StrContains(model, "c_rocketboots_soldier") != -1
			|| StrContains(model, "knife_shield") != -1;

		if (!excluded)
		{
			SDKHook(entity, SDKHook_SetTransmit, Transmit_HatRemove);
		}
	}

	return Plugin_Handled;
}

public Action Transmit_HatRemove(int entity, int client)
{
	return Plugin_Handled;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	bool isCosmeticItem = StrEqual(classname, "tf_wearable", false) || StrEqual(classname, "tf_wearable_demoshield", false) || StrEqual(classname, "tf_powerup_bottle", false) || StrEqual(classname, "tf_weapon_spellbook", false);

	if (!AllowCosmetics && isCosmeticItem) 
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void OnGameFrame()
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (GlobalForward_OnGameFrame != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnGameFrame);
		Call_Finish();
	}

	if (GameRules_GetRoundState() == RoundState_Pregame && GamemodeStatus != GameStatus_WaitingForPlayers)
	{
		GamemodeStatus = GameStatus_WaitingForPlayers;
	}
}

public void TF2_OnWaitingForPlayersStart()
{
	if (!IsPluginEnabled)
	{
		return;
	}

	ResetGamemode();
}

public void TF2_OnWaitingForPlayersEnd()
{
	if (!IsPluginEnabled)
	{
		return;
	}

	PrepareConVars();

	GamemodeStatus = GameStatus_Tutorial;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			if (!player.IsBot)
			{
				StopSound(i, SNDCHAN_AUTO, SYSBGM_WAITING);
			}

			player.IsParticipating = true;
		}
	}

	#if defined DEBUG
	PrintCenterTextAll("DEBUG MODE active. Plugin events will be logged");
	#endif

	CreateTimer(0.1, Timer_GameLogic_EngineInitialisation);
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (GlobalForward_OnPlayerConditionAdded != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnPlayerConditionAdded);
		Call_PushCell(client);
		Call_PushCell(view_as<int>(condition));
		Call_Finish();
	}

	bool removeCondition = true;

	switch (condition)
	{
		case 
			TFCond_Slowed,
			TFCond_Zoomed,
			TFCond_Jarated, 
			TFCond_Kritzkrieged, 
			TFCond_Bonked, 
			TFCond_Dazed, 
			TFCond_Taunting,
			TFCond_Bleeding,
			TFCond_RuneHaste,
			TFCond_CritCola:
		{
			removeCondition = false;
		}
	}

	if (removeCondition)
	{
		TF2_RemoveCondition(client, condition);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (GlobalForward_OnPlayerConditionRemoved != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnPlayerConditionRemoved);
		Call_PushCell(client);
		Call_PushCell(view_as<int>(condition));
		Call_Finish();
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsInGame)
	{
		if (!player.IsBot)
		{
			SendConVarValue(client, FindConVar("sv_cheats"), "1");
			QueryClientConVar(client, "mat_dxlevel", OnQueryClientConVarCallback);
		
			if (GamemodeStatus == GameStatus_WaitingForPlayers)
			{
				player.DisplayOverlay(OVERLAY_WELCOME);
				EmitSoundToClient(client, SYSBGM_WAITING);
			}
		}

		if (GamemodeStatus != GameStatus_WaitingForPlayers && SpecialRoundID == 9)
		{
			player.Score = 4;
			player.Status = PlayerStatus_NotWon;
		}

		if (SpecialRoundID != 17)
		{
			player.IsParticipating = true;
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	AttachPlayerHooks(client);
}

public void OnClientDisconnect(int client)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsInGame)
	{
		player.Score = 0;
		player.Status = PlayerStatus_NotWon;
		player.IsUsingLegacyDirectX = false;
		player.SetCaption("");

		DetachPlayerHooks(player.ClientId);
	}
}

stock void HookEvents()
{
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_PostNoCopy);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("sticky_jump", Event_PlayerStickyJump);
	HookEvent("rocket_jump", Event_PlayerRocketJump);
	HookEvent("player_builtobject", Event_PlayerBuiltObject);
	HookEvent("player_changeclass", Event_PlayerChangeClass);
	HookEvent("player_stunned", Event_PlayerStunned);
	HookEvent("break_prop", Event_PropBroken);
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_stalemate", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_win", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("post_inventory_application", Event_Regenerate, EventHookMode_Post);
	HookEvent("player_sapped_object", Event_PlayerSappedObject);
	HookUserMessage(GetUserMessageId("PlayerJarated"), Event_PlayerJarated);
}

public void OnQueryClientConVarCallback(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (StrEqual(cvarName, "mat_dxlevel"))
	{
		int dxLevel = StringToInt(cvarValue);
		
		IsPlayerUsingLegacyDirectX[client] = dxLevel == 80 || dxLevel == 81;
	}
}
