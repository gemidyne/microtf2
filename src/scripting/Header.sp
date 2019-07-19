#define HIDEHUD_WEAPONSELECTION ( 1<<0 ) // Hide ammo count & weapon selection
#define HIDEHUD_FLASHLIGHT ( 1<<1 )
#define HIDEHUD_ALL ( 1<<2 )
#define HIDEHUD_HEALTH ( 1<<3 ) // Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD ( 1<<4 ) // Hide when local player's dead
#define HIDEHUD_NEEDSUIT ( 1<<5 ) // Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS ( 1<<6 ) // Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT ( 1<<7 ) // Hide all communication elements (saytext, voice icon, etc)
#define HIDEHUD_CROSSHAIR ( 1<<8 ) // Hide crosshairs
#define HIDEHUD_VEHICLE_CROSSHAIR ( 1<<9 ) // Hide vehicle crosshair
#define HIDEHUD_INVEHICLE ( 1<<10 )
#define HIDEHUD_BONUS_PROGRESS ( 1<<11 ) // Hide bonus progress display (for bonus map challenges)

#define HIDEHUD_BITCOUNT 12

// Special Rounds
#define SPR_GAMEMODEID 99

#define SPR_MIN 0
#define SPR_MAX 32

enum GameStatus
{
	GameStatus_Unknown = 0,
	GameStatus_WaitingForPlayers,
	GameStatus_Tutorial,
	GameStatus_Playing,
	GameStatus_GameOver,
	GameStatus_Loading,
};

enum PlayerStatuses
{
	PlayerStatus_Unknown = 0,
	PlayerStatus_Failed,
	PlayerStatus_NotWon,
	PlayerStatus_Winner
}

/**
 * Integers
 */

int MinigameID = 0;
int BossgameID = 0;
int PreviousMinigameID = 0;
int PreviousBossgameID = 0;
int SpecialRoundID = 0;
int ScoreAmount = 1;
int MinigamesPlayed = 0;
int NextMinigamePlayedSpeedTestThreshold = 0;
int BossGameThreshold = 20;
int MaxRounds = 4;
int RoundsPlayed = 0;
int PlayerScore[MAXPLAYERS+1] = 0;
int PlayerMinigamesLost[MAXPLAYERS+1] = 0;
int PlayerMinigamesWon[MAXPLAYERS+1] = 0;
int PlayerIndex[MAXPLAYERS+1] = 0;

int g_iAnnotationEventId = 0;

/**
 * Floats
 */

float SpeedLevel = 1.0;

/**
 * Booleans
 */

bool IsPluginEnabled = false;
bool IsMinigameActive = false;
bool IsMinigameEnding = false;
bool IsMapEnding = false;
bool IsBonusRound = false;
bool IsBlockingTaunts = true;
bool IsBlockingDeathCommands = true;
bool IsBlockingDamage = true;
bool IsOnlyBlockingDamageByPlayers = false;
bool IsPlayerParticipant[MAXPLAYERS+1] = false;
bool IsPlayerWinner[MAXPLAYERS+1] = false;
bool HideHudGamemodeText = false;

/**
 * Enums
 */

GameStatus GamemodeStatus = GameStatus_Unknown;
PlayerStatuses PlayerStatus[MAXPLAYERS+1] = PlayerStatus_Unknown;

/**
 * Handles
 */

Handle ConVar_HostTimescale = INVALID_HANDLE;
Handle ConVar_PhysTimescale = INVALID_HANDLE;
Handle ConVar_ServerGravity = INVALID_HANDLE;
Handle ConVar_TFCheapObjects = INVALID_HANDLE;
Handle ConVar_TFFastBuild = INVALID_HANDLE;
Handle ConVar_FriendlyFire = INVALID_HANDLE;
Handle Handle_BossCheckTimer = INVALID_HANDLE;
Handle Handle_ActiveGameTimer = INVALID_HANDLE;

Handle ConVar_MTF2MaxRounds = INVALID_HANDLE;
Handle ConVar_MTF2IntermissionEnabled = INVALID_HANDLE;
Handle ConVar_MTF2BonusPoints = INVALID_HANDLE;
Handle ConVar_MTF2ForceMinigame = INVALID_HANDLE;
Handle ConVar_MTF2ForceBossgame = INVALID_HANDLE;
Handle ConVar_MTF2ForceBossgameThreshold = INVALID_HANDLE;

/**
 * Offsets
 */
int Offset_Collision;
int Offset_WeaponBaseClip1;
int Offset_PlayerActiveWeapon;
int Offset_PlayerAmmo;