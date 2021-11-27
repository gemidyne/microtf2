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

enum DamageBlockResults
{
	EDamageBlockResult_DoNothing = 0,
	EDamageBlockResult_AllowDamage,
	EDamageBlockResult_BlockDamage,
}

/**
 * Integers
 */

int g_iActiveMinigameId = 0;
int g_iActiveBossgameId = 0;
int g_iLastPlayedMinigameId = 0;
int g_iLastPlayedBossgameId = 0;
int g_iSpecialRoundId = 0;
int g_iWinnerScorePointsAmount = 1;
int g_iMinigamesPlayedCount = 0;
int g_iNextMinigamePlayedSpeedTestThreshold = 0;
int g_iBossGameThreshold = 20;
int g_iMaxRoundsPlayable = 4;
int g_iTotalRoundsPlayed = 0;
int g_iPlayerScore[MAXPLAYERS+1];
int g_iPlayerMinigamesLost[MAXPLAYERS+1];
int g_iPlayerMinigamesWon[MAXPLAYERS+1];
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
bool g_bIsMinigameActive = false;
bool g_bIsMinigameEnding = false;
bool g_bIsMapEnding = false;
bool g_bIsGameOver = false;
bool g_bIsBlockingTaunts = true;
bool g_bIsBlockingKillCommands = true;
bool g_bIsPlayerParticipant[MAXPLAYERS+1];
bool g_bIsPlayerWinner[MAXPLAYERS+1];
bool g_bHideHudGamemodeText = false;
bool g_bAllowCosmetics = false;
bool g_bIsPlayerUsingLegacyDirectX[MAXPLAYERS+1];

/**
 * Enums
 */

GameStatus g_eGamemodeStatus = GameStatus_Unknown;
PlayerStatuses g_ePlayerStatus[MAXPLAYERS+1];
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