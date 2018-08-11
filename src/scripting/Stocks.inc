/**
 * MicroTF2 - Stocks.inc
 * 
 * Contains alot of Stocks for use in Minigames / Other stuff
 */

stock IsClientValid(client)
{
	if (client <= 0 || client > MaxClients)
	{
		return false;
	}

	if (!IsClientInGame(client))
	{
		return false;
	}

	if (IsFakeClient(client))
	{
		return false;
	}

	new team = GetClientTeam(client);

	if (team == 2 || team == 3)
	{
		return true;
	}
	else
	{
		return false;
	}
}

stock DisplayOverlayToClient(client, const String:path[])
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
		ClientCommand(client, "r_screenoverlay \"%s\"", path);
		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (FCVAR_CHEAT));
	}
}

stock DisplayOverlayToAll(const String:path[])
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			DisplayOverlayToClient(i, path);
		}
	}
}

stock void SetPlayerHealth(int client, int health)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
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

stock IsGodModeEnabled(client, bool:enabled)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", enabled ? 0 : 2, 1);
	}
}

stock IsPlayerCollisionsEnabled(client, bool:enabled)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		SetEntData(client, Offset_Collision, enabled ? 5 : 2, 4, true);
	}
}

stock RemovePlayerWearables(client)
{
	new entity = -1;
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

	new edict = (MaxClients + 1);
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		decl String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if ((idx == 57 || idx == 133 || idx == 231 || idx == 444 || idx == 405) && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				RemoveEdict(edict);
			}
		}
	}

	edict = (MaxClients + 1);
	while ((edict = FindEntityByClassname2(edict, "tf_wearable_demoshield")) != -1)
	{
		new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
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

		new weapon = 0;
		new weaponID = -1;
		new newWeaponID = 0;

		for (new i = 0; i <= 5; i++)
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

stock ResetHealth(client)
{
	if (IsClientInGame(client))
	{
		new TFClassType:class = TF2_GetPlayerClass(client);
		new health = 125;

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

stock ChooseRandomClass(client)
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

stock PlaySoundToPlayer(client, const String:sound[])
{
	if (IsClientInGame(client) && !IsFakeClient(client) && !IsMapEnding)
	{
		EmitSoundToClient(client, sound, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
	}
}

stock PlaySoundToAll(const String:sound[])
{
	for (new i = 1; i <= MaxClients; i++)
	{
		PlaySoundToPlayer(i, sound);
	}
}

public Action:Timer_Respawn(Handle:timer, any:client)
{
	if (IsClientValid(client) && IsPlayerParticipant[client])
	{
		TF2_RespawnPlayer(client);
	}
}

stock ClientWonMinigame(client)
{
	if (IsClientValid(client) && PlayerStatus[client] == PlayerStatus_NotWon && IsPlayerParticipant[client])
	{
		PlayerStatus[client] = PlayerStatus_Winner;
		EmitSoundToAll(SYSFX_WINNER, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());

		new i = GetRandomInt(0, 5);
		new String:colours[6][32] = { "Micro_Win_Blue", "Micro_Win_Green", "Micro_Win_Purple", "Micro_Win_Rainbow", "Micro_Win_Red", "Micro_Win_Yellow" };
		new String:particle[128];

		particle = colours[i];

		CreateParticle(client, particle, 4.0);
	}
}

stock ResizePlayer(client, Float:fScale = 1.0)
{
	new Float:fCurrent = GetEntPropFloat(client, Prop_Send, "m_flModelScale");

	if (fCurrent == fScale || fScale == 0.0) 
	{
		return;
	}

	SetEntPropFloat(client, Prop_Send, "m_flModelScale", fScale);
}

new _annotationEventId = 0;
stock ShowAnnotation(client, Float:lifetime, const String:text[])
{
	new bitfield = BuildBitStringExcludingClient(client);
	ShowAnnotationWithBitfield(client, lifetime, text, bitfield);
}

stock ShowAnnotationWithBitfield(client, Float:lifetime, const String:text[], bitfield)
{
	new Handle:event = CreateEvent("show_annotation");
	if (event == INVALID_HANDLE)
	{
		return;
	}

	if (_annotationEventId > 100000)
	{
		// This shouldn't really happen...
		_annotationEventId = 0;
	}

	//https://forums.alliedmods.net/showpost.php?p=1996379&postcount=14
	SetEventInt(event, "id", _annotationEventId);
	SetEventInt(event, "follow_entindex", client);
	SetEventFloat(event, "lifetime", lifetime);
	SetEventString(event, "text", text);
	SetEventString(event, "play_sound", "misc/null.wav");
	SetEventBool(event, "show_effect", true);
	SetEventInt(event, "visibilityBitfield", bitfield);
	FireEvent(event);
	
	_annotationEventId++;
}

public BuildBitStringExcludingClient(client)
{
	new bitfield = 0;

	// Iterating through all clients to build a visibility bitfield of all alive players
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && i != client)
		{
			// 1-based
			bitfield |= (1 << i);
		}
	}

	return bitfield;
}

public AddClientToBitString(bitfield, client)
{
	bitfield |= (1 << client);
}

stock SetPlayerAmmo(client, ammoCount)
{
	new activeweapon = FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon");

	if (activeweapon <= 0)
	{
		return;
	}

	new entity = GetEntDataEnt2(client, activeweapon);

	if (!IsValidEntity(entity)) 
	{
		return;
	}

	new ammotype = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	new ammo = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	new clip = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");

	if (ammo <= 0)
	{
		return;
	}

	if (clip <= 0)
	{
		return;
	}

	SetEntData(entity, clip, ammoCount, 4, true);
	SetEntData(client, ammotype+ammo, ammoCount, 4, true);
}

stock DestroyPlayerSentryGun(client, bool:cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		new iEnt = -1;
		while ((iEnt = FindEntityByClassname(iEnt, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client)
			{
				if (cleanDestroy)
				{
					AcceptEntityInput(iEnt, "Kill");
				}
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
	}
}

stock DestroyPlayerDispenser(client, bool:cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		new iEnt = -1;
		while ((iEnt = FindEntityByClassname(iEnt, "obj_dispenser")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client)
			{
				if (cleanDestroy)
				{
					AcceptEntityInput(iEnt, "Kill");
				}
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
	}
}

stock DestroyPlayerTeleporterEntrance(client, bool:cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		new iEnt = -1;
		while ((iEnt = FindEntityByClassname(iEnt, "obj_teleporter")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client && TF2_GetObjectMode(iEnt) == TFObjectMode_Entrance)
			{
				if (cleanDestroy)
				{
					AcceptEntityInput(iEnt, "Kill");
				}
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
	}
}

stock DestroyPlayerTeleporterExit(client, bool:cleanDestroy = false)
{
	if (IsClientInGame(client))
	{
		new iEnt = -1;
		while ((iEnt = FindEntityByClassname(iEnt, "obj_teleporter")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntPropEnt(iEnt, Prop_Send, "m_hBuilder") == client && TF2_GetObjectMode(iEnt) == TFObjectMode_Exit)
			{
				if (cleanDestroy)
				{
					AcceptEntityInput(iEnt, "Kill");
				}
				else
				{
					SetVariantInt(1000);
					AcceptEntityInput(iEnt, "RemoveHealth");
				}
			}
		}
	}
}

stock DestroyPlayerBuildings(client, bool:cleanDestroy = false)
{
	DestroyPlayerSentryGun(client, cleanDestroy);
	DestroyPlayerDispenser(client, cleanDestroy);
	DestroyPlayerTeleporterEntrance(client, cleanDestroy);
	DestroyPlayerTeleporterExit(client, cleanDestroy);
}

stock RemoveAllStunballEntities()
{
	new iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_projectile_stun_ball")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(iEnt, "Kill");
	}
}

stock RemoveAllJarateEntities()
{
	new iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_projectile_jar")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(iEnt, "Kill");
	}
}

stock DisplayHudMessage(const String:title[], const String:body[], Float:duration)
{
#if defined NEW_HUD
	if (SpecialRoundID == 19)
	{
		new String:rewrittenTitle[MINIGAME_CAPTION_LENGTH];
		new String:rewrittenBody[MINIGAME_CAPTION_LENGTH];

		// Rewrite title
		new rc = 0;
		new len = strlen(title);

		for (new c = len - 1; c >= 0; c--)
		{
			rewrittenTitle[rc] = title[c];
			rc++;
		}

		// Rewrite body
		rc = 0;
		len = strlen(body);

		for (new c = len - 1; c >= 0; c--)
		{
			rewrittenBody[rc] = body[c];
			rc++;
		}

		TrainingMessage(rewrittenTitle, rewrittenBody, duration);
	}
	else
	{
		TrainingMessage(title, body, duration);
	}
#else
	
#endif
}

stock DisplayHudMessageToClient(client, const String:title[], const String:body[], Float:duration)
{
#if defined NEW_HUD
	if (SpecialRoundID == 19)
	{
		new String:rewrittenTitle[MINIGAME_CAPTION_LENGTH];
		new String:rewrittenBody[MINIGAME_CAPTION_LENGTH];

		// Rewrite title
		new rc = 0;
		new len = strlen(title);

		for (new c = len - 1; c >= 0; c--)
		{
			rewrittenTitle[rc] = title[c];
			rc++;
		}

		// Rewrite body
		rc = 0;
		len = strlen(body);

		for (new c = len - 1; c >= 0; c--)
		{
			rewrittenBody[rc] = body[c];
			rc++;
		}

		TrainingMessageToClient(client, rewrittenTitle, rewrittenBody, duration);
	}
	else
	{
		TrainingMessageToClient(client, title, body, duration);
	}
#else

#endif
}