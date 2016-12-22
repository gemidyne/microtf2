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

new MinigameID = 0;
new BossgameID = 0;
new PreviousMinigameID = 0;
new PreviousBossgameID = 0;
new SpecialRoundID = 0;
new ScoreAmount = 1;
new MinigamesPlayed = 0;
new BossGameThreshold = 20;
new MaxRounds = 4;
new RoundsPlayed = 0;
new PlayerScore[MAXPLAYERS+1] = 0;
new PlayerMinigamesLost[MAXPLAYERS+1] = 0;
new PlayerMinigamesWon[MAXPLAYERS+1] = 0;
new IsPlayerWinner[MAXPLAYERS+1] = 0;
new PlayerIndex[MAXPLAYERS+1] = 0;

/**
 * Floats
 */

new Float:SpeedLevel = 1.0;

/**
 * Booleans
 */

new bool:IsMinigameActive = false;
new bool:IsMinigameEnding = false;
new bool:IsMapEnding = false;
new bool:IsBonusRound = false;
new bool:IsBlockingTaunts = true;
new bool:IsBlockingDeaths = true;
new bool:IsBlockingDamage = true;
new bool:IsOnlyBlockingDamageByPlayers = false;
new bool:IsPlayerParticipant[MAXPLAYERS+1] = false;

/**
 * Enums
 */

new GameStatus:GamemodeStatus = GameStatus_Unknown;
new PlayerStatuses:PlayerStatus[MAXPLAYERS+1] = PlayerStatus_Unknown;

/**
 * Handles
 */

new Handle:ConVar_HostTimescale = INVALID_HANDLE;
new Handle:ConVar_PhysTimescale = INVALID_HANDLE;
new Handle:ConVar_ServerGravity = INVALID_HANDLE;
new Handle:ConVar_TFCheapObjects = INVALID_HANDLE;
new Handle:ConVar_TFFastBuild = INVALID_HANDLE;
new Handle:Handle_BossCheckTimer = INVALID_HANDLE;
new Handle:Handle_ActiveGameTimer = INVALID_HANDLE;

new Handle:ConVar_MTF2MaxRounds = INVALID_HANDLE;

new Offset_Collision;