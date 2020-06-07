/**
 * MicroTF2 - Minigame 11
 * 
 * Keep Moving / Don't stop moving!
 */


int Minigame11_Mode = -1;
bool Minigame11_CanCheckConditions = false;

public void Minigame11_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame11_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame11_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame11_OnGameFrame);
}

public void Minigame11_OnMinigameSelectedPre()
{
	if (MinigameID == 11)
	{
		Minigame11_Mode = GetRandomInt(1, 2);
		Minigame11_CanCheckConditions = false;

		CreateTimer(2.0, Timer_Minigame11_AllowConditions);
	}
}

public Action Timer_Minigame11_AllowConditions(Handle timer)
{
	Minigame11_CanCheckConditions = true;
}

public void Minigame11_OnMinigameSelected(int client)
{
	if (MinigameID != 11)
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
		player.Status = PlayerStatus_Winner;
	}
}

public void Minigame11_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		if (Minigame11_Mode == 2)
		{
			Format(text, sizeof(text), "%T", "Minigame11_Caption_DontStopMoving", client);
		}
		else
		{
			Format(text, sizeof(text), "%T", "Minigame11_Caption_DontMove", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame11_OnGameFrame()
{
	if (MinigameID != 11)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	if (Minigame11_CanCheckConditions)
	{
		float velocity[3];
		float speed = 0.0;
		float limit = 0.0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				limit = player.MaxSpeed - 100.0;
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", velocity);
				speed = GetVectorLength(velocity);

				if (Minigame11_Mode == 2)
				{
					if (speed < limit && player.Status == PlayerStatus_Winner) 
					{
						player.Status = PlayerStatus_Failed;
						player.Kill();
					}
				}
				else if (Minigame11_Mode == 1)
				{
					if (speed > 100.0 && player.Status == PlayerStatus_Winner)
					{
						player.Status = PlayerStatus_Failed;
						player.Kill();
					}
				}
			}
		}
	}
}

