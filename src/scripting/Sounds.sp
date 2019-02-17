public void InitialiseSounds()
{
    AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Sounds_OnMapStart);
}

public void Sounds_OnMapStart()
{
    AddNormalSoundHook(Hook_GameSound);
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
		|| StrContains(sample, "vo/spy_", false) != -1
		|| StrContains(sample, "stsv/soundmods/", false) != -1;

	bool isBlockedSound = StrContains(sample, "rocket_pack_boosters_fire", false) != -1
		|| StrContains(sample, "rocket_pack_boosters_loop", false) != -1
		|| StrContains(sample, "grenade_jump", false) != -1;

	if (isBlockedSound)
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