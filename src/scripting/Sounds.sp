#define SYSBGM_WAITING "gemidyne/warioware/system/bgm/waitingforplayers.wav"
#define SYSBGM_SPECIAL "gemidyne/warioware/system/bgm/specialround.mp3"
#define SYSBGM_ENDING "gemidyne/warioware/system/bgm/mapend.mp3"

#define SYSFX_CLOCK "gemidyne/warioware/system/sfx/clock.mp3"
#define SYSFX_WINNER "gemidyne/warioware/system/sfx/bing.wav"
#define SYSFX_SELECTED "gemidyne/warioware/system/sfx/beep.mp3"

bool IsBlockingVoices = false;

public void InitialiseSounds()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Sounds_OnMapStart);
}

stock void PreloadSound(const char[] sound)
{
	if (strlen(sound) == 0)
	{
		return;
	}

	PrecacheSound(sound, true);

	// This call intentionally does not add sounds to the files download table.
	// This is because the correct approach to distributing the gamemode is to pack 
	// the resources into the BSP so your players only require one download.
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

	PrecacheSound("ui/system_message_alert.wav", true);
	PrecacheSound("vo/announcer_ends_10sec.wav", true);
	PrecacheSound("vo/announcer_ends_5sec.wav", true);
	PrecacheSound("vo/announcer_ends_4sec.wav", true);
	PrecacheSound("vo/announcer_ends_3sec.wav", true);
	PrecacheSound("vo/announcer_ends_2sec.wav", true);
	PrecacheSound("vo/announcer_ends_1sec.wav", true);
	PrecacheSound("vo/announcer_success.wav", true);
}

public Action Hook_GameSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsPluginEnabled)
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

	if (isVoiceSound && IsBlockingVoices)
	{
		return Plugin_Stop;
	}

	if (SpecialRoundID == 14 || SpecialRoundID == 15)
	{
		if (isVoiceSound)
		{
			pitch = (SpecialRoundID == 14 ? SNDPITCH_HIGH : SNDPITCH_LOW);
			return Plugin_Changed;
		}
	}
	else
	{
		if (isVoiceSound)
		{
			pitch = GetSoundMultiplier();
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}
