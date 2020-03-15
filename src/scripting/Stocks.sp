/**
 * MicroTF2 - Stocks.inc
 * 
 * Contains alot of Stocks for use in Minigames / Other stuff
 */

stock void DisplayOverlayToAll(const char[] path)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			player.DisplayOverlay(path);
		}
	}
}

stock void ResetWeapon(int client, bool viewModel)
{
	Player player = new Player(client);

	if (player.IsInGame)
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

		if (SpecialRoundID != 12)
		{
			player.SetWeaponVisible(viewModel);
			player.SetViewModelVisible(viewModel);
		}
	}
}

stock void PlaySoundToPlayer(int client, const char[] sound)
{
	Player player = new Player(client);

	if (player.IsInGame && !player.IsBot && !IsMapEnding)
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
	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		player.Respawn();
	}
}

stock void ClientWonMinigame(int client)
{
	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating && player.Status == PlayerStatus_NotWon)
	{
		player.Status = PlayerStatus_Winner;

		if (ActiveParticipantCount > 12)
		{
			EmitSoundToClient(client, SYSFX_WINNER, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
		}
		else
		{
			EmitSoundToAll(SYSFX_WINNER, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
		}

		if (player.Team == TFTeam_Blue)
		{
			CreateParticle(client, "Micro_Win_Blue", 6.0);
		}
		else if (player.Team == TFTeam_Red)
		{
			CreateParticle(client, "Micro_Win_Red", 6.0);
		}
	}
}

stock void ShowAnnotation(int client, int attachToEntity, float lifetime, char text[32])
{
	int bitfield = BuildBitStringExcludingClient(attachToEntity);

	ShowAnnotationWithBitfield(client, attachToEntity, lifetime, text, bitfield);
}

stock void ShowAnnotationWithBitfield(int client, int attachToEntity, float lifetime, char text[32], int bitfield)
{
	Event event = CreateEvent("show_annotation");

	if (event == INVALID_HANDLE)
	{
		return;
	}

	if (g_iAnnotationEventId > 9999)
	{
		g_iAnnotationEventId = 0;
	}

	if (SpecialRoundID == 19)
	{
		char rewritten[32];
		int rc = 0;
		int len = strlen(text);

		for (int c = len - 1; c >= 0; c--)
		{
			if (text[c] == '\0')
			{
				continue;
			}

			rewritten[rc] = text[c];
			rc++;
		}

		strcopy(text, sizeof(text), rewritten);
	}

	//https://forums.alliedmods.net/showpost.php?p=1996379&postcount=14
	event.SetInt("id", g_iAnnotationEventId);
	event.SetInt("follow_entindex", attachToEntity);
	event.SetFloat("lifetime", lifetime);
	event.SetString("text", text);
	event.SetString("play_sound", "misc/null.wav");
	event.SetBool("show_effect", false);
	event.SetInt("visibilityBitfield", bitfield);
	event.FireToClient(client);
	event.Cancel();	//Free the handle memory
	
	g_iAnnotationEventId++;
}

public int BuildBitStringExcludingClient(int client)
{
	int bitfield = 0;

	// Iterating through all clients to build a visibility bitfield of all alive players
	for (int i = 1; i <= MaxClients; i++)
	{
		if (client == i) 
		{
			continue;
		}

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
	Player player = new Player(entity);

	return (entity != data && !player.IsValid);
}

public float GetSpeedMultiplier(float count)
{
    float divide = ((SpeedLevel-1.0)/7.5)+1.0;
    float speed = count / divide;
    return speed;
}

stock void GetEntityPosition(int entity, float position[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
}

stock float NormalizeAngle(float angle)
{
	angle -= RoundToFloor(angle / 360.0) * 360.0;
	
	if (angle > 180)
	{
		angle -= 360;
	}
    
	if (angle < -180)
	{
		angle += 360;
	}

	return angle;
}