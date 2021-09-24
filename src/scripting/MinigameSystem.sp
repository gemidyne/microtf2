/**
 * MicroTF2 - MinigameSystem.inc
 * 
 * Implements a System for Minigames.
 */

int g_iMinigamesLoadedCount = 0;
int g_iBossgamesLoadedCount = 0;

bool g_bMinigameIsEnabled[MAXIMUM_MINIGAMES];
char g_sDynamicCaptionFunctionName[MAXIMUM_MINIGAMES][64];
bool g_bMinigameHasDynamicCaption[MAXIMUM_MINIGAMES];
bool g_bMinigameBlockedSpecialRound[MAXIMUM_MINIGAMES][SPR_MAX];
bool g_bMinigameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];
float g_fMinigameBlockedOnSpeedsGreaterThan[MAXIMUM_MINIGAMES];
int g_iMinigameMaximumParticipantCount[MAXIMUM_MINIGAMES];
int g_iMinigameMinimumParticipantCount[MAXIMUM_MINIGAMES];

bool g_bBossgameIsEnabled[MAXIMUM_MINIGAMES];
bool g_bBossgameUsesCaption[MAXIMUM_MINIGAMES];
char g_sBossgameDynamicCaptionFunctionName[MAXIMUM_MINIGAMES][64];
bool g_bBossgameHasDynamicCaption[MAXIMUM_MINIGAMES];
bool g_bBossgameBlockedSpecialRound[MAXIMUM_MINIGAMES][SPR_MAX];
bool g_bBossgameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];
float g_fBossgameBlockedOnSpeedsGreaterThan[MAXIMUM_MINIGAMES];

char g_sMinigameBgm[MAXIMUM_MINIGAMES][MAX_PATH_LENGTH];
float g_fMinigameBgmLength[MAXIMUM_MINIGAMES];

char g_sBossgameBgm[MAXIMUM_MINIGAMES][MAX_PATH_LENGTH];
float g_fBossgameBgmLength[MAXIMUM_MINIGAMES];

ArrayList g_hPlayedMinigamePool;
ArrayList g_hPlayedBossgamePool;

#include "MinigameStocks.sp"

// Minigames
#include "Minigames/Minigame1.sp"
#include "Minigames/Minigame2.sp"
#include "Minigames/Minigame3.sp"
#include "Minigames/Minigame4.sp"
#include "Minigames/Minigame5.sp"
#include "Minigames/Minigame6.sp"
#include "Minigames/Minigame7.sp"
#include "Minigames/Minigame8.sp"
#include "Minigames/Minigame9.sp"
#include "Minigames/Minigame10.sp"
#include "Minigames/Minigame11.sp"
#include "Minigames/Minigame12.sp"
#include "Minigames/Minigame13.sp"
#include "Minigames/Minigame14.sp" 
#include "Minigames/Minigame15.sp"
#include "Minigames/Minigame16.sp"
#include "Minigames/Minigame17.sp"
#include "Minigames/Minigame18.sp"
#include "Minigames/Minigame19.sp"
#include "Minigames/Minigame20.sp"
#include "Minigames/Minigame21.sp"
#include "Minigames/Minigame22.sp"
#include "Minigames/Minigame23.sp"
#include "Minigames/Minigame24.sp"
#include "Minigames/Minigame25.sp"
#include "Minigames/Minigame26.sp"
#include "Minigames/Minigame27.sp"
#include "Minigames/Minigame28.sp"
#include "Minigames/Minigame29.sp"
#include "Minigames/Minigame30.sp"

// Bossgames
#include "Bossgames/Bossgame1.sp"
#include "Bossgames/Bossgame2.sp"
#include "Bossgames/Bossgame3.sp"
#include "Bossgames/Bossgame4.sp"
#include "Bossgames/Bossgame5.sp"
#include "Bossgames/Bossgame6.sp"
#include "Bossgames/Bossgame7.sp"
#include "Bossgames/Bossgame8.sp"

public void InitializeMinigames()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Minigame System...");
	#endif

	LoadMinigameData();
	LoadBossgameData();

	LogMessage("Minigame System initialized with %d Minigame(s) and %d Bossgame(s).", g_iMinigamesLoadedCount, g_iBossgamesLoadedCount);

	AddToForward(g_pfOnMapStart, INVALID_HANDLE, MinigameSystem_OnMapStart);
	AddToForward(g_pfOnMapEnd, INVALID_HANDLE, MinigameSystem_OnMapEnd);
}

