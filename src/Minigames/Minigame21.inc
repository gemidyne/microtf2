/**
 * MicroTF2 - Minigame 21
 *
 * Stun an Enemy
 */

public Minigame21_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame21_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerStunned, INVALID_HANDLE, Minigame21_OnPlayerStunned);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame21_OnMinigameFinish);
}

public bool:Minigame21_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}

	if (GetTeamClientCount(2) < 1 || GetTeamClientCount(3) < 1)
	{
		return false;
	}

	return true;
}

public Minigame21_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 21 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Scout);

		GiveWeapon(client, 44);
		IsViewModelVisible(client, true);
		IsGodModeEnabled(client, false);

		SetPlayerHealth(client, 1000);
		SetPlayerAmmo(client, 5);
		SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
	}
}

public Minigame21_OnPlayerStunned(stunner, victim)
{
	if (IsMinigameActive && MinigameID == 21)
	{
		if (IsClientValid(stunner) && IsPlayerParticipant[stunner])
		{
			ClientWonMinigame(stunner);
			GiveWeapon(stunner, 0);
			IsViewModelVisible(stunner, false);
		}
	}
}

public Minigame21_OnMinigameFinish()
{
	if (IsMinigameActive && MinigameID == 21)
	{
		RemoveAllStunballEntities();
	}
}