/**
 * MicroTF2 - MinigameSystem.inc
 * 
 * Implements a System for Minigames.
 */

int MinigamesLoaded = 0;
int BossgamesLoaded = 0;

bool MinigameIsEnabled[MAXIMUM_MINIGAMES];
char MinigameCaptions[MAXIMUM_MINIGAMES][CAPTION_LENGTH];
char MinigameDynamicCaptionFunctions[MAXIMUM_MINIGAMES][64];
bool MinigameCaptionIsDynamic[MAXIMUM_MINIGAMES];
bool MinigameBlockedSpecialRounds[MAXIMUM_MINIGAMES][SPR_MAX];
bool MinigameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];
float MinigameBlockedSpeedsHigherThan[MAXIMUM_MINIGAMES];
int MinigameMaximumParticipantCount[MAXIMUM_MINIGAMES];

bool BossgameIsEnabled[MAXIMUM_MINIGAMES];
char BossgameCaptions[MAXIMUM_MINIGAMES][CAPTION_LENGTH];
char BossgameDynamicCaptionFunctions[MAXIMUM_MINIGAMES][64];
bool BossgameCaptionIsDynamic[MAXIMUM_MINIGAMES];
bool BossgameBlockedSpecialRounds[MAXIMUM_MINIGAMES][SPR_MAX];
bool BossgameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];
float BossgameBlockedSpeedsHigherThan[MAXIMUM_MINIGAMES];

char MinigameMusic[MAXIMUM_MINIGAMES][128];
float MinigameMusicLength[MAXIMUM_MINIGAMES];

char BossgameMusic[MAXIMUM_MINIGAMES][128];
float BossgameLength[MAXIMUM_MINIGAMES];

ArrayList PlayedMinigamePool;
ArrayList PlayedBossgamePool;

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

// Bossgames
#include "Bossgames/Bossgame1.sp"
#include "Bossgames/Bossgame2.sp"
#include "Bossgames/Bossgame3.sp"
#include "Bossgames/Bossgame4.sp"
#include "Bossgames/Bossgame5.sp"
#include "Bossgames/Bossgame6.sp"
#include "Bossgames/Bossgame7.sp"

public void InitializeMinigames()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Minigame System...");
	#endif

	LoadMinigameData();
	LoadBossgameData();

	LogMessage("Minigame System initialized with %d Minigame(s) and %d Bossgame(s).", MinigamesLoaded, BossgamesLoaded);

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, MinigameSystem_OnMapStart);
	AddToForward(GlobalForward_OnMapEnd, INVALID_HANDLE, MinigameSystem_OnMapEnd);
}

public void MinigameSystem_OnMapStart()
{
	PlayedMinigamePool = new ArrayList();
	PlayedBossgamePool = new ArrayList();

	for (int i = 1; i <= MinigamesLoaded; i++)
	{
		if (strlen(MinigameMusic[i]) == 0)
		{
			continue;
		}

		PreloadSound(MinigameMusic[i]);
	}

	for (int i = 1; i <= BossgamesLoaded; i++)
	{
		if (strlen(BossgameMusic[i]) == 0)
		{
			continue;
		}

		PreloadSound(BossgameMusic[i]);
	}
}

