/**
 * MicroTF2 - Minigame 11
 * 
 * Keep Moving / Don't stop moving!
 */


new MinigameEleven_Mode = -1;
new bool:MinigameEleven_CanCheckConditions = false;

public Minigame11_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameEleven_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameEleven_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, MinigameEleven_OnGameFrame);
}

public MinigameEleven_OnMinigameSelectedPre()
{
	if (MinigameID == 11)
	{
		MinigameEleven_Mode = GetRandomInt(1, 2);

		MinigameEleven_CanCheckConditions = false;
		CreateTimer(2.0, Timer_MinigameEleven_AllowConditions);		
	}
}

public Action:Timer_MinigameEleven_AllowConditions(Handle:timer)
{
	MinigameEleven_CanCheckConditions = true;
}

public MinigameEleven_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 11 && IsClientValid(client))
	{
		PlayerStatus[client] = PlayerStatus_Winner;
	}
}

public Minigame11_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		decl String:text[64];

		if (MinigameEleven_Mode == 2)
		{
			text = "DON\'T STOP MOVING!";
		}
		else
		{
			text = "DON\'T MOVE!";
		}

		MinigameCaption[client] = text;
	}
}

public MinigameEleven_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 11 && MinigameEleven_CanCheckConditions)
	{
		decl Float:fVelocity[3];
		new Float:speed = 0.0;
		new Float:limit = 0.0;

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i])
			{
				limit = GetEntPropFloat(i, Prop_Send, "m_flMaxspeed") - 100.0;
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);
				speed = GetVectorLength(fVelocity);

				if (MinigameEleven_Mode == 2)
				{
					if (speed < limit && PlayerStatus[i] == PlayerStatus_Winner) 
					{
						PlayerStatus[i] = PlayerStatus_Failed;
						ForcePlayerSuicide(i);
					}
				}
				else if (MinigameEleven_Mode == 1)
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

