/**
 * MicroTF2 - Minigame 7
 * 
 * Rocket Jump!
 */

public Minigame7_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame7_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame7_OnMinigameSelected);
	AddToForward(GlobalForward_OnRocketJump, INVALID_HANDLE, Minigame7_OnRocketJump);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame7_OnMinigameFinish);
}

public Minigame7_OnMinigameSelectedPre()
{
	if (MinigameID == 7)
	{
		IsBlockingDamage = false;
		IsBlockingDeaths = true;
	}
}

public Minigame7_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 7 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Soldier);
		ResetWeapon(client, true);
		IsGodModeEnabled(client, false);
		SetPlayerHealth(client, 1000);
		GiveWeapon(client, 237);
		IsViewModelVisible(client, true);
	}
}

public Minigame7_OnRocketJump(client)
{
	if (IsMinigameActive && MinigameID == 7 && IsClientValid(client) && IsPlayerParticipant[client])
	{
		ClientWonMinigame(client);
		SetEntityGravity(client, 0.5);
	}
}

public Minigame7_OnMinigameFinish()
{
	if (MinigameID == 7)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i] && !IsFakeClient(i))
			{
				StopSound(i, SNDCHAN_AUTO, "misc/grenade_jump_lp_01.wav");
			}
		}
	}
}