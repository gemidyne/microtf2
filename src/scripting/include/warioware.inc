#if defined _warioware_included_
  #endinput
#endif
#define _warioware_included_

/**
 * This forward is called when Intermission begins. 
 * 
 * Developers: 
 *  You should implement this forward and call your respective map voting plugin to begin the voting process.
 *  WarioWare REDUX will call a separate forward to check if the vote has ended.
 */
forward void Intermission_StartMapVote();

/**
 * This forward is called multiple times during the intermission. 
 * 
 * Developers: 
 *  You should implement this forward and return a boolean in regards to if the voting has ended.
 *  Return true if the vote has ended, or false if it is ongoing.
 */
forward bool Intermission_HasMapVoteEnded();

/**
 * Called when a player has won a minigame.
 *
 * @param client - player who won.
 */
forward void Event_OnPlayerWinMinigame(int client);

/**
 * Called when a player has failed a minigame.
 *
 * @param client - player who failed.
 */
forward void Event_OnPlayerFailedMinigame(int client);

/**
 * Called when a player has won a bossgame.
 *
 * @param client - player who won.
 */
forward void Event_OnPlayerWinBossgame(int client);

/**
 * Called when a player has failed a bossgame.
 *
 * @param client - player who failed.
 */
forward void Event_OnPlayerFailedBossgame(int client);

/**
 * Called when a player has won a round.
 *
 * @param client - player who won.
 */
forward void Event_OnPlayerWinRound(int client);

/**
 * Called when a player has lost a round.
 *
 * @param client - player who failed.
 */
forward void Event_OnPlayerLoseRound(int client);