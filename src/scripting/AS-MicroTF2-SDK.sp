#pragma semicolon 1
#define REQUIRE_PLUGIN

#include <sourcemod>
#include <sdktools>
#include <soundlib>

#pragma newdecls required
#define SYSMUSIC_MAXSTRINGLENGTH 192

public Plugin myinfo = 
{
	name = "WarioWare REDUX: SDK",
	author = "Gemidyne Softworks / Team WarioWare",
	description = "Software Development Kit",
	version = "1.0",
	url = "https://www.gemidyne.com/"
}

public void OnPluginStart()
{
	if (GetExtensionFileStatus("soundlib.ext") < 1)
	{
		SetFailState("The SoundLib Extension is not loaded.");
	}

	RegConsoleCmd("mtf2_sdk_process_sounds", Cmd_ProcessSounds, "Processes all sounds used by the gamemode", 0);
}

public Action Cmd_ProcessSounds(int client, int args)
{
	PrintToServer("Processing system music");
	ProcessSystemMusic();

	PrintToServer("Processing minigame music");
	ProcessMinigameMusic();

	return Plugin_Handled;
}

public void ProcessSystemMusic()
{
	char file[128];
	BuildPath(Path_SM, file, sizeof(file), "data/microtf2/Gamemodes.txt");

	KeyValues kv = new KeyValues("Gamemodes");

	if (!kv.ImportFromFile(file))
	{
		LogError("Unable to read Gamemodes.txt from data/microtf2/");
		kv.Close();
		return;
	}
 
	if (kv.GotoFirstSubKey())
	{
		do
		{
			int gamemodeId = GetIdFromSectionName(kv);

			PrintToServer("Processing gamemode sounds #%i", gamemodeId);
			ProcessMusicKeySingular(kv, "SysMusic_Failure");
			ProcessMusicKeySingular(kv, "SysMusic_Winner");

			ProcessSysMusicSection(kv);
		}
		while (kv.GotoNextKey());
	}

	kv.Rewind();

	if (!kv.ExportToFile(file))
	{
		LogError("Unable to write gamemodes.txt in data/microtf2/ directory");
	}
 
	kv.Close();
	PrintToServer("System Music processing complete");
}

public void ProcessMinigameMusic()
{
	char file[128];
	BuildPath(Path_SM, file, sizeof(file), "data/microtf2/Minigames.txt");

	KeyValues kv = new KeyValues("Minigames");

	if (!kv.ImportFromFile(file))
	{
		SetFailState("Unable to read Minigames.txt from data/microtf2/");
		kv.Close();
		return;
	}

	if (kv.GotoFirstSubKey())
	{
		do
		{
			ProcessMusicKeySingular(kv, "BackgroundMusic");
		}
		while (kv.GotoNextKey());
	}

	kv.Rewind();

	if (!kv.ExportToFile(file))
	{
		LogError("Unable to write Minigames.txt in data/microtf2/ directory");
	}
 
	kv.Close();
	PrintToServer("Minigame Music processing complete");
}

stock int GetIdFromSectionName(KeyValues kv)
{
	char buffer[16];

	kv.GetSectionName(buffer, sizeof(buffer));

	return StringToInt(buffer);
}

stock void ProcessSysMusicSection(KeyValues kv)
{
	if (!kv.GotoFirstSubKey())
	{
		return;
	}

	do
	{
		char section[32];
		kv.GetSectionName(section, sizeof(section));

		if (kv.GotoFirstSubKey())
		{
			bool isSubsection = StrEqual(section, "SysMusic_PreMinigame", false)
				|| StrEqual(section, "SysMusic_BossTime", false)
				|| StrEqual(section, "SysMusic_SpeedUp", false)
				|| StrEqual(section, "SysMusic_GameOver", false);

			if (isSubsection)
			{
				do
				{
					ProcessMusicKeySectionItem(kv, "File");
				}
				while (kv.GotoNextKey());
			}

			kv.GoBack();
		}
	}
	while (kv.GotoNextKey());

	kv.GoBack();
}

stock void ProcessMusicKeySingular(KeyValues kv, const char[] key)
{
	float length = GetMusicLengthFromKey(kv, key);

	char lengthKey[32];

	Format(lengthKey, sizeof(lengthKey), "%s_Length", key);

	kv.SetFloat(lengthKey, length);
}

stock void ProcessMusicKeySectionItem(KeyValues kv, const char[] key)
{
	float length = GetMusicLengthFromKey(kv, key);

	kv.SetFloat("Length", length);
}

stock float GetMusicLengthFromKey(KeyValues kv, const char[] key)
{
	Handle sndfile = INVALID_HANDLE;

	char fileName[SYSMUSIC_MAXSTRINGLENGTH];

	kv.GetString(key, fileName, SYSMUSIC_MAXSTRINGLENGTH);

	sndfile = OpenSoundFile(fileName);

	if (sndfile == INVALID_HANDLE)
	{
		PrintToServer("Failed to get sound length for %s.", key, fileName);
		return 0.00;
	}
	else
	{
		float result = GetSoundLengthFloat(sndfile);
		CloseHandle(sndfile);

		return result;
	}
}