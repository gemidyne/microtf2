/* 
 * Microgames for Team Fortress 2
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
#define PLUGIN_VERSION "5.0.0"
#define PLUGIN_PREFIX "\x0700FFFF[ \x07FFFF00WarioWare \x0700FFFF] {default}"
#define PLUGIN_MAPPREFIX "warioware_redux_"
//#define PLUGIN_DOPRECACHE 

#define MAXIMUM_MINIGAMES 64
#define SPR_GAMEMODEID 99
#define SPR_MIN 0
#define SPR_MAX 32

#include "Header.sp"
#include "Forwards.sp"
#include "Sounds.sp"
#include "MethodMaps/Player.inc"
#include "Weapons.sp"
#include "Voices.sp"
#include "ConVars.sp"
#include "System.sp"
#include "Commands.sp"
#include "TimelimitManager.sp"
#include "PluginInterop.sp"
#include "Speed.sp"
#include "Hud.sp"
#include "MinigameSystem.sp"
#include "MethodMaps/Minigame.inc"
#include "MethodMaps/Bossgame.inc"
#include "Hooks.sp"
#include "Events.sp"
#include "SpecialRounds.sp"
#include "Internal.sp"
#include "Stocks.sp"

public Plugin myinfo = 
{
	name = "Microgames in Team Fortress 2",
	author = "gemidyne",
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
	if (g_bIsPluginEnabled)
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

	g_bIsPluginEnabled = IsWarioWareMap();

	if (g_bIsPluginEnabled)
	{
		if (g_pfOnMapStart != INVALID_HANDLE)
		{
			Call_StartForward(g_pfOnMapStart);
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

public void OnConfigsExecuted()
{
	if (g_bIsPluginEnabled && g_pfOnConfigsExecuted != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnConfigsExecuted);
		Call_Finish();
	}
}

public void OnMapEnd()
{
	if (g_bIsPluginEnabled && g_pfOnMapEnd != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnMapEnd);
		Call_Finish();
		
		ResetConVars();
	}
}

public Action Timer_GameLogic_EngineInitialisation(Handle timer)
{
	g_eGamemodeStatus = GameStatus_Playing;

	MinigameID = 0;
	BossgameID = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	g_iSpecialRoundId = 0;
	g_iWinnerScorePointsAmount = 1;
	g_iMinigamesPlayedCount = 0;
	g_iNextMinigamePlayedSpeedTestThreshold = 0;
	g_iBossGameThreshold = 20;
	g_iMaxRoundsPlayable = g_hConVarPluginMaxRounds.IntValue;
	g_iTotalRoundsPlayed = 0;
	g_fActiveGameSpeed = 1.0;

	g_bIsMinigameActive = false;
	g_bIsMinigameEnding = false;
	g_bIsMapEnding = false;
	g_bIsGameOver = false;
	g_bIsBlockingTaunts = true;
	g_bIsBlockingKillCommands = true;
	IsBlockingVoices = false;
	g_eDamageBlockMode = EDamageBlockMode_All;

	CreateTimer(0.25, Timer_GameLogic_PrepareForMinigame);
	return Plugin_Handled;
}

public Action Timer_GameLogic_PrepareForMinigame(Handle timer)
{
	if (g_eGamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	g_eGamemodeStatus = GameStatus_Playing;

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Timer_GameLogic_PrepareForMinigame");
	#endif

	if (g_pfOnMinigamePreparePre != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnMinigamePreparePre);
		Call_Finish();
	}

	SetSpeed();

	if (g_iSpecialRoundId == 16)
	{
		g_iWinnerScorePointsAmount = GetRandomInt(2, 14);
	}
	else
	{
		g_iWinnerScorePointsAmount = (g_iMinigamesPlayedCount >= g_iBossGameThreshold ? 5 : 1);
	}

	if (g_iMinigamesPlayedCount >= g_iBossGameThreshold)
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

	if (GamemodeID == SPR_GAMEMODEID && g_iSpecialRoundId == 20)
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

			if (!player.IsParticipating && g_iSpecialRoundId != 9 && g_iSpecialRoundId != 17)
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

			if (g_pfOnMinigamePrepare != INVALID_HANDLE)
			{
				Call_StartForward(g_pfOnMinigamePrepare);
				Call_PushCell(i);
				Call_Finish();
			}

			if (g_iSpecialRoundId == 16)
			{
				char buffer[128];
				Format(buffer, sizeof(buffer), "%T", "SpecialRound16_Caption_Points", i, g_iWinnerScorePointsAmount);

				PrintCenterText(i, buffer);
			}
			else if (g_iSpecialRoundId == 17)
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

				if (player.IsParticipating && g_iSpecialRoundId != 12 && g_iSpecialRoundId != 17)
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
	if (g_eGamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] Timer_GameLogic_StartMinigame called - Starting Forward Calls for OnMinigameSelectedPre");
	#endif

	if (g_pfOnMinigameSelectedPre != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnMinigameSelectedPre);
		Call_Finish();
	}

	if (g_iSpecialRoundId == 7 && BossgameID > 0)
	{
		g_fActiveGameSpeed = 0.7;
	}

	SetSpeed();

	g_iCenterHudUpdateFrame = 999;
	g_bIsMinigameActive = true;

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

				if (strlen(MinigameMusic[MinigameID]) > 0)
				{
					PlaySoundToPlayer(i, MinigameMusic[MinigameID]);
					PlaySoundToPlayer(i, SYSFX_CLOCK);
				}
			}
			
			if (player.IsValid && player.IsParticipating)
			{
				if (isCaptionDynamic)
				{
					Call_StartFunction(INVALID_HANDLE, func);
					Call_PushCell(i);
					Call_Finish();
				}

				if (g_pfOnMinigameSelected != INVALID_HANDLE)
				{
					Call_StartForward(g_pfOnMinigameSelected);
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

	if (g_pfOnMinigameSelectedPost != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnMinigameSelectedPost);
		Call_Finish();
	}

	if (MinigameID > 0)
	{
		CreateTimer(minigame.Duration, Timer_GameLogic_EndMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer((minigame.Duration - 0.5), Timer_GameLogic_OnPreFinish, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (BossgameID > 0)
	{
		g_hActiveGameTimer = CreateTimer(bossgame.Duration, Timer_GameLogic_EndMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, Timer_RemoveBossOverlay, _, TIMER_FLAG_NO_MAPCHANGE);
		g_hBossCheckTimer = CreateTimer(5.0, Timer_CheckBossEnd, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		ThrowError("MinigameID and BossgameID are both 0: this should never happen.");
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_EndMinigame(Handle timer)
{
	g_bIsMinigameEnding = true;

	SetSpeed();

	if (g_pfOnMinigameFinish != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnMinigameFinish);
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
		if (g_hBossCheckTimer != INVALID_HANDLE)
		{
			// Closes the Boss Check Timer.
			KillTimer(g_hBossCheckTimer);
			g_hBossCheckTimer = INVALID_HANDLE;
		}

		returnedFromBoss = true;
		playAnotherBossgame = (g_iSpecialRoundId == 10 && g_iMinigamesPlayedCount == g_iBossGameThreshold);

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame)
			{
				StopSound(i, SNDCHAN_AUTO, BossgameMusic[PreviousBossgameID]);
			}
		}
	}

	g_bIsMinigameActive = false;
	g_bIsMinigameEnding = false;
	g_iMinigamesPlayedCount++;
	MinigameID = 0;
	BossgameID = 0;

	g_bIsBlockingKillCommands = true;
	g_bIsBlockingTaunts = true;
	g_eDamageBlockMode = EDamageBlockMode_All;
	g_bForceCalculationCritical = false;
	IsBlockingVoices = false;

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

				bool showFailure = ((g_iSpecialRoundId == 17 && player.IsParticipating) || g_iSpecialRoundId != 17);

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

					if (g_iSpecialRoundId != 12)
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

					if (g_iSpecialRoundId == 17)
					{
						player.IsParticipating = false;
						PrintCenterText(i, "%T", "SpecialRound_SuddenDeath_PlayerKnockOutNotification", i);
					}

					if (g_iSpecialRoundId == 18)
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

				player.Score += g_iWinnerScorePointsAmount;
				player.MinigamesWon++;

				if (g_iSpecialRoundId != 12)
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

			if (g_pfOnMinigameFinishPost != INVALID_HANDLE)
			{
				Call_StartForward(g_pfOnMinigameFinishPost);
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

	if (g_iSpecialRoundId == 11)
	{
		SetTeamScore(view_as<int>(TFTeam_Red), CalculateTeamScore(TFTeam_Red));
		SetTeamScore(view_as<int>(TFTeam_Blue), CalculateTeamScore(TFTeam_Blue));
	}
	else
	{
		SetTeamScore(view_as<int>(TFTeam_Red), 0);
		SetTeamScore(view_as<int>(TFTeam_Blue), 0);
	}

	if (g_iSpecialRoundId == 17)
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
			g_iBossGameThreshold = 99999;
		}
	}
	else if (g_iBossGameThreshold > 75)
	{
		// Maybe it will be funny if we let the plugin free for a bit,
		// but we *must* constrain it to a max of 75 if something goes wrong ;)

		g_iBossGameThreshold = g_iMinigamesPlayedCount;
	}

	if (TrySpeedChangeEvent())
	{
		CreateTimer(2.0, Timer_GameLogic_SpeedChange, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}

	if ((g_iSpecialRoundId != 10 && g_iMinigamesPlayedCount == g_iBossGameThreshold && !playAnotherBossgame) || (g_iSpecialRoundId == 10 && (g_iMinigamesPlayedCount == g_iBossGameThreshold || playAnotherBossgame)))
	{
		CreateTimer(2.0, Timer_GameLogic_BossTime, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}
	else if (g_iMinigamesPlayedCount > g_iBossGameThreshold && !playAnotherBossgame)
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
	if (g_pfOnMinigameFinishPre != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnMinigameFinishPre);
		Call_Finish();
	}

	return Plugin_Handled;
}

public Action Timer_GameLogic_SpeedChange(Handle timer)
{
	bool down = g_iSpecialRoundId == 1;

	ExecuteSpeedEvent();

	if (g_iSpecialRoundId == 20)
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
	g_fActiveGameSpeed = 1.0;
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
	if (g_eGamemodeStatus != GameStatus_Playing)
	{
		ResetGamemode();
		return Plugin_Stop;
	}

	#if defined DEBUG
	PrintToChatAll("[DEBUG] GameOverStart");
	#endif

	g_bForceCalculationCritical = false;
	g_bIsBlockingKillCommands = false;
	g_bIsBlockingTaunts = false;
	IsBlockingVoices = false;
	g_eDamageBlockMode = EDamageBlockMode_WinnersOnly;
	g_bIsGameOver = true;
	g_fActiveGameSpeed = 1.0;
	SetSpeed();

	g_hConVarTFFastBuild.BoolValue = true;

	int score = g_iSpecialRoundId == 9 
		? GetLowestScore() 
		: GetHighestScore();

	int winnerCount = 0;
	Handle winners = CreateArray();

	bool isWinner = false;

	int redTeamScore = CalculateTeamScore(TFTeam_Red);
	int blueTeamScore = CalculateTeamScore(TFTeam_Blue);
	TFTeam overallWinningTeam;
	bool teamsHaveSameScore = redTeamScore == blueTeamScore;

	if (g_iSpecialRoundId == 11 && !teamsHaveSameScore)
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
	
			switch (g_iSpecialRoundId)
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
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsInGame && !player.IsBot)
			{
				if (g_iSpecialRoundId == 11)
				{
					if (teamsHaveSameScore)
					{
						player.PrintChatText("%T", "GameOver_WinningTeam_Stalemate", player.ClientId);
					}
					else if (overallWinningTeam == TFTeam_Red)
					{
						player.PrintChatText("%T", "GameOver_WinningTeam_Red", player.ClientId, redTeamScore);
					}
					else if (overallWinningTeam == TFTeam_Blue)
					{
						player.PrintChatText("%T", "GameOver_WinningTeam_Blue", player.ClientId, blueTeamScore);
					}

					continue;
				}

				char prefix[256];
				char names[1024];

				for (int winnerId = 0; winnerId < GetArraySize(winners); winnerId++)
				{
					Player winner = new Player(GetArrayCell(winners, winnerId));

					char name[64];

					if (winner.Team == TFTeam_Red)
					{
						Format(name, sizeof(name), "{red}%N", winner.ClientId);
					}
					else if (winner.Team == TFTeam_Blue)
					{
						Format(name, sizeof(name), "{blue}%N", winner.ClientId);
					}
					else
					{
						Format(name, sizeof(name), "{white}%N", winner.ClientId);
					}

					if (winnerCount > 1)
					{
						if (winnerId >= (GetArraySize(winners)-1))
						{
							Format(names, sizeof(names), "%T", "GameOver_WinnersAnd", player.ClientId, names, name);
						}
						else
						{
							Format(names, sizeof(names), "%s, %s{default}", names, name);
						}
					}
					else
					{
						Format(names, sizeof(names), name);
					}
				}

				if (winnerCount > 1)
				{
					ReplaceStringEx(names, sizeof(names), ", ", "");
				}

				if (winnerCount == 1)
				{
					Format(prefix, sizeof(prefix), "%T", "GameOver_WinnerPrefixSingle", player.ClientId);
				}
				else
				{
					Format(prefix, sizeof(prefix), "%T", "GameOver_WinnerPrefixMultiple", player.ClientId);
				}

				if (g_iSpecialRoundId == 17)
				{
					player.PrintChatText("%s %s{default}!", prefix, names);
				}
				else
				{
					player.PrintChatText("%T", "GameOver_WinnerSuffix", i, prefix, names, score);
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
				player.PrintChatText("%T", "GameOver_WinnerPrefixNoOne", player.ClientId);
			}
		}
	}

	ClearArray(winners);
	CloseHandle(winners);
	winners = INVALID_HANDLE;

	if (g_pfOnGameOverStart != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnGameOverStart);
		Call_Finish();
	}

	CreateTimer(bgmDuration, Timer_GameLogic_GameOverEnd, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Timer_GameLogic_GameOverEnd(Handle timer)
{
	if (g_eGamemodeStatus != GameStatus_Playing)
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
	g_iSpecialRoundId = 0;
	PreviousMinigameID = 0;
	PreviousBossgameID = 0;
	g_iMinigamesPlayedCount = 0;
	g_iNextMinigamePlayedSpeedTestThreshold = 0;

	g_iTotalRoundsPlayed++;
	
	g_bIsMinigameActive = false;
	g_bIsGameOver = false;

	PlayedMinigamePool.Clear();
	PlayedBossgamePool.Clear();

	g_bIsBlockingKillCommands = true;
	g_bIsBlockingTaunts = true;
	IsBlockingVoices = false;
	g_eDamageBlockMode = EDamageBlockMode_All;

	g_iBossGameThreshold = g_hConVarPluginForceBossgameThreshold.IntValue > 0 
		? g_hConVarPluginForceBossgameThreshold.IntValue
		: GetRandomInt(15, 26);

	SetSpeed();

	g_hConVarTFFastBuild.BoolValue = false;

	bool hasTimelimit = TimelimitManager_HasTimeLimit();

	if ((!hasTimelimit && (g_iMaxRoundsPlayable == 0 || g_iTotalRoundsPlayed < g_iMaxRoundsPlayable)) || (hasTimelimit && !TimelimitManager_HasExceededTimeLimit()))
	{
		bool isWaitingForVoteToFinish = false;

		if (PluginForward_HasMapIntegrationLoaded() && !hasTimelimit && g_hConVarPluginIntermissionEnabled.BoolValue && g_iMaxRoundsPlayable != 0 && g_iTotalRoundsPlayed == (g_iMaxRoundsPlayable / 2))
		{
			PluginForward_StartMapVote();
			isWaitingForVoteToFinish = true;
		}

		if (GetRandomInt(0, 2) == 1 || g_bForceSpecialRound)
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
		g_bHideHudGamemodeText = true;

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
	if (g_hConVarPluginIntermissionEnabled.BoolValue && !TimelimitManager_HasTimeLimit() && PluginForward_HasMapIntegrationLoaded())
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
		g_bHideHudGamemodeText = false;
		CreateTimer(0.0, Timer_GameLogic_PrepareForMinigame, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}