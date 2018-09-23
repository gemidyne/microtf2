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
	if (IsMinigameActive && MinigameID == 11 && IsClientValid(client))
	{
		PlayerStatus[client] = PlayerStatus_Winner;
	}
}

public void Minigame11_GetDynamicCaption(int client)
{
	if (IsClientValid(client))
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		if (Minigame11_Mode == 2)
		{
			text = "DON\'T STOP MOVING!";
		}
		else
		{
			text = "DON\'T MOVE!";
		}

		MinigameCaption[client]	= text;
	}
}

public void Minigame11_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 11 && Minigame11_CanCheckConditions)
	{
		float velocity[3];
		float speed = 0.0;
		float limit = 0.0;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i])
			{
				limit = GetEntPropFloat(i, Prop_Send, "m_flMaxspeed") - 100.0;
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", velocity);
				speed = GetVectorLength(velocity);

				if (Minigame11_Mode == 2)
				{
					if (speed < limit && PlayerStatus[i] == PlayerStatus_Winner) 
					{
						PlayerStatus[i] = PlayerStatus_Failed;
						ForcePlayerSuicide(i);
					}
				}
				else if (Minigame11_Mode == 1)
				{
					if (speed > 100.0 && PlayerStatus[i] == PlayerStatus_Winner)
					{
						PlayerStatus[i] = PlayerStatus_Failed;
						ForcePlayerSuicide(i);
					}
				}
			}
		}
	}
}

