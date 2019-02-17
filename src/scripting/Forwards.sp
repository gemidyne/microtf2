/**
 * MicroTF2 - Forwards.inc
 * 
 * Implements Forwarding for the gamemode and minigames.
 */

/**
 * Forward is called when Map Starts.
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnMapStart;

/**
 * Forward is called when a Minigame is being preloaded.
 * NOTE: This is done when minigames are getting loaded into memory for the first time.
 * All minigames should have added their Preload function otherwise the minigames won't be run.
 * 
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnMinigamePreload;

/**
 * Forward is called before preparing for a minigame
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnMinigamePreparePre;

/**
 * Forward is called before preparing for a minigame
 *
 * @param Client to target
 * @noreturn
 */
Handle GlobalForward_OnMinigamePrepare;

/**
 * Forward is called just before a Minigame is started
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnMinigameSelectedPre;

/**
 * Forward is called when a Minigame is started.
 *
 * @param Client to target
 * @noreturn
 */
Handle GlobalForward_OnMinigameSelected;

/**
 * Forward is called just after a Minigame is started.
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnMinigameSelectedPost;

/**
 * Forward is called just before a Minigame finishes.
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnMinigameFinishPre;

/**
 * Forward is called when a Minigame finishes.
 *
 * @param Client to target
 * @noreturn
 */
Handle GlobalForward_OnMinigameFinish;

/**
 * Forward is called on every game frame. 
 * NOTE: Only run minimal code here.
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnGameFrame;

/**
 * Forward is called when an entity is created.
 *
 * @param Entity Index
 * @param Entity Classname
 * @noreturn
 */
Handle GlobalForward_OnEntityCreated;

/**
 * Forward is called when PropBroken event is fired.
 *
 * @param Client who broke the prop
 * @noreturn
 */
Handle GlobalForward_OnPropBroken;

/**
 * Forward is called when a Player successfully performs a Sticky Jump.
 *
 * @param Client who performed the Sticky Jump
 * @noreturn
 */
Handle GlobalForward_OnStickyJump;

/**
 * Forward is called when a Player successfully performs a Rocket Jump.
 *
 * @param Client who performed the Rocket Jump
 * @noreturn
 */
Handle GlobalForward_OnRocketJump;

/**
 * Forward is called when a Player successfully builds an object (Sentry, Dispenser, Teleporter).
 *
 * @param Client who build the Object
 * @param Edict of entity that was built.
 * @noreturn
 */
Handle GlobalForward_OnBuildObject;

/**
 * Forward is called when a Player dies.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
Handle GlobalForward_OnPlayerDeath;

/**
 * Forward is called when a Player gets hurt.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
Handle GlobalForward_OnPlayerHurt;

/**
 * Forward is called when a Player takes damage (SDKHook).
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @param Damage amount
 * @noreturn
 */
Handle GlobalForward_OnPlayerTakeDamage;

/**
 * Forward is called when a Player gets Jarate thrown onto them.
 *
 * @param Client who was the Victim
 * @param Client who was the Attacker
 * @noreturn
 */
Handle GlobalForward_OnPlayerJarated;

/**
 * Forward is called when a Player changes their class.
 *
 * @param Client who is changing class
 * @param Class the client changed to.
 * @noreturn
 */
Handle GlobalForward_OnPlayerClassChange;

/**
 * Forward is called when a Player gets stunned.
 *
 * @param Client who got hit by the stun ball (Victim)
 * @param Client who hit the ball to the victim (Attacker)
 * @noreturn
 */
Handle GlobalForward_OnPlayerStunned;

/**
 * Forward is called when a Player's Critical Chance is calculated.
 *
 * @param Client that this is being calculated for
 * @param Weapon Entity Index
 * @param Weapon Name 
 * @noreturn
 */
Handle GlobalForward_OnPlayerCalculateCritical;

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
Handle GlobalForward_OnPlayerRunCmd;

