/**
 * MicroTF2 - Events.inc
 * 
 * Implements event functionality for the gamemode & minigames
 */

public void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
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
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Handled;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.RemoveWearables();

		if (g_bIsGameOver)
		{
			player.SetThirdPersonMode(true);
							
			TF2_StunPlayer(player.ClientId, 8.0, 0.0, TF_STUNFLAGS_LOSERSTATE, 0);
			player.SetHealth(1);
		}
		else if (!g_bIsGameOver)
		{
			player.SetGodMode(true);
		}
		else if (g_iMinigamesPlayedCount == 999 || !g_bIsPlayerParticipant[client])
		{
			player.SetGodMode(false);
		}

		player.ResetWeapon(false);

		if (g_pfOnPlayerSpawn != INVALID_HANDLE)
		{
			Call_StartForward(g_pfOnPlayerSpawn);
			Call_PushCell(client);
			Call_Finish();
		}

		if (g_bIsMinigameActive && !player.IsParticipating && g_iSpecialRoundId != 17)
		{
			//Someone joined during a Minigame, & isn't a Participant, so lets notify them.
			player.PrintChatText("%T", "System_PlayerSpawn_RespawnNotice", player.ClientId);
		}
	}

	return Plugin_Continue;
}

public void Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	Player player = new Player(client);

	if (player.IsInGame)
	{
		player.IsParticipating = false;
		player.Status = PlayerStatus_NotWon;
	}
}

public Action Event_Regenerate(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Handled;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, Timer_LockerWeaponReset, GetClientUserId(client));

	return Plugin_Handled;
}

public Action Timer_LockerWeaponReset(Handle timer, int userid)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Handled;
	}

	int client = GetClientOfUserId(userid);
	Player player = new Player(client);

	if (player.IsValid && !g_bIsMinigameActive && !g_bIsGameOver)
	{
		player.RemoveWearables();
		player.ResetWeapon(false);
	}

	return Plugin_Handled;
}

public void Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client))
	{
		if (g_bIsMinigameActive)
		{
			if (g_bIsPlayerParticipant[client])
			{
				if (g_pfOnPlayerDeath != INVALID_HANDLE)
				{
					int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

					Call_StartForward(g_pfOnPlayerDeath);
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
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (g_pfOnPlayerHurt != INVALID_HANDLE && g_bIsPlayerParticipant[client] && g_bIsPlayerParticipant[attacker])
	{
		Call_StartForward(g_pfOnPlayerHurt);
		Call_PushCell(client);
		Call_PushCell(attacker);
		Call_Finish();
	}
}

public void Event_PlayerBuiltObject(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int entity = GetEventInt(event, "index");

	if (g_pfOnBuildObject != INVALID_HANDLE && g_bIsPlayerParticipant[client])
	{
		Call_StartForward(g_pfOnBuildObject);
		Call_PushCell(client);
		Call_PushCell(entity);
		Call_Finish();
	}
}

public void Event_PlayerStickyJump(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (g_pfOnStickyJump != INVALID_HANDLE && g_bIsPlayerParticipant[client])
	{
		Call_StartForward(g_pfOnStickyJump);
		Call_PushCell(client);
		Call_Finish();
	}
}

public Action Event_PlayerJarated(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	int client = BfReadByte(bf);
	int victim = BfReadByte(bf);

	if (g_pfOnPlayerJarated != INVALID_HANDLE && g_bIsPlayerParticipant[client] && g_bIsPlayerParticipant[victim])
	{
		Call_StartForward(g_pfOnPlayerJarated);
		Call_PushCell(client);
		Call_PushCell(victim);
		Call_Finish();
	}

	return Plugin_Continue;
}

public void Event_PlayerRocketJump(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (g_pfOnRocketJump != INVALID_HANDLE && g_bIsPlayerParticipant[client])
	{
		Call_StartForward(g_pfOnRocketJump);
		Call_PushCell(client);
		Call_Finish();
	}
}

public void Event_PropBroken(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (g_pfOnPropBroken != INVALID_HANDLE && g_bIsPlayerParticipant[client])
	{
		Call_StartForward(g_pfOnPropBroken);
		Call_PushCell(client);
		Call_Finish();
	}
}

public void Event_PlayerChangeClass(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int newClass = GetEventInt(event, "class");

	if (g_pfOnPlayerClassChange != INVALID_HANDLE && g_bIsPlayerParticipant[client])
	{
		Call_StartForward(g_pfOnPlayerClassChange);
		Call_PushCell(client);
		Call_PushCell(newClass);
		Call_Finish();
	}
}

public void Event_PlayerStunned(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	int stunner = GetClientOfUserId(GetEventInt(event, "stunner"));
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));

	if (g_pfOnPlayerStunned != INVALID_HANDLE && g_bIsPlayerParticipant[stunner] && g_bIsPlayerParticipant[victim])
	{
		Call_StartForward(g_pfOnPlayerStunned);
		Call_PushCell(stunner);
		Call_PushCell(victim);
		Call_Finish();
	}
}

public void Event_PlayerSappedObject(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	Player attacker = new Player(GetClientOfUserId(GetEventInt(event, "userid")));
	Player buildingOwner = new Player(GetClientOfUserId(GetEventInt(event, "ownerid")));

	if (g_pfOnPlayerSappedObject != INVALID_HANDLE && attacker.IsParticipating && buildingOwner.IsParticipating)
	{
		Call_StartForward(g_pfOnPlayerSappedObject);
		Call_PushCell(attacker.ClientId);
		Call_PushCell(buildingOwner.ClientId);
		Call_Finish();
	}
}

public void Event_PlayerHealed(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	Player target = new Player(GetClientOfUserId(GetEventInt(event, "patient")));
	Player owner = new Player(GetClientOfUserId(GetEventInt(event, "healer")));

	if (g_pfOnPlayerHealed != INVALID_HANDLE && target.IsParticipating && owner.IsParticipating)
	{
		Call_StartForward(g_pfOnPlayerHealed);
		Call_PushCell(target.ClientId);
		Call_PushCell(owner.ClientId);
		Call_Finish();
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_bIsPluginEnabled)
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

	if (g_pfOnPlayerRunCmd != INVALID_HANDLE && player.IsValid && player.IsParticipating)
	{
		Call_StartForward(g_pfOnPlayerRunCmd);
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
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (g_pfOnTfRoundStart != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnTfRoundStart);
		Call_Finish();
	}

	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (g_eGamemodeStatus != GameStatus_WaitingForPlayers)
	{
		g_bIsMapEnding = true;
		g_fActiveGameSpeed = 1.0;
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	if (!g_bAllowCosmetics && StrEqual(classname, "tf_wearable"))
	{
		// Delay is present so m_ModelName is set 
		CreateTimer(0.1, Timer_HatRemove, entity);
	}
	else
	{
		if (g_pfOnEntityCreated != INVALID_HANDLE)
		{
			Call_StartForward(g_pfOnEntityCreated);
			Call_PushCell(entity);
			Call_PushString(classname);
			Call_Finish();
		}
	}
}

public Action Timer_HatRemove(Handle timer, int entity)
{
	if (!g_bIsPluginEnabled || g_bAllowCosmetics)
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
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	bool isCosmeticItem = StrEqual(classname, "tf_wearable", false) || StrEqual(classname, "tf_wearable_demoshield", false) || StrEqual(classname, "tf_powerup_bottle", false) || StrEqual(classname, "tf_weapon_spellbook", false);

	if (!g_bAllowCosmetics && isCosmeticItem) 
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void OnGameFrame()
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	if (g_pfOnGameFrame != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnGameFrame);
		Call_Finish();
	}

	if (GameRules_GetRoundState() == RoundState_Pregame && g_eGamemodeStatus != GameStatus_WaitingForPlayers)
	{
		g_eGamemodeStatus = GameStatus_WaitingForPlayers;
	}
}

public void TF2_OnWaitingForPlayersStart()
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	ResetGamemode();
}

