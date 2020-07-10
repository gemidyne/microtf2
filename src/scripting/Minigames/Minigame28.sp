/**
 * MicroTF2 - Minigame 28
 *
 * Listen for it!
 */

int Minigame28_SoundPositionId;

public void Minigame28_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame28_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame28_OnMinigameSelected);
}

public void Minigame27_OnMinigameSelectedPre()
{
	if (MinigameID == 28)
	{
		Minigame28_SoundPositionId = GetRandomInt(0, 1) == 1;
	}
}

public void Minigame28_OnMinigameSelected(int client)
{
	if (MinigameID != 28)
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
		
	}
}