public void MinigameSystem_OnMapStart()
{
	g_hPlayedMinigamePool = new ArrayList();
	g_hPlayedBossgamePool = new ArrayList();

	for (int i = 1; i <= g_iMinigamesLoadedCount; i++)
	{
		if (strlen(g_sMinigameBgm[i]) == 0)
		{
			continue;
		}

		PreloadSound(g_sMinigameBgm[i]);
	}

	for (int i = 1; i <= g_iBossgamesLoadedCount; i++)
	{
		if (strlen(g_sBossgameBgm[i]) == 0)
		{
			continue;
		}

		PreloadSound(g_sBossgameBgm[i]);
	}
}

public void MinigameSystem_OnMapEnd()
{
	g_hPlayedMinigamePool.Close();
	g_hPlayedBossgamePool.Close();
}

public void LoadMinigameData()
{
	char funcName[64];
	char file[128];

	// Our method of initializing minigames is:
	// Each minigame has a method called Minigame<NUMBER>_EntryPoint
	// This method is invoked and allows the minigame to add itself to the Minigame-cycle and add itself to forwards.

	// Determine count of Minigames that are available.
	BuildPath(Path_SM, file, sizeof(file), "data/microtf2/Minigames.txt");

	KeyValues kv = new KeyValues("Minigames");

	if (!kv.ImportFromFile(file))
	{
		SetFailState("Unable to read Minigames.txt from data/microtf2/");
		kv.Close();
		return;
	}

	if (kv.GotoFirstSubKey())
	{
		do
		{
			int i = GetIdFromSectionName(kv);

			g_iMinigamesLoadedCount++;

			g_bMinigameIsEnabled[i] = kv.GetNum("Enabled", 0) == 1;

			kv.GetString("EntryPoint", funcName, sizeof(funcName));

			Function func = GetFunctionByName(INVALID_HANDLE, funcName);
			if (func != INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, func);
				Call_Finish();
			}
			else
			{
				g_bMinigameIsEnabled[i] = false;
				LogError("Unable to find EntryPoint for Minigame #%i with name: \"%s\". This minigame will not be run.", i, funcName);
				continue;
			}

			kv.GetString("BackgroundMusic", g_sMinigameBgm[i], 128);
			g_fMinigameBgmLength[i] = kv.GetFloat("BackgroundMusic_Length");
			g_bMinigameHasDynamicCaption[i] = kv.GetNum("CaptionIsDynamic", 0) == 1;

			if (g_bMinigameHasDynamicCaption[i])
			{
				kv.GetString("DynamicCaptionMethod", g_sDynamicCaptionFunctionName[i], 64);
			}

			char blockedSpecialRounds[64];
			kv.GetString("BlockedSpecialRounds", blockedSpecialRounds, sizeof(blockedSpecialRounds));

			if (strlen(blockedSpecialRounds) > 0)
			{
				char specialRoundIds[32][6];
				int count = ExplodeString(blockedSpecialRounds, ",", specialRoundIds, 32, 6, false);

				for (int j = 0; j < count; j++)
				{
					int id = StringToInt(specialRoundIds[j]);

					g_bMinigameBlockedSpecialRound[i][id] = true;
				}
			}

			g_bMinigameRequiresMultiplePlayers[i] = kv.GetNum("RequiresMultiplePlayers", 0) == 1;
			g_fMinigameBlockedOnSpeedsGreaterThan[i] = kv.GetFloat("BlockedOnSpeedsHigherThan", 0.0);
			g_iMinigameMaximumParticipantCount[i] = kv.GetNum("MaximumPlayerCount", 0);
			g_iMinigameMinimumParticipantCount[i] = kv.GetNum("MinimumPlayerCount", 0);
		}
		while (kv.GotoNextKey());
	}
 
	kv.Close();
}

