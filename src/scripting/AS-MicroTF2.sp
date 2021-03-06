/* 
 * WarioWare for TF2 (formerly MicroTF2)
 * Copyright (C) 2010 - 2020 Gemidyne Softworks.
 *
 * https://www.gemidyne.com/
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <tf_econ_data>
#include <warioware>

#undef REQUIRE_PLUGIN

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS

#include <sdkhooks>
#include <steamtools>
#include <tf2items>
#include <tf2attributes>

#pragma newdecls required


/**
 * Defines
 */
//#define DEBUG
//#define LOGGING_STARTUP
#define PLUGIN_VERSION "4.2.0"
#define PLUGIN_PREFIX "\x0700FFFF[ \x07FFFF00WarioWare \x0700FFFF] {default}"
#define PLUGIN_MAPPREFIX "warioware_redux_"
//#define PLUGIN_DOPRECACHE 

#define MAXIMUM_MINIGAMES 64
#define SPR_GAMEMODEID 99
#define SPR_MIN 0
#define SPR_MAX 32

#include "Header.sp"
#include "Forwards.sp"
#include "MethodMaps/Player.inc"
#include "Weapons.sp"
#include "Voices.sp"
#include "Sounds.sp"
#include "System.sp"
#include "Commands.sp"
#include "TimelimitManager.sp"
#include "PluginInterop.sp"
#include "Speed.sp"
#include "Hud.sp"
#include "MinigameSystem.sp"
#include "MethodMaps/Minigame.inc"
#include "MethodMaps/Bossgame.inc"
#include "PrecacheSystem.sp"
#include "Hooks.sp"
#include "Events.sp"
#include "SpecialRounds.sp"
#include "Internal.sp"
#include "Stocks.sp"
#include "PrecacheManifest.sp"

public Plugin myinfo = 
{
	name = "WarioWare REDUX",
	author = "Gemidyne Softworks / Team WarioWare",
	description = "Yet another WarioWare gamemode for Team Fortress 2",
	version = PLUGIN_VERSION,
	url = "https://www.gemidyne.com/"
}

public void OnPluginStart()
{
	InitializeSystem();
}

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
	RegPluginLibrary("warioware");
	InitializePluginNatives();

	return APLRes_Success;
}

public void OnPluginEnd()
{
	if (IsPluginEnabled)
	{
		ResetConVars();
	}
}

public void OnMapStart()
{
	AddServerTag("warioware");
	AddServerTag("wario ware");
	AddServerTag("microtf2");
	AddServerTag("minigames");
	AddServerTag("mini games");
	AddServerTag("microgames");
	AddServerTag("micro games");

	IsPluginEnabled = IsWarioWareMap();

	if (IsPluginEnabled)
	{
		if (GlobalForward_OnMapStart != INVALID_HANDLE)
		{
			Call_StartForward(GlobalForward_OnMapStart);
			Call_Finish();
		}
		else
		{
			SetFailState("WarioWare failed to initialise: ForwardSystem failed to start.");
		}

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				AttachPlayerHooks(i);
			}
		}
	}
}

public void OnMapEnd()
{
	if (IsPluginEnabled && GlobalForward_OnMapEnd != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnMapEnd);
		Call_Finish();
		
		ResetConVars();
	}
}

