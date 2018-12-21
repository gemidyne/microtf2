/**
 * MicroTF2 - Stocks.inc
 * 
 * Contains alot of Stocks for use in Minigames / Other stuff
 */

stock bool IsClientValid(int client)
{
	if (client <= 0 || client > MaxClients)
	{
		return false;
	}

	if (!IsClientInGame(client))
	{
		return false;
	}

	int team = GetClientTeam(client);

	return team == 2 || team == 3;
}

stock void DisplayOverlayToClient(int client, const char[] path)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
		ClientCommand(client, "r_screenoverlay \"%s\"", path);
		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (FCVAR_CHEAT));
	}
}

stock void DisplayOverlayToAll(const char[] path)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		DisplayOverlayToClient(i, path);
	}
}

stock void SetPlayerHealth(int client, int health)
{
	if (IsClientInGame(client))
	{
		int maxHealthOffset = FindDataMapInfo(client, "m_iMaxHealth");
		int healthOffset = FindDataMapInfo(client, "m_iHealth");

		if (maxHealthOffset == -1 || healthOffset == -1)
		{
			SetFailState("Failed to find m_iMaxHealth / m_iHealth on CTFPlayer.");
		}

		SetEntData(client, maxHealthOffset, health, 4, true);
		SetEntData(client, healthOffset, health, 4, true);
	}
}

stock void IsViewModelVisible(int client, bool visible)
{
	return;

	// if (IsClientInGame(client) && !IsFakeClient(client))
	// {
	// 	int weaponOffset = FindSendPropOffs("CTFPlayer", "m_hActiveWeapon");

	// 	if (weaponOffset <= 0)
	// 	{
	// 		SetFailState("Unable to find m_hActiveWeapon offset on CTFPlayer.");
	// 	}

	// 	int weapon = GetEntDataEnt2(client, weaponOffset);

	// 	if (IsValidEntity(weapon))
	// 	{
	// 		SetEntityRenderColor(weapon, 255, 255, 255, (visible ? 255 : 0));
	// 		SetEntityRenderMode(weapon, (visible ? RENDER_NORMAL : RENDER_TRANSCOLOR));
	// 		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", (visible ? 1 : 0));
	// 	}
	// }
}

stock void IsGodModeEnabled(int client, bool enabled)
{
	if (IsClientInGame(client))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", enabled ? 0 : 2, 1);
	}
}

stock void IsPlayerCollisionsEnabled(int client, bool enabled)
{
	if (IsClientInGame(client))
	{
		SetEntData(client, Offset_Collision, enabled ? 5 : 2, 4, true);
	}
}

stock void RemovePlayerWearables(int client)
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		AcceptEntityInput(entity, "kill");
	}

	entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_wearable_demoshield")) != -1)
	{
		AcceptEntityInput(entity, "kill");
	}

	entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_powerup_bottle")) != -1)
	{
		AcceptEntityInput(entity, "kill");
	}
	
	entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_weapon_spellbook")) != -1)
	{
		AcceptEntityInput(entity, "kill");
	}

	int edict = (MaxClients + 1);
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if ((idx == 57 || idx == 133 || idx == 231 || idx == 444 || idx == 405) && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				RemoveEdict(edict);
			}
		}
	}

	edict = (MaxClients + 1);
	while ((edict = FindEntityByClassname2(edict, "tf_wearable_demoshield")) != -1)
	{
		int idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
		if ((idx == 131 || idx == 406) && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
		{
			RemoveEdict(edict);
		}
	}
}

stock void ResetWeapon(int client, bool viewModel)
{
	if (IsClientInGame(client))
	{
		if (TF2_IsPlayerInCondition(client, TFCond_Taunting))
		{
			TF2_RemoveCondition(client, TFCond_Taunting);
		}

		int weapon = 0;
		int weaponID = -1;
		int newWeaponID = 0;

		for (int i = 0; i <= 5; i++)
		{
			weapon = GetPlayerWeaponSlot(client, i);

			if (i != 2)
			{
				TF2_RemoveWeaponSlot(client, i);
				continue;
			}
			
			if (weapon != -1)
			{
				weaponID = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			}
			else
			{
				weaponID = -1;
			}
			
			switch (TF2_GetPlayerClass(client))
			{
				case TFClass_Scout: newWeaponID = 0;
				case TFClass_Soldier: newWeaponID = 6;
				case TFClass_Pyro: newWeaponID = 2;
				case TFClass_DemoMan: newWeaponID = 1;
				case TFClass_Heavy: newWeaponID = 5;
				case TFClass_Engineer: newWeaponID = 7;
				case TFClass_Medic: newWeaponID = 8;
				case TFClass_Sniper: newWeaponID = 3;
				case TFClass_Spy: newWeaponID = 4;
			}

			if (weaponID != newWeaponID)
			{
				GiveWeapon(client, newWeaponID);
			}
		}

		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, 2));

		IsViewModelVisible(client, viewModel);
	}
}

