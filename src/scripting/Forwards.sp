/**
 * MicroTF2 - Forwards.inc
 * 
 * Implements Forwarding for the gamemode and minigames.
 */

/**
 * Forward is called when the map is starting.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMapStart;

/**
 * Forward is called when configs have executed.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnConfigsExecuted;

/**
 * Forward is called when the map is ending.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMapEnd;

/**
 * Forward is called when a Minigame is being preloaded.
 * NOTE: This is done when minigames are getting loaded into memory for the first time.
 * All minigames should have added their Preload function otherwise the minigames won't be run.
 * 
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigamePreload;

/**
 * Forward is called before preparing for a minigame
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigamePreparePre;

/**
 * Forward is called before preparing for a minigame
 *
 * @param Client to target
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigamePrepare;

/**
 * Forward is called just before a Minigame is started
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigameSelectedPre;

/**
 * Forward is called when a Minigame is started.
 *
 * @param Client to target
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigameSelected;

/**
 * Forward is called just after a Minigame is started.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigameSelectedPost;

/**
 * Forward is called just before a Minigame finishes.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigameFinishPre;

/**
 * Forward is called when a Minigame finishes.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigameFinish;

/**
 * Forward is called when a Minigame finishes.
 *
 * @param Client to target
 * @noreturn
 */
PrivateForward GlobalForward_OnMinigameFinishPost;

/**
 * Forward is called on every game frame. 
 * NOTE: Only run minimal code here.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnGameFrame;

/**
 * Forward is called when an entity is created.
 *
 * @param Entity Index
 * @param Entity Classname
 * @noreturn
 */
PrivateForward GlobalForward_OnEntityCreated;

/**
 * Forward is called when PropBroken event is fired.
 *
 * @param Client who broke the prop
 * @noreturn
 */
PrivateForward GlobalForward_OnPropBroken;

/**
 * Forward is called when a Player successfully performs a Sticky Jump.
 *
 * @param Client who performed the Sticky Jump
 * @noreturn
 */
PrivateForward GlobalForward_OnStickyJump;

/**
 * Forward is called when a Player successfully performs a Rocket Jump.
 *
 * @param Client who performed the Rocket Jump
 * @noreturn
 */
PrivateForward GlobalForward_OnRocketJump;

/**
 * Forward is called when a Player successfully builds an object (Sentry, Dispenser, Teleporter).
 *
 * @param Client who build the Object
 * @param Edict of entity that was built.
 * @noreturn
 */
PrivateForward GlobalForward_OnBuildObject;

/**
 * Forward is called when a Player spawns.
 *
 * @param Client who spawned
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerSpawn;

/**
 * Forward is called when a Player dies.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerDeath;

/**
 * Forward is called when a Player gets hurt.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerHurt;

/**
 * Forward is called when a Player takes damage (SDKHook).
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @param Damage amount
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerTakeDamage;

/**
 * Forward is called when a Player gets Jarate thrown onto them.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerJarated;

/**
 * Forward is called when a Player changes their class.
 *
 * @param Client who is changing class
 * @param Class the client changed to.
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerClassChange;

/**
 * Forward is called when a Player gets stunned.
 *
 * @param Client who got hit by the stun ball (Victim)
 * @param Client who hit the ball to the victim (Attacker)
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerStunned;

/**
 * Forward is called when a Spy has sapped an Engineer's building.
 *
 * @param Client who placed the sapper.
 * @param Client who owns the building the was sapped.
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerSappedObject;

/**
 * Forward is called when a Player's Critical Chance is calculated.
 *
 * @param Client that this is being calculated for
 * @param Weapon Entity Index
 * @param Weapon Name 
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerCalculateCritical;

/**
 * Forward is called when a Player runs a command.
 *
 * @param Client who is running command
 * @param Buttons 
 * @param Impulse 
 * @param Velocity
 * @param Angles
 * @param Weapon
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerRunCmd;

/**
 * Forward is called when a Boss Minigame will be attempted to stop. 
 *
 * @noparams
 * @returns True / False depending if the Boss can be stopped now.
 */
PrivateForward GlobalForward_OnBossStopAttempt;

/**
 * Forward is called when a Player runs a command.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnTfRoundStart;

/**
 * Forward is called when the HUD is about to be rendered.
 *
 * @param String to append data to
 * @noreturn
 */
