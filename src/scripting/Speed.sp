void ExecuteSpeedEvent()
{
	if (SpecialRoundID == 1)
	{
		SpeedLevel -= 0.1;
	}
	else
	{
		SpeedLevel += 0.1;
	}

	SetSpeed();
	PluginForward_SendSpeedChange(SpeedLevel);
}

int GetSoundMultiplier()
{
	return SNDPITCH_NORMAL + RoundToCeil(((SpeedLevel-1.0) * 10)*8.0);
}

bool IsSpeedLimitHit()
{
	return SpeedLevel >= 2.3 || SpeedLevel <= 0.4;
}

bool TrySpeedChangeEvent()
{
	if (!Special_AreSpeedEventsEnabled())
	{
		return false;
	}

	if (MinigamesPlayed < 3)
	{
		return false;
	}

	if (IsSpeedLimitHit())
	{
		return false;
	}

	if (MinigamesPlayed < BossGameThreshold && MinigamesPlayed >= NextMinigamePlayedSpeedTestThreshold)
	{
		bool success = GamemodeID == 99 && SpecialRoundID == 1
			? GetRandomInt(0, 1) == 1 // On Adrenaline shot, higher chance of speed down
			: GetRandomInt(0, 2) == 1;

		if (success)
		{
			NextMinigamePlayedSpeedTestThreshold = MinigamesPlayed + 2;

			return true;
		}
	}

	return false;
}

void SetSpeed()
{
	if (SpeedLevel > 2.3)
	{
		SpeedLevel = 2.3;
	}

	if (SpeedLevel < 0.4)
	{
		SpeedLevel = 0.4;
	}

	SetConVarFloat(ConVar_HostTimescale, SpeedLevel);
	SetConVarFloat(ConVar_PhysTimescale, SpeedLevel);

	char buffer[2];

	if (FloatCompare(SpeedLevel, 1.0) != 0)
	{
		strcopy(buffer, sizeof(buffer), "1");
	}
	else
	{
		strcopy(buffer, sizeof(buffer), "0");
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsInGame && !player.IsBot)
		{
			SendConVarValue(player.ClientId, ConVar_SvCheats, buffer);
		}
	}
}

float GetSpeedMultiplier(float count)
{
    float divide = ((SpeedLevel-1.0)/7.5)+1.0;
    float speed = count / divide;
    return speed;
}