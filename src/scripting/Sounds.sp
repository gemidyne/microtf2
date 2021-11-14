/**
 * MicroTF2 - Sounds.sp
 * 
 * All custom sounds should be defined here
 */

#define SYSBGM_WAITING "gemidyne/warioware/{version}/system/bgm/waitingforplayers.wav"
#define SYSBGM_SPECIAL "gemidyne/warioware/{version}/system/bgm/specialround.mp3"
#define SYSBGM_ENDING "gemidyne/warioware/{version}/system/bgm/mapend.mp3"

#define SYSFX_CLOCK "gemidyne/warioware/{version}/system/sfx/clock.mp3"
#define SYSFX_WINNER "gemidyne/warioware/{version}/system/sfx/bing.wav"
#define SYSFX_SELECTED "gemidyne/warioware/{version}/system/sfx/beep.mp3"

// Bossgame Sound Effects
#define BOSSGAME_SFX_BBCOUNT "gemidyne/warioware/{version}/bosses/sfx/beatblock_count.mp3"

bool g_bIsBlockingPlayerClassVoices = false;

public void InitialiseSounds()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Sounds_OnMapStart);
}

stock void PreloadSound(const char[] path)
{
	if (strlen(path) == 0)
	{
		return;
	}

	char rewritten[MAX_PATH_LENGTH];
	Sounds_ConvertTokens(path, rewritten, sizeof(rewritten));

	PrecacheSound(rewritten, true);

	// This call intentionally does not add sounds to the files download table.
	// This is because the correct approach to distributing the gamemode is to pack 
	// the resources into the BSP so your players only require one download.
}

stock void StopSoundEx(int client, const char[] path)
{
	if (strlen(path) == 0)
	{
		return;
	}

	char rewritten[MAX_PATH_LENGTH];
	Sounds_ConvertTokens(path, rewritten, sizeof(rewritten));

	StopSound(client, SNDCHAN_AUTO, rewritten);
}

public void Sounds_OnMapStart()
{
	AddNormalSoundHook(Hook_GameSound);
	
	PreloadSound(SYSBGM_WAITING);
	PreloadSound(SYSBGM_SPECIAL);
	PreloadSound(SYSBGM_ENDING);
	PreloadSound(SYSFX_SELECTED);
	PreloadSound(SYSFX_CLOCK);
	PreloadSound(SYSFX_WINNER);

	PreloadSound("ui/system_message_alert.wav");
	PreloadSound("vo/announcer_ends_10sec.wav");
	PreloadSound("vo/announcer_ends_5sec.wav");
	PreloadSound("vo/announcer_ends_4sec.wav");
	PreloadSound("vo/announcer_ends_3sec.wav");
	PreloadSound("vo/announcer_ends_2sec.wav");
	PreloadSound("vo/announcer_ends_1sec.wav");
	PreloadSound("vo/announcer_success.wav");
}

public Action Hook_GameSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	bool isVoiceSound = StrContains(sample, "vo/scout_", false) != -1 
		|| StrContains(sample, "vo/soldier_", false) != -1 
		|| StrContains(sample, "vo/pyro_", false) != -1 
		|| StrContains(sample, "vo/demoman_", false) != -1 
		|| StrContains(sample, "vo/heavy_", false) != -1 
		|| StrContains(sample, "vo/engineer_", false) != -1 
		|| StrContains(sample, "vo/medic_", false) != -1 
		|| StrContains(sample, "vo/sniper_", false) != -1 
		|| StrContains(sample, "vo/spy_", false) != -1;

	bool isBlockedSound = StrContains(sample, "rocket_pack_", false) != -1
		|| StrContains(sample, "grenade_jump", false) != -1;

	if (isBlockedSound)
	{
		return Plugin_Stop;
	}

	if (isVoiceSound && g_bIsBlockingPlayerClassVoices)
	{
		return Plugin_Stop;
	}

	if ((g_iSpecialRoundId == 14 || g_iSpecialRoundId == 15) && isVoiceSound)
	{
		pitch = (g_iSpecialRoundId == 14 ? SNDPITCH_HIGH : SNDPITCH_LOW);
		return Plugin_Changed;
	}
	else if (isVoiceSound)
	{
		pitch = GetSoundMultiplier();
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

void Sounds_ConvertTokens(const char[] path, char[] output, int size)
{
	char rewritten[MAX_PATH_LENGTH];

	strcopy(rewritten, sizeof(rewritten), path);
	ReplaceString(rewritten, sizeof(rewritten), "{version}", ASSET_VERSION);

	strcopy(output, size, rewritten);
}