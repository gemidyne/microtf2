/**
 * MicroTF2 - Minigame 8
 * 
 * Maths
 */

char Minigame8_SayTextQuestion[64];
bool Minigame8_HasBeenAnswered = false;
int Minigame8_SayTextAnswer = 0;

public void Minigame8_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame8_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame8_OnMinigameFinish);

	RegConsoleCmd("say", Command_Minigame8Say);
	RegConsoleCmd("say_team", Command_Minigame8Say);
}

public void Minigame8_OnMinigameSelectedPre()
{
	if (MinigameID == 8)
	{
		Minigame8_HasBeenAnswered = false;

		int int1 = GetRandomInt(3, 15);
		int int2 = GetRandomInt(3, 15);
		char form[12];

		switch (GetRandomInt(1, 3))
		{
			case 1:
			{
				if (GetRandomInt(1, 50) == 1)
				{
					int1 = GetRandomInt(1,9)*1000;
					int2 = 9001 - int1;
				}

				Minigame8_SayTextAnswer = int1 + int2;
				Format(form, sizeof(form), "+");
			}

			case 2:
			{
				if (GetRandomInt(1, 50) == 1)
				{
					int1 = 1; 
					int2 = 1;
				}

				Minigame8_SayTextAnswer = int1 - int2;
				Format(form, sizeof(form), "-");
			}

			case 3:
			{
				Format(form, sizeof(form), "*");

				int1 = GetRandomInt(2, 10);
				int2 = GetRandomInt(2, 10);
				Minigame8_SayTextAnswer = int1 * int2;
			}
		}

		Format(Minigame8_SayTextQuestion, sizeof(Minigame8_SayTextQuestion), "%d %s %d", int1, form, int2);
	}
}

public void Minigame8_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsInGame)
	{
		char text[64];
		Format(text, sizeof(text), "%s\n%s = ?", MinigameCaption[client], Minigame8_SayTextQuestion);	
		
		MinigameCaption[client] = text;
	}
}


public Action Command_Minigame8Say(int client, int args)
{
	if (IsMinigameActive && MinigameID == 8)
	{
		char text[192];
		if (GetCmdArgString(text, sizeof(text)) < 1)
		{
			return Plugin_Continue;
		}
	
		if (IsPlayerParticipant[client])
		{
			int startidx;
			if (text[strlen(text)-1] == '"')
			{
				text[strlen(text)-1] = '\0';
			}

			startidx = 1;

			char message[192];
			BreakString(text[startidx], message, sizeof(message));

			char strArgument[64];
			GetCmdArg(1, strArgument, sizeof(strArgument));
				
			if (!IsStringInt(strArgument)) 
			{
				return Plugin_Continue;
			}
		
			int guess = StringToInt(strArgument);
		
			if (guess == Minigame8_SayTextAnswer)
			{
				ClientWonMinigame(client);

				if (!Minigame8_HasBeenAnswered)
				{
					CPrintToChatAllEx(client, "%s{teamcolor}%N {green}got the correct answer first! (Bonus Point!)", PLUGIN_PREFIX, client);

					PlayerScore[client]++;
					Minigame8_HasBeenAnswered = true;
				}

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void Minigame8_OnMinigameFinish()
{
	if (MinigameID == 8)
	{
		CPrintToChatAll("{green}The correct answer was %d!", Minigame8_SayTextAnswer);
	}
}