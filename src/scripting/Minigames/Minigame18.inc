/*
 * MicroTF2 - Minigame 18
 * 
 * Hit the Target!
 */

new String:Minigame18_SniperTargets[4][64];

new Minigame18_TargetEntIndex = -1;
new Minigame18_TargetModel = 0;

public Minigame18_EntryPoint()
{
	Minigame18_SniperTargets[0] = "models/props_training/target_scout.mdl";
	Minigame18_SniperTargets[1] = "models/props_training/target_demoman.mdl";
	Minigame18_SniperTargets[2] = "models/props_training/target_sniper.mdl";
	Minigame18_SniperTargets[3] = "models/props_training/target_medic.mdl";

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame18_OnMapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame18_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame18_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame18_OnMinigameFinish);
}

public Minigame18_OnMapStart()
{
	for (new i = 0; i < 4; i++)
	{
		PrecacheModel(Minigame18_SniperTargets[i], true);
	}

	decl String:buffer[32];

	for (new i = 1; i < 9; i++)
	{
		Format(buffer, sizeof(buffer), "vo/scout_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/medic_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);
	}

	for (new i = 1; i < 8; i++)
	{
		Format(buffer, sizeof(buffer), "vo/demoman_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);
	}

	for (new i = 1; i < 7; i++)
	{
		Format(buffer, sizeof(buffer), "vo/scout_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);
	}

	for (new i = 1; i < 5; i++)
	{
		Format(buffer, sizeof(buffer), "vo/demoman_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/sniper_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/sniper_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/medic_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);
	}
}

public bool:Minigame18_OnCheck()
{
	return true;
}

public Minigame18_OnMinigameSelectedPre()
{
	if (MinigameID == 18)
	{
		Minigame18_TargetEntIndex = CreateEntityByName("prop_physics");

		if (IsValidEntity(Minigame18_TargetEntIndex))
		{                      
			Minigame18_TargetModel = GetRandomInt(0,3);

			DispatchKeyValue(Minigame18_TargetEntIndex, "model", Minigame18_SniperTargets[Minigame18_TargetModel]);
			DispatchSpawn(Minigame18_TargetEntIndex);

			SetEntityMoveType(Minigame18_TargetEntIndex, MOVETYPE_NONE);   

			SDKHook(Minigame18_TargetEntIndex, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage2);
			
			new Float:pos[3];
			new Float:ang[3] = { 0.0, -90.0, 0.0 };

			pos[0] = GetRandomFloat(9856.3, 12800.0);
			pos[1] = GetRandomFloat(7835.2, 9397.2);
			pos[2] = -330.0;

			if (IsValidEntity(Minigame18_TargetEntIndex))
			{
				TeleportEntity(Minigame18_TargetEntIndex, pos, ang, NULL_VECTOR);
				CreateParticle(Minigame18_TargetEntIndex, "bombinomicon_flash", 1.0);
			}
		}
	}
}

public Minigame18_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 18 && IsClientValid(client))
	{
		TF2_RemoveAllWeapons(client);
		TF2_SetPlayerClass(client, TFClass_Sniper);
		GiveWeapon(client, 14);

		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3] = { 0.0, 90.0, 0.0 };
		new Float:pos[3];

		new column = client;
		new row = 0;
		while (column > 24)
		{
			column = column - 24;
			row = row + 1;
		}

		pos[0] = 10406.0 + float(column*60); 
		pos[1] = 7100.0 - float(row*100);
		pos[2] = -260.0;

		TeleportEntity(client, pos, ang, vel);
		IsViewModelVisible(client, true);

		SDKHook(client, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage);
	}
}

public Minigame18_OnMinigameFinish()
{
	if (MinigameID == 18 && IsMinigameActive)
	{
		SDKUnhook(Minigame18_TargetEntIndex, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage2);

		if (IsValidEntity(Minigame18_TargetEntIndex))
		{
			AcceptEntityInput(Minigame18_TargetEntIndex, "Kill");
		}

		Minigame18_TargetEntIndex = -1;

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i))
			{
				TF2_RespawnPlayer(i);
				SDKUnhook(i, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage);
			}
		}
	}
}


public Action:Minigame18_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	damage = 0.0;
	Minigame18_HitTarget(attacker);
	return Plugin_Changed;
}

public Action:Minigame18_OnTakeDamage2(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	damage = 0.0;
	Minigame18_HitTarget(attacker);
	return Plugin_Changed;
}

stock Minigame18_HitTarget(attacker)
{
	if (IsClientValid(attacker))
	{
		ClientWonMinigame(attacker);
		switch (Minigame18_TargetModel)
		{
			case 0: PlayScoutHurtSound(attacker);
			case 1: PlayDemoHurtSound(attacker);
			case 2: PlaySniperHurtSound(attacker);
			case 3: PlayMedicHurtSound(attacker);
		}
	}
}