public Action Timer_GameLogic_EngineInitialisation(Handle timer)
{
	GamemodeStatus = GameStatus_Playing;

	MinigameID = 0;
	BossgameID = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	SpecialRoundID = 0;
	ScoreAmount = 1;
	MinigamesPlayed = 0;
	NextMinigamePlayedSpeedTestThreshold = 0;
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

	CreateTimer(0.25, Timer_GameLogic_PrepareForMinigame);
	return Plugin_Handled;
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

	if (GlobalForward_OnMinigamePreparePre != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnMinigamePreparePre);
		Call_Finish();
	}

	SetSpeed();

	if (SpecialRoundID == 16)
	{
		ScoreAmount = GetRandomInt(2, 14);
	}
	else
	{
		ScoreAmount = (MinigamesPlayed >= BossGameThreshold ? 5 : 1);
	}

	if (MinigamesPlayed >= BossGameThreshold)
	{
		DoSelectBossgame();
	}
	else
	{
		DoSelectMinigame();
	}

	int count = SystemMusicCount[GamemodeID][SYSMUSIC_PREMINIGAME];
	int selectedBgmIdx = GetRandomInt(0, count-1);

	float duration = SystemMusicLength[GamemodeID][SYSMUSIC_PREMINIGAME][selectedBgmIdx];

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

			if (!player.IsParticipating && SpecialRoundID != 9 && SpecialRoundID != 17)
			{
				// If not a participant, and not Sudden Death, then they should now be a participant.
				player.IsParticipating = true;
			}

			player.ResetWeapon(false);
			player.SetCollisionsEnabled(false);
			player.SetGodMode(true);
			player.ResetHealth();
			player.SetGlow(false);
			player.SetGravity(1.0);

			SetClientViewEntity(i, i);

			ClientCommand(i, "r_cleardecals");

			player.Status = PlayerStatus_NotWon;

			if (GlobalForward_OnMinigamePrepare != INVALID_HANDLE)
			{
				Call_StartForward(GlobalForward_OnMinigamePrepare);
				Call_PushCell(i);
				Call_Finish();
			}

			if (SpecialRoundID == 16)
			{
				char buffer[128];
				Format(buffer, sizeof(buffer), "%T", "SpecialRound16_Caption_Points", i, ScoreAmount);

				PrintCenterText(i, buffer);
			}
			else if (SpecialRoundID == 17)
			{
				char buffer[4096];

				char names[2048];
				int currentPlayers = 0;
				int maxPlayers = 0;

				for (int j = 1; j <= MaxClients; j++)
				{
					Player p = new Player(j);

					if (p.IsValid)
					{
						maxPlayers++;

						if (p.IsParticipating)
						{
							currentPlayers++;

							if (currentPlayers <= 7)
							{
								Format(names, sizeof(names), "%s%N\n", names, j);
							}
						}
					}
				}

				if (currentPlayers > 7)
				{
					Format(names, sizeof(names), "%T", "SpecialRound17_Caption_AndMore", i, names, (currentPlayers  - 7));
				}

				Format(buffer, sizeof(buffer), "%T", "SpecialRound17_Caption_Full", i, currentPlayers, maxPlayers, names);
				PrintCenterText(i, buffer);
			}

			if (duration >= 1.0)
			{
				player.DisplayOverlay(OVERLAY_BLANK);
				player.SetCaption("");

				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_PREMINIGAME][selectedBgmIdx]);

				if (player.IsParticipating && SpecialRoundID != 12 && SpecialRoundID != 17)
				{
					// Print localised annotations
					for (int j = 1; j <= MaxClients; j++)
					{
						Player annotationViewer = new Player(j);

						if (annotationViewer.IsInGame && !annotationViewer.IsBot)
						{
							char score[32];
							Format(score, sizeof(score), "%T", "Hud_Score_Default", j, player.Score);
							annotationViewer.ShowAnnotation(player.ClientId, 3.0, score);
						}
					}
				}
			}
		}
		else if (player.IsInGame && player.Team == TFTeam_Spectator)
		{
			player.Status = PlayerStatus_NotWon;
			player.DisplayOverlay(OVERLAY_BLANK);
			player.SetCaption("");
			
			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_PREMINIGAME][selectedBgmIdx]);
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

	g_iCenterHudUpdateFrame = 999;
	IsMinigameActive = true;

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Preparing clients..");
	#endif

	bool isCaptionDynamic;
	Function func = INVALID_FUNCTION;

	Minigame minigame = new Minigame(MinigameID);
	Bossgame bossgame = new Bossgame(BossgameID);

	if (minigame.HasDynamicCaption || bossgame.HasDynamicCaption)
	{
		isCaptionDynamic = true;
	}

	if (isCaptionDynamic)
	{
		char funcName[64];

		if (MinigameID > 0)
		{
			minigame.GetDynamicCaptionFunctionName(funcName, sizeof(funcName));
		}
		else if (BossgameID > 0)
		{
			bossgame.GetDynamicCaptionFunctionName(funcName, sizeof(funcName));
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

		if (player.IsInGame)
		{
			if (BossgameID > 0) 
			{
				if (!isCaptionDynamic)
				{
					char text[64];
					char translationKey[32];

					Format(translationKey, sizeof(translationKey), "Bossgame%d_Caption", BossgameID);
					Format(text, sizeof(text), "%T", translationKey, player.ClientId);

					player.SetCaption(text);
				}

				if (strlen(BossgameMusic[BossgameID]) > 0)
				{
					PlaySoundToPlayer(i, BossgameMusic[BossgameID]);
				}
			}
			else if (MinigameID > 0)
			{
				if (!isCaptionDynamic)
				{
					char text[64];
					char translationKey[32];

					Format(translationKey, sizeof(translationKey), "Minigame%d_Caption", MinigameID);
					Format(text, sizeof(text), "%T", translationKey, player.ClientId);

					player.SetCaption(text);
				}

				PlaySoundToPlayer(i, MinigameMusic[MinigameID]);
				PlaySoundToPlayer(i, SYSFX_CLOCK);
			}
			
			if (player.IsValid && player.IsParticipating)
			{
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

			if (player.HasCaption() && !player.IsUsingLegacyDirectX)
			{
				player.DisplayOverlay(OVERLAY_MINIGAMEBLANK);
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
		CreateTimer(minigame.Duration, Timer_GameLogic_EndMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer((minigame.Duration - 0.5), Timer_GameLogic_OnPreFinish, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (BossgameID > 0)
	{
		Handle_ActiveGameTimer = CreateTimer(bossgame.Duration, Timer_GameLogic_EndMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, Timer_RemoveBossOverlay, _, TIMER_FLAG_NO_MAPCHANGE);
		Handle_BossCheckTimer = CreateTimer(5.0, Timer_CheckBossEnd, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		ThrowError("MinigameID and BossgameID are both 0: this should never happen.");
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_EndMinigame(Handle timer)
{
	IsMinigameEnding = true;

	SetSpeed();

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
			Player player = new Player(i);

			if (player.IsInGame)
			{
				StopSound(i, SNDCHAN_AUTO, BossgameMusic[PreviousBossgameID]);
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
	ForceCalculationCritical = false;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		player.SetCaption("");

		if (player.IsValid)
		{
			if (!player.IsAlive || returnedFromBoss)
			{
				player.Respawn();
			}

			player.SetGravity(1.0);
			player.SetCustomHudText("");
			player.ClearConditions();

			if (player.Status == PlayerStatus_Failed || player.Status == PlayerStatus_NotWon)
			{
				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_FAILURE][0]); 
				PlayNegativeVoice(i);

				bool showFailure = ((SpecialRoundID == 17 && player.IsParticipating) || SpecialRoundID != 17);

				if (showFailure)
				{
					if (player.IsUsingLegacyDirectX)
					{
						char text[64];
						Format(text, sizeof(text), "%T", "General_Failure", player.ClientId);
						player.SetCaption(text);
						player.DisplayOverlay(OVERLAY_BLANK);
					}
					else
					{
						player.DisplayOverlay(OVERLAY_FAIL);
					}
				}
				else
				{
					player.DisplayOverlay(OVERLAY_BLANK);
				}

				if (player.IsParticipating)
				{
					#if defined DEBUG
					PrintToChatAll("[DEBUG] %N: Participant, NotWon/Failed", i);
					#endif

					if (returnedFromBoss)
					{
						PluginForward_SendPlayerFailedBossgame(player.ClientId, PreviousBossgameID);
					}
					else
					{
						PluginForward_SendPlayerFailedMinigame(player.ClientId, PreviousMinigameID);
					}

					player.SetHealth(1);
					player.SetGlow(true);

					player.MinigamesLost++;

					if (SpecialRoundID != 12)
					{
						// Print localised annotations
						for (int j = 1; j <= MaxClients; j++)
						{
							Player annotationViewer = new Player(j);

							if (annotationViewer.IsInGame && !annotationViewer.IsBot)
							{
								char text[32];
								Format(text, sizeof(text), "%T", "General_Loser", j);
								annotationViewer.ShowAnnotation(player.ClientId, 2.0, text);
							}
						}
					}

					if (SpecialRoundID == 17)
					{
						player.IsParticipating = false;
						PrintCenterText(i, "%T", "SpecialRound_SuddenDeath_PlayerKnockOutNotification", i);
					}

					if (SpecialRoundID == 18)
					{
						player.Score = 0;
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

				if (returnedFromBoss)
				{
					PluginForward_SendPlayerWinBossgame(player.ClientId, PreviousBossgameID);
				}
				else
				{
					PluginForward_SendPlayerWinMinigame(player.ClientId, PreviousMinigameID);
				}

				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_WINNER][0]);
				PlayPositiveVoice(i);

				if (player.IsUsingLegacyDirectX)
				{
					char text[64];
					Format(text, sizeof(text), "%T", "General_Success", player.ClientId);
					player.SetCaption(text);
					player.DisplayOverlay(OVERLAY_BLANK);
				}
				else
				{
					player.DisplayOverlay(OVERLAY_WON);
				}

				player.ResetHealth();
				player.SetGlow(true);

				player.Score += ScoreAmount;
				player.MinigamesWon++;

				if (SpecialRoundID != 12)
				{
					// Print localised annotations
					for (int j = 1; j <= MaxClients; j++)
					{
						Player annotationViewer = new Player(j);

						if (annotationViewer.IsInGame && !annotationViewer.IsBot)
						{
							char text[32];
							Format(text, sizeof(text), "%T", "General_Winner", j);
							annotationViewer.ShowAnnotation(player.ClientId, 2.0, text);
						}
					}
				}
			}

			player.Status = PlayerStatus_NotWon;
			player.SetCollisionsEnabled(false);
			player.SetGodMode(true);
			player.ResetWeapon(false);

			if (GlobalForward_OnMinigameFinishPost != INVALID_HANDLE)
			{
				Call_StartForward(GlobalForward_OnMinigameFinishPost);
				Call_PushCell(i);
				Call_Finish();
			}
		}
		else if (player.IsInGame && !player.IsBot && player.Team == TFTeam_Spectator)
		{
			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_FAILURE][0]); 
			PlayNegativeVoice(i);

			player.DisplayOverlay(OVERLAY_BLANK);
		}
	}

	if (SpecialRoundID == 11)
	{
		SetTeamScore(view_as<int>(TFTeam_Red), CalculateTeamScore(TFTeam_Red));
		SetTeamScore(view_as<int>(TFTeam_Blue), CalculateTeamScore(TFTeam_Blue));
	}
	else
	{
		SetTeamScore(view_as<int>(TFTeam_Red), 0);
		SetTeamScore(view_as<int>(TFTeam_Blue), 0);
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

	if (TrySpeedChangeEvent())
	{
		CreateTimer(2.0, Timer_GameLogic_SpeedChange, _, TIMER_FLAG_NO_MAPCHANGE);
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
	bool down = SpecialRoundID == 1;

	ExecuteSpeedEvent();

	if (SpecialRoundID == 20)
	{
		// In Non-stop, speed events should not be announced!
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid)
			{
				player.SetGlow(false);
			}
		}

		CreateTimer(0.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		int count = SystemMusicCount[GamemodeID][SYSMUSIC_SPEEDUP];
		int selectedBgmIdx = GetRandomInt(0, count-1);

		float duration = SystemMusicLength[GamemodeID][SYSMUSIC_SPEEDUP][selectedBgmIdx];

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && !player.IsBot)
			{
				if (player.IsValid)
				{
					player.SetGlow(false);
				}
				
				if (player.IsUsingLegacyDirectX)
				{
					player.DisplayOverlay(OVERLAY_BLANK);

					char text[64];
					Format(text, sizeof(text), "%T", down ? "General_SpeedDown" : "General_SpeedUp", player.ClientId);
					player.SetCaption(text);
				}
				else
				{
					player.DisplayOverlay((down ? OVERLAY_SPEEDDN : OVERLAY_SPEEDUP));
				}

				PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_SPEEDUP][selectedBgmIdx]);
			}
		}

		CreateTimer(duration, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_BossTime(Handle timer)
{
	SpeedLevel = 1.0;
	SetSpeed();

	int count = SystemMusicCount[GamemodeID][SYSMUSIC_BOSSTIME];
	int selectedBgmIdx = GetRandomInt(0, count-1);

	float duration = SystemMusicLength[GamemodeID][SYSMUSIC_BOSSTIME][selectedBgmIdx];

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			if (player.IsValid)
			{
				player.SetGlow(false);
			}

			if (player.IsUsingLegacyDirectX)
			{
				char text[64];
				Format(text, sizeof(text), "%T", "General_BossTime", player.ClientId);
				player.SetCaption(text);
				player.DisplayOverlay(OVERLAY_BLANK);
			}
			else
			{
				player.DisplayOverlay(OVERLAY_BOSS);
			}

			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_BOSSTIME][selectedBgmIdx]);
		}
	}

	CreateTimer(duration, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
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

	ForceCalculationCritical = false;
	IsBlockingDamage = false;
	IsBlockingDeathCommands = false;
	IsBlockingTaunts = false;
	IsOnlyBlockingDamageByPlayers = false;
	IsBonusRound = true;
	SpeedLevel = 1.0;
	SetSpeed();

	SetConVarInt(ConVar_TFFastBuild, 1);

	int score = SpecialRoundID == 9 
		? GetLowestScore() 
		: GetHighestScore();

	int winnerCount = 0;
	Handle winners = CreateArray();
	char prefix[128];
	char names[1024];
	bool isWinner = false;

	int redTeamScore = CalculateTeamScore(TFTeam_Red);
	int blueTeamScore = CalculateTeamScore(TFTeam_Blue);
	TFTeam overallWinningTeam;
	bool teamsHaveSameScore = redTeamScore == blueTeamScore;

	if (SpecialRoundID == 11 && !teamsHaveSameScore)
	{
		overallWinningTeam = redTeamScore > blueTeamScore
			? TFTeam_Red
			: TFTeam_Blue;
	}

	int selectedBgmCount = SystemMusicCount[GamemodeID][SYSMUSIC_GAMEOVER];
	int selectedBgmIdx = GetRandomInt(0, selectedBgmCount-1);

	float bgmDuration = SystemMusicLength[GamemodeID][SYSMUSIC_GAMEOVER][selectedBgmIdx];

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid)
		{
			if (GamemodeID == SPR_GAMEMODEID)
			{
				player.PrintCenterTextLocalised("GameOver_SpecialRoundHasFinished");
			}

			if (player.IsUsingLegacyDirectX)
			{
				char text[64];
				Format(text, sizeof(text), "%T", "General_GameOver", player.ClientId);
				player.SetCaption(text);
				player.DisplayOverlay(OVERLAY_BLANK);
			}
			else
			{
				player.DisplayOverlay(OVERLAY_GAMEOVER);
			}

			PlaySoundToPlayer(i, SystemMusic[GamemodeID][SYSMUSIC_GAMEOVER][selectedBgmIdx]);

			SetEntityRenderColor(i, 255, 255, 255, 255);
			SetEntityRenderMode(i, RENDER_NORMAL);
	
			switch (SpecialRoundID)
			{
				case 9:
				{
					isWinner = player.Score == score;
				}

				case 11:
				{
					isWinner = teamsHaveSameScore || player.Team == overallWinningTeam;
				}

				case 17:
				{
					isWinner = player.IsParticipating;
				}

				default:
				{
					isWinner = player.Score >= score;
				}
			}

			player.IsWinner = isWinner;
			player.SetGodMode(isWinner);
			player.SetCollisionsEnabled(false);
			player.IsParticipating = true;

			if (isWinner)
			{
				winnerCount++;

				PluginForward_SendPlayerWinRound(i, player.Score);

				player.SetRandomClass();
				player.Regenerate();
				player.SetViewModelVisible(true);

				if (winnerCount <= 5)
				{
					CreateParticle(i, "Micro_Win_Sparkle", 10.0);
					//CreateParticle(i, "Micro_Cheer_Winner", 10.0, true);
					CreateParticle(i, "unusual_aaa_aaa", 10.0, true);
				}
				
				player.AddCondition(TFCond_Kritzkrieged, 10.0);

				PushArrayCell(winners, i);
			}
			else
			{
				PluginForward_SendPlayerLoseRound(i, player.Score);

				player.SetThirdPersonMode(true);
						
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
					Format(names, sizeof(names), "%s & {olive}%N{green}", names, client); // "AND" here needs to be fixed!!!
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
				if (SpecialRoundID == 11)
				{
					if (teamsHaveSameScore)
					{
						CPrintToChat(i, "%T", "GameOver_WinningTeam_Stalemate", i, PLUGIN_PREFIX);
					}
					else if (overallWinningTeam == TFTeam_Red)
					{
						CPrintToChat(i, "%T", "GameOver_WinningTeam_Red", i, PLUGIN_PREFIX, redTeamScore);
					}
					else if (overallWinningTeam == TFTeam_Blue)
					{
						CPrintToChat(i, "%T", "GameOver_WinningTeam_Blue", i, PLUGIN_PREFIX, blueTeamScore);
					}

					continue;
				}

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
					CPrintToChat(i, "%T", "GameOver_WinnerSuffix", i, PLUGIN_PREFIX, prefix, names, score);
				}
			}
		}
	}
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && !player.IsBot)
			{
				Format(prefix, sizeof(prefix), "{green}%T", "GameOver_WinnerPrefixNoOne", i);

				player.PrintChatText(prefix);
			}
		}
	}

	ClearArray(winners);
	CloseHandle(winners);
	winners = INVALID_HANDLE;

	if (GlobalForward_OnGameOverStart != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnGameOverStart);
		Call_Finish();
	}

	CreateTimer(bgmDuration, Timer_GameLogic_GameOverEnd, _, TIMER_FLAG_NO_MAPCHANGE);
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
		Player player = new Player(i);

		player.Status = PlayerStatus_NotWon;
		player.Score = 0;
		player.MinigamesWon = 0;
		player.MinigamesLost = 0;

		if (player.IsValid)
		{
			player.IsParticipating = true;
			
			if (player.IsWinner)
			{
				player.ResetWeapon(false);
				player.IsWinner = false;
				player.DestroyPlayerBuildings(true);
			}

			player.SetGodMode(true);
			player.SetViewModelVisible(false);
			player.ClearConditions();
		}
	}

	SetTeamScore(view_as<int>(TFTeam_Red), 0);
	SetTeamScore(view_as<int>(TFTeam_Blue), 0);

	BossgameID = 0;
	MinigameID = 0;
	SpecialRoundID = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	MinigamesPlayed = 0;
	NextMinigamePlayedSpeedTestThreshold = 0;

	RoundsPlayed++;
	
	IsMinigameActive = false;
	IsBonusRound = false;

	PlayedMinigamePool.Clear();
	PlayedBossgamePool.Clear();

	IsBlockingDamage = true;
	IsBlockingDeathCommands = true;
	IsBlockingTaunts = true;
	IsOnlyBlockingDamageByPlayers = false;

	BossGameThreshold = GetConVarInt(ConVar_MTF2ForceBossgameThreshold) > 0 
		? GetConVarInt(ConVar_MTF2ForceBossgameThreshold)
		: GetRandomInt(15, 26);

	SetSpeed();
	SetConVarInt(ConVar_TFFastBuild, 0);

	bool hasTimelimit = TimelimitManager_HasTimeLimit();

	if ((!hasTimelimit && (MaxRounds == 0 || RoundsPlayed < MaxRounds)) || (hasTimelimit && !TimelimitManager_HasExceededTimeLimit()))
	{
		bool isWaitingForVoteToFinish = false;

		if (PluginForward_HasMapIntegrationLoaded() && !hasTimelimit && GetConVarBool(ConVar_MTF2IntermissionEnabled) && MaxRounds != 0 && RoundsPlayed == (MaxRounds / 2))
		{
			PluginForward_StartMapVote();
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

		PluginForward_SendGamemodeChanged(GamemodeID);
		HideHudGamemodeText = true;

		float waitTime;

		if (isWaitingForVoteToFinish)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				Player player = new Player(i);

				if (player.IsInGame && !player.IsBot)
				{
					char header[64];
					Format(header, sizeof(header), "%T", "System_Intermission_Header", i);

					char body[128];
					Format(body, sizeof(body), "%T", "System_Intermission_Body", i);

					char combined[256];
					Format(combined, sizeof(combined), "%s\n%s", header, body);

					player.PrintChatText(combined);
					EmitSoundToClient(i, SYSBGM_WAITING);
				}
			}

			waitTime = 3.0;
		}
		else
		{
			waitTime = 0.0;
		}

		CreateTimer(waitTime, Timer_GameLogic_WaitForVoteToFinishIfAny, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		EndGame();
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_WaitForVoteToFinishIfAny(Handle timer)
{
	if (GetConVarBool(ConVar_MTF2IntermissionEnabled) && !TimelimitManager_HasTimeLimit() && PluginForward_HasMapIntegrationLoaded())
	{
		bool voteHasEnded = PluginForward_HasMapVoteEnded();

		if (!voteHasEnded)
		{
			CreateTimer(1.0, Timer_GameLogic_WaitForVoteToFinishIfAny, _, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Handled;
		}
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
		HideHudGamemodeText = false;
		CreateTimer(0.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}