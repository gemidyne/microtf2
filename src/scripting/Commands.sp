
/**
 * MicroTF2 - Commands.sp
 * 
 * Implements functionality for commands.
 */

void InitializeCommands()
{
	// Command Listeners
	AddCommandListener(CmdOnPlayerTaunt, "taunt");
	AddCommandListener(CmdOnPlayerTaunt, "+taunt");
	AddCommandListener(CmdOnPlayerTaunt, "use_action_slot_item_server");
	AddCommandListener(CmdOnPlayerTaunt, "+use_action_slot_item_server");

	AddCommandListener(CmdOnPlayerKill, "kill");
	AddCommandListener(CmdOnPlayerKill, "explode");

	RegAdminCmd("sm_changegamemode", Command_SetGamemode, ADMFLAG_VOTE, "Changes the current gamemode.");
	RegAdminCmd("sm_triggerboss", Command_TriggerBoss, ADMFLAG_VOTE, "Triggers a bossgame to be played next.");
}

public Action CmdOnPlayerTaunt(int client, const char[] command, int args)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToServer("[WWDBG] Client num #%d CmdOnPlayerTaunt. g_bIsBlockingTaunts: %s", client, g_bIsBlockingTaunts ? "True": "False");
	#endif

	return (g_bIsBlockingTaunts ? Plugin_Handled : Plugin_Continue);
}

public Action CmdOnPlayerKill(int client, const char[] command, int args)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	#if defined DEBUG
	PrintToServer("[WWDBG] Client num #%d CmdOnPlayerKill. g_bIsBlockingTaunts: %s", client, g_bIsBlockingTaunts ? "True": "False");
	#endif

	return (g_bIsBlockingKillCommands ? Plugin_Handled : Plugin_Continue);
}


public Action Command_SetGamemode(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[WWR] Usage: sm_changegamemode <gamemodeid>");
		return Plugin_Handled;
	}

	char text[10];
	GetCmdArg(1, text, sizeof(text));

	int id = StringToInt(text);

	if (id < TOTAL_GAMEMODES)
	{
		g_iActiveGamemodeId = id;
		g_iSpecialRoundId = 0;

		ReplyToCommand(client, "[WWR] Gamemode changed to \"%s\".", g_sGamemodeThemeName[g_iActiveGamemodeId]);

		PluginForward_SendGamemodeChanged(id);

		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "[WWR] Error: specified gamemode ID is invalid.");
	
	return Plugin_Handled;
}

public Action Command_TriggerBoss(int client, int args)
{
	g_iMinigamesPlayedCount = g_iBossGameThreshold - 1;

	ReplyToCommand(client, "[WWR] Bossgame will be played shortly.");

	return Plugin_Handled;
}
