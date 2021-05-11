/**
 * MicroTF2 - Minigame 11
 * 
 * Keep Moving / Don't stop moving!
 */


int g_iMinigame11Mode = -1;
bool g_iMinigame11CanCheckConditions = false;

public void Minigame11_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame11_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame11_OnMinigameSelected);
	AddToForward(g_pfOnGameFrame, INVALID_HANDLE, Minigame11_OnGameFrame);
}

public void Minigame11_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 11)
	{
		g_iMinigame11Mode = GetRandomInt(1, 2);
		g_iMinigame11CanCheckConditions = false;

		CreateTimer(2.0, Timer_Minigame11_AllowConditions);
	}
}

public Action Timer_Minigame11_AllowConditions(Handle timer)
{
	g_iMinigame11CanCheckConditions = true;
	return Plugin_Handled;
}

public void Minigame11_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 11)
	{
		return;
	}

	if (!g_bIsMinigameActive)
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
		char text[64];

		if (g_iMinigame11Mode == 2)
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
	if (g_iActiveMinigameId != 11)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	if (g_iMinigame11CanCheckConditions)
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

				if (g_iMinigame11Mode == 2 && speed < limit && player.Status == PlayerStatus_Winner)
				{
					player.Status = PlayerStatus_Failed;
					player.Kill();
				}
				else if (g_iMinigame11Mode == 1 && speed > 100.0 && player.Status == PlayerStatus_Winner)
				{
					player.Status = PlayerStatus_Failed;
					player.Kill();
				}
			}
		}
	}
}

