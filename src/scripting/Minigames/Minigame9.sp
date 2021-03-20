/**
 * MicroTF2 - Minigame 9
 * 
 * Simon Says!
 */

int g_iMinigame9Mode = -1;
bool g_bMinigame9CanCheckConditions = false;

public void Minigame9_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame9_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameFinishPre, INVALID_HANDLE, Minigame9_OnMinigameFinishPre);
	AddToForward(g_pfOnGameFrame, INVALID_HANDLE, Minigame9_OnGameFrame);
}

public void Minigame9_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 9)
	{
		g_bIsBlockingTaunts = false;
		g_iMinigame9Mode = GetRandomInt(1, 6);
		g_bMinigame9CanCheckConditions = false;

		CreateTimer(1.5, Timer_Minigame9_AllowConditions);
	}
}

public Action Timer_Minigame9_AllowConditions(Handle timer)
{
	g_bMinigame9CanCheckConditions = true;
	return Plugin_Handled;
}

public void Minigame9_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsInGame)
	{
		char text[64];

		switch (g_iMinigame9Mode)
		{
			case 1: Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonSaysTaunt", client);
			case 2: Format(text, sizeof(text), "%T", "Minigame9_Caption_SomeoneSaysTaunt", client);
			case 3: Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonSaysJump", client);
			case 4: Format(text, sizeof(text), "%T", "Minigame9_Caption_SomeoneSaysJump", client);
			case 5: Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonSaysCrouch", client);
			case 6: Format(text, sizeof(text), "%T", "Minigame9_Caption_SomeoneSaysCrouch", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame9_OnGameFrame()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 9)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && g_bMinigame9CanCheckConditions)
			{
				switch (g_iMinigame9Mode)
				{
					case 1:
					{
						if (player.HasCondition(TFCond_Taunting) && player.Status != PlayerStatus_Winner) 
						{
							player.TriggerSuccess();
						}
					}

					case 2: 
					{
						if (player.HasCondition(TFCond_Taunting) && player.Status != PlayerStatus_Failed)
						{
							char text[64];
							Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonDidntSayIt", i);
							player.SetCaption(text);
							player.Status = PlayerStatus_Failed;
						}
					}

					case 3:
					{
						int button = GetClientButtons(i);

						if ((button & IN_JUMP) == IN_JUMP && player.Status != PlayerStatus_Winner) 
						{
							player.TriggerSuccess();
						}
					}

					case 4:
					{
						int button = GetClientButtons(i);

						if ((button & IN_JUMP) == IN_JUMP && player.Status != PlayerStatus_Failed)
						{
							char text[64];
							Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonDidntSayIt", i);
							player.SetCaption(text);
							player.Status = PlayerStatus_Failed;
						}
					}

					case 5:
					{
						int button = GetClientButtons(i);

						if ((button & IN_DUCK) == IN_DUCK && player.Status != PlayerStatus_Winner)
						{
							player.TriggerSuccess();
						}
					}

					case 6:
					{
						int button = GetClientButtons(i);

						if ((button & IN_DUCK) == IN_DUCK && player.Status != PlayerStatus_Failed)
						{
							char text[64];
							Format(text, sizeof(text), "%T", "Minigame9_Caption_SimonDidntSayIt", i);
							player.SetCaption(text);
							player.Status = PlayerStatus_Failed;
						}
					}
				}
			}
		}
	}
}

public void Minigame9_OnMinigameFinishPre()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 9)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				if (g_iMinigame9Mode == 2)
				{
					if (!player.HasCondition(TFCond_Taunting))
					{
						player.TriggerSuccess();
					}
				}
				else if (g_iMinigame9Mode == 4) 
				{
					int button = GetClientButtons(i);

					if ((button & IN_JUMP) != IN_JUMP)
					{
						player.TriggerSuccess();
					}
				}
				else if (g_iMinigame9Mode == 6)
				{
					int button = GetClientButtons(i);

					if ((button & IN_DUCK) != IN_DUCK)
					{
						player.TriggerSuccess();
					}
				}
			}
		}
	}
}