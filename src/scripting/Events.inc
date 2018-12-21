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
		
		if (IsClientValid(client))
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

	if (IsClientValid(client))
	{
		RemovePlayerWearables(client);

		if (!IsBonusRound)
		{
			IsGodModeEnabled(client, true);
		}
		else if (MinigamesPlayed == 999 || !IsPlayerParticipant[client])
		{
			IsGodModeEnabled(client, false);
		}

		ResetWeapon(client, false);
		SetupSPR(client);

		if (IsMinigameActive && !IsPlayerParticipant[client] && SpecialRoundID != 17)
		{
			//Someone joined during a Minigame, & isn't a Participant, so lets notify them.
			CPrintToChat(client, "%s%T", PLUGIN_PREFIX, "PlayerSpawn_RespawnNotice", client);
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
	if (IsClientValid(client) && !IsMinigameActive && !IsBonusRound)
	{
		RemovePlayerWearables(client);
		ResetWeapon(client, false);
	}

	return Plugin_Handled;
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Handled;
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

	return Plugin_Handled;
}

public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Handled;
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

	return Plugin_Handled;
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

	if (GlobalForward_OnPlayerClassChange != INVALID_HANDLE && IsPlayerParticipant[client])
	{
		Call_StartForward(GlobalForward_OnPlayerClassChange);
		Call_PushCell(client);
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

public Action Hook_GameSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	bool isVoiceSound = StrContains(sample, "vo/scout_", false) != -1 
		|| StrContains(sample, "vo/soldier_", false) != -1 
		|| StrContains(sample, "vo/pyro_", false) != -1 
		|| StrContains(sample, "vo/demoman_", false) != -1 
		|| StrContains(sample, "vo/heavy_", false) != -1 
		|| StrContains(sample, "vo/engineer_", false) != -1 
		|| StrContains(sample, "vo/medic_", false) != -1 
		|| StrContains(sample, "vo/sniper_", false) != -1 
		|| StrContains(sample, "vo/spy_", false) != -1
		|| StrContains(sample, "stsv/soundmods/", false) != -1;

	bool isBlockedSound = StrContains(sample, "rocket_pack_boosters_fire", false) != -1
		|| StrContains(sample, "rocket_pack_boosters_loop", false) != -1
		|| StrContains(sample, "grenade_jump", false) != -1;

	if (isBlockedSound)
	{
		return Plugin_Stop;
	}

	if (SpecialRoundID == 14 || SpecialRoundID == 15)
	{
		if (isVoiceSound)
		{
			pitch = (SpecialRoundID == 14 ? SNDPITCH_HIGH : SNDPITCH_LOW);
			return Plugin_Changed;
		}
	}
	else
	{
		if (isVoiceSound)
		{
			pitch = GetSoundMultiplier();
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
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
	
	result = false;
	return Plugin_Changed;
}


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (GlobalForward_OnPlayerRunCmd != INVALID_HANDLE)
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

	if (StrEqual(classname, "tf_wearable"))
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
	if (!IsPluginEnabled)
	{
		return Plugin_Handled;
	}

	if (IsValidEdict(entity))
	{
		//Hook transmit
		//Unless it's a The Razorback, Darwin's Danger Shield or Gunboats
		char sModel[256];

		GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

		if(!( StrContains(sModel, "croc_shield") != -1 
			|| StrContains(sModel, "c_rocketboots_soldier") != -1
			|| StrContains(sModel, "knife_shield") != -1 ))
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

public Action Client_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (GlobalForward_OnPlayerTakeDamage != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnPlayerTakeDamage);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_PushFloat(damage);
		Call_Finish();
	}

	if (IsOnlyBlockingDamageByPlayers && IsClientValid(attacker) && IsPlayerParticipant[attacker])
	{
		damage = 0.0;
		
		if (inflictor < 0) 
		{
			inflictor = 0;
		}

		return Plugin_Changed;
	}

	if (IsBlockingDamage || (IsBonusRound && IsPlayerWinner[attacker] == 0))
	{
		damage = 0.0;

		if (inflictor < 0) 
		{
			inflictor = 0;
		}
		
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (StrEqual(classname, "tf_wearable", false) || StrEqual(classname, "tf_wearable_demoshield", false) || StrEqual(classname, "tf_powerup_bottle", false) || StrEqual(classname, "tf_weapon_spellbook", false))
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

	bool isCurrentlyPlaying = (IsMinigameActive && GamemodeStatus == GameStatus_Playing && (MinigameID > 0 || BossgameID > 0));
	bool isCurrentlyInTutorial = (GamemodeStatus == GameStatus_Tutorial);
	bool isCurrentlyInGameOver = (GamemodeStatus == GameStatus_Playing && !IsMinigameActive && MinigamesPlayed == 0);
	bool canUpdateHudText = (isCurrentlyPlaying || isCurrentlyInTutorial || isCurrentlyInGameOver);

	if (canUpdateHudText)
	{
		g_iCenterHudUpdateFrame++;
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

	if (g_iCenterHudUpdateFrame > g_iCenterHudUpdateInterval)
	{
		if (canUpdateHudText)
		{
			SetHudTextParamsEx(-1.0, 0.2, 1.0, { 255, 255, 255, 255 }, { 0, 0, 0, 0 }, 2, 0.0, 0.0, 0.0);
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientValid(i))
				{
					char buffer[MINIGAME_CAPTION_LENGTH];
					Format(buffer, sizeof(buffer), MinigameCaption[i]);

					if (SpecialRoundID == 19)
					{
						char rewritten[MINIGAME_CAPTION_LENGTH];
						int rc = 0;
						int len = strlen(buffer);

						for (int c = len - 1; c >= 0; c--)
						{
							rewritten[rc] = buffer[c];
							rc++;
						}

						strcopy(buffer, sizeof(buffer), rewritten);
					}

					if (strlen(buffer) > 0)	
					{	
						ShowSyncHudText(i, HudSync_Caption, buffer);	
					}	
					else	
					{	
						ClearSyncHud(i, HudSync_Caption);	
					}
				}
			}

			g_iCenterHudUpdateFrame = 0;
		}
	}

	#if defined DEBUG
	if (GamemodeStatus != GameStatus_WaitingForPlayers && g_iCenterHudUpdateFrame > g_iCenterHudUpdateInterval)
	{
		PrintHintTextToAll("MinigameID: %i\nBossgameID: %i\nSpecialRoundID: %i\nMinigamesPlayed: %i\nSpeedLevel: %.1f", MinigameID, BossgameID, SpecialRoundID, MinigamesPlayed, SpeedLevel);

		g_iCenterHudUpdateFrame = 0;
	}
	#endif
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
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
			{
				StopSound(i, SNDCHAN_AUTO, SYSMUSIC_WAITINGFORPLAYERS);
			}

			IsPlayerParticipant[i] = true;
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
			TFCond_Taunting:
		{
			removeCondition = false;
		}
	}

	if (removeCondition)
	{
		TF2_RemoveCondition(client, condition);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (IsClientInGame(client))
	{
		if (!IsFakeClient(client))
		{
			SendConVarValue(client, FindConVar("sv_cheats"), "1");
		
			if (GamemodeStatus == GameStatus_WaitingForPlayers)
			{
				DisplayOverlayToClient(client, OVERLAY_WELCOME);
				EmitSoundToClient(client, SYSMUSIC_WAITINGFORPLAYERS);
			}
		}

		if (GamemodeStatus != GameStatus_WaitingForPlayers && SpecialRoundID == 9)
		{
			PlayerScore[client] = 4;
			PlayerStatus[client] = PlayerStatus_NotWon;
		}

		if (SpecialRoundID != 17)
		{
			IsPlayerParticipant[client] = true;
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	SDKHook(client, SDKHook_OnTakeDamage, Client_TakeDamage);
	SDKHook(client, SDKHook_Touch, Special_NoTouch);
	SecuritySystem_OnClientPutInServer(client);
}

public void OnClientDisconnect(int client)
{
	if (!IsPluginEnabled)
	{
		return;
	}

	if (IsClientInGame(client))
	{
		PlayerScore[client] = 0;
		PlayerStatus[client] = PlayerStatus_NotWon;

		SDKUnhook(client, SDKHook_OnTakeDamage, Client_TakeDamage);
		SDKUnhook(client, SDKHook_Touch, Special_NoTouch);
	}
}

stock void HookEvents()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_PostNoCopy);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("sticky_jump", Event_PlayerStickyJump);
	HookEvent("rocket_jump", Event_PlayerRocketJump);
	HookEvent("player_builtobject", Event_PlayerBuiltObject);
	HookEvent("player_changeclass", Event_PlayerChangeClass);
	HookEvent("player_stunned", Event_PlayerStunned);
	HookEvent("break_prop", Event_PropBroken);
	HookEvent("teamplay_round_stalemate", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_win", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("post_inventory_application", Event_Regenerate, EventHookMode_Post);
	HookUserMessage(GetUserMessageId("PlayerJarated"), Event_PlayerJarated);
}