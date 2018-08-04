/**
 * MicroTF2 - MinigameStocks.inc
 * 
 * Provides stocks for use in some minigames.
 */

stock CreatePropEntity(Float:fPosition[3], String:sModel[], iHealth, Float:fDuration = 4.0, bool:bPhysic = true)
{
	new iEntity = bPhysic ? CreateEntityByName("prop_physics_override") : CreateEntityByName("prop_dynamic_override");
	
	if (IsValidEntity(iEntity))
	{
		SetEntityModel(iEntity, sModel);
		
		DispatchKeyValue(iEntity, "disableshadows", "1");
		DispatchKeyValue(iEntity, "disablereceiveshadows", "1");
		DispatchKeyValue(iEntity, "massScale", "70");
		
		DispatchSpawn(iEntity);
		
		SetEntProp(iEntity, Prop_Data, "m_takedamage", 2); 
		
		DispatchKeyValue(iEntity, "Solid", "6");
		
		//SetEntProp(iEntity, Prop_Data, "m_nSolidType", 6);
		SetEntProp(iEntity, Prop_Send, "m_nSolidType", 6);
		//SetEntProp(iEntity, Prop_Data, "m_CollisionGroup", 5);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 5);
		//SetEntProp(iEntity, Prop_Data, "m_usSolidFlags", 16);
		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags", 16);
	
		SetEntityMoveType(iEntity, MOVETYPE_VPHYSICS);
		
		AcceptEntityInput(iEntity, "DisableCollision");
		AcceptEntityInput(iEntity, "EnableCollision");
		
		SetEntityRenderColor(iEntity, 255, 255, 255, 255);
		
		SetEntProp(iEntity, Prop_Data, "m_iMaxHealth", iHealth);
		SetEntProp(iEntity, Prop_Data, "m_iHealth", iHealth);
		
		TeleportEntity(iEntity, fPosition, NULL_VECTOR, NULL_VECTOR);
		
		CreateTimer(fDuration, Timer_RemoveEntity, iEntity);
	}

	return iEntity;
}

stock CreateParticle(client, const String:effect[], Float:time, bool:attachToHead = false) 
{  
	new iParticle = CreateEntityByName("info_particle_system");

	if (IsValidEntity(iParticle)) 
	{
		new Float:fPosition[3];
		decl String:sName[128];

		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPosition);
		TeleportEntity(iParticle, fPosition, NULL_VECTOR, NULL_VECTOR);
        
		Format(sName, sizeof(sName), "target%i", client);
		DispatchKeyValue(client, "targetname", sName);
        
		DispatchKeyValue(iParticle, "targetname", "tf2particle");
		DispatchKeyValue(iParticle, "parentname", sName);
		DispatchKeyValue(iParticle, "effect_name", effect);
		DispatchSpawn(iParticle);

		SetVariantString(sName);
		AcceptEntityInput(iParticle, "SetParent", iParticle, iParticle, 0);

		if (attachToHead) 
		{
			SetVariantString("head");
			AcceptEntityInput(iParticle, "SetParentAttachment", iParticle, iParticle, 0);
		}

		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "start");
        
		CreateTimer(time, Timer_RemoveEntity, iParticle);
	}
}

public Action:Timer_RemoveEntity(Handle:hTimer, any:iEntity) 
{
    if (IsValidEntity(iEntity)) 
	{
        AcceptEntityInput(iEntity, "Kill");
    }

    return Plugin_Stop;
}

public Action:Timer_RemoveBossOverlay(Handle:timer)
{
	DisplayOverlayToAll(OVERLAY_BLANK);

	for (new i = 1; i <= MaxClients; i++)
	{
		MinigameCaption[i] = "";
	}
}

public Action:Timer_CheckBossEnd(Handle:timer, any:client)
{ 
	if (GamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	if (IsMinigameActive && BossgameID > 0)
	{
		if (GlobalForward_OnBossStopAttempt != INVALID_HANDLE)
		{
			Call_StartForward(GlobalForward_OnBossStopAttempt);
			Call_Finish();
		}

		Handle_BossCheckTimer = CreateTimer(2.0, Timer_CheckBossEnd);
	}

	return Plugin_Handled;
}

stock EndBoss()
{
	if (IsMinigameActive && BossgameID > 0 && MinigameID == 0)
	{
		SetConVarInt(FindConVar("mp_friendlyfire"), 1);

		if (MinigamesPlayed != BossGameThreshold)
		{
			// That is us!
			SpeedLevel = 1.0;
			MinigamesPlayed = 999;
		}

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
                for (new a = 0; a < 10; a++)
                {
                    StopSound(i, SNDCHAN_AUTO, BossgameMusic[BossgameID]);
                }

                if (IsPlayerParticipant[i])
                {
					TF2_RespawnPlayer(i);
				}
			}
		}

		if (Handle_ActiveGameTimer != INVALID_HANDLE)
		{
			KillTimer(Handle_ActiveGameTimer);
			Handle_ActiveGameTimer = INVALID_HANDLE;
		}
		CreateTimer(0.0, Timer_GameLogic_EndMinigame);
	}
}

stock SetMinigameCaptionForAll(const String:text[])
{
	decl String:objective[64];
	Format(objective, sizeof(objective), text);

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientValid(i))
		{
			DisplayHudMessage("INFORMATION", objective, 3.0);
		}
	}
}

stock ClearMinigameCaptionForAll()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientValid(i))
		{
			DisplayOverlayToClient(i, OVERLAY_BLANK);
			strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, "");
		}
	}
}