stock void ResetHealth(int client)
{
	if (IsClientInGame(client))
	{
		TFClassType class = TF2_GetPlayerClass(client);
		int health = 125;

		switch (class)
		{
			case TFClass_Soldier: health = 200;
			case TFClass_Pyro: health = 175;
			case TFClass_DemoMan: health = 175;
			case TFClass_Heavy: health = 300;
			case TFClass_Medic: health = 150;
		}

		SetPlayerHealth(client, health);
	}
}

stock void ChooseRandomClass(int client)
{
	if (IsClientInGame(client))
	{
		switch (GetRandomInt(0, 8))
		{
			case 0: TF2_SetPlayerClass(client, TFClass_Scout);
			case 1: TF2_SetPlayerClass(client, TFClass_Soldier);
			case 2: TF2_SetPlayerClass(client, TFClass_Pyro);
			case 3: TF2_SetPlayerClass(client, TFClass_DemoMan);
			case 4: TF2_SetPlayerClass(client, TFClass_Heavy);
			case 5: TF2_SetPlayerClass(client, TFClass_Engineer);
			case 6: TF2_SetPlayerClass(client, TFClass_Medic);
			case 7: TF2_SetPlayerClass(client, TFClass_Sniper);
			case 8: TF2_SetPlayerClass(client, TFClass_Spy);
		}
	}
}

stock void PlaySoundToPlayer(int client, const char[] sound)
{
	if (IsClientInGame(client) && !IsFakeClient(client) && !IsMapEnding)
	{
		EmitSoundToClient(client, sound, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
	}
}

stock void PlaySoundToAll(const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		PlaySoundToPlayer(i, sound);
	}
}

public Action Timer_Respawn(Handle timer, int client)
{
	if (IsClientValid(client) && IsPlayerParticipant[client])
	{
		TF2_RespawnPlayer(client);
	}
}

stock void ClientWonMinigame(int client)
{
	if (IsClientValid(client) && PlayerStatus[client] == PlayerStatus_NotWon && IsPlayerParticipant[client])
	{
		PlayerStatus[client] = PlayerStatus_Winner;
		EmitSoundToAll(SYSFX_WINNER, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());

		int i = GetRandomInt(0, 5);
		char colours[6][32] = { "Micro_Win_Blue", "Micro_Win_Green", "Micro_Win_Purple", "Micro_Win_Rainbow", "Micro_Win_Red", "Micro_Win_Yellow" };
		char particle[128];

		particle = colours[i];

		CreateParticle(client, particle, 4.0);
	}
}

stock void ResizePlayer(int client, float fScale = 1.0)
{
	float fCurrent = GetEntPropFloat(client, Prop_Send, "m_flModelScale");

	if (fCurrent == fScale || fScale == 0.0) 
	{
		return;
	}

	SetEntPropFloat(client, Prop_Send, "m_flModelScale", fScale);
}

stock void ShowAnnotation(int client, float lifetime, const char[] text)
{
	int bitfield = BuildBitStringExcludingClient(client);

	ShowAnnotationWithBitfield(client, lifetime, text, bitfield);
}

stock void ShowAnnotationWithBitfield(int client, float lifetime, const char[] text, int bitfield)
{
	Handle event = CreateEvent("show_annotation");

	if (event == INVALID_HANDLE)
	{
		return;
	}

	if (g_iAnnotationEventId > 100000)
	{
		// This shouldn't really happen...
		g_iAnnotationEventId = 0;
	}

	//https://forums.alliedmods.net/showpost.php?p=1996379&postcount=14
	SetEventInt(event, "id", g_iAnnotationEventId);
	SetEventInt(event, "follow_entindex", client);
	SetEventFloat(event, "lifetime", lifetime);
	SetEventString(event, "text", text);
	SetEventString(event, "play_sound", "misc/null.wav");
	SetEventBool(event, "show_effect", true);
	SetEventInt(event, "visibilityBitfield", bitfield);
	FireEvent(event);
	
	g_iAnnotationEventId++;
}

public int BuildBitStringExcludingClient(int client)
{
	int bitfield = 0;

	// Iterating through all clients to build a visibility bitfield of all alive players
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && i != client)
		{
			// 1-based
			bitfield |= (1 << i);
		}
	}

	return bitfield;
}

public void AddClientToBitString(int bitfield, int client)
{
	bitfield |= (1 << client);
}

