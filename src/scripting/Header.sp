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
int ActiveParticipantCount = 0;
int ActiveRedParticipantCount = 0;
int ActiveBlueParticipantCount = 0;
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
bool AllowCosmetics = false;

/**
 * Enums
 */

GameStatus GamemodeStatus = GameStatus_Unknown;
PlayerStatuses PlayerStatus[MAXPLAYERS+1] = PlayerStatus_Unknown;

/**
 * Handles
 */

Handle ConVar_MTF2MaxRounds = INVALID_HANDLE;
Handle Handle_BossCheckTimer = INVALID_HANDLE;
Handle Handle_ActiveGameTimer = INVALID_HANDLE;

/**
 * Offsets
 */
int Offset_Collision;
int Offset_WeaponBaseClip1;
int Offset_PlayerActiveWeapon;
int Offset_PlayerAmmo;