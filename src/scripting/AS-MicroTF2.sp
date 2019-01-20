/* 
 * WarioWare for TF2 (formerly MicroTF2)
 * Copyright (C) 2010 - 2018 StSv.TF productions, in association with GEMINI Developments.
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>

#undef REQUIRE_PLUGIN

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS

//#define UMC_MAPCHOOSER

#include <sdkhooks>
#include <soundlib>
#include <steamtools>
#include <tf2items>
#include <tf2attributes>

#if defined UMC_MAPCHOOSER
#include <umc-core>
#else
#include <mapchooser>
#endif

#pragma newdecls required

/**
 * Defines
 */
//#define DEBUG
#define PLUGIN_VERSION "2019 devtest"
#define PLUGIN_PREFIX "\x0700FFFF[ \x07FFFF00WarioWare \x0700FFFF] {default}"

#include "Header.sp"
#include "Forwards.sp"
#include "MethodMaps/Player.inc"
#include "Weapons.sp"
#include "Voices.sp"
#include "System.sp"
#include "MinigameSystem.sp"
#include "PrecacheSystem.sp"
#include "SecuritySystem.sp"
#include "Events.sp"
#include "SpecialRounds.sp"
#include "Internal.sp"
#include "Stocks.sp"
#include "Commands.sp"
#include "InternalWebAPI.sp"

public Plugin myinfo = 
{
	name = "WarioWare",
	author = "",
	description = "Yet another WarioWare gamemode for Team Fortress 2",
	version = PLUGIN_VERSION,
	url = "http://www.gemini.software/"
}

public void OnPluginStart()
{
#if defined FIXED_IP
	int hostIP = GetConVarInt(FindConVar("hostip"));
	if (hostIP != FIXED_IP)
	{
		SetFailState("This server has not been authorized to run WarioWare.");
	}
#endif

	char gameFolder[32];
	GetGameFolderName(gameFolder, sizeof(gameFolder));

	if (!StrEqual(gameFolder, "tf"))
	{
		SetFailState("WarioWare can only be run on Team Fortress 2.");
	}

	if (GetExtensionFileStatus("sdkhooks.ext") < 1) 
	{
		SetFailState("The SDKHooks Extension is not loaded.");
	}

	if (GetExtensionFileStatus("tf2items.ext") < 1)
	{
		SetFailState("The TF2Items Extension is not loaded.");
	}

	if (GetExtensionFileStatus("steamtools.ext") < 1)
	{
		SetFailState("The SteamTools Extension is not loaded.");
	}

	if (GetExtensionFileStatus("soundlib.ext") < 1)
	{
		SetFailState("The SoundLib Extension is not loaded.");
	}

	LoadTranslations("microtf2.phrases.txt");
	HookEvents();
	InitializeSystem();
}

public void OnMapStart()
{
	// Perform map check to see whether or not the plugin should do anything.
	IsPluginEnabled = IsWarioWareMap();

	if (IsPluginEnabled)
	{
		char gameDescription[32];
		Format(gameDescription, sizeof(gameDescription), "WarioWare (%s)", PLUGIN_VERSION);
		Steam_SetGameDescription(gameDescription);

		CreateTimer(120.0, GamemodeAdvertisement, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		PrepareConVars();

		int playerManagerEntity = FindEntityByClassname(MaxClients+1, "tf_player_manager");
		if (playerManagerEntity == -1)
		{
			SetFailState("Unable to find tf_player_manager entity");
		}
		else
		{
			SDKHook(playerManagerEntity, SDKHook_ThinkPost, Hook_Scoreboard);
		}

		AddNormalSoundHook(Hook_GameSound);

		if (GlobalForward_OnMapStart != INVALID_HANDLE)
		{
			LogMessage("Calling OnMapStart forward... ");
			Call_StartForward(GlobalForward_OnMapStart);
			Call_Finish();
			LogMessage("Called OnMapStart forward.");
		}
		else
		{
			SetFailState("MicroTF2 failed to initialise: ForwardSystem failed to start.");
		}
	}
}

public Action Timer_GameLogic_EngineInitialisation(Handle timer)
{
	IntroCountdown = 6;

	GamemodeStatus = GameStatus_Playing;

	MinigameID = 0;
	BossgameID = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	SpecialRoundID = 0;
	ScoreAmount = 1;
	MinigamesPlayed = 0;
	BossGameThreshold = 20;
	MaxRounds = GetConVarInt(ConVar_MTF2MaxRounds);
	RoundsPlayed = 0;
	SpeedLevel = 1.0;

	IsMinigameActive = false;
	IsMinigameEnding = false;
	IsMapEnding = false;
	IsBonusRound = false;
	IsBlockingTaunts = true;
	IsBlockingDeathCommands = true;
	IsBlockingDamage = true;
	IsOnlyBlockingDamageByPlayers = false;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			char header[64];
			Format(header, sizeof(header), "%T", "Startup_Header", i);

			char body[64];
			Format(body, sizeof(body), "%T", "Startup_BodyIntro", i);

			DisplayHudMessageToClient(i, header, body, 3.0);

			player.DisplayOverlay(OVERLAY_MINIGAMEBLANK);
		}
	}

	CreateTimer(1.0, Timer_GameLogic_EngineInitialisationCountdown);
}

