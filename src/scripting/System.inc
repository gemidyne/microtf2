/**
 * MicroTF2 - System.inc
 * 
 * Implements main system
 */

#define TOTAL_GAMEMODES 100
#define TOTAL_SYSMUSIC 6
#define TOTAL_SYSFX_VOCAL_TYPES 2
#define TOTAL_SYSFX_VOCALS 7
#define TOTAL_SYSOVERLAYS 10

#define SYSMUSIC_PREMINIGAME 0
#define SYSMUSIC_BOSSTIME 1
#define SYSMUSIC_SPEEDUP 2
#define SYSMUSIC_GAMEOVER 3
#define SYSMUSIC_FAILURE 4
#define SYSMUSIC_WINNER 5

#define SYSMUSIC_WAITINGFORPLAYERS "stsv/microtf2/sys/waitingforplayers.wav"
#define SYSMUSIC_SPECIALROUND "stsv/microtf2/sys/specialround.mp3"
#define SYSMUSIC_SPECIALROUND_SELECTED "stsv/microtf2/sys/fx/beep.mp3"
#define SYSMUSIC_MAPEND "stsv/microtf2/sys/mapend.mp3"
#define SYSFX_CLOCK "stsv/microtf2/sys/fx/clock.mp3"
#define SYSFX_WINNER "stsv/microtf2/sys/fx/bing.wav"

#define SYSFX_VOCAL_POSITIVE 0
#define SYSFX_VOCAL_NEGATIVE 1

#define SYSMUSIC_MAXSTRINGLENGTH 192

#define OVERLAY_BLANK "stsv/microtf2/overlays/blank"
#define OVERLAY_MINIGAMEBLANK "stsv/microtf2/overlays/minigameblank"
#define OVERLAY_WON	 "stsv/microtf2/overlays/minigamewin"
#define OVERLAY_FAIL "stsv/microtf2/overlays/minigamelose"
#define OVERLAY_SPEEDUP "stsv/microtf2/overlays/speedchange_faster"
#define OVERLAY_SPEEDDN	"stsv/microtf2/overlays/speedchange_slower"
#define OVERLAY_BOSS "stsv/microtf2/overlays/bossevent"
#define OVERLAY_GAMEOVER "stsv/microtf2/overlays/gameover"		
#define OVERLAY_WELCOME "stsv/microtf2/overlays/waitingforplayers"
#define OVERLAY_SPECIALROUND "stsv/microtf2/overlays/specialround"

new String:SystemNames[TOTAL_GAMEMODES+1][32];
new String:SystemMusic[TOTAL_GAMEMODES+1][TOTAL_SYSMUSIC+1][SYSMUSIC_MAXSTRINGLENGTH];
new Float:SystemMusicLength[TOTAL_GAMEMODES+1][TOTAL_SYSMUSIC+1];
new String:SystemVocal[TOTAL_SYSFX_VOCAL_TYPES+1][TOTAL_SYSFX_VOCALS+1][SYSMUSIC_MAXSTRINGLENGTH];

new GamemodeID = 0;
new MaxGamemodesSelectable = 0;

new Handle:HudSync_Score;
new Handle:HudSync_Special;
new Handle:HudSync_Round;
new Handle:HudSync_Caption;