public void TF2_OnWaitingForPlayersEnd()
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	PrepareConVars();

	g_eGamemodeStatus = GameStatus_Tutorial;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame)
		{
			if (!player.IsBot)
			{
				StopSoundEx(i, SYSBGM_WAITING);
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
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	if (g_pfOnPlayerConditionAdded != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnPlayerConditionAdded);
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
			TFCond_CritCola,
			TFCond_HalloweenCritCandy:
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
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	if (g_pfOnPlayerConditionRemoved != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnPlayerConditionRemoved);
		Call_PushCell(client);
		Call_PushCell(view_as<int>(condition));
		Call_Finish();
	}
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (IsChatTrigger())
	{
		return Plugin_Continue;
	}

	if (g_pfOnPlayerChatMessage != INVALID_HANDLE)
	{
		Action result;

		Call_StartForward(g_pfOnPlayerChatMessage);
		Call_PushCell(client);
		Call_PushString(sArgs);
		Call_PushCell(strcmp(command, "say_team", false));
		Call_Finish(result);

		return result;
	}

	return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
	if (!g_bIsPluginEnabled)
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
		
			if (g_eGamemodeStatus == GameStatus_WaitingForPlayers)
			{
				player.DisplayOverlay(OVERLAY_WELCOME);
				PlaySoundToPlayer(client, SYSBGM_WAITING);
			}
		}

		if (g_eGamemodeStatus != GameStatus_WaitingForPlayers && g_iSpecialRoundId == 9)
		{
			player.Score = 4;
			player.Status = PlayerStatus_NotWon;
		}

		if (g_iSpecialRoundId != 17)
		{
			player.IsParticipating = true;
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!g_bIsPluginEnabled)
	{
		return;
	}

	AttachPlayerHooks(client);
}

public void OnClientDisconnect(int client)
{
	if (!g_bIsPluginEnabled)
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
	HookEvent("player_healed", Event_PlayerHealed);
	HookUserMessage(GetUserMessageId("PlayerJarated"), Event_PlayerJarated);
}

public void OnQueryClientConVarCallback(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (StrEqual(cvarName, "mat_dxlevel"))
	{
		int dxLevel = StringToInt(cvarValue);

		g_bIsPlayerUsingLegacyDirectX[client] = dxLevel == 80 || dxLevel == 81;
	}
}
