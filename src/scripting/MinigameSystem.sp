/**
 * MicroTF2 - MinigameSystem.inc
 * 
 * Implements a System for Minigames.
 */

#include <sourcemod>

#define MAXIMUM_MINIGAMES 64
#define MINIGAME_CAPTION_LENGTH 128

int MinigamesLoaded = 0;
int BossgamesLoaded = 0;

bool MinigameIsEnabled[MAXIMUM_MINIGAMES];
char MinigameCaptions[MAXIMUM_MINIGAMES][MINIGAME_CAPTION_LENGTH];
char MinigameDynamicCaptionFunctions[MAXIMUM_MINIGAMES][64];
bool MinigameCaptionIsDynamic[MAXIMUM_MINIGAMES];
bool MinigameBlockedSpecialRounds[MAXIMUM_MINIGAMES][SPR_MAX];
bool MinigameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];
float MinigameBlockedSpeedsHigherThan[MAXIMUM_MINIGAMES];

bool BossgameIsEnabled[MAXIMUM_MINIGAMES];
char BossgameCaptions[MAXIMUM_MINIGAMES][MINIGAME_CAPTION_LENGTH];
char BossgameDynamicCaptionFunctions[MAXIMUM_MINIGAMES][64];
bool BossgameCaptionIsDynamic[MAXIMUM_MINIGAMES];
bool BossgameBlockedSpecialRounds[MAXIMUM_MINIGAMES][SPR_MAX];
bool BossgameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];
float BossgameBlockedSpeedsHigherThan[MAXIMUM_MINIGAMES];

char MinigameMusic[MAXIMUM_MINIGAMES][128];
float MinigameMusicLength[MAXIMUM_MINIGAMES];

char BossgameMusic[MAXIMUM_MINIGAMES][128];
float BossgameLength[MAXIMUM_MINIGAMES];

char MinigameCaption[MAXPLAYERS][MINIGAME_CAPTION_LENGTH];

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

// Bossgames
#include "Bossgames/Bossgame1.sp"
#include "Bossgames/Bossgame2.sp"
#include "Bossgames/Bossgame3.sp"
#include "Bossgames/Bossgame4.sp"
#include "Bossgames/Bossgame5.sp"

