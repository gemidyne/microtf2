#define TOTAL_SYSFX_VOCAL_TYPES 2
#define TOTAL_SYSFX_VOCALS 16
#define SYSFX_VOCAL_CAPACITY 192

#define SYSFX_VOCAL_POSITIVE 0
#define SYSFX_VOCAL_NEGATIVE 1

char g_sSystemVocal[TOTAL_SYSFX_VOCAL_TYPES+1][TOTAL_SYSFX_VOCALS+1][SYSFX_VOCAL_CAPACITY];
int g_iSystemVoicesPositiveCount = 0;
int g_iSystemVoicesNegativeCount = 0;

void InitialiseVoices()
{
	LoadPositiveVoices();
	LoadNegativeVoices();

	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Voices_OnMapStart);
}

void LoadPositiveVoices()
{
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/Voices.Positive.txt");

	File file = OpenFile(path, "r"); 

	if (file == INVALID_HANDLE)
	{
		return;
	}

	char line[64];

	while (file.ReadLine(line, sizeof(line)))
	{
		if (g_iSystemVoicesPositiveCount >= TOTAL_SYSFX_VOCALS)
		{
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		g_sSystemVocal[SYSFX_VOCAL_POSITIVE][g_iSystemVoicesPositiveCount] = line;
		g_iSystemVoicesPositiveCount++;
	}

	file.Close();

	#if defined LOGGING_STARTUP
	LogMessage("System Voices: Loaded %i positive vocals", g_iSystemVoicesPositiveCount);
	#endif

	return;
}

void LoadNegativeVoices()
{
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/Voices.Negative.txt");

	File file = OpenFile(path, "r"); 

	if (file == INVALID_HANDLE)
	{
		return;
	}

	char line[64];

	while (file.ReadLine(line, sizeof(line)))
	{
		if (g_iSystemVoicesNegativeCount >= TOTAL_SYSFX_VOCALS)
		{
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		g_sSystemVocal[SYSFX_VOCAL_NEGATIVE][g_iSystemVoicesNegativeCount] = line;
		g_iSystemVoicesNegativeCount++;
	}

	file.Close();

	#if defined LOGGING_STARTUP
	LogMessage("System Voices: Loaded %i negative vocals", g_iSystemVoicesNegativeCount);
	#endif

	return;
}

void Voices_OnMapStart()
{
	char buffer[192];

	for (int t = 0; t < TOTAL_SYSFX_VOCAL_TYPES; t++)
	{
		for (int i = 0; i < TOTAL_SYSFX_VOCALS; i++)
		{
			buffer = g_sSystemVocal[t][i];

			if (strlen(buffer) > 0)
			{
				PreloadSound(g_sSystemVocal[t][i]);
			}
		}
	}
}

void PlayNegativeVoice(int client)
{
    if (g_iSystemVoicesNegativeCount <= 0)
    {
        return;
    }

    PlaySoundToPlayer(client, g_sSystemVocal[SYSFX_VOCAL_NEGATIVE][GetRandomInt(0, g_iSystemVoicesNegativeCount)]);
}

void PlayPositiveVoice(int client)
{
    if (g_iSystemVoicesPositiveCount <= 0)
    {
        return;
    }

    PlaySoundToPlayer(client, g_sSystemVocal[SYSFX_VOCAL_POSITIVE][GetRandomInt(0, g_iSystemVoicesPositiveCount)]);
}