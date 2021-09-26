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
PrivateForward g_pfOnMapStart;

/**
 * Forward is called when configs have executed.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnConfigsExecuted;

/**
 * Forward is called when the map is ending.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMapEnd;

/**
 * Forward is called when a Minigame is being preloaded.
 * NOTE: This is done when minigames are getting loaded into memory for the first time.
 * All minigames should have added their Preload function otherwise the minigames won't be run.
 * 
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMinigamePreload;

/**
 * Forward is called before preparing for a minigame
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMinigamePreparePre;

/**
 * Forward is called before preparing for a minigame
 *
 * @param Client to target
 * @noreturn
 */
PrivateForward g_pfOnMinigamePrepare;

/**
 * Forward is called just before a Minigame is started
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMinigameSelectedPre;

/**
 * Forward is called when a Minigame is started.
 *
 * @param Client to target
 * @noreturn
 */
PrivateForward g_pfOnMinigameSelected;

/**
 * Forward is called just after a Minigame is started.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMinigameSelectedPost;

/**
 * Forward is called just before a Minigame finishes.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMinigameFinishPre;

/**
 * Forward is called when a Minigame finishes.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnMinigameFinish;

/**
 * Forward is called when a Minigame finishes.
 *
 * @param Client to target
 * @noreturn
 */
PrivateForward g_pfOnMinigameFinishPost;

/**
 * Forward is called on every game frame. 
 * NOTE: Only run minimal code here.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnGameFrame;

/**
 * Forward is called when an entity is created.
 *
 * @param Entity Index
 * @param Entity Classname
 * @noreturn
 */
PrivateForward g_pfOnEntityCreated;

/**
 * Forward is called when PropBroken event is fired.
 *
 * @param Client who broke the prop
 * @noreturn
 */
PrivateForward g_pfOnPropBroken;

/**
 * Forward is called when a Player successfully performs a Sticky Jump.
 *
 * @param Client who performed the Sticky Jump
 * @noreturn
 */
PrivateForward g_pfOnStickyJump;

/**
 * Forward is called when a Player successfully performs a Rocket Jump.
 *
 * @param Client who performed the Rocket Jump
 * @noreturn
 */
PrivateForward g_pfOnRocketJump;

/**
 * Forward is called when a Player successfully builds an object (Sentry, Dispenser, Teleporter).
 *
 * @param Client who build the Object
 * @param Edict of entity that was built.
 * @noreturn
 */
PrivateForward g_pfOnBuildObject;

/**
 * Forward is called when a Player spawns.
 *
 * @param Client who spawned
 * @noreturn
 */
PrivateForward g_pfOnPlayerSpawn;

/**
 * Forward is called when a Player dies.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
PrivateForward g_pfOnPlayerDeath;

/**
 * Forward is called when a Player gets hurt.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
PrivateForward g_pfOnPlayerHurt;

/**
 * Forward is called when a Player takes damage (SDKHook).
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @param Damage amount
 * @noreturn
 */
PrivateForward g_pfOnPlayerTakeDamage;

/**
 * Forward is called when a Player gets Jarate thrown onto them.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
PrivateForward g_pfOnPlayerJarated;

/**
 * Forward is called when a Player changes their class.
 *
 * @param Client who is changing class
 * @param Class the client changed to.
 * @noreturn
 */
PrivateForward g_pfOnPlayerClassChange;

/**
 * Forward is called when a Player gets stunned.
 *
 * @param Client who got hit by the stun ball (Victim)
 * @param Client who hit the ball to the victim (Attacker)
 * @noreturn
 */
PrivateForward g_pfOnPlayerStunned;

/**
 * Forward is called when a Spy has sapped an Engineer's building.
 *
 * @param Client who placed the sapper.
 * @param Client who owns the building the was sapped.
 * @noreturn
 */
PrivateForward g_pfOnPlayerSappedObject;

/**
 * Forward is called when a player is healed.
 *
 * @param Client who is the "patient" (the one getting healed)
 * @param Client who is the healer. (the one who is healing the patient)
 * @noreturn
 */
PrivateForward g_pfOnPlayerHealed;

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
PrivateForward g_pfOnPlayerRunCmd;

/**
 * Forward is called when a Boss Minigame will be attempted to stop. 
 *
 * @noparams
 * @returns True / False depending if the Boss can be stopped now.
 */
PrivateForward g_pfOnBossStopAttempt;

/**
 * Forward is called when a Player runs a command.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnTfRoundStart;

/**
 * Forward is called when the HUD is about to be rendered.
 *
 * @param String to append data to
 * @noreturn
 */
PrivateForward g_pfOnRenderHudFrame;

/**
 * Forward is called when the round has finished and game over begins.
 *
 * @noparams
 * @noreturn
 */
PrivateForward g_pfOnGameOverStart;

/**
 * Forward is called when a player receives a TFCondition.
 *
 * @param Client of player
 * @param Condition ID. You will want to cast this to TFCond.
 * @noreturn
 */
PrivateForward g_pfOnPlayerConditionAdded;

/**
 * Forward is called when a player has a TFCondition removed.
 *
 * @param Client of player
 * @param Condition ID. You will want to cast this to TFCond.
 * @noreturn
 */
PrivateForward g_pfOnPlayerConditionRemoved;

/**
 * Forward is called when a player collides with another player.
 *
 * @param Player 1
 * @param Player 2
 * @noreturn
 */
