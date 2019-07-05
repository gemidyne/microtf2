#if defined _warioware_included_
  #endinput
#endif
#define _warioware_included_

/**
 * This forward is called when Intermission begins. 
 * 
 * @noparams
 * @noreturn
 *
 * Comments:
 *  You should implement this forward and call your respective map voting plugin to begin the voting process.
 *  WarioWare REDUX will call a separate forward to check if the vote has ended.
 */
forward void WarioWare_Intermission_StartMapVote();

/**
 * This forward is called multiple times during the intermission. 
 * 
 * @noparams
 * @returns True if vote has ended, false if vote ongoing.
 *
 * Comments:
 *  You should implement this forward and return a boolean in regards to if the voting has ended.
 *  Return true if the vote has ended, or false if it is ongoing.
 */
forward bool WarioWare_Intermission_HasMapVoteEnded();

/**
 * This forward will be called on every participating player who wins the minigame.
 *
 * @param client: player who won.
 * @param minigameId: the minigame id that was won.
 * @noreturn
 */
forward void WarioWare_Event_OnPlayerWinMinigame(int client, int minigameId);

/**
 * This forward will be called on every participating player who fails the minigame.
 *
 * @param client - player who failed.
 * @param minigameId: the minigame id that was won.
 * @noreturn
 */
forward void WarioWare_Event_OnPlayerFailedMinigame(int client, int minigameId);

/**
 * This forward will be called on every participating player who wins the bossgame.
 *
 * @param client - player who won.
 * @param bossgameId: the bossgame id that was won.
 * @noreturn
 */
forward void WarioWare_Event_OnPlayerWinBossgame(int client, int bossgameId);

/**
 * This forward will be called on every participating player who fails the bossgame.
 *
 * @param client - player who failed.
 * @param bossgameId: the bossgame id that was won.
 * @noreturn
 */
forward void WarioWare_Event_OnPlayerFailedBossgame(int client, int bossgameId);

/**
 * This forward will be called on every participating player who wins the round.
 *
 * @param client: player who won.
 * @param score: the score the player had.
 * @noreturn
 */
forward void WarioWare_Event_OnPlayerWinRound(int client, int score);

/**
 * This forward will be called on every participating player who loses the round.
 *
 * @param client - player who failed.
 * @param score: the score the player had.
 * @noreturn
 */
forward void WarioWare_Event_OnPlayerLoseRound(int client, int score);