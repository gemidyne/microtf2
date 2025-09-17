/**
 * MicroTF2 - Minigame 6
 * 
 * Say the Word!
 */

#define MINIGAME6_SAYTEXTANSWERS_CAPACITY 128

char g_sMinigame6SayTextAnswers[MINIGAME6_SAYTEXTANSWERS_CAPACITY][64];
int g_iMinigame6SayTextAnswerCount; 

char g_sMinigame6SayTextAnswer[64];
bool g_bMinigame6HasAnyPlayerWon = false;

public void Minigame6_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Minigame6_OnMinigameSelectedPre);
	g_pfOnPlayerChatMessage.AddFunction(INVALID_HANDLE, Minigame6_OnChatMessage);

	Minigame6_LoadAnswers();
}

public void Minigame6_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 6)
	{
		Format(g_sMinigame6SayTextAnswer, sizeof(g_sMinigame6SayTextAnswer), g_sMinigame6SayTextAnswers[GetRandomInt(0, g_iMinigame6SayTextAnswerCount - 1)]);
		g_bMinigame6HasAnyPlayerWon = false;
	}
}

public void Minigame6_GetDynamicCaption(int client)
{
	Player player = new Player(client);
	
	if (player.IsInGame)
	{
		char text[64];
		Format(text, sizeof(text), "%T", "Minigame6_SayTheWord_CaptionFormatted", client, g_sMinigame6SayTextAnswer);
		player.SetCaption(text);
	}
}

public Action Minigame6_OnChatMessage(int client, const char[] messageText, bool isTeamMessage)
{
	if (!g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}

	if (g_iActiveMinigameId != 6)
	{
		return Plugin_Continue;
	}

	Player invoker = new Player(client);

	if (!invoker.IsParticipating)
	{
		return Plugin_Continue;
	}

	if (strcmp(messageText, g_sMinigame6SayTextAnswer, false) == 0)
	{
		invoker.TriggerSuccess();

		if (!g_bMinigame6HasAnyPlayerWon && Config_BonusPointsEnabled())
		{
			invoker.Score++;
			g_bMinigame6HasAnyPlayerWon = true;

			Minigame6_NotifyFirstPlayerComplete(invoker);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public bool Minigame6_LoadAnswers()
{
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/Minigame6.Answers.txt");

	File file = OpenFile(manifestPath, "r"); 

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open Minigame6.Answers.txt in data/microtf2. This minigame has been disabled.");
		return false;
	}

	char line[64];

	while (file.ReadLine(line, sizeof(line)))
	{
		if (g_iMinigame6SayTextAnswerCount >= MINIGAME6_SAYTEXTANSWERS_CAPACITY)
		{
			LogError("Hit the hardcoded limit of answers for Minigame6. If you really want to add more, recompile the plugin with the limit changed.");
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		g_sMinigame6SayTextAnswers[g_iMinigame6SayTextAnswerCount] = line;
		g_iMinigame6SayTextAnswerCount++;
	}

	file.Close();

	LogMessage("Minigame6: Loaded %i answers", g_iMinigame6SayTextAnswerCount);

	return true;
}

void Minigame6_NotifyFirstPlayerComplete(Player invoker)
{
	char name[64];
	
	if (invoker.Team == TFTeam_Red)
	{
		Format(name, sizeof(name), "{red}%N{default}", invoker.ClientId);
	}
	else if (invoker.Team == TFTeam_Blue)
	{
		Format(name, sizeof(name), "{blue}%N{default}", invoker.ClientId);
	}
	else
	{
		Format(name, sizeof(name), "{white}%N{default}", invoker.ClientId);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			player.PrintChatText("%T", "Minigame6_SayTheWord_PlayerSaidWordFirst", i, name);
		}
	}
}