PrivateForward g_pfOnPlayerCollisionWithPlayer;

/**
 * Forward is called when a player uses say/say_team command
 *
 * @param Player who sent the message
 * @param Message text
 * @param Is team only?
 * @noreturn
 */
PrivateForward g_pfOnPlayerChatMessage;

void InitializeForwards()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Forwards...");
	#endif

	g_pfOnMapStart = new PrivateForward(ET_Ignore);
	g_pfOnConfigsExecuted = new PrivateForward(ET_Ignore);
	g_pfOnMapEnd = new PrivateForward(ET_Ignore);
	g_pfOnMinigamePreload = new PrivateForward(ET_Ignore);
	g_pfOnMinigamePreparePre = new PrivateForward(ET_Ignore);
	g_pfOnMinigamePrepare = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnMinigameSelectedPre = new PrivateForward(ET_Ignore);
	g_pfOnMinigameSelected = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnMinigameSelectedPost = new PrivateForward(ET_Ignore);
	g_pfOnMinigameFinishPre = new PrivateForward(ET_Ignore);
	g_pfOnMinigameFinish = new PrivateForward(ET_Ignore);
	g_pfOnMinigameFinishPost = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnGameFrame = new PrivateForward(ET_Ignore);
	g_pfOnEntityCreated = new PrivateForward(ET_Ignore, Param_Any, Param_String);
	g_pfOnPropBroken = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnStickyJump = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnRocketJump = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnBuildObject = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerSpawn = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnPlayerDeath = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerHurt = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerTakeDamage = new PrivateForward(ET_Event, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	g_pfOnPlayerJarated = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerClassChange = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerStunned = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerSappedObject = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerHealed = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerRunCmd = new PrivateForward(ET_Ignore, Param_Any, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_pfOnBossStopAttempt = new PrivateForward(ET_Single);
	g_pfOnTfRoundStart = new PrivateForward(ET_Ignore);
	g_pfOnRenderHudFrame = new PrivateForward(ET_Ignore, Param_Any);
	g_pfOnGameOverStart = new PrivateForward(ET_Ignore);
	g_pfOnPlayerConditionAdded = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerConditionRemoved = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerCollisionWithPlayer = new PrivateForward(ET_Ignore, Param_Any, Param_Any);
	g_pfOnPlayerChatMessage = new PrivateForward(ET_Event, Param_Any, Param_String, Param_Any);
}

void RemoveForwardsFromMemory()
{
	SafelyRemoveAllFromForward(g_pfOnMapStart);
	SafelyRemoveAllFromForward(g_pfOnConfigsExecuted);
	SafelyRemoveAllFromForward(g_pfOnMapEnd);
	SafelyRemoveAllFromForward(g_pfOnMinigamePreload);
	SafelyRemoveAllFromForward(g_pfOnMinigamePreparePre);
	SafelyRemoveAllFromForward(g_pfOnMinigamePrepare);
	SafelyRemoveAllFromForward(g_pfOnMinigameSelectedPre);
	SafelyRemoveAllFromForward(g_pfOnMinigameSelected);
	SafelyRemoveAllFromForward(g_pfOnMinigameSelectedPost);
	SafelyRemoveAllFromForward(g_pfOnMinigameFinishPre);
	SafelyRemoveAllFromForward(g_pfOnMinigameFinish);
	SafelyRemoveAllFromForward(g_pfOnMinigameFinishPost);
	SafelyRemoveAllFromForward(g_pfOnGameFrame);
	SafelyRemoveAllFromForward(g_pfOnEntityCreated);
	SafelyRemoveAllFromForward(g_pfOnPropBroken);
	SafelyRemoveAllFromForward(g_pfOnStickyJump);
	SafelyRemoveAllFromForward(g_pfOnRocketJump);
	SafelyRemoveAllFromForward(g_pfOnBuildObject);
	SafelyRemoveAllFromForward(g_pfOnPlayerSpawn);
	SafelyRemoveAllFromForward(g_pfOnPlayerDeath);
	SafelyRemoveAllFromForward(g_pfOnPlayerHurt);
	SafelyRemoveAllFromForward(g_pfOnPlayerJarated);
	SafelyRemoveAllFromForward(g_pfOnPlayerClassChange);
	SafelyRemoveAllFromForward(g_pfOnPlayerStunned);
	SafelyRemoveAllFromForward(g_pfOnPlayerSappedObject);
	SafelyRemoveAllFromForward(g_pfOnPlayerHealed);
	SafelyRemoveAllFromForward(g_pfOnPlayerRunCmd);
	SafelyRemoveAllFromForward(g_pfOnBossStopAttempt);
	SafelyRemoveAllFromForward(g_pfOnTfRoundStart);
	SafelyRemoveAllFromForward(g_pfOnRenderHudFrame);
	SafelyRemoveAllFromForward(g_pfOnGameOverStart);
	SafelyRemoveAllFromForward(g_pfOnPlayerConditionAdded);
	SafelyRemoveAllFromForward(g_pfOnPlayerConditionRemoved);
	SafelyRemoveAllFromForward(g_pfOnPlayerCollisionWithPlayer);
	SafelyRemoveAllFromForward(g_pfOnPlayerChatMessage);
}

stock void SafelyRemoveAllFromForward(PrivateForward fwd)
{
	if (fwd != INVALID_HANDLE)
	{
		fwd.RemoveAllFunctions(INVALID_HANDLE);
	}
}