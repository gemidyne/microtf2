/**
 * MicroTF2 - Minigame 5
 * 
 * Sticky Jump!
 */

public void Minigame5_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame5_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame5_OnMinigameSelected);
	AddToForward(GlobalForward_OnStickyJump, INVALID_HANDLE, Minigame5_OnStickyJump);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame5_OnMinigameFinish);
}

public bool Minigame5_OnCheck()
{
	return true;
}

public void Minigame5_OnMinigameSelectedPre()
{
	if (MinigameID == 5)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
	}
}

public void Minigame5_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 5 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_DemoMan);
		TF2_RemoveAllWeapons(client);

		IsGodModeEnabled(client, false);
		SetPlayerHealth(client, 1000);
		GiveWeapon(client, 265);
		IsViewModelVisible(client, true);
	}
}

public void Minigame5_OnStickyJump(int client)
{
	if (IsMinigameActive && MinigameID == 5 && IsPlayerParticipant[client])
	{
		ClientWonMinigame(client);
		SetEntityGravity(client, 0.5);
	}
}

public void Minigame5_OnMinigameFinish()
{
	if (MinigameID == 5)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i] && !IsFakeClient(i))
			{
				StopSound(i, SNDCHAN_AUTO, "misc/grenade_jump_lp_01.wav");
			}
		}
	}
}