public void MinigameSystem_OnMapEnd()
{
	PlayedMinigamePool.Close();
	PlayedBossgamePool.Close();
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

			MinigamesLoaded++;

			MinigameIsEnabled[i] = kv.GetNum("Enabled", 0) == 1;

			kv.GetString("EntryPoint", funcName, sizeof(funcName));

			Function func = GetFunctionByName(INVALID_HANDLE, funcName);
			if (func != INVALID_FUNCTION)
			{
				Call_StartFunction(INVALID_HANDLE, func);
				Call_Finish();
			}
			else
			{
				MinigameIsEnabled[i] = false;
				LogError("Unable to find EntryPoint for Minigame #%i with name: \"%s\". This minigame will not be run.", i, funcName);
				continue;
			}

			kv.GetString("BackgroundMusic", MinigameMusic[i], 128);
			MinigameMusicLength[i] = kv.GetFloat("BackgroundMusic_Length");

			kv.GetString("Caption", MinigameCaptions[i], 64);

			MinigameCaptionIsDynamic[i] = (kv.GetNum("CaptionIsDynamic", 0) == 1);

			if (MinigameCaptionIsDynamic[i])
			{
				kv.GetString("DynamicCaptionMethod", MinigameDynamicCaptionFunctions[i], 64);
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

					MinigameBlockedSpecialRounds[i][id] = true;
				}
			}

			MinigameRequiresMultiplePlayers[i] = kv.GetNum("RequiresMultiplePlayers", 0) == 1;
			MinigameBlockedSpeedsHigherThan[i] = kv.GetFloat("BlockedOnSpeedsHigherThan", 0.0);
			MinigameMaximumParticipantCount[i] = kv.GetNum("MaximumPlayerCount", 0);
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

			BossgameIsEnabled[i] = kv.GetNum("Enabled", 0) == 1;
			BossgamesLoaded++;

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
				BossgameIsEnabled[i] = false;
				LogError("Unable to find EntryPoint for Bossgame #%i with name: \"%s\". This bossgame will not be run.", i, funcName);
				continue;
			}

			kv.GetString("BackgroundMusic", BossgameMusic[i], 128);
			kv.GetString("Caption", BossgameCaptions[i], 64);

			BossgameLength[i] = kv.GetFloat("Duration", 30.0);
			BossgameCaptionIsDynamic[i] = (kv.GetNum("CaptionIsDynamic", 0) == 1);

			if (BossgameCaptionIsDynamic[i])
			{
				kv.GetString("DynamicCaptionMethod", BossgameDynamicCaptionFunctions[i], 64);
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

					BossgameBlockedSpecialRounds[i][id] = true;
				}
			}

			BossgameRequiresMultiplePlayers[i] = kv.GetNum("RequiresMultiplePlayers", 0) == 1;
			BossgameBlockedSpeedsHigherThan[i] = kv.GetFloat("BlockedOnSpeedsHigherThan", 0.0);
		}
		while (kv.GotoNextKey());
	}
 
	kv.Close();
}

public void DoSelectMinigame()
{
	CalculateActiveParticipantCount();

	int forcedMinigameID = GetConVarInt(ConVar_MTF2ForceMinigame);
	int rollCount = 0;

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
		do
		{
			MinigameID = GetRandomInt(1, MinigamesLoaded);
			rollCount++;

			if (MinigamesLoaded == 1)
			{
				PreviousMinigameID = 0;
			}

			bool recentlyPlayed = PlayedMinigamePool.FindValue(MinigameID) >= 0;

			if (recentlyPlayed)
			{
				MinigameID = PreviousMinigameID;

				if (rollCount >= MinigamesLoaded)
				{
					PlayedMinigamePool.Clear();
				}
			}
			else
			{
				if (!MinigameIsEnabled[MinigameID])
				{
					MinigameID = PreviousMinigameID;
				}

				if (GamemodeID == SPR_GAMEMODEID && MinigameBlockedSpecialRounds[MinigameID][SpecialRoundID])
				{
					// If minigame is blocked on this special round, re-roll
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as its blocked on special round #", MinigameID, SpecialRoundID);
					#endif

					MinigameID = PreviousMinigameID;
				}
				else if (MinigameRequiresMultiplePlayers[MinigameID] && (ActiveRedParticipantCount == 0 || ActiveBlueParticipantCount == 0)) 
				{
					// Minigame requires players on both teams
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as we need players on both teams", MinigameID);
					#endif

					MinigameID = PreviousMinigameID;
				}
				else if (MinigameBlockedSpeedsHigherThan[MinigameID] > 0.0 && SpeedLevel > MinigameBlockedSpeedsHigherThan[MinigameID])
				{
					// Minigame cannot run on speeds higher than specified
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as speed level exceeds maximum", MinigameID);
					#endif

					MinigameID = PreviousMinigameID;
				}
				else if (MinigameMaximumParticipantCount[MinigameID] > 0 && ActiveParticipantCount > MinigameMaximumParticipantCount[MinigameID])
				{
					// Current participant count exceeds maximum participant count specified for minigame
					#if defined DEBUG
					PrintToChatAll("[MINIGAMESYS] Chose minigame %i, but rerolling as active participant count exceeds maximum permitted", MinigameID);
					#endif

					MinigameID = PreviousMinigameID;
				}
			}
		}
		while (MinigameID == PreviousMinigameID);

		PlayedMinigamePool.Push(MinigameID);

		#if defined DEBUG
		PrintToChatAll("[MINIGAMESYS] Chose minigame %i, minigame pool count: %i", MinigameID, PlayedMinigamePool.Length);
		#endif
	}

	PluginForward_SendMinigameSelected(MinigameID);
}