public Action Timer_GameLogic_EngineInitialisationCountdown(Handle timer)
{
	if (IntroCountdown > 0)
	{
		IntroCountdown--;

		if (IntroCountdown <= 3)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				Player player = new Player(i);

				if (player.IsInGame && !player.IsBot)
				{
					char header[64];
					Format(header, sizeof(header), "%T", "Startup_Header", i);

					char body[64];
					Format(body, sizeof(body), "%T", "Startup_BodyCountdown", i, IntroCountdown);

					DisplayHudMessageToClient(i, header, body, 1.1);
					player.DisplayOverlay(OVERLAY_MINIGAMEBLANK);
				}
			}
		}

		CreateTimer(1.0, Timer_GameLogic_EngineInitialisationCountdown);
	}
	else
	{
		CreateTimer(0.0, Timer_GameLogic_PrepareForMinigame);
	}
}

public Action Timer_GameLogic_PrepareForMinigame(Handle timer)
{
	if (GamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	GamemodeStatus = GameStatus_Playing;

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Timer_GameLogic_PrepareForMinigame");
	#endif

	if (!IsBonusRound)
	{
		SetSpeed_SpecialRound();
	}
	
	SetSpeed();

	ShowPlayerScores(true);
	SpecialRound_SetupEnv();

	char centerText[4096];

	if (SpecialRoundID == 16)
	{
		ScoreAmount = GetRandomInt(2, 14);
		Format(centerText, sizeof(centerText), "If you win this minigame, you will be awarded \"%d\" points!", ScoreAmount);
	}
	else if (SpecialRoundID == 17)
	{
		ScoreAmount = (MinigamesPlayed >= BossGameThreshold ? 5 : 1);

		char names[2048];
		int currentPlayers = 0;
		int maxPlayers = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid)
			{
				maxPlayers++;

				if (IsPlayerParticipant[i])
				{
					if (currentPlayers < 7)
					{
						Format(names, sizeof(names), "%s%N\n", names, i);
					}
					else if (currentPlayers == 7)
					{
						Format(names, sizeof(names), "%s - Plus %d More - ", names, (maxPlayers - 7));
					}

					currentPlayers++;
				}
			}
		}

		Format(centerText, sizeof(centerText), "Current Players (%d of %d)\n%s", currentPlayers, maxPlayers, names);
	}
	else
	{
		ScoreAmount = (MinigamesPlayed >= BossGameThreshold ? 5 : 1);
		centerText = "";
	}

	if (MinigamesPlayed >= BossGameThreshold)
	{
		int forcedBossgameID = GetConVarInt(ConVar_MTF2ForceBossgame);

		if (forcedBossgameID > 0)
		{
			PreviousBossgameID = 0;
			BossgameID = forcedBossgameID;
		}
		else
		{
			int i = 0;
			do
			{
				BossgameID = GetRandomInt(1, BossgamesLoaded);

				if (BossgamesLoaded == 1)
				{
					PreviousBossgameID = 0;
				}

				char funcName[64];
				Format(funcName, sizeof(funcName), "Bossgame%i_OnCheck", BossgameID);
				Function func = GetFunctionByName(INVALID_HANDLE, funcName);

				if (func != INVALID_FUNCTION)
				{
					bool isPlayable = false;

					Call_StartFunction(INVALID_HANDLE, func);
					Call_Finish(isPlayable);

					if (!isPlayable)
					{
						BossgameID = PreviousBossgameID;
					}

					if (i > 20)
					{
						PreviousBossgameID = 0;
					}
				}

				i++;
			}
			while (BossgameID == PreviousBossgameID);
		}

		#if defined DEBUG
		PrintToChatAll("[DEBUG] Chose bossgame %i", BossgameID);
		#endif
	}
	else
	{
		int forcedMinigameID = GetConVarInt(ConVar_MTF2ForceMinigame);

		if (SpecialRoundID == 8)
		{
			PreviousMinigameID = 0;
			MinigameID = 8;
		}
		else if (forcedMinigameID > 0 && forcedMinigameID <= MinigamesLoaded)
		{
			PreviousMinigameID = 0;
			MinigameID = forcedMinigameID;
		}
		else
		{
			int i = 0;
			do
			{
				MinigameID = GetRandomInt(1, MinigamesLoaded);

				if (MinigamesLoaded == 1)
				{
					PreviousMinigameID = 0;
				}

				char funcName[64];
				Format(funcName, sizeof(funcName), "Minigame%i_OnCheck", MinigameID);
				Function func = GetFunctionByName(INVALID_HANDLE, funcName);

				if (func != INVALID_FUNCTION)
				{
					bool isPlayable = false;

					Call_StartFunction(INVALID_HANDLE, func);
					Call_Finish(isPlayable);

					if (!isPlayable)
					{
						MinigameID = PreviousMinigameID;
					}

					if (i > 20)
					{
						// This fixes a crash.
						PreviousMinigameID = 1;
					}
				}

				i++;
			}
			while (MinigameID == PreviousMinigameID);

			#if defined DEBUG
			PrintToChatAll("[DEBUG] Chose minigame %i", MinigameID);
			#endif
		}
	}

	float duration = SystemMusicLength[GamemodeID][SYSMUSIC_PREMINIGAME];

	if (GamemodeID == SPR_GAMEMODEID && SpecialRoundID == 20)
	{
		duration = 0.05;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid)
		{
			if (!player.IsAlive)
			{
				player.Respawn();
			}

			if (!player.IsParticipating && SpecialRoundID != 17)
			{
				// If not a participant, and not Sudden Death, then they should now be a participant.
				player.IsParticipating = true;
			}

			ResetWeapon(i, false);

			player.SetCollisionsEnabled(true);
			player.SetGodMode(true);
			player.ResetHealth();
			player.SetGlow(false);
			player.SetGravity(1.0);

			ClientCommand(i, "r_cleardecals");

			player.Status = PlayerStatus_NotWon;
			SetupSPR(i);

			PrintCenterText(i, centerText);

			if (duration >= 1.0)
			{
				player.DisplayOverlay(OVERLAY_BLANK);
				strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, "");
				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_PREMINIGAME]);

				if (SpecialRoundID != 12)
				{
					char score[32];
					Format(score, sizeof(score), "%d POINTS", PlayerScore[i]);
					ShowAnnotation(i, duration, score);
				}
			}
		}
		else if (player.IsInGame && player.Team == TFTeam_Spectator)
		{
			player.Status = PlayerStatus_NotWon;
			player.DisplayOverlay(OVERLAY_BLANK);

			strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, "");
			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_PREMINIGAME]);
		}
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Clients ready. Creating timer for Timer_GameLogic_StartMinigame");
	#endif

	CreateTimer(duration, Timer_GameLogic_StartMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action Timer_GameLogic_StartMinigame(Handle timer)
{
	if (GamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Timer_GameLogic_StartMinigame called - Starting Forward Calls for OnMinigameSelectedPre");
	#endif

	if (GlobalForward_OnMinigameSelectedPre != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnMinigameSelectedPre);
		Call_Finish();
	}

	if (SpecialRoundID == 7 && BossgameID > 0)
	{
		SpeedLevel = 0.7;
	}

	UpdatePlayerIndexes();

	SetSpeed();
	ShowPlayerScores(true);
	SpecialRound_SetupEnv();

	g_iCenterHudUpdateFrame = g_iCenterHudUpdateInterval + 1;
	IsMinigameActive = true;

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Preparing clients..");
	#endif

	bool isCaptionDynamic;
	Function func = INVALID_FUNCTION;

	if (MinigameCaptionIsDynamic[MinigameID] || BossgameCaptionIsDynamic[BossgameID])
	{
		isCaptionDynamic = true;
	}

	if (isCaptionDynamic)
	{
		char funcName[64];

		if (MinigameID > 0)
		{
			funcName = MinigameDynamicCaptionFunctions[MinigameID];
		}
		else if (BossgameID > 0)
		{
			funcName = BossgameDynamicCaptionFunctions[MinigameID];
		}

		func = GetFunctionByName(INVALID_HANDLE, funcName);

		if (func == INVALID_FUNCTION)
		{
			LogError("Unable to find function \"%s\".", funcName);
		}
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			if (BossgameID > 0) 
			{
				strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, BossgameCaptions[BossgameID]);	

				if (!isCaptionDynamic)
				{
					char objective[64];
					Format(objective, sizeof(objective), BossgameCaptions[BossgameID]);

					strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, BossgameCaptions[BossgameID]);

					DisplayHudMessageToClient(i, objective, "", 5.0);
				}

				PlaySoundToPlayer(i, BossgameMusic[BossgameID]);
			}
			else if (MinigameID > 0)
			{
				strcopy(MinigameCaption[i], MINIGAME_CAPTION_LENGTH, MinigameCaptions[MinigameID]);

				if (!isCaptionDynamic)
				{
					char objective[64];
					Format(objective, sizeof(objective), MinigameCaptions[MinigameID]);
					DisplayHudMessageToClient(i, objective, "", 3.0);
				}

				PlaySoundToPlayer(i, MinigameMusic[MinigameID]);
				PlaySoundToPlayer(i, SYSFX_CLOCK);
			}

			player.DisplayOverlay(OVERLAY_MINIGAMEBLANK);

			if (player.IsValid && player.IsParticipating)
			{
				SetupSPR(i); 

				if (isCaptionDynamic)
				{
					Call_StartFunction(INVALID_HANDLE, func);
					Call_PushCell(i);
					Call_Finish();
				}

				if (GlobalForward_OnMinigameSelected != INVALID_HANDLE)
				{
					Call_StartForward(GlobalForward_OnMinigameSelected);
					Call_PushCell(i);
					Call_Finish();
				}
			}
		}
	}

	if (GlobalForward_OnMinigameSelectedPost != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnMinigameSelectedPost);
		Call_Finish();
	}

	if (MinigameID > 0)
	{
		CreateTimer(MinigameMusicLength[MinigameID], Timer_GameLogic_EndMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer((MinigameMusicLength[MinigameID] - 0.5), Timer_GameLogic_OnPreFinish, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (BossgameID > 0)
	{
		Handle_ActiveGameTimer = CreateTimer(BossgameLength[BossgameID], Timer_GameLogic_EndMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, Timer_RemoveBossOverlay, _, TIMER_FLAG_NO_MAPCHANGE);
		Handle_BossCheckTimer = CreateTimer(5.0, Timer_CheckBossEnd, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		#if defined DEBUG
		PrintToChatAll("[DEBUG] MinigameID and BossgameID are 0: Something has went wrong.");
		#endif
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_EndMinigame(Handle timer)
{
	IsMinigameEnding = true;

	SetSpeed();
	ShowPlayerScores(true);

	if (GlobalForward_OnMinigameFinish != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnMinigameFinish);
		Call_Finish();
	}

	bool playAnotherBossgame = false;
	bool returnedFromBoss = false;

	if (MinigameID > 0)
	{
		PreviousMinigameID = MinigameID;
	}
	else if (BossgameID > 0)
	{
		PreviousBossgameID = BossgameID;
		if (Handle_BossCheckTimer != INVALID_HANDLE)
		{
			// Closes the Boss Check Timer.
			KillTimer(Handle_BossCheckTimer);
			Handle_BossCheckTimer = INVALID_HANDLE;
		}

		returnedFromBoss = true;
		playAnotherBossgame = (SpecialRoundID == 10 && MinigamesPlayed == BossGameThreshold);

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
                for (int a = 0; a < 10; a++)
                {
                    StopSound(i, SNDCHAN_AUTO, BossgameMusic[PreviousBossgameID]);
                }
			}
		}
	}

	IsMinigameActive = false;
	IsMinigameEnding = false;
	MinigamesPlayed++;
	MinigameID = 0;
	BossgameID = 0;

	IsBlockingDamage = true;
	IsBlockingDeathCommands = true;
	IsBlockingTaunts = true;
	IsOnlyBlockingDamageByPlayers = false;

	SpecialRound_SetupEnv();

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid)
		{
			if (!player.IsAlive || returnedFromBoss)
			{
				player.Respawn();
			}

			player.SetGravity(1.0);

			TF2_RemoveCondition(i, TFCond_Disguised);
			TF2_RemoveCondition(i, TFCond_Disguising);
			TF2_RemoveCondition(i, TFCond_Jarated);
			TF2_RemoveCondition(i, TFCond_OnFire);
			TF2_RemoveCondition(i, TFCond_Bonked);
			TF2_RemoveCondition(i, TFCond_Dazed);

			ClearSyncHud(i, HudSync_Caption);

			if (player.Status == PlayerStatus_Failed || player.Status == PlayerStatus_NotWon)
			{
				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_FAILURE]); 
				PlayNegativeVoice(i);

				player.DisplayOverlay(((SpecialRoundID == 17 && IsPlayerParticipant[i]) || SpecialRoundID != 17) ? OVERLAY_FAIL : OVERLAY_BLANK);

				if (player.IsParticipating)
				{
					#if defined DEBUG
					PrintToChatAll("[DEBUG] %N: Participant, NotWon/Failed", i);
					#endif

					player.SetHealth(1);
					player.SetGlow(true);

					PlayerMinigamesLost[i]++;

					if (SpecialRoundID != 12)
					{
						char text[64];
						Format(text, sizeof(text), "%T", "General_Loser", i);

						ShowAnnotation(i, 2.0, text);
					}

					if (SpecialRoundID == 17)
					{
						IsPlayerParticipant[i] = false;
						PrintCenterText(i, "%T", "SuddenDeath_YouHaveBeenKnockedOut", i);
					}

					if (SpecialRoundID == 18)
					{
						PlayerScore[i] = 0;
					}
				}
				else
				{
					#if defined DEBUG
					PrintToChatAll("[DEBUG] %N: NOT participant, NotWon/Failed", i);
					#endif
				}
			}
			else
			{
				#if defined DEBUG
				PrintToChatAll("[DEBUG] %N: Participant, Winner", i);
				#endif

				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_WINNER]);
				PlayPositiveVoice(i);

				player.DisplayOverlay(OVERLAY_WON);
				player.ResetHealth();
				player.SetGlow(true);

				PlayerScore[i] += ScoreAmount;
				PlayerMinigamesWon[i]++;

				if (SpecialRoundID != 12)
				{
					char text[64];
					Format(text, sizeof(text), "%T", "General_Winner", i);
					ShowAnnotation(i, 2.0, text);
				}
			}

			player.Status = PlayerStatus_NotWon;
			player.SetCollisionsEnabled(true);
			player.SetGodMode(true);

			ResetWeapon(i, false);
			SetupSPR(i);
		}
		else if (player.IsInGame && !player.IsBot && player.Team == TFTeam_Spectator)
		{
			ClearSyncHud(i, HudSync_Caption);

			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_FAILURE]); 
			PlayNegativeVoice(i);

			player.DisplayOverlay(OVERLAY_BLANK);
		}
	}

	if (SpecialRoundID == 17)
	{
		int participants = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				participants++;
			}
		}

		if (participants <= 1)
		{
			// End the round!
			CreateTimer(2.0, Timer_GameLogic_GameOverStart, _, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Handled;
		}
		else
		{
			BossGameThreshold = 99999;
		}
	}
	else if (BossGameThreshold > 75)
	{
		// Maybe it will be funny if we let the plugin free for a bit,
		// but we *must* constrain it to a max of 75 if something goes wrong ;)

		BossGameThreshold = MinigamesPlayed;
	}

	if (MinigamesPlayed > 2 && Special_AreSpeedEventsEnabled() && SpeedLevel < 2.5 && MinigamesPlayed < BossGameThreshold)
	{
		if (GetRandomInt(0, 1) == 1)
		{
			#if defined DEBUG
			PrintToChatAll("[DEBUG] Decided to do a speed change!");
			#endif

			CreateTimer(2.0, Timer_GameLogic_SpeedChange, _, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Handled;
		}
	}

	if (GamemodeID != SPR_GAMEMODEID && MinigamesPlayed < BossGameThreshold && GetRandomInt(0, 50) == 1)
	{
		GamemodeID = SPR_GAMEMODEID;

		SpecialRoundID = GetRandomInt(SPR_MIN, SPR_MAX);

		CreateTimer(2.0, Timer_GameLogic_SpecialRoundSelectionStart, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}

	if ((SpecialRoundID != 10 && MinigamesPlayed == BossGameThreshold && !playAnotherBossgame) || (SpecialRoundID == 10 && (MinigamesPlayed == BossGameThreshold || playAnotherBossgame)))
	{
		CreateTimer(2.0, Timer_GameLogic_BossTime, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}
	else if (MinigamesPlayed > BossGameThreshold && !playAnotherBossgame)
	{
		CreateTimer(2.0, Timer_GameLogic_GameOverStart, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Decided to continue gameplay as normal.");
	#endif

	CreateTimer(2.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_OnPreFinish(Handle timer)
{
	if (GlobalForward_OnMinigameFinishPre != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnMinigameFinishPre);
		Call_Finish();
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_SpeedChange(Handle timer)
{
	bool flag = false;
	if (SpecialRoundID == 1)
	{
		flag = true;
		SpeedLevel -= 0.1;
	}
	else
	{
		SpeedLevel += 0.1;
	}

	SetSpeed();
	ShowPlayerScores(true);

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			if (player.IsValid)
			{
				player.SetGlow(false);
			}
			
			player.DisplayOverlay((flag ? OVERLAY_SPEEDDN : OVERLAY_SPEEDUP));
			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_SPEEDUP]);
		}
	}

	CreateTimer(SystemMusicLength[GamemodeID][SYSMUSIC_SPEEDUP], Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_BossTime(Handle timer)
{
	SpeedLevel = 1.0;
	SetSpeed();

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			if (player.IsValid)
			{
				player.SetGlow(false);
			}

			player.DisplayOverlay(OVERLAY_BOSS);
			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_BOSSTIME]);
		}
	}

	CreateTimer(SystemMusicLength[GamemodeID][SYSMUSIC_BOSSTIME], Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_GameOverStart(Handle timer)
{
	if (GamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] GameOverStart");
	#endif

	IsBlockingDamage = false;
	IsBlockingDeathCommands = false;
	IsBlockingTaunts = false;
	IsOnlyBlockingDamageByPlayers = false;
	IsBonusRound = true;
	SpeedLevel = 1.0;
	SetSpeed();

	SetConVarInt(ConVar_TFFastBuild, 1);

	int score = 0;
	int winnerCount = 0;
	Handle winners = CreateArray();
	char prefix[128];
	char names[1024];
	bool isWinner = false;

	score = SpecialRoundID == 9 ? GetLowestScore() : GetHighestScore();

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid)
		{
			if (GamemodeID == SPR_GAMEMODEID)
			{
				PrintCenterText(i, "%T", "GameOver_SpecialRoundHasFinished", i);
			}

			player.DisplayOverlay(OVERLAY_GAMEOVER);
			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_GAMEOVER]);

			SetEntityRenderColor(i, 255, 255, 255, 255);
			SetEntityRenderMode(i, RENDER_NORMAL);
	
			switch (SpecialRoundID)
			{
				case 17:
				{
					isWinner = IsPlayerParticipant[i];
				}

				case 9:
				{
					isWinner = (PlayerScore[i] == score);
				}

				default:
				{
					isWinner = (PlayerScore[i] >= score);
				}
			}

			IsPlayerWinner[i] = isWinner;
			player.SetGodMode(isWinner);
			player.SetCollisionsEnabled(true);
			player.IsParticipating = true;

			if (isWinner)
			{
				winnerCount++;

				player.SetRandomClass();
				player.Regenerate();

				CreateParticle(i, "Micro_Win_Sparkle", 10.0);
				CreateParticle(i, "Micro_Cheer_Winner", 10.0, true);
				CreateParticle(i, "unusual_aaa_aaa", 10.0, true);

				TF2_AddCondition(i, TFCond_Kritzkrieged, 10.0);

				PushArrayCell(winners, i);
			}
			else
			{
				SetCommandFlags("thirdperson", GetCommandFlags("thirdperson") & (~FCVAR_CHEAT));
				ClientCommand(i, "thirdperson");
				SetCommandFlags("thirdperson", GetCommandFlags("thirdperson") & (FCVAR_CHEAT));
						
				TF2_StunPlayer(i, 8.0, 0.0, TF_STUNFLAGS_LOSERSTATE, 0);
				player.SetHealth(1);
			}
		}
	}

	if (winnerCount > 0)
	{
		for (int i = 0; i < GetArraySize(winners); i++)
		{
			int client = GetArrayCell(winners, i);

			if (winnerCount > 1)
			{
				if (i >= (GetArraySize(winners)-1))
				{
					Format(names, sizeof(names), "%s and {olive}%N{green}", names, client); // "AND" here needs to be fixed!!!
				}
				else
				{
					Format(names, sizeof(names), "%s, {olive}%N{green}", names, client);
				}
			}
			else
			{
				Format(names, sizeof(names), "{olive}%N{green}", client);
			}
		}

		if (winnerCount > 1)
		{
			ReplaceStringEx(names, sizeof(names), ", ", "");
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				if (winnerCount == 1)
				{
					Format(prefix, sizeof(prefix), "{green}%T", "GameOver_WinnerPrefixSingle", i);
				}
				else
				{
					Format(prefix, sizeof(prefix), "{green}%T", "GameOver_WinnerPrefixMultiple", i);
				}

				if (SpecialRoundID == 17)
				{
					CPrintToChat(i, "%s%s %s!", PLUGIN_PREFIX, prefix, names);
				}
				else
				{
					CPrintToChat(i, "%s%s %s {green}with %i points!", PLUGIN_PREFIX, prefix, names, score);
				}
			}
		}
	}
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				Format(prefix, sizeof(prefix), "{green}%T", "GameOver_WinnerPrefixNoOne", i);

				CPrintToChat(i, "%s%s", PLUGIN_PREFIX, prefix);
			}
		}
	}

	ClearArray(winners);
	CloseHandle(winners);
	winners = INVALID_HANDLE;

	CreateTimer(8.0, Timer_GameLogic_GameOverEnd, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_GameOverEnd(Handle timer)
{
	if (GamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		// Intentionally out side of IsClientValid - to cover any possible spectators with stale data.
		PlayerStatus[i] = PlayerStatus_NotWon;
		PlayerScore[i] = 0;
		PlayerMinigamesWon[i] = 0;
		PlayerMinigamesLost[i] = 0;

		Player player = new Player(i);

		if (player.IsValid)
		{
			IsPlayerParticipant[i] = true;
			
			if (IsPlayerWinner[i])
			{
				TF2_SetPlayerPowerPlay(i, false);
				ResetWeapon(i, false);
			
				IsPlayerWinner[i] = false;

				player.DestroyPlayerBuildings(true);
			}

			player.SetGodMode(true);
		}
	}

	BossgameID = 0;
	MinigameID = 0;
	SpecialRoundID = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	MinigamesPlayed = 0;
	
	IsMinigameActive = false;
	IsBonusRound = false;

	IsBlockingDamage = true;
	IsBlockingDeathCommands = true;
	IsBlockingTaunts = true;
	IsOnlyBlockingDamageByPlayers = false;

	BossGameThreshold = GetRandomInt(15, 26);

	SetSpeed();
	SetConVarInt(ConVar_TFFastBuild, 0);

	if (MaxRounds == 0 || RoundsPlayed < MaxRounds)
	{
		ShowPlayerScores(true);
		bool isWaitingForVoteToFinish = false;

		if (MaxRounds != 0 && RoundsPlayed == (MaxRounds / 2))
		{
			#if defined UMC_MAPCHOOSER
			// This should be using UMC_StartVote native, but that requires too many parameters... TODO: update this later on 
			ServerCommand("sm_umc_mapvote 2");
			#else
			InitiateMapChooserVote(MapChange_MapEnd);
			#endif
			
			isWaitingForVoteToFinish = true;
		}

		if (GetRandomInt(0, 2) == 1 || ForceNextSpecialRound)
		{
			// Special Round
			GamemodeID = SPR_GAMEMODEID;
		}
		else
		{
			// Back to normal - use themes.
			GamemodeID = GetRandomInt(0, MaxGamemodesSelectable - 1);
		}

		if (isWaitingForVoteToFinish)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					char header[64];
					Format(header, sizeof(header), "%T", "Intermission_Header", i);

					char body[64];
					Format(body, sizeof(body), "%T", "Intermission_Body", i);

					EmitSoundToClient(i, SYSBGM_WAITING);

					CPrintToChat(i, "%s%s", PLUGIN_PREFIX, header);
					CPrintToChat(i, "%s%s", PLUGIN_PREFIX, body);
				}
			}
		}

		CreateTimer(2.0, Timer_GameLogic_WaitForVoteToFinishIfAny, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		// If any commands are put after this call, they will not be called;
		// The plugin will have already unloaded.
		EndGame();
	}

	RoundsPlayed++;
	return Plugin_Handled;
}

