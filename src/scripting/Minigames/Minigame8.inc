/**
 * MicroTF2 - Minigame 8
 * 
 * Maths
 */

new String:MinigameEight_SayTextQuestion[64];
new bool:MinigameEight_HasBeenAnswered = false;
new MinigameEight_SayTextAnswer = 0;

public Minigame8_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameEight_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, MinigameEight_OnMinigameFinish);

	RegConsoleCmd("say", Command_MinigameEightSay);
	RegConsoleCmd("say_team", Command_MinigameEightSay);
}

public bool:Minigame8_OnCheck()
{
	return true;
}

public MinigameEight_OnMinigameSelectedPre()
{
	if (MinigameID == 8)
	{
		MinigameEight_HasBeenAnswered = false;

		new int1 = GetRandomInt(3, 15);
		new int2 = GetRandomInt(3, 15);
		new String:form[12];

		switch (GetRandomInt(1, 3))
		{
			case 1:
			{
				if (GetRandomInt(1, 50) == 1)
				{
					int1 = GetRandomInt(1,9)*1000;
					int2 = 9001 - int1;
				}

				MinigameEight_SayTextAnswer = int1 + int2;
				Format(form, sizeof(form), "+");
			}

			case 2:
			{
				if (GetRandomInt(1, 50) == 1)
				{
					int1 = 1; 
					int2 = 1;
				}

				MinigameEight_SayTextAnswer = int1 - int2;
				Format(form, sizeof(form), "-");
			}

			case 3:
			{
				Format(form, sizeof(form), "*");

				int1 = GetRandomInt(2, 10);
				int2 = GetRandomInt(2, 10);
				MinigameEight_SayTextAnswer = int1 * int2;
			}
		}
		Format(MinigameEight_SayTextQuestion, sizeof(MinigameEight_SayTextQuestion), "%d %s %d", int1, form, int2);
	}
}

public Minigame8_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		decl String:text[64];

		Format(text, sizeof(text), "%s = ?", MinigameEight_SayTextQuestion);

		TrainingMessageToClient(client, MinigameCaption[client], text, 3.0);
	}
}


public Action:Command_MinigameEightSay(client, args)
{
	if (IsMinigameActive && MinigameID == 8)
	{
		decl String:text[192];
		if (GetCmdArgString(text, sizeof(text)) < 1)
		{
			return Plugin_Continue;
		}
	
		if (IsPlayerParticipant[client])
		{
			new startidx;
			if (text[strlen(text)-1] == '"')
			{
				text[strlen(text)-1] = '\0';
			}

			startidx = 1;

			decl String:message[192];
			BreakString(text[startidx], message, sizeof(message));

			decl String:strArgument[64]; 
			GetCmdArg(1, strArgument, sizeof(strArgument));
				
			if (!Math_IsStringANumber(strArgument)) 
			{
				return Plugin_Continue;
			}
		
			new guess = StringToInt(strArgument);
		
			if (guess == MinigameEight_SayTextAnswer)
			{
				ClientWonMinigame(client);

				if (!MinigameEight_HasBeenAnswered)
				{
					CPrintToChatAllEx(client, "{teamcolor}%N {green}got the correct answer first! (Bonus Point!)", client);

					PlayerScore[client]++;
					MinigameEight_HasBeenAnswered = true;
				}

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

stock bool:Math_IsStringANumber(String:Arg[64])
{
    if (StringToInt(Arg) != 0) return true;
    if (StrEqual(Arg, "0")) return true;
    return false;
}

public MinigameEight_OnMinigameFinish()
{
	if (MinigameID == 8)
	{
		CPrintToChatAll("{green}The correct answer was %d!", MinigameEight_SayTextAnswer);
	}
}