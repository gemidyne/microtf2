/**
 * MicroTF2 - Minigame 1
 * 
 * Get to the End
 */

public void Minigame1_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame1_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame1_OnSelection);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame1_OnGameFrame);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame1_OnFinish);
}

public void Minigame1_OnSelectionPre()
{
	if (MinigameID == 1)
	{
		IsBlockingDamage = false;
		IsBlockingDeathCommands = false;
	}
}

public void Minigame1_OnSelection(int client)
{
	if (MinigameID != 1)
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
		float ang[3] = { 0.0, 90.0, 0.0 };
		float vel[3] = { 0.0, 0.0, 0.0 };
		float pos[3];

		player.Class = TFClass_Scout;
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);
		player.SetHealth(1000);
		player.ResetWeapon(false);

		int column = client;
		int row = 0;
		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		pos[0] = -4728.0 + float(column*55);
		pos[1] = 2911.0 - float(row*55);
		pos[2] = -1380.0;

		TeleportEntity(client, pos, ang, vel);
	}
}

public void Minigame1_OnGameFrame()
{
	if (MinigameID != 1)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);
		
		if (player.IsValid && player.IsParticipating && player.Status == PlayerStatus_NotWon)
		{
			float pos[3];
			GetClientAbsOrigin(i, pos);

			if (pos[1] > 3755.0)
			{
				ClientWonMinigame(i);
			}
		}
	}
}

public void Minigame1_OnFinish()
{
	if (MinigameID != 1)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++) 
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating) 
		{
			player.Respawn();
		}
	}
}