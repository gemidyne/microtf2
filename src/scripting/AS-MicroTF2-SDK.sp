#pragma semicolon 1
#define REQUIRE_PLUGIN

#include <sourcemod>
#include <console>
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
}

public void ProcessSystemMusic()
{
	char file[128];
	BuildPath(Path_SM, file, sizeof(file), "data/microtf2/Gamemodes.txt");

	KeyValues kv = new KeyValues("Gamemodes");

	if (!kv.ImportFromFile(file))
	{
		LogError("Unable to read gamemodes.txt from data/microtf2/");
		kv.Close();
		return;
	}
 
	if (kv.GotoFirstSubKey())
	{
		do
		{
			int gamemodeId = GetGamemodeIdFromSectionName(kv);

			PrintToServer("Processing gamemode sounds #%i", gamemodeId);
			ProcessMusicKey(kv, "SysMusic_PreMinigame");
			ProcessMusicKey(kv, "SysMusic_BossTime");
			ProcessMusicKey(kv, "SysMusic_SpeedUp");
			ProcessMusicKey(kv, "SysMusic_GameOver");
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

stock int GetGamemodeIdFromSectionName(KeyValues kv)
{
	char buffer[16];

	kv.GetSectionName(buffer, sizeof(buffer));

	return StringToInt(buffer);
}

stock void ProcessMusicKey(KeyValues kv, const char[] key)
{
	float length = GetMusicLengthFromKey(kv, key);

	char lengthKey[32];

	Format(lengthKey, sizeof(lengthKey), "%s_Length", key);

	kv.SetFloat(lengthKey, length);
}

stock float GetMusicLengthFromKey(KeyValues kv, const char[] key)
{
	Handle sndfile = INVALID_HANDLE;

	char fileName[SYSMUSIC_MAXSTRINGLENGTH];

	kv.GetString(key, fileName, SYSMUSIC_MAXSTRINGLENGTH);

	sndfile = OpenSoundFile(fileName);

	if (sndfile == INVALID_HANDLE)
	{
		PrintToServer("Failed to get sound length for \"%s\" - %s", key, fileName);
		return 0.00;
	}
	else
	{
		float result = GetSoundLengthFloat(sndfile);
		CloseHandle(sndfile);

		return result;
	}
}