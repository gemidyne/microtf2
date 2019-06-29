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