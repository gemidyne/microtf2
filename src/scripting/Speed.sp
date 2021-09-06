void ExecuteSpeedEvent()
{
	if (g_iSpecialRoundId == 1)
	{
		g_fActiveGameSpeed -= 0.1;
	}
	else
	{
		g_fActiveGameSpeed += 0.1;
	}

	SetSpeed();
	PluginForward_SendSpeedChange(g_fActiveGameSpeed);
}

int GetSoundMultiplier()
{
	return SNDPITCH_NORMAL + RoundToCeil(((g_fActiveGameSpeed-1.0) * 10)*8.0);
}

bool IsSpeedLimitHit()
{
	return g_fActiveGameSpeed >= 2.3 || g_fActiveGameSpeed <= 0.4;
}

bool TrySpeedChangeEvent()
{
	if (!Special_AreSpeedEventsEnabled())
	{
		return false;
	}

	if (g_iMinigamesPlayedCount < 3)
	{
		return false;
	}

	if (IsSpeedLimitHit())
	{
		return false;
	}

	if (g_iMinigamesPlayedCount < g_iBossGameThreshold && g_iMinigamesPlayedCount >= g_iNextMinigamePlayedSpeedTestThreshold)
	{
		int chanceUpperLimit = g_iActiveGamemodeId == 99 && g_iSpecialRoundId == 1
			? 1 // On Adrenaline shot, higher chance of speed down
			: 2;

		bool success = GetRandomInt(0, chanceUpperLimit) == 1; // On Adrenaline shot, higher chance of speed down

		if (success)
		{
			g_iNextMinigamePlayedSpeedTestThreshold = g_iMinigamesPlayedCount + 2;

			return true;
		}
	}

	return false;
}

void SetSpeed()
{
	if (g_fActiveGameSpeed > 2.3)
	{
		g_fActiveGameSpeed = 2.3;
	}

	if (g_fActiveGameSpeed < 0.4)
	{
		g_fActiveGameSpeed = 0.4;
	}

	g_hConVarHostTimescale.FloatValue = g_fActiveGameSpeed;
	g_hConVarPhysTimescale.FloatValue = g_fActiveGameSpeed;

	char buffer[2];

	if (FloatCompare(g_fActiveGameSpeed, 1.0) != 0)
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
			g_hConVarServerCheats.ReplicateToClient(player.ClientId, buffer);
		}
	}
}

float GetSpeedMultiplier(float count)
{
    float divide = ((g_fActiveGameSpeed-1.0)/7.5)+1.0;
    float speed = count / divide;
    return speed;
}