PlayScoutHurtSound(attacker)
{
	switch (GetRandomInt(0, 13))
	{
		case 0: EmitSoundToClient(attacker, "vo/scout_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/scout_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/scout_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/scout_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/scout_painsharp05.mp3");
		case 5: EmitSoundToClient(attacker, "vo/scout_painsharp06.mp3");
		case 6: EmitSoundToClient(attacker, "vo/scout_painsharp07.mp3");
		case 7: EmitSoundToClient(attacker, "vo/scout_painsharp08.mp3");
		case 8: EmitSoundToClient(attacker, "vo/scout_painsevere01.mp3");
		case 9: EmitSoundToClient(attacker, "vo/scout_painsevere02.mp3");
		case 10: EmitSoundToClient(attacker, "vo/scout_painsevere03.mp3");
		case 11: EmitSoundToClient(attacker, "vo/scout_painsevere04.mp3");
		case 12: EmitSoundToClient(attacker, "vo/scout_painsevere05.mp3");
		case 13: EmitSoundToClient(attacker, "vo/scout_painsevere06.mp3");
	}
}

PlayDemoHurtSound(attacker)
{
	switch (GetRandomInt(0, 10))
	{
		case 0: EmitSoundToClient(attacker, "vo/demoman_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/demoman_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/demoman_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/demoman_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/demoman_painsharp05.mp3");
		case 5: EmitSoundToClient(attacker, "vo/demoman_painsharp06.mp3");
		case 6: EmitSoundToClient(attacker, "vo/demoman_painsharp07.mp3");
		case 7: EmitSoundToClient(attacker, "vo/demoman_painsevere01.mp3");
		case 8: EmitSoundToClient(attacker, "vo/demoman_painsevere02.mp3");
		case 9: EmitSoundToClient(attacker, "vo/demoman_painsevere03.mp3");
		case 10: EmitSoundToClient(attacker, "vo/demoman_painsevere04.mp3");
	}
}

PlaySniperHurtSound(attacker)
{
	switch (GetRandomInt(0, 7))
	{
		case 0: EmitSoundToClient(attacker, "vo/sniper_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/sniper_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/sniper_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/sniper_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/sniper_painsevere01.mp3");
		case 5: EmitSoundToClient(attacker, "vo/sniper_painsevere02.mp3");
		case 6: EmitSoundToClient(attacker, "vo/sniper_painsevere03.mp3");
		case 7: EmitSoundToClient(attacker, "vo/sniper_painsevere04.mp3");
	}
}

PlayMedicHurtSound(attacker)
{
	switch (GetRandomInt(0, 11))
	{
		case 0: EmitSoundToClient(attacker, "vo/medic_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/medic_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/medic_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/medic_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/medic_painsharp05.mp3");
		case 5: EmitSoundToClient(attacker, "vo/medic_painsharp06.mp3");
		case 6: EmitSoundToClient(attacker, "vo/medic_painsharp07.mp3");
		case 7: EmitSoundToClient(attacker, "vo/medic_painsharp08.mp3");
		case 8: EmitSoundToClient(attacker, "vo/medic_painsevere01.mp3");
		case 9: EmitSoundToClient(attacker, "vo/medic_painsevere02.mp3");
		case 10: EmitSoundToClient(attacker, "vo/medic_painsevere03.mp3");
		case 11: EmitSoundToClient(attacker, "vo/medic_painsevere04.mp3");
	}
}

stock DoSniperDamageCheck(client, weapon, String:weaponname[])
{
	if (strncmp(weaponname, "tf_weapon_sniperrifle", 21, false) != 0) return;

	decl Float:pos[3], Float:dist;

	new target = GetClientAimEntity3(client, dist, pos);

	if (target <= 0 || !IsValidEdict(target)) return;
	if (dist > 8192) return;

	decl String:classname[32];
	GetEdictClassname(target, classname, sizeof(classname));

	if (StrContains(classname, "pumpkin", false) == -1 && StrContains(classname, "breakable", false) == -1 && StrContains(classname, "physics", false) == -1 && StrContains(classname, "physbox", false) == -1 && StrContains(classname, "button", false) == -1)
	{
		return;
	}

	Minigame18_HitTarget(client);
}

stock GetClientAimEntity3(client, &Float:distancetoentity, Float:endpos[3])	//Javalia
{
	decl Float:cleyepos[3], Float:cleyeangle[3];
	GetClientEyePosition(client, cleyepos);
	GetClientEyeAngles(client, cleyeangle);
	new Handle:traceresulthandle = INVALID_HANDLE;
	traceresulthandle = TR_TraceRayFilterEx(cleyepos, cleyeangle, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfOrPlayers, client);

	if (TR_DidHit(traceresulthandle) == true)
	{
		TR_GetEndPosition(endpos, traceresulthandle);
		distancetoentity = GetVectorDistance(cleyepos, endpos);
		new entindextoreturn = TR_GetEntityIndex(traceresulthandle);
		CloseHandle(traceresulthandle);
		return entindextoreturn;
	}

	CloseHandle(traceresulthandle);
	return -1;
}

public bool:TraceRayDontHitSelfOrPlayers(entity, mask, any:data)
{
	return (entity != data && !IsClientValid(entity));
}