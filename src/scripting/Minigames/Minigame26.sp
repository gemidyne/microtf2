/**
 * MicroTF2 - Minigame 26
 *
 * No laughing!
 */

public void Minigame26_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame26_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame26_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerConditionAdded, INVALID_HANDLE, Minigame26_OnPlayerConditionAdded);
}

public void Minigame26_OnMinigameSelectedPre()
{
	if (MinigameID == 26)
	{
		IsBlockingDamage = false;
	}
}

public void Minigame26_OnMinigameSelected(int client)
{
	if (MinigameID != 26)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.Class = TFClass_Heavy;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		player.SetHealth(3000);
		player.Status = PlayerStatus_Winner;

		GiveWeapon(client, 656);
	}
}

public void Minigame26_OnPlayerConditionAdded(int client, int conditionId)
{
	if (MinigameID != 26)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	if (!player.IsParticipating)
	{
		return;
	}

	TFCond condition = view_as<TFCond>(conditionId);

	if (condition == TFCond_Taunting)
	{
		player.Status = PlayerStatus_Failed;
	}
}