public void InitializeMinigames()
{
	LogMessage("Initializing Minigame System...");

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

	Handle sndfile = INVALID_HANDLE;

	for (int i = 1; i <= MinigamesLoaded; i++)
	{
		if (strlen(MinigameMusic[i]) == 0)
		{
			continue;
		}

		PreloadSound(MinigameMusic[i]);
		sndfile = OpenSoundFile(MinigameMusic[i]);

		if (sndfile == INVALID_HANDLE)
		{
			LogError("Failed to get sound length for Minigame %d - %s", i, MinigameMusic[i]);
		}
		else
		{
			MinigameMusicLength[i] = GetSoundLengthFloat(sndfile);
			CloseHandle(sndfile);
		}
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
	char manifestPath[128];

	// Our method of initializing minigames is:
	// Each minigame has a method called Minigame<NUMBER>_EntryPoint
	// This method is invoked and allows the minigame to add itself to the Minigame-cycle and add itself to forwards.

	// Determine count of Minigames that are available.
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/Minigames.txt");

	Handle kv = CreateKeyValues("Minigames");
	FileToKeyValues(kv, manifestPath);
 
	if (KvGotoFirstSubKey(kv))
	{
		int i = 0;

		do
		{
			i++;

			MinigameIsEnabled[i] = KvGetNum(kv, "Enabled", 0) == 1;

			KvGetString(kv, "EntryPoint", funcName, sizeof(funcName));

			Function func = GetFunctionByName(INVALID_HANDLE, funcName);
			if (func != INVALID_FUNCTION)
			{
				MinigamesLoaded++;

				Call_StartFunction(INVALID_HANDLE, func);
				Call_Finish();
			}
			else
			{
				LogError("Unable to find EntryPoint for Minigame #%i with name: \"%s\"", i, funcName);
				continue;
			}

			KvGetString(kv, "BackgroundMusic", MinigameMusic[i], 128);
			KvGetString(kv, "Caption", MinigameCaptions[i], 64);

			MinigameCaptionIsDynamic[i] = (KvGetNum(kv, "CaptionIsDynamic", 0) == 1);

			if (MinigameCaptionIsDynamic[i])
			{
				KvGetString(kv, "DynamicCaptionMethod", MinigameDynamicCaptionFunctions[i], 64);
			}

			char blockedSpecialRounds[64];
			KvGetString(kv, "BlockedSpecialRounds", blockedSpecialRounds, sizeof(blockedSpecialRounds));

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

			MinigameRequiresMultiplePlayers[i] = KvGetNum(kv, "RequiresMultiplePlayers", 0) == 1;
			MinigameBlockedSpeedsHigherThan[i] = KvGetFloat(kv, "BlockedOnSpeedsHigherThan", 0.0);
		}
		while (KvGotoNextKey(kv));
	}
 
	CloseHandle(kv);
}

public void LoadBossgameData()
{
	char funcName[64];
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/Bossgames.txt");

	Handle kv = CreateKeyValues("Bossgames");
	FileToKeyValues(kv, manifestPath);
 
	if (KvGotoFirstSubKey(kv))
	{
		int i = 0;

		do
		{
			i++;

			BossgameIsEnabled[i] = KvGetNum(kv, "Enabled", 0) == 1;

			// Get EntryPoint first of all!
			KvGetString(kv, "EntryPoint", funcName, sizeof(funcName));

			Function func = GetFunctionByName(INVALID_HANDLE, funcName);
			if (func != INVALID_FUNCTION)
			{
				BossgamesLoaded++;

				Call_StartFunction(INVALID_HANDLE, func);
				Call_Finish();
			}
			else
			{
				LogError("Unable to find EntryPoint for Bossgame #%i with name: \"%s\"", i, funcName);
				continue;
			}

			KvGetString(kv, "BackgroundMusic", BossgameMusic[i], 128);
			KvGetString(kv, "Caption", BossgameCaptions[i], 64);

			BossgameLength[i] = KvGetFloat(kv, "Duration", 30.0);
			BossgameCaptionIsDynamic[i] = (KvGetNum(kv, "CaptionIsDynamic", 0) == 1);

			if (BossgameCaptionIsDynamic[i])
			{
				KvGetString(kv, "DynamicCaptionMethod", BossgameDynamicCaptionFunctions[i], 64);
			}

			char blockedSpecialRounds[64];
			KvGetString(kv, "BlockedSpecialRounds", blockedSpecialRounds, sizeof(blockedSpecialRounds));

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

			BossgameRequiresMultiplePlayers[i] = KvGetNum(kv, "RequiresMultiplePlayers", 0) == 1;
			BossgameBlockedSpeedsHigherThan[i] = KvGetFloat(kv, "BlockedOnSpeedsHigherThan", 0.0);
		}
		while (KvGotoNextKey(kv));
	}
 
	CloseHandle(kv);
}

public void DoSelectMinigame()
{
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
					MinigameID = PreviousMinigameID;
				}
				else if (MinigameRequiresMultiplePlayers[MinigameID])
				{
					int redParticipants = 0;
					int blueParticipants = 0;

					for (int j = 1; j <= MaxClients; j++)
					{
						Player player = new Player(j);

						if (player.IsValid && player.IsParticipating)
						{
							switch (player.Team)
							{
								case TFTeam_Red:
									redParticipants++;

								case TFTeam_Blue:
									blueParticipants++;
							}
						}
					}

					if (redParticipants == 0 || blueParticipants == 0)
					{
						// Minigame requires players on both teams
						MinigameID = PreviousMinigameID;
					}
				}
				else if (MinigameBlockedSpeedsHigherThan[MinigameID] > 0.0 && SpeedLevel > MinigameBlockedSpeedsHigherThan[MinigameID])
				{
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
}

public void DoSelectBossgame()
{
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

				if (rollCount >= BossgamesLoaded)
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
					int redParticipants = 0;
					int blueParticipants = 0;

					for (int j = 1; j <= MaxClients; j++)
					{
						Player player = new Player(j);

						if (player.IsValid && player.IsParticipating)
						{
							switch (player.Team)
							{
								case TFTeam_Red:
									redParticipants++;

								case TFTeam_Blue:
									blueParticipants++;
							}
						}
					}

					if (redParticipants == 0 || blueParticipants == 0)
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
}

public bool TrySpeedChangeEvent()
{
	if (!Special_AreSpeedEventsEnabled())
	{
		return false;
	}

	if (MinigamesPlayed > 2 && SpeedLevel < 2.3 && MinigamesPlayed < BossGameThreshold && MinigamesPlayed >= NextMinigamePlayedSpeedTestThreshold)
	{
		if (GetRandomInt(0, 2) == 1)
		{
			NextMinigamePlayedSpeedTestThreshold = MinigamesPlayed + 2;

			return true;
		}
	}

	return false;
}