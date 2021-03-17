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

enum DamageBlockModes
{
	EDamageBlockMode_Nothing = 0,
	EDamageBlockMode_OtherPlayersOnly,
	EDamageBlockMode_AllPlayers,
	EDamageBlockMode_WinnersOnly,
	EDamageBlockMode_All
}

/**
 * Integers
 */

int MinigameID = 0;
int BossgameID = 0;
int PreviousMinigameID = 0;
int PreviousBossgameID = 0;
int g_iSpecialRoundId = 0;
int g_iWinnerScorePointsAmount = 1;
int MinigamesPlayed = 0;
int g_iNextMinigamePlayedSpeedTestThreshold = 0;
int BossGameThreshold = 20;
int MaxRounds = 4;
int RoundsPlayed = 0;
int g_iPlayerScore[MAXPLAYERS+1] = 0;
int g_iPlayerMinigamesLost[MAXPLAYERS+1] = 0;
int g_iPlayerMinigamesWon[MAXPLAYERS+1] = 0;
int g_iActiveParticipantCount = 0;
int g_iActiveRedParticipantCount = 0;
int g_iActiveBlueParticipantCount = 0;
int g_iAnnotationEventId = 0;

/**
 * Floats
 */

float g_fActiveGameSpeed = 1.0;

/**
 * Booleans
 */

bool g_bIsPluginEnabled = false;
bool IsMinigameActive = false;
bool g_bIsMinigameEnding = false;
bool g_bIsMapEnding = false;
bool g_bIsGameOver = false;
bool g_bIsBlockingTaunts = true;
bool g_bIsBlockingKillCommands = true;
bool IsPlayerParticipant[MAXPLAYERS+1] = false;
bool g_bIsPlayerWinner[MAXPLAYERS+1] = false;
bool g_bHideHudGamemodeText = false;
bool g_bAllowCosmetics = false;
bool g_bForceCalculationCritical = false;
bool g_bIsPlayerUsingLegacyDirectX[MAXPLAYERS+1] = false;

/**
 * Enums
 */

GameStatus g_eGamemodeStatus = GameStatus_Unknown;
PlayerStatuses g_ePlayerStatus[MAXPLAYERS+1] = PlayerStatus_Unknown;
DamageBlockModes g_eDamageBlockMode = EDamageBlockMode_All;

/**
 * Handles
 */

Handle g_hBossCheckTimer = INVALID_HANDLE;
Handle g_hActiveGameTimer = INVALID_HANDLE;

/**
 * Offsets
 */
int g_oCollisionGroup;
int g_oWeaponBaseClip1;
int g_oPlayerActiveWeapon;
int g_oPlayerAmmo;