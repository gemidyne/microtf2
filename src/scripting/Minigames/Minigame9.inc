/**
 * MicroTF2 - Minigame 9
 * 
 * Simon Says!
 */

new MinigameNine_Mode = -1;
new bool:MinigameNine_CanCheckConditions = false;

public Minigame9_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameNine_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameFinishPre, INVALID_HANDLE, MinigameNine_OnMinigameFinishPre);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, MinigameNine_OnGameFrame);
}

public bool:Minigame9_OnCheck()
{
	return true;
}

public MinigameNine_OnMinigameSelectedPre()
{
	if (MinigameID == 9)
	{
		//IsBlockingTaunts = false;
		MinigameNine_Mode = GetRandomInt(3, 6);

		MinigameNine_CanCheckConditions = false;
		CreateTimer(1.5, Timer_MinigameNine_AllowConditions);		
	}
}

public Action:Timer_MinigameNine_AllowConditions(Handle:timer)
{
	MinigameNine_CanCheckConditions = true;
}

public Minigame9_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		decl String:text[64];

		switch (MinigameNine_Mode)
		{
			case 1: text = "SIMON SAYS: TAUNT!";
			case 2: text = "SOMEONE SAYS: TAUNT!";
			case 3: text = "SIMON SAYS: JUMP!";	
			case 4: text = "SOMEONE SAYS: JUMP!";
			case 5: text = "SIMON SAYS: CROUCH!";
			case 6: text = "SOMEONE SAYS: CROUCH!";
		}

		MinigameCaption[client] = text; // for storage only
		TrainingMessageToClient(client, text, "...", 3.0);
	}
}

public MinigameNine_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 9)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i] && MinigameNine_CanCheckConditions)
			{
				new button = GetClientButtons(i);
				if ((button & IN_DUCK) == IN_DUCK)
				{
					if (MinigameNine_Mode == 5) 
					{
						ClientWonMinigame(i);
					}
					else if (MinigameNine_Mode == 6 && PlayerStatus[i] != PlayerStatus_Failed)
					{
						TrainingMessageToClient(i, MinigameCaption[i], "(SIMON DIDN\'T SAY IT..)", 3.0);
						PlayerStatus[i] = PlayerStatus_Failed;
					}
				}
	
				if (MinigameNine_Mode == 1 && TF2_IsPlayerInCondition(i, TFCond_Taunting)) 
				{
					//Simon Says Taunt!
					ClientWonMinigame(i);
				}
				else if (MinigameNine_Mode == 2)
				{ 
					//Someone Says: Taunt!
					if (TF2_IsPlayerInCondition(i, TFCond_Taunting) && PlayerStatus[i] != PlayerStatus_Failed)
					{
						TrainingMessageToClient(i, MinigameCaption[i], "(SIMON DIDN\'T SAY IT..)", 3.0);
						PlayerStatus[i] = PlayerStatus_Failed;
					}
				}
				else if (MinigameNine_Mode == 3 && (button & IN_JUMP) == IN_JUMP) 
				{
					//Simon Says: Jump!
					ClientWonMinigame(i);
				}
				else if (MinigameNine_Mode == 4)
				{ 
					//Someone Says: Jump!
					if ((button & IN_JUMP) == IN_JUMP && PlayerStatus[i] != PlayerStatus_Failed)
					{
						TrainingMessageToClient(i, MinigameCaption[i], "(SIMON DIDN\'T SAY IT..)", 3.0);
						PlayerStatus[i] = PlayerStatus_Failed;
					}
				}
			}
		}
	}
}

public MinigameNine_OnMinigameFinishPre()
{
	if (IsMinigameActive && MinigameID == 9)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i])
			{
				if (MinigameNine_Mode == 2)
				{
					if (!TF2_IsPlayerInCondition(i, TFCond_Taunting))
					{
						ClientWonMinigame(i);
					}
				}
				else if (MinigameNine_Mode == 4) 
				{
					new button = GetClientButtons(i);

					if ((button & IN_JUMP) != IN_JUMP)
					{
						ClientWonMinigame(i);
					}
				}
				else if (MinigameNine_Mode == 6)
				{
					new button = GetClientButtons(i);

					if ((button & IN_DUCK) != IN_DUCK)
					{
						ClientWonMinigame(i);
					}
				}
			}
		}
	}
}