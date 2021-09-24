/**
 * MicroTF2 - MinigameStocks.inc
 * 
 * Provides stocks for use in some minigames.
 */

stock int CreatePropEntity(float position[3], char[] modelPath, int health, float duration = 4.0, bool enablePhysics = true)
{
	int entity = enablePhysics 
		? CreateEntityByName("prop_physics_override") 
		: CreateEntityByName("prop_dynamic_override");
	
	if (IsValidEntity(entity))
	{
		DispatchKeyValue(entity, "model", modelPath);

		DispatchKeyValue(entity, "disableshadows", "1");
		DispatchKeyValue(entity, "disablereceiveshadows", "1");
		DispatchKeyValue(entity, "massScale", "70");
		
		DispatchSpawn(entity);
		
		SetEntProp(entity, Prop_Data, "m_takedamage", 2); 
		
		DispatchKeyValue(entity, "Solid", "6");
		
		SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 5);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 16);
	
		SetEntityMoveType(entity, MOVETYPE_VPHYSICS);
		
		AcceptEntityInput(entity, "DisableCollision");
		AcceptEntityInput(entity, "EnableCollision");
		
		SetEntityRenderColor(entity, 255, 255, 255, 255);
		
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		
		TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);
		
		if (duration > 0.0) 
		{
			CreateTimer(duration, Timer_RemoveEntity, entity);
		}
	}

	return entity;
}

stock void CreateParticle(int client, const char[] effect, float time, bool attachToHead = false) 
{  
	int entity = CreateEntityByName("info_particle_system");

	if (IsValidEntity(entity)) 
	{
		float position[3];
		char name[128];

		GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
		TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);
        
		Format(name, sizeof(name), "target%i", client);
		DispatchKeyValue(client, "targetname", name);
        
		DispatchKeyValue(entity, "targetname", "tf2particle");
		DispatchKeyValue(entity, "parentname", name);
		DispatchKeyValue(entity, "effect_name", effect);
		DispatchSpawn(entity);

		SetVariantString(name);
		AcceptEntityInput(entity, "SetParent", entity, entity, 0);

		if (attachToHead) 
		{
			SetVariantString("head");
			AcceptEntityInput(entity, "SetParentAttachment", entity, entity, 0);
		}

		ActivateEntity(entity);
		AcceptEntityInput(entity, "start");
        
		CreateTimer(time, Timer_RemoveEntity, entity);
	}
}

stock int CreateGlow(int target, int color[4] = {255, 255, 255, 255}, float duration)
{
	// Credit to Drixevel for this. Original version @ https://github.com/Drixevel/SM-Resources/blob/master/includes/misc-tf.inc
	char classname[64];
	GetEntityClassname(target, classname, sizeof(classname));

	char targetName[128];
	Format(targetName, sizeof(targetName), "%s%i", classname, target);
	DispatchKeyValue(target, "targetname", targetName);

	int entity = CreateEntityByName("tf_glow");

	if (IsValidEntity(entity))
	{
		char colour[64];
		Format(colour, sizeof(colour), "%i %i %i %i", color[0], color[1], color[2], color[3]);

		DispatchKeyValue(entity, "target", targetName);
		DispatchKeyValue(entity, "Mode", "1"); //Mode is currently broken.
		DispatchKeyValue(entity, "GlowColor", colour);
		DispatchSpawn(entity);
		
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target, entity);
		AcceptEntityInput(entity, "Enable");

		// We don't want to leak; so remove after this time
		CreateTimer(duration, Timer_RemoveEntity, entity);
	}

	return entity;
}

public Action Timer_RemoveEntity(Handle timer, int entity) 
{
    if (IsValidEntity(entity)) 
	{
        AcceptEntityInput(entity, "Kill");
    }

    return Plugin_Stop;
}

public Action Timer_RemoveBossOverlay(Handle timer)
{
	DisplayOverlayToAll(OVERLAY_BLANK);

	for (int i = 1; i <= MaxClients; i++)
	{
		SetCaption(i, "");
	}

	return Plugin_Handled;
}

public Action Timer_CheckBossEnd(Handle timer, int client)
{ 
	if (g_eGamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	if (g_bIsMinigameActive && g_iActiveBossgameId > 0)
	{
		if (g_pfOnBossStopAttempt != INVALID_HANDLE)
		{
			Call_StartForward(g_pfOnBossStopAttempt);
			Call_Finish();
		}

		g_hBossCheckTimer = CreateTimer(2.5, Timer_CheckBossEnd);
	}

	return Plugin_Handled;
}

public void EndBoss()
{
	if (g_bIsMinigameActive && g_iActiveBossgameId > 0 && g_iActiveMinigameId == 0)
	{
		g_hConVarFriendlyFire.BoolValue = true;

		if (g_iMinigamesPlayedCount != g_iBossGameThreshold)
		{
			g_fActiveGameSpeed = 1.0;
			g_iMinigamesPlayedCount = 999;
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame)
			{
                for (int a = 0; a < 10; a++)
                {
                    StopSoundEx(i, g_sBossgameBgm[g_iActiveBossgameId]);
                }

                if (player.IsParticipating)
                {
					player.Respawn();
				}
			}
		}

		if (g_hActiveGameTimer != INVALID_HANDLE)
		{
			KillTimer(g_hActiveGameTimer);
			g_hActiveGameTimer = INVALID_HANDLE;
		}

		CreateTimer(0.0, Timer_GameLogic_EndMinigame);
	}
}