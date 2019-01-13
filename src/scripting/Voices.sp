#define TOTAL_SYSFX_VOCAL_TYPES 2
#define TOTAL_SYSFX_VOCALS 16
#define SYSFX_VOCAL_CAPACITY 192

#define SYSFX_VOCAL_POSITIVE 0
#define SYSFX_VOCAL_NEGATIVE 1

char SystemVocal[TOTAL_SYSFX_VOCAL_TYPES+1][TOTAL_SYSFX_VOCALS+1][SYSFX_VOCAL_CAPACITY];

int SystemVoicesPositiveCount = 0;
int SystemVoicesNegativeCount = 0;

public void InitialiseVoices()
{
	LoadPositiveVoices();
	LoadNegativeVoices();

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Voices_OnMapStart);
}

public void LoadPositiveVoices()
{
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/Voices.Positive.txt");

	Handle file = OpenFile(path, "r"); 

	if (file == INVALID_HANDLE)
	{
		return;
	}

	char line[64];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (SystemVoicesPositiveCount >= TOTAL_SYSFX_VOCALS)
		{
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		SystemVocal[SYSFX_VOCAL_POSITIVE][SystemVoicesPositiveCount] = line;
		SystemVoicesPositiveCount++;
	}

	CloseHandle(file);

	LogMessage("System Voices: Loaded %i positive vocals", SystemVoicesPositiveCount);

	return;
}

public void LoadNegativeVoices()
{
	char path[128];
	BuildPath(Path_SM, path, sizeof(path), "data/microtf2/Voices.Negative.txt");

	Handle file = OpenFile(path, "r"); 

	if (file == INVALID_HANDLE)
	{
		return;
	}

	char line[64];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		if (SystemVoicesNegativeCount >= TOTAL_SYSFX_VOCALS)
		{
			break;
		}

		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		SystemVocal[SYSFX_VOCAL_NEGATIVE][SystemVoicesNegativeCount] = line;
		SystemVoicesNegativeCount++;
	}

	CloseHandle(file);

	LogMessage("System Voices: Loaded %i negative vocals", SystemVoicesNegativeCount);

	return;
}

public void Voices_OnMapStart()
{
	char buffer[192];

	for (int t = 0; t < TOTAL_SYSFX_VOCAL_TYPES; t++)
	{
		for (int i = 0; i < TOTAL_SYSFX_VOCALS; i++)
		{
			buffer = SystemVocal[t][i];

			if (strlen(buffer) > 0)
			{
				PreloadSound(SystemVocal[t][i]);
			}
		}
	}
}

stock void PlayNegativeVoice(int client)
{
    if (SystemVoicesNegativeCount > 0)
    {
        return;
    }

    PlaySoundToPlayer(client, SystemVocal[SYSFX_VOCAL_NEGATIVE][GetRandomInt(0, SystemVoicesNegativeCount)]);
}

stock void PlayPositiveVoice(int client)
{
    if (SystemVoicesPositiveCount > 0)
    {
        return;
    }

    PlaySoundToPlayer(client, SystemVocal[SYSFX_VOCAL_POSITIVE][GetRandomInt(0, SystemVoicesPositiveCount)]);
}