public Action Timer_GameLogic_WaitForVoteToFinishIfAny(Handle timer)
{
	#if defined UMC_MAPCHOOSER
	bool voteIsInProgress = UMC_IsVoteInProgress("core");
	#else
	bool voteIsInProgress = IsVoteInProgress();
	#endif

	if (voteIsInProgress)
	{
		CreateTimer(1.0, Timer_GameLogic_WaitForVoteToFinishIfAny, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			StopSound(i, SNDCHAN_AUTO, SYSBGM_WAITING);
		}
	}

	ClearMinigameCaptionForAll();

	if (GamemodeID == SPR_GAMEMODEID)
	{
		CreateTimer(0.0, Timer_GameLogic_SpecialRoundSelectionStart, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		CreateTimer(0.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundSelectionStart(Handle timer)
{
	if (SpeedLevel == 1.0)
	{
		EmitSoundToAll(SYSBGM_SPECIAL);
	}
	else
	{
		PlaySoundToAll(SYSBGM_SPECIAL);
	}
	
	CreateTimer(0.2, Timer_GameLogic_SpecialRoundChoosing3, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosing3(Handle timer)
{
	CreateTimer(0.3, Timer_GameLogic_SpecialRoundChoosing2, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosing2(Handle timer)
{
	CreateTimer(0.3, Timer_GameLogic_SpecialRoundChoosing1, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosing1(Handle timer)
{
	IsChoosingSpecialRound = true;

	DisplayOverlayToAll(OVERLAY_SPECIALROUND);

	CreateTimer(6.8, Timer_GameLogic_SpecialRoundChoosing0, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_SpecialRoundChoosing0(Handle timer)
{
	#if defined DEBUG
	PrintToChatAll("chose a special round, timer for PrepareForMinigame @ 5.0 from now");
	#endif

	SelectNewSpecialRound();
	PrintSelectedSpecialRound();

	CreateTimer(5.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}