public void LoadBossgameData()
{
	char funcName[64];
	char file[128];
	BuildPath(Path_SM, file, sizeof(file), "data/microtf2/Bossgames.txt");

	KeyValues kv = new KeyValues("Bossgames");

	if (!kv.ImportFromFile(file))
	{
		SetFailState("Unable to read Bossgames.txt from data/microtf2/");
		kv.Close();
		return;
	}
 
	if (kv.GotoFirstSubKey())
	{
		do
		{
			int i = GetIdFromSectionName(kv);

			g_bBossgameIsEnabled[i] = kv.GetNum("Enabled", 0) == 1;
			g_iBossgamesLoadedCount++;

			// Get EntryPoint first of all!
			kv.GetString("EntryPoint", funcName, sizeof(funcName));

			Function func = GetFunctionByName(INVALID_HANDLE, funcName);
			if (func != INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, func);
				Call_Finish();
			}
			else
			{
				g_bBossgameIsEnabled[i] = false;
				LogError("Unable to find EntryPoint for Bossgame #%i with name: \"%s\". This bossgame will not be run.", i, funcName);
				continue;
			}

			kv.GetString("BackgroundMusic", g_sBossgameBgm[i], 128);

			g_fBossgameBgmLength[i] = kv.GetFloat("Duration", 30.0);
			g_bBossgameUsesCaption[i] = kv.GetNum("UsesCaption", 0) == 1;
			g_bBossgameHasDynamicCaption[i] = kv.GetNum("CaptionIsDynamic", 0) == 1;

			if (g_bBossgameHasDynamicCaption[i])
			{
				kv.GetString("DynamicCaptionMethod", g_sBossgameDynamicCaptionFunctionName[i], 64);
			}

			char blockedSpecialRounds[64];
			kv.GetString("BlockedSpecialRounds", blockedSpecialRounds, sizeof(blockedSpecialRounds));

			if (strlen(blockedSpecialRounds) > 0)
			{
				char specialRoundIds[32][6];
				int count = ExplodeString(blockedSpecialRounds, ",", specialRoundIds, 32, 6, false);

				for (int j = 0; j < count; j++)
				{
					int id = StringToInt(specialRoundIds[j]);

					g_bBossgameBlockedSpecialRound[i][id] = true;
				}
			}

			g_bBossgameRequiresMultiplePlayers[i] = kv.GetNum("RequiresMultiplePlayers", 0) == 1;
			g_fBossgameBlockedOnSpeedsGreaterThan[i] = kv.GetFloat("BlockedOnSpeedsHigherThan", 0.0);
		}
		while (kv.GotoNextKey());
	}
 
	kv.Close();
}

public void ResetPlayedGamePools()
{
	g_hPlayedMinigamePool.Clear();
	g_hPlayedBossgamePool.Clear();
}

public void DoSelectMinigame()
{
	int forcedMinigameId = g_hConVarPluginForceMinigame.IntValue;
	int rollCount = 0;

	if (g_iSpecialRoundId == 8)
	{
		g_iLastPlayedMinigameId = 0;
		g_iActiveMinigameId = 8;
	}
	else if (forcedMinigameId > 0 && forcedMinigameId <= g_iMinigamesLoadedCount)
	{
		g_iLastPlayedMinigameId = 0;
		g_iActiveMinigameId = forcedMinigameId;
	}
	else
	{
		do
		{
			g_iActiveMinigameId = GetRandomInt(1, g_iMinigamesLoadedCount);
			rollCount++;

			if (g_iMinigamesLoadedCount == 1)
			{
				g_iLastPlayedMinigameId = 0;
			}

			bool recentlyPlayed = g_hPlayedMinigamePool.FindValue(g_iActiveMinigameId) >= 0;

			if (recentlyPlayed)
			{
				g_iActiveMinigameId = g_iLastPlayedMinigameId;

				if (rollCount > (g_iMinigamesLoadedCount * 2))
				{
					// Essentially, start from the beginning again until we're cleared at end of the round
					g_hPlayedMinigamePool.Erase(0);
				}
			}
			else
			{
				if (!g_bMinigameIsEnabled[g_iActiveMinigameId])
				{
					g_iActiveMinigameId = g_iLastPlayedMinigameId;
				}

				if (g_iActiveGamemodeId == SPR_GAMEMODEID && g_bMinigameBlockedSpecialRound[g_iActiveMinigameId][g_iSpecialRoundId])
				{
					// If minigame is blocked on this special round, re-roll
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as its blocked on special round #", g_iActiveMinigameId, g_iSpecialRoundId);
					#endif

					g_iActiveMinigameId = g_iLastPlayedMinigameId;
				}
				else if (g_bMinigameRequiresMultiplePlayers[g_iActiveMinigameId] && (g_iActiveRedParticipantCount == 0 || g_iActiveBlueParticipantCount == 0)) 
				{
					// Minigame requires players on both teams
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as we need players on both teams", g_iActiveMinigameId);
					#endif

					g_iActiveMinigameId = g_iLastPlayedMinigameId;
				}
				else if (g_fMinigameBlockedOnSpeedsGreaterThan[g_iActiveMinigameId] > 0.0 && g_fActiveGameSpeed > g_fMinigameBlockedOnSpeedsGreaterThan[g_iActiveMinigameId])
				{
					// Minigame cannot run on speeds higher than specified
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as speed level exceeds maximum", g_iActiveMinigameId);
					#endif

					g_iActiveMinigameId = g_iLastPlayedMinigameId;
				}
				else if (g_iMinigameMaximumParticipantCount[g_iActiveMinigameId] > 0 && g_iActiveParticipantCount > g_iMinigameMaximumParticipantCount[g_iActiveMinigameId])
				{
					// Current participant count exceeds maximum participant count specified for minigame
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as active participant count exceeds maximum permitted", g_iActiveMinigameId);
					#endif

					g_iActiveMinigameId = g_iLastPlayedMinigameId;
				}
				else if (g_iMinigameMinimumParticipantCount[g_iActiveMinigameId] > 0 && g_iActiveParticipantCount < g_iMinigameMinimumParticipantCount[g_iActiveMinigameId])
				{
					// Current participant count does not meet minimum requirement for minigame
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as active participant count does not meet minimum required for minigame", g_iActiveMinigameId);
					#endif

					g_iActiveMinigameId = g_iLastPlayedMinigameId;
				}
			}
		}
		while (g_iActiveMinigameId == g_iLastPlayedMinigameId);

		g_hPlayedMinigamePool.Push(g_iActiveMinigameId);

		#if defined DEBUG
		PrintToChatAll("[MINIGAMESYS] Chose minigame %i, minigame pool count: %i", g_iActiveMinigameId, g_hPlayedMinigamePool.Length);
		#endif
	}

	PluginForward_SendMinigameSelected(g_iActiveMinigameId);
}

