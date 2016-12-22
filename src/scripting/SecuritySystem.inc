/**
 * MicroTF2 - SecuritySystem.inc
 * 
 * Security System aims to prevent and block various exploitable commands.
 */

new Handle:AllowedCheats;

/* Entities that are not allowed to be created with ent_create or give */
new String:ForbiddenEntities[][] = { "point_servercommand", "point_clientcommand", "logic_timer", "logic_relay"
	,"logic_auto", "logic_autosave", "logic_branch", "logic_case", "logic_collision_pair", "logic_compareto" 
	,"logic_lineto", "logic_measure_movement", "logic_multicompare", "logic_navigation" };

/* Strings that are not allowed to be present in ent_fire commands */
new String:ForbiddenCommands[][] = { "quit", "quti", "restart", "sm", "admin", "ma_", "rcon", "sv_", "mp_", "meta", "alias" };

/* ConVars that clients are not permitted to have */
new String:ForbiddenClientConVars[][] = { "sourcemod_version", "metamod_version", "mani_admin_plugin_version", "eventscripts_ver", "est_version", "bat_version", "beetlesmod_version" };

new SecuritySystem_ConVarPos[MAXPLAYERS];
new bool:SecuritySystem_IgnoreServerCmdCheckOnce = false;

stock InitialiseSecuritySystem()
{
	AddCommandListener(Cmd_EntCreate, "ent_create");
	AddCommandListener(Cmd_EntCreate, "give");
	AddCommandListener(Cmd_EntFire, "ent_fire");

	SecuritySystem_HookCheatCommands();

	LogMessage("Security System initialised.");
}

stock SecuritySystem_HookCheatCommands()
{
	AllowedCheats = CreateArray(64);

	PushArrayString(AllowedCheats, "host_timescale");
	PushArrayString(AllowedCheats, "r_screenoverlay");
	PushArrayString(AllowedCheats, "thirdperson");
	PushArrayString(AllowedCheats, "firstperson");
	PushArrayString(AllowedCheats, "sv_cheats");

	new String:cvarName[256];
	new Handle:cvarHandle;
	new bool:isCmd;
	new flags;

	cvarHandle = FindFirstConCommand(cvarName, sizeof(cvarName), isCmd, flags);

	if (cvarHandle == INVALID_HANDLE)
	{
		SetFailState("Console Variable list could not be loaded.");
	}
	do
	{
		if (!(flags & FCVAR_CHEAT))
		{
			continue;
		}

		if (isCmd) 
		{
			AddCommandListener(SecuritySystem_CheatCmdExec, cvarName);
			AddReplicatedFlag(cvarName, true);
		}
		else
		{
			HookConVarChange(FindConVar(cvarName), SecuritySystem_CheatCvarChange);
			AddReplicatedFlag(cvarName, false);
		}
	}
	while (FindNextConCommand(cvarHandle, cvarName, sizeof(cvarName), isCmd, flags));

	CloseHandle(cvarHandle);
}

stock SecuritySystem_OnClientPutInServer(client)
{
	SecuritySystem_ConVarPos[client] = 0;
	CreateTimer(1.0, SecuritySystem_KillServerCmds, client, TIMER_REPEAT);
	CreateTimer(0.1, SecuritySystem_CheckPlayerMoveType, client, TIMER_REPEAT);
	CreateTimer(5.0, SecuritySystem_CheckPlayerConVars, client, TIMER_REPEAT);
}

public Action:SecuritySystem_KillServerCmds(Handle:timer, any:value)
{
	if (SecuritySystem_IgnoreServerCmdCheckOnce)
	{
		SecuritySystem_IgnoreServerCmdCheckOnce = false;
		return Plugin_Continue;
	}

	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "point_servercommand")) != -1)
	{
		AcceptEntityInput(entity, "kill");
	}

	return Plugin_Continue;
}

