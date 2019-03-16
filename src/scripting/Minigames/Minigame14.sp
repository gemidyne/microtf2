/**
 * MicroTF2 - Minigame 14
 * 
 * Get into the water
 */

#define FL_ISINWATER (FL_INWATER | FL_FLY | FL_SWIM)

public void Minigame14_EntryPoint()
{
	// AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame14_OnMinigameSelectedPre);
	// AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame14_OnMinigameSelected);
	// AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame14_OnGameFrame);
	// AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame14_OnMinigameFinish);
}

public void Minigame14_OnMinigameSelectedPre()
{
	if (MinigameID != 14)
	{
		return;
	}
	
	IsBlockingDamage = false;
	IsOnlyBlockingDamageByPlayers = true;
}

public void Minigame14_OnMinigameSelected(int client)
{
	if (MinigameID != 14)
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
		player.Class = TFClass_Scout;
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);

		ResetWeapon(client, false);

		/*
		new Float:vel[3] = { 0.0, 0.0, 0.0 };
		new Float:ang[3] = { 0.0, 90.0, 0.0 };

		new column = i;
		new row = 0;
		while (column > 9)
		{
			column = column - 9;
			row = row + 1;
		}

		new Float:pos[3];
		pos[0] = -5240.4 + float(column*55);
		pos[1] = 2659.9 - float(row*55);
		pos[2] = -293.6;

		TeleportEntity(i, pos, ang, vel);*/

		PrintCenterText(client, "AREA NOT FOUND\n\nUnable to teleport player - automatic win set");
	}
}

public void Minigame14_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 14)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && (GetEntityFlags(i) & FL_ISINWATER))
			{
				ClientWonMinigame(i);
			}
		}
	}
}

public void Minigame14_OnMinigameFinish()
{
	if (MinigameID == 14)
	{
		for (int i = 1; i <= MaxClients; i++) 
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating) 
			{
				player.Respawn();
			}
		}
	}
}