PrivateForward GlobalForward_OnRenderHudFrame;

/**
 * Forward is called when the round has finished and game over begins.
 *
 * @noparams
 * @noreturn
 */
PrivateForward GlobalForward_OnGameOverStart;

/**
 * Forward is called when a player receives a TFCondition.
 *
 * @param Client of player
 * @param Condition ID. You will want to cast this to TFCond.
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerConditionAdded;

/**
 * Forward is called when a player has a TFCondition removed.
 *
 * @param Client of player
 * @param Condition ID. You will want to cast this to TFCond.
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerConditionRemoved;

/**
 * Forward is called when a player collides with another player.
 *
 * @param Player 1
 * @param Player 2
 * @noreturn
 */
PrivateForward GlobalForward_OnPlayerCollisionWithPlayer;

stock void InitializeForwards()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Forwards...");
	#endif

	GlobalForward_OnMapStart = new PrivateForward(ET_Ignore);
	GlobalForward_OnConfigsExecuted = new PrivateForward(ET_Ignore);
	GlobalForward_OnMapEnd = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigamePreload = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigamePreparePre = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigamePrepare = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnMinigameSelectedPre = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigameSelected = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnMinigameSelectedPost = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigameFinishPre = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigameFinish = new PrivateForward(ET_Ignore);
	GlobalForward_OnMinigameFinishPost = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnGameFrame = new PrivateForward(ET_Ignore);
	GlobalForward_OnEntityCreated = new PrivateForward(ET_Ignore, Param_Any, Param_String);
	GlobalForward_OnPropBroken = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnStickyJump = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnRocketJump = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnBuildObject = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerSpawn = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnPlayerDeath = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerHurt = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerTakeDamage = new PrivateForward(ET_Ignore, Param_Any, Param_Any, Param_Float);
	GlobalForward_OnPlayerJarated = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerClassChange = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerStunned = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerSappedObject = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerCalculateCritical = new PrivateForward(ET_Ignore, Param_Any, Param_Any, Param_String);
	GlobalForward_OnPlayerRunCmd = new PrivateForward(ET_Ignore, Param_Any, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	GlobalForward_OnBossStopAttempt = new PrivateForward(ET_Single);
	GlobalForward_OnTfRoundStart = new PrivateForward(ET_Ignore);
	GlobalForward_OnRenderHudFrame = new PrivateForward(ET_Ignore, Param_Any);
	GlobalForward_OnGameOverStart = new PrivateForward(ET_Ignore);
	GlobalForward_OnPlayerConditionAdded = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerConditionRemoved = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerCollisionWithPlayer = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
}

stock void RemoveForwardsFromMemory()
{
	SafelyRemoveAllFromForward(GlobalForward_OnMapStart);
	SafelyRemoveAllFromForward(GlobalForward_OnConfigsExecuted);
	SafelyRemoveAllFromForward(GlobalForward_OnMapEnd);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigamePreload);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigamePreparePre);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigamePrepare);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameSelectedPre);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameSelected);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameSelectedPost);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameFinishPre);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameFinish);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameFinishPost);
	SafelyRemoveAllFromForward(GlobalForward_OnGameFrame);
	SafelyRemoveAllFromForward(GlobalForward_OnEntityCreated);
	SafelyRemoveAllFromForward(GlobalForward_OnPropBroken);
	SafelyRemoveAllFromForward(GlobalForward_OnStickyJump);
	SafelyRemoveAllFromForward(GlobalForward_OnRocketJump);
	SafelyRemoveAllFromForward(GlobalForward_OnBuildObject);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerSpawn);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerDeath);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerHurt);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerJarated);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerClassChange);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerStunned);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerSappedObject);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerCalculateCritical);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerRunCmd);
	SafelyRemoveAllFromForward(GlobalForward_OnBossStopAttempt);
	SafelyRemoveAllFromForward(GlobalForward_OnTfRoundStart);
	SafelyRemoveAllFromForward(GlobalForward_OnRenderHudFrame);
	SafelyRemoveAllFromForward(GlobalForward_OnGameOverStart);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerConditionAdded);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerConditionRemoved);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerCollisionWithPlayer);
}

stock void SafelyRemoveAllFromForward(PrivateForward fwd)
{
	if (fwd != INVALID_HANDLE)
	{
		fwd.RemoveAllFunctions(INVALID_HANDLE);
	}
}