public void DoSelectBossgame()
{
	CalculateActiveParticipantCount();

	int forcedBossgameID = GetConVarInt(ConVar_MTF2ForceBossgame);
	int rollCount = 0;

	if (forcedBossgameID > 0)
	{
		PreviousBossgameID = 0;
		BossgameID = forcedBossgameID;
	}
	else
	{
		do
		{
			BossgameID = GetRandomInt(1, BossgamesLoaded);
			rollCount++;

			if (BossgamesLoaded == 1)
			{
				PreviousBossgameID = 0;
			}

			bool recentlyPlayed = PlayedBossgamePool.FindValue(BossgameID) >= 0;

			if (recentlyPlayed)
			{
				BossgameID = PreviousBossgameID;

				if (rollCount > 32)
				{
					PlayedBossgamePool.Clear();
				}
			}
			else
			{
				if (!BossgameIsEnabled[BossgameID])
				{
					BossgameID = PreviousBossgameID;
				}

				if (GamemodeID == SPR_GAMEMODEID && BossgameBlockedSpecialRounds[BossgameID][SpecialRoundID])
				{
					// If bossgame is blocked on this special round, re-roll
					BossgameID = PreviousBossgameID;
				}
				else if (BossgameRequiresMultiplePlayers[BossgameID])
				{
					if (ActiveRedParticipantCount == 0 || ActiveBlueParticipantCount == 0)
					{
						// Bossgame requires players on both teams
						BossgameID = PreviousBossgameID;
					}
				}
				else if (BossgameBlockedSpeedsHigherThan[BossgameID] > 0.0 && SpeedLevel > BossgameBlockedSpeedsHigherThan[BossgameID])
				{
					BossgameID = PreviousBossgameID;
				}
			}
		}
		while (BossgameID == PreviousBossgameID);

		PlayedBossgamePool.Push(BossgameID);
	}

	#if defined DEBUG
	PrintToChatAll("[MINIGAMESYS] Chose bossgame %i, bossgame pool count: %i", BossgameID, PlayedBossgamePool.Length);
	#endif

	PluginForward_SendBossgameSelected(BossgameID);
}

public void CalculateActiveParticipantCount()
{
	ActiveRedParticipantCount = 0;
	ActiveBlueParticipantCount = 0;

	for (int j = 1; j <= MaxClients; j++)
	{
		Player player = new Player(j);

		if (player.IsValid && player.IsParticipating)
		{
			switch (player.Team)
			{
				case TFTeam_Red:
					ActiveRedParticipantCount++;

				case TFTeam_Blue:
					ActiveBlueParticipantCount++;
			}
		}
	}

	ActiveParticipantCount = ActiveRedParticipantCount + ActiveBlueParticipantCount;
}