stock InitializeSystem()
{
	LogMessage("Initializing System...");
	
	InitializeForwards();
	InitializeCommands();
	InitializeSpecialRounds();

	SystemVocal[SYSFX_VOCAL_POSITIVE][0] = "microtf2/vo/mtf2_response01.mp3";
	SystemVocal[SYSFX_VOCAL_POSITIVE][1] = "microtf2/vo/mtf2_response07.mp3";
	SystemVocal[SYSFX_VOCAL_POSITIVE][2] = "microtf2/vo/mtf2_response08.mp3";
	SystemVocal[SYSFX_VOCAL_POSITIVE][3] = "microtf2/vo/mtf2_response09.mp3";
	SystemVocal[SYSFX_VOCAL_POSITIVE][4] = "microtf2/vo/mtf2_response10.mp3";
	SystemVocal[SYSFX_VOCAL_POSITIVE][5] = "microtf2/vo/mtf2_response11.mp3";
	SystemVocal[SYSFX_VOCAL_POSITIVE][6] = "microtf2/vo/mtf2_response12.mp3";

	SystemVocal[SYSFX_VOCAL_NEGATIVE][0] = "microtf2/vo/mtf2_response02.mp3";
	SystemVocal[SYSFX_VOCAL_NEGATIVE][1] = "microtf2/vo/mtf2_response03.mp3";
	SystemVocal[SYSFX_VOCAL_NEGATIVE][2] = "microtf2/vo/mtf2_response04.mp3";
	SystemVocal[SYSFX_VOCAL_NEGATIVE][3] = "microtf2/vo/mtf2_response05.mp3";
	SystemVocal[SYSFX_VOCAL_NEGATIVE][4] = "microtf2/vo/mtf2_response06.mp3";

	HudSync_Score = CreateHudSynchronizer();
	HudSync_Special = CreateHudSynchronizer();
	HudSync_Round = CreateHudSynchronizer();
	HudSync_Caption = CreateHudSynchronizer();

	decl String:gamemodeManifestPath[128];
	BuildPath(Path_SM, gamemodeManifestPath, sizeof(gamemodeManifestPath), "data/microtf2/gamemodes.txt");

	new Handle:kv = CreateKeyValues("Gamemodes");
	FileToKeyValues(kv, gamemodeManifestPath);
 
	if (KvGotoFirstSubKey(kv))
	{
		do
		{
			new gamemodeID = GetGamemodeIDFromSectionName(kv);

			LoadSysMusicType(gamemodeID, SYSMUSIC_PREMINIGAME, kv, "SysMusic_PreMinigame");
			LoadSysMusicType(gamemodeID, SYSMUSIC_BOSSTIME, kv, "SysMusic_BossTime");
			LoadSysMusicType(gamemodeID, SYSMUSIC_SPEEDUP, kv, "SysMusic_SpeedUp");
			LoadSysMusicType(gamemodeID, SYSMUSIC_GAMEOVER, kv, "SysMusic_GameOver");

			// These 2 cannot have the different lengths; they're played at the same time
			KvGetString(kv, "SysMusic_Failure", SystemMusic[gamemodeID][SYSMUSIC_FAILURE], SYSMUSIC_MAXSTRINGLENGTH);
			KvGetString(kv, "SysMusic_Winner", SystemMusic[gamemodeID][SYSMUSIC_WINNER], SYSMUSIC_MAXSTRINGLENGTH);

			KvGetString(kv, "FriendlyName", SystemNames[gamemodeID], 32);

			if (KvGetNum(kv, "Selectable", 0) == 1)
			{
				// Selectable Gamemodes must be at the start of the Gamemodes.txt file
				MaxGamemodesSelectable++;
			}

			LogMessage("Loaded gamemode %d - %s", gamemodeID, SystemNames[gamemodeID]);
		}
		while (KvGotoNextKey(kv));
	}
 
	CloseHandle(kv);

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, System_OnMapStart);
	InitializeMinigames();
	InitialisePrecacheSystem();
	InitialiseSecuritySystem();

	InitialiseWeapons();
}

public System_OnMapStart()
{
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

	// Preload (Precache and Add To Downloads Table) all Sounds needed for every gamemode
	decl String:buffer[192];

	for (new g = 0; g < TOTAL_GAMEMODES; g++)
	{
		for (new i = 0; i < TOTAL_SYSMUSIC; i++)
		{
			buffer = SystemMusic[g][i];

			if (strlen(buffer) > 0)
			{
				PreloadSound(SystemMusic[g][i]);
			}
		}
	}

	for (new t = 0; t < TOTAL_SYSFX_VOCAL_TYPES; t++)
	{
		for (new i = 0; i < TOTAL_SYSFX_VOCALS; i++)
		{
			buffer = SystemVocal[t][i];

			if (strlen(buffer) > 0)
			{
				PreloadSound(SystemVocal[t][i]);
			}
		}
	}

	PreloadSound(SYSMUSIC_WAITINGFORPLAYERS);
	PreloadSound(SYSMUSIC_SPECIALROUND);
	PreloadSound(SYSMUSIC_SPECIALROUND_SELECTED);
	PreloadSound(SYSMUSIC_MAPEND);
	PreloadSound(SYSFX_CLOCK);
	PreloadSound(SYSFX_WINNER);

	PrecacheSound("ui/system_message_alert.wav", true);
	PrecacheSound("vo/announcer_ends_10sec.wav", true);
	PrecacheSound("vo/announcer_ends_5sec.wav", true);
	PrecacheSound("vo/announcer_ends_4sec.wav", true);
	PrecacheSound("vo/announcer_ends_3sec.wav", true);
	PrecacheSound("vo/announcer_ends_2sec.wav", true);
	PrecacheSound("vo/announcer_ends_1sec.wav", true);
	PrecacheSound("vo/announcer_success.wav", true);
}

stock GetGamemodeIDFromSectionName(Handle:kv)
{
	decl String:buffer[16];

	KvGetSectionName(kv, buffer, sizeof(buffer));

	return StringToInt(buffer);
}

stock LoadSysMusicType(gamemodeID, musicType, Handle:kv, const String:key[])
{
	new Handle:sndfile = INVALID_HANDLE;

	KvGetString(kv, key, SystemMusic[gamemodeID][musicType], SYSMUSIC_MAXSTRINGLENGTH);
	sndfile = OpenSoundFile(SystemMusic[gamemodeID][musicType]);

	if (sndfile == INVALID_HANDLE)
	{
		LogError("Failed to get sound length for \"%s\" - %s", key, SystemMusic[gamemodeID][musicType]);
	}
	else
	{
		SystemMusicLength[gamemodeID][musicType] = GetSoundLengthFloat(sndfile);
		CloseHandle(sndfile);
	}
}