public void DoSelectBossgame()
{
	int forcedBossgameId = g_hConVarPluginForceBossgame.IntValue;
	int rollCount = 0;

	if (forcedBossgameId > 0 && forcedBossgameId <= g_iBossgamesLoadedCount)
	{
		g_iLastPlayedBossgameId = 0;
		g_iActiveBossgameId = forcedBossgameId;
	}
	else
	{
		do
		{
			g_iActiveBossgameId = GetRandomInt(1, g_iBossgamesLoadedCount);
			rollCount++;

			if (g_iBossgamesLoadedCount == 1)
			{
				g_iLastPlayedBossgameId = 0;
			}

			bool recentlyPlayed = g_hPlayedBossgamePool.FindValue(g_iActiveBossgameId) >= 0;

			if (recentlyPlayed)
			{
				g_iActiveBossgameId = g_iLastPlayedBossgameId;

				if (rollCount > (g_iBossgamesLoadedCount * 2))
				{
					// Essentially, start from the beginning again until we're cleared at end of the round
					g_hPlayedBossgamePool.Erase(0);
				}
			}
			else
			{
				if (!g_bBossgameIsEnabled[g_iActiveBossgameId])
				{
					g_iActiveBossgameId = g_iLastPlayedBossgameId;
				}

				if (g_iActiveGamemodeId == SPR_GAMEMODEID && g_bBossgameBlockedSpecialRound[g_iActiveBossgameId][g_iSpecialRoundId])
				{
					// If bossgame is blocked on this special round, re-roll
					g_iActiveBossgameId = g_iLastPlayedBossgameId;
				}
				else if (g_bBossgameRequiresMultiplePlayers[g_iActiveBossgameId])
				{
					if (g_iActiveRedParticipantCount == 0 || g_iActiveBlueParticipantCount == 0)
					{
						// Bossgame requires players on both teams
						g_iActiveBossgameId = g_iLastPlayedBossgameId;
					}
				}
				else if (g_fBossgameBlockedOnSpeedsGreaterThan[g_iActiveBossgameId] > 0.0 && g_fActiveGameSpeed > g_fBossgameBlockedOnSpeedsGreaterThan[g_iActiveBossgameId])
				{
					g_iActiveBossgameId = g_iLastPlayedBossgameId;
				}
			}
		}
		while (g_iActiveBossgameId == g_iLastPlayedBossgameId);

		g_hPlayedBossgamePool.Push(g_iActiveBossgameId);
	}

	#if defined DEBUG
	PrintToChatAll("[MINIGAMESYS] Chose bossgame %i, bossgame pool count: %i", g_iActiveBossgameId, g_hPlayedBossgamePool.Length);
	#endif

	PluginForward_SendBossgameSelected(g_iActiveBossgameId);
}

public void CalculateActiveParticipantCount()
{
	g_iActiveRedParticipantCount = 0;
	g_iActiveBlueParticipantCount = 0;

	for (int j = 1; j <= MaxClients; j++)
	{
		Player player = new Player(j);

		if (player.IsValid && player.IsParticipating)
		{
			switch (player.Team)
			{
				case TFTeam_Red:
					g_iActiveRedParticipantCount++;

				case TFTeam_Blue:
					g_iActiveBlueParticipantCount++;
			}
		}
	}

	g_iActiveParticipantCount = g_iActiveRedParticipantCount + g_iActiveBlueParticipantCount;
}