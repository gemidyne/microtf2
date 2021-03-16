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
bool IsPlayerParticipant[MAXPLAYERS+1] = false;
bool IsPlayerWinner[MAXPLAYERS+1] = false;
bool HideHudGamemodeText = false;
bool AllowCosmetics = false;
bool ForceCalculationCritical = false;
bool IsPlayerUsingLegacyDirectX[MAXPLAYERS+1] = false;

/**
 * Enums
 */

GameStatus GamemodeStatus = GameStatus_Unknown;
PlayerStatuses PlayerStatus[MAXPLAYERS+1] = PlayerStatus_Unknown;

DamageBlockModes DamageBlockMode = EDamageBlockMode_All;

/**
 * Handles
 */

Handle Handle_BossCheckTimer = INVALID_HANDLE;
Handle Handle_ActiveGameTimer = INVALID_HANDLE;

/**
 * Offsets
 */
int g_oCollisionGroup;
int g_oWeaponBaseClip1;
int g_oPlayerActiveWeapon;
int g_oPlayerAmmo;