stock void SetPlayerAmmo(int client, int ammoCount)
{
	int weaponHandleId = FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon");

	if (weaponHandleId <= 0)
	{
		return;
	}

	int entity = GetEntDataEnt2(client, weaponHandleId);

	if (!IsValidEntity(entity)) 
	{
		return;
	}

	int ammoType = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	int ammo = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	int clip = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");

	if (ammo <= 0)
	{
		return;
	}

	if (clip <= 0)
	{
		return;
	}

	SetEntData(entity, clip, ammoCount, 4, true);
	SetEntData(client, ammoType+ammo, ammoCount, 4, true);
}

stock void DestroyPlayerSentryGun(int client, bool cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		TryDestroyPlayerBuilding(client, cleanDestroy, "obj_sentrygun");
	}
}

stock void DestroyPlayerDispenser(int client, bool cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		TryDestroyPlayerBuilding(client, cleanDestroy, "obj_dispenser");
	}
}

stock void DestroyPlayerTeleporterEntrance(int client, bool cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		TryDestroyPlayerBuilding(client, cleanDestroy, "obj_teleporter", TFObjectMode_Entrance);
	}
}

stock void DestroyPlayerTeleporterExit(int client, bool cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		TryDestroyPlayerBuilding(client, cleanDestroy, "obj_teleporter", TFObjectMode_Exit);
	}
}

stock void TryDestroyPlayerBuilding(int client, bool cleanDestroy, char[] entityClassname, TFObjectMode objectMode = TFObjectMode_None)
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, entityClassname)) != INVALID_ENT_REFERENCE)
	{
		if (GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client && (objectMode == TFObjectMode_None || TF2_GetObjectMode(entity) == objectMode))
		{
			if (cleanDestroy)
			{
				AcceptEntityInput(entity, "Kill");
			}
			else
			{
				SetVariantInt(1000);
				AcceptEntityInput(entity, "RemoveHealth");
			}
		}
	}
}

stock void DestroyPlayerBuildings(int client, bool cleanDestroy = false)
{
	DestroyPlayerSentryGun(client, cleanDestroy);
	DestroyPlayerDispenser(client, cleanDestroy);
	DestroyPlayerTeleporterEntrance(client, cleanDestroy);
	DestroyPlayerTeleporterExit(client, cleanDestroy);
}

stock void RemoveAllStunballEntities()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_stun_ball")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

stock void RemoveAllJarateEntities()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_jar")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

stock void DisplayHudMessage(const char[] title, const char[] body, float duration)
{
	char formatted[MINIGAME_CAPTION_LENGTH];

	Format(formatted, sizeof(formatted), "%s\n%s", title, body);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, formatted);
		}
	}
}

stock void DisplayHudMessageToClient(int client, const char[] title, const char[] body, float duration)
{
	char formatted[MINIGAME_CAPTION_LENGTH];

	Format(formatted, sizeof(formatted), "%s\n%s", title, body);

	strcopy(MinigameCaption[client], MINIGAME_CAPTION_LENGTH, formatted);
}

// Credit to authors of SMLIB. Moved here due to the include file not building on newer spcomp, also converted to new syntax
stock void ToUpperString(const char[] input, char[] output, int size)
{
	size--;

	int x = 0;

	while (input[x] != '\0' && x < size) 
	{
		output[x] = CharToUpper(input[x]);
		x++;
	}

	output[x] = '\0';
}

stock bool IsStringInt(const char arg[64])
{
    if (StringToInt(arg) != 0) return true;
    if (StrEqual(arg, "0")) return true;
	
    return false;
}

public int GetClientAimEntity3(int client, float &distancetoentity, float endpos[3])	//Snippet by Javalia
{
	float cleyepos[3];
	float cleyeangle[3];

	GetClientEyePosition(client, cleyepos);
	GetClientEyeAngles(client, cleyeangle);

	Handle traceresulthandle = INVALID_HANDLE;
	traceresulthandle = TR_TraceRayFilterEx(cleyepos, cleyeangle, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfOrPlayers, client);

	if (TR_DidHit(traceresulthandle) == true)
	{
		TR_GetEndPosition(endpos, traceresulthandle);
		distancetoentity = GetVectorDistance(cleyepos, endpos);
		int entindextoreturn = TR_GetEntityIndex(traceresulthandle);
		CloseHandle(traceresulthandle);
		return entindextoreturn;
	}

	CloseHandle(traceresulthandle);
	return -1;
}

public bool TraceRayDontHitSelfOrPlayers(int entity, int mask, int data)
{
	return (entity != data && !IsClientValid(entity));
}

public float GetSpeedMultiplier(float count)
{
    float divide = ((SpeedLevel-1.0)/7.5)+1.0;
    float speed = count / divide;
    return speed;
}