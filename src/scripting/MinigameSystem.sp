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

char MinigameCaptions[MAXIMUM_MINIGAMES][MINIGAME_CAPTION_LENGTH];
char MinigameDynamicCaptionFunctions[MAXIMUM_MINIGAMES][64];
bool MinigameCaptionIsDynamic[MAXIMUM_MINIGAMES];
bool MinigameBlockedSpecialRounds[MAXIMUM_MINIGAMES][SPR_MAX];
bool MinigameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];

char BossgameCaptions[MAXIMUM_MINIGAMES][MINIGAME_CAPTION_LENGTH];
char BossgameDynamicCaptionFunctions[MAXIMUM_MINIGAMES][64];
bool BossgameCaptionIsDynamic[MAXIMUM_MINIGAMES];
bool BossgameBlockedSpecialRounds[MAXIMUM_MINIGAMES][SPR_MAX];
bool BossgameRequiresMultiplePlayers[MAXIMUM_MINIGAMES];

char MinigameMusic[MAXIMUM_MINIGAMES][128];
float MinigameMusicLength[MAXIMUM_MINIGAMES];

char BossgameMusic[MAXIMUM_MINIGAMES][128];
float BossgameLength[MAXIMUM_MINIGAMES];

char MinigameCaption[MAXPLAYERS][MINIGAME_CAPTION_LENGTH];

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
#include "Bossgames/Bossgame6.sp"

public void InitializeMinigames()
{
	LogMessage("Initializing Minigame System...");

	LoadMinigameData();
	LoadBossgameData();

	LogMessage("Minigame System initialized with %d Minigame(s) and %d Bossgame(s).", MinigamesLoaded, BossgamesLoaded);

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, MinigameSystem_OnMapStart);
}

public void MinigameSystem_OnMapStart()
{
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

public void LoadMinigameData()
{
	char funcName[64];
	char manifestPath[128];

	// Our method of initializing minigames is:
	// Each minigame has a method called Minigame<NUMBER>_EntryPoint
	// This method is invoked and allows the minigame to add itself to the Minigame-cycle and add itself to forwards.

	// Determine count of Minigames that are available.
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/minigames.txt");

	Handle kv = CreateKeyValues("Minigames");
	FileToKeyValues(kv, manifestPath);
 
	if (KvGotoFirstSubKey(kv))
	{
		int i = 0;

		do
		{
			i++;

			if (KvGetNum(kv, "Enabled", 0) == 0)
			{
				// The Enabled/Disabled system needs reworking.
				// MinigamesLoaded might be lower and this means some minigames 
				// cant run...
				continue;
			}

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

			MinigameRequiresMultiplePlayers[i] = KvGetNum(kv, "MultiplePlayersOnly", 0) == 1;
		}
		while (KvGotoNextKey(kv));
	}
 
	CloseHandle(kv);
}

public void LoadBossgameData()
{
	char funcName[64];
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/bossgames.txt");

	Handle kv = CreateKeyValues("Bossgames");
	FileToKeyValues(kv, manifestPath);
 
	if (KvGotoFirstSubKey(kv))
	{
		int i = 0;

		do
		{
			i++;

			if (KvGetNum(kv, "Enabled", 0) == 0)
			{
				continue;
			}

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

			BossgameRequiresMultiplePlayers[i] = KvGetNum(kv, "MultiplePlayersOnly", 0) == 1;
		}
		while (KvGotoNextKey(kv));
	}
 
	CloseHandle(kv);
}

public void DoSelectMinigame()
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

			if (GamemodeID == SPR_GAMEMODEID && MinigameBlockedSpecialRounds[MinigameID][SpecialRoundID])
			{
				// If minigame is blocked on this special round, re-roll
				MinigameID = PreviousMinigameID;
			}
			else if (MinigameRequiresMultiplePlayers[MinigameID])
			{
				int redParticipants = 0;
				int bluParticipants = 0;

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
								bluParticipants++;
						}
					}
				}

				if (redParticipants == 0 || bluParticipants == 0)
				{
					// Minigame requires players on both teams
					MinigameID = PreviousMinigameID;
				}
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

public void DoSelectBossgame()
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

			if (GamemodeID == SPR_GAMEMODEID && BossgameBlockedSpecialRounds[BossgameID][SpecialRoundID])
			{
				// If bossgame is blocked on this special round, re-roll
				BossgameID = PreviousBossgameID;
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