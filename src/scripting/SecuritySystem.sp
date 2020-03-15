/**
 * MicroTF2 - SecuritySystem.inc
 * 
 * Security System aims to prevent and block various exploitable commands.
 */

Handle AllowedCheats;

char ForbiddenClientConVars[][] = 
{
	"sourcemod_version",
	"metamod_version",
	"mani_admin_plugin_version",
	"eventscripts_ver",
	"est_version",
	"bat_version",
	"beetlesmod_version"
};

int SecuritySystem_ConVarPos[MAXPLAYERS];
bool SecuritySystem_IgnoreServerCmdCheckOnce = false;

public void InitialiseSecuritySystem()
{
	AddCommandListener(Cmd_BlockCompletely, "ent_create");
	AddCommandListener(Cmd_BlockCompletely, "give");
	AddCommandListener(Cmd_BlockCompletely, "ent_fire");
	AddCommandListener(Cmd_BlockCompletely, "addcond");
	AddCommandListener(Cmd_BlockCompletely, "buddha");
	AddCommandListener(Cmd_BlockCompletely, "bot");
	AddCommandListener(Cmd_BlockCompletely, "hurtme");
	AddCommandListener(Cmd_BlockCompletely, "noclip");
	AddCommandListener(Cmd_BlockCompletely, "autoteam");
	AddCommandListener(Cmd_BlockCompletely, "currency_give");
	AddCommandListener(Cmd_BlockCompletely, "ent_remove");
	AddCommandListener(Cmd_BlockCompletely, "ent_remove_all");
	AddCommandListener(Cmd_BlockCompletely, "mp_playanimation");
	AddCommandListener(Cmd_BlockCompletely, "mp_playgesture");
	AddCommandListener(Cmd_BlockCompletely, "particle_test_start");
	AddCommandListener(Cmd_BlockCompletely, "particle_test_stop");
	AddCommandListener(Cmd_BlockCompletely, "showtriggers_toggle");
	AddCommandListener(Cmd_BlockCompletely, "r_drawclipbrushes");

	SecuritySystem_HookCheatCommands();

	#if defined LOGGING_STARTUP
	LogMessage("Security System initialised.");
	#endif
}

public void SecuritySystem_HookCheatCommands()
{
	AllowedCheats = CreateArray(64);

	PushArrayString(AllowedCheats, "host_timescale");
	PushArrayString(AllowedCheats, "r_screenoverlay");
	PushArrayString(AllowedCheats, "thirdperson");
	PushArrayString(AllowedCheats, "firstperson");
	PushArrayString(AllowedCheats, "sv_cheats");

	char cvarName[256];
	Handle cvarHandle;
	bool isCmd;
	int flags;

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

stock void SecuritySystem_OnClientPutInServer(int client)
{
	SecuritySystem_ConVarPos[client] = 0;
	CreateTimer(1.0, SecuritySystem_KillServerCmds, client, TIMER_REPEAT);
	CreateTimer(0.1, SecuritySystem_CheckPlayerMoveType, client, TIMER_REPEAT);
	CreateTimer(5.0, SecuritySystem_CheckPlayerConVars, client, TIMER_REPEAT);
}

public Action SecuritySystem_KillServerCmds(Handle timer, int value)
{
	if (SecuritySystem_IgnoreServerCmdCheckOnce)
	{
		SecuritySystem_IgnoreServerCmdCheckOnce = false;
		return Plugin_Continue;
	}

	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "point_servercommand")) != -1)
	{
		AcceptEntityInput(entity, "kill");
	}

	return Plugin_Continue;
}

public Action SecuritySystem_CheckPlayerConVars(Handle timer, int value)
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

public void SecuritySystem_ConVarDone(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int value)
{
	if (result != ConVarQuery_Okay && result != ConVarQuery_Protected)
	{
		return;
	}

	LogMessage("Removing client '%L' as %s=%s", client, cvarName, cvarValue);
	KickClient(client, "Please remove any plugins you are running.");
}

public Action SecuritySystem_CheckPlayerMoveType(Handle timer, int value)
{
	if (!IsClientInGame(value) || IsFakeClient(value)) 
	{
		return Plugin_Stop;
	}

 	MoveType move = GetEntityMoveType(value);

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

public Action Cmd_BlockCompletely(int client, const char[] command, int argc)
{
	LogMessage("Blocking cheat command from %N: %s", client, command);
	return Plugin_Handled;
}

stock void AddReplicatedFlag(const char[] convar, bool isCommand)
{
    if (!isCommand)
    {
        Handle handle = FindConVar(convar);
        if (handle != INVALID_HANDLE)
        {
            int flags = GetConVarFlags(handle);
            SetConVarFlags(handle, flags & FCVAR_REPLICATED);
        }
    }
    else 
    {
        int flags = GetCommandFlags(convar);
        SetCommandFlags(convar, flags & FCVAR_REPLICATED);
    }
}

public Action SecuritySystem_CheatCmdExec(int client, const char[] command, int args)
{
	char buffer[256];

	for (int i = 0; i < GetArraySize(AllowedCheats); i++)
	{
		GetArrayString(AllowedCheats, i, buffer, sizeof(buffer));

		if (StrEqual(buffer, command, false))
		{
			return Plugin_Continue;
		}
		else
		{
			if (client > 0 && client <= MaxClients && IsClientInGame(client))
			{
				KickClient(client, "Attempted to use a Cheat Command");
			}
			else
			{
				LogMessage("Attempted to use cheat command, but client was server");
			}

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public void SecuritySystem_CheatCvarChange(Handle conVar, const char[] oldValue, const char[] newValue)
{
	char cvarName[128];
	char buffer[128];

	GetConVarName(conVar, cvarName, sizeof(cvarName));

	for (int i = 0; i < GetArraySize(AllowedCheats); i++)
	{
		GetArrayString(AllowedCheats, i, buffer, sizeof(buffer));

		if (StrEqual(buffer, cvarName, false))
		{
			return;
		}
	}
}