public Action:SecuritySystem_CheckPlayerConVars(Handle:timer, any:value)
{
	if (!IsClientInGame(value) || IsFakeClient(value)) 
	{
		return Plugin_Stop;
	}

	if (value >= sizeof(SecuritySystem_ConVarPos))
	{
		return Plugin_Stop;
	}

	if (SecuritySystem_ConVarPos[value] >= sizeof(ForbiddenClientConVars))
	{
		return Plugin_Stop;
	}
	
	QueryClientConVar(value, ForbiddenClientConVars[SecuritySystem_ConVarPos[value]], SecuritySystem_ConVarDone);
	SecuritySystem_ConVarPos[value]++;

	if (SecuritySystem_ConVarPos[value] >= sizeof(ForbiddenClientConVars))
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public SecuritySystem_ConVarDone(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[], any:value)
{
	if (result != ConVarQuery_Okay && result != ConVarQuery_Protected)
	{
		return;
	}

	LogMessage("Removing client '%L' as %s=%s", client, cvarName, cvarValue);
	KickClient(client, "Please remove any plugins you are running.");
}

public Action:SecuritySystem_CheckPlayerMoveType(Handle:timer, any:value)
{
	if (!IsClientInGame(value) || IsFakeClient(value)) 
	{
		return Plugin_Stop;
	}

 	new MoveType:move = GetEntityMoveType(value);

 	if (move == MOVETYPE_NOCLIP)
	{
		KickClient(value);
	}
 	else if (move != MOVETYPE_WALK)
 	{
 		SetEntityMoveType(value, MOVETYPE_WALK);
 	}

	return Plugin_Continue;
}

public Action:Cmd_EntCreate(client, const String:command[], argc)
{
	new String:entname[128];
	GetCmdArg(1, entname, sizeof(entname));

	for (new i = 0; i < sizeof(ForbiddenEntities); i++)
	{
		if (StrEqual(entname, ForbiddenEntities[i], false))
		{
			LogMessage("Blocking ent_create from '%L', for containing %s", client, ForbiddenEntities[i]);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:Cmd_EntFire(client, const String:command[], argc)
{
	new String:argstring[1024];
	GetCmdArgString(argstring, sizeof(argstring));

	for (new i = 0; i < sizeof(ForbiddenCommands); i++)
	{
		if (StrContains(argstring, ForbiddenCommands[i], false) != -1)
		{
			LogMessage("Blocking ent_fire from '%L': %s", client, argstring);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

stock AddReplicatedFlag(const String:convar[], bool:isCommand)
{
    if (!isCommand)
    {
        new Handle:hConVar = FindConVar(convar);
        if (hConVar != INVALID_HANDLE)
        {
            new flags = GetConVarFlags(hConVar);
            SetConVarFlags(hConVar, flags & FCVAR_REPLICATED);
        }
    }
    else 
    {
        new flags = GetCommandFlags(convar);
        SetCommandFlags(convar, flags & FCVAR_REPLICATED);
    }
}

public Action:SecuritySystem_CheatCmdExec(client, const String:command[], args)
{
	decl String:buffer[256];

	for (new i = 0; i < GetArraySize(AllowedCheats); i++)
	{
		GetArrayString(AllowedCheats, i, buffer, sizeof(buffer));

		if (StrEqual(buffer, command, false))
		{
			return Plugin_Continue;
		}
		else
		{
			KickClient(client, "Attempted to use a Cheat Command.");
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public SecuritySystem_CheatCvarChange(Handle:conVar, const String:oldValue[], const String:newValue[])
{
	decl String:cvarName[128];
	decl String:buffer[128];

	GetConVarName(conVar, cvarName, sizeof(cvarName));

	for (new i = 0; i < GetArraySize(AllowedCheats); i++)
	{
		GetArrayString(AllowedCheats, i, buffer, sizeof(buffer));

		if (StrEqual(buffer, cvarName, false))
		{
			return;
		}
	}
}