/**
 * Forward is called when a Boss Minigame will be attempted to stop. 
 *
 * @noparams
 * @returns True / False depending if the Boss can be stopped now.
 */
Handle GlobalForward_OnBossStopAttempt;

/**
 * Forward is called when a Player runs a command.
 *
 * @noparams
 * @noreturn
 */
Handle GlobalForward_OnTfRoundStart;

stock void InitializeForwards()
{
	LogMessage("Initializing Forwards...");

	GlobalForward_OnMapStart = CreateForward(ET_Ignore);
	GlobalForward_OnMinigamePreload = CreateForward(ET_Ignore);
	GlobalForward_OnMinigamePreparePre = CreateForward(ET_Ignore);
	GlobalForward_OnMinigamePrepare = CreateForward(ET_Ignore, Param_Any);
	GlobalForward_OnMinigameSelectedPre = CreateForward(ET_Ignore);
	GlobalForward_OnMinigameSelected = CreateForward(ET_Ignore, Param_Any);
	GlobalForward_OnMinigameSelectedPost = CreateForward(ET_Ignore);
	GlobalForward_OnMinigameFinishPre = CreateForward(ET_Ignore);
	GlobalForward_OnMinigameFinish = CreateForward(ET_Ignore, Param_Any);
	GlobalForward_OnGameFrame = CreateForward(ET_Ignore);
	GlobalForward_OnEntityCreated = CreateForward(ET_Ignore, Param_Any, Param_String);
	GlobalForward_OnPropBroken = CreateForward(ET_Ignore, Param_Any);
	GlobalForward_OnStickyJump = CreateForward(ET_Ignore, Param_Any);
	GlobalForward_OnRocketJump = CreateForward(ET_Ignore, Param_Any);
	GlobalForward_OnBuildObject = CreateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerDeath = CreateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerHurt = CreateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerTakeDamage = CreateForward(ET_Ignore, Param_Any, Param_Any, Param_Float);
	GlobalForward_OnPlayerJarated = CreateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerClassChange = CreateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerStunned = CreateForward(ET_Ignore, Param_Any, Param_Any);
	GlobalForward_OnPlayerCalculateCritical = CreateForward(ET_Ignore, Param_Any, Param_Any, Param_String);
	GlobalForward_OnPlayerRunCmd = CreateForward(ET_Ignore, Param_Any, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	GlobalForward_OnBossStopAttempt = CreateForward(ET_Single);
	GlobalForward_OnTfRoundStart = CreateForward(ET_Ignore);
}

stock void RemoveForwardsFromMemory()
{
	SafelyRemoveAllFromForward(GlobalForward_OnMapStart);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigamePreload);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigamePreparePre);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigamePrepare);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameSelectedPre);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameSelected);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameSelectedPost);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameFinishPre);
	SafelyRemoveAllFromForward(GlobalForward_OnMinigameFinish);
	SafelyRemoveAllFromForward(GlobalForward_OnGameFrame);
	SafelyRemoveAllFromForward(GlobalForward_OnEntityCreated);
	SafelyRemoveAllFromForward(GlobalForward_OnPropBroken);
	SafelyRemoveAllFromForward(GlobalForward_OnStickyJump);
	SafelyRemoveAllFromForward(GlobalForward_OnRocketJump);
	SafelyRemoveAllFromForward(GlobalForward_OnBuildObject);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerDeath);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerHurt);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerJarated);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerClassChange);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerStunned);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerCalculateCritical);
	SafelyRemoveAllFromForward(GlobalForward_OnPlayerRunCmd);
	SafelyRemoveAllFromForward(GlobalForward_OnBossStopAttempt);
	SafelyRemoveAllFromForward(GlobalForward_OnTfRoundStart);
}

stock void SafelyRemoveAllFromForward(Handle hndl)
{
	if (hndl != INVALID_HANDLE)
	{
		RemoveAllFromForward(hndl, INVALID_HANDLE);
	}
}