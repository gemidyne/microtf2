/**
 * MicroTF2 - Minigame 6
 * 
 * Say the Word!
 */

new String:MinigameSix_SayTextAnswer[64];
new bool:MinigameSix_HasBeenAnswered = false;

public Minigame6_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameSix_OnMinigameSelectedPre);

	RegConsoleCmd("say", Command_MinigameSixSay);
	RegConsoleCmd("say_team", Command_MinigameSixSay);
}

public bool:Minigame6_OnCheck()
{
	return true;
}

public MinigameSix_OnMinigameSelectedPre()
{
	if (MinigameID == 6)
	{
		switch (GetRandomInt(0, 23))
		{
			case 0: MinigameSix_SayTextAnswer = "Heavy";
			case 1: MinigameSix_SayTextAnswer = "Scout";
			case 2: MinigameSix_SayTextAnswer = "Jarate";
			case 3: MinigameSix_SayTextAnswer = "Wrench";
			case 4: MinigameSix_SayTextAnswer = "Spy";
			case 5: MinigameSix_SayTextAnswer = "Soldier";
			case 6: MinigameSix_SayTextAnswer = "Medic";
			case 7: MinigameSix_SayTextAnswer = "Sniper";
			case 8: MinigameSix_SayTextAnswer = "Sasha";
			case 9: MinigameSix_SayTextAnswer = "Engy";
			case 10: MinigameSix_SayTextAnswer = "Saxton";
			case 11: MinigameSix_SayTextAnswer = "Sandman";
			case 12: MinigameSix_SayTextAnswer = "Pyro";
			case 13: MinigameSix_SayTextAnswer = "Demoman";
			case 14: MinigameSix_SayTextAnswer = "Bat";
			case 15: MinigameSix_SayTextAnswer = "Bear";
			case 16: MinigameSix_SayTextAnswer = "Fists";
			case 17: MinigameSix_SayTextAnswer = "White";
			case 18: MinigameSix_SayTextAnswer = "Wario";
			case 19: MinigameSix_SayTextAnswer = "Valve";
			case 20: MinigameSix_SayTextAnswer = "Black";
			case 21: MinigameSix_SayTextAnswer = "Yellow";
			case 22: MinigameSix_SayTextAnswer = "Green";
			case 23: MinigameSix_SayTextAnswer = "Blue";
		}
		MinigameSix_HasBeenAnswered = false;
	}
}

public Minigame6_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		decl String:text[64];

		Format(text, sizeof(text), "%s\n%s", MinigameCaption[client], MinigameSix_SayTextAnswer);

		MinigameCaption[client] = text;
	}
}

public Action:Command_MinigameSixSay(client, args)
{
	if (IsMinigameActive && MinigameID == 6)
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
	
			if (strcmp(message, MinigameSix_SayTextAnswer, false) == 0)
			{
				ClientWonMinigame(client);

				if (!MinigameSix_HasBeenAnswered)
				{
					CPrintToChatAllEx(client, "{teamcolor}%N {green}answered first! (Bonus Point!)", client);

					PlayerScore[client]++;
					MinigameSix_HasBeenAnswered = true;
				}

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}