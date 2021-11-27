public void AttachPlayerHooks(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Hooks_OnTakeDamage);
	SDKHook(client, SDKHook_Touch, Hooks_OnTouch);
}

public void DetachPlayerHooks(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, Hooks_OnTakeDamage);
	SDKUnhook(client, SDKHook_Touch, Hooks_OnTouch);
}

public Action Hooks_OnTakeDamage(int victim, int &attackerId, int &inflictor, float &damage, int &damagetype, int &weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if (!g_bIsPluginEnabled)
	{
		return Plugin_Continue;
	}

	DamageBlockResults forwardResult;

	if (g_pfOnPlayerTakeDamage != INVALID_HANDLE)
	{
		Call_StartForward(g_pfOnPlayerTakeDamage);
		Call_PushCell(victim);
		Call_PushCell(attackerId);
		Call_PushFloat(damage);
		Call_PushCell(damagecustom);
		Call_Finish(forwardResult);
	}

	bool doBlock = false;

	switch (g_eDamageBlockMode)
	{
		case EDamageBlockMode_Nothing:
		{
			doBlock = false;
		}

		case EDamageBlockMode_OtherPlayersOnly:
		{
			Player player = new Player(attackerId);

			doBlock = attackerId != victim && player.IsValid && player.IsParticipating;
		}

		case EDamageBlockMode_AllPlayers:
		{
			Player player = new Player(inflictor);

			doBlock = player.IsValid && player.IsParticipating;
		}

		case EDamageBlockMode_WinnersOnly:
		{
			Player player = new Player(victim);

			doBlock = g_bIsGameOver && player.IsWinner;
		}

		case EDamageBlockMode_All:
		{
			doBlock = true;
		}
	}

	// This check is here so we can inherit default global rules, and then allow them to be
	// overridden by a forward function (i.e. minigame or bossgame)
	// The default for the g_pfOnPlayerTakeDamage is DoNothing in which can we assume the global rule
	if (forwardResult == EDamageBlockResult_AllowDamage)
	{
		doBlock = false;
	}
	else if (forwardResult == EDamageBlockResult_BlockDamage)
	{
		doBlock = true;
	}

	if (doBlock)
	{
		damage = 0.0;

		if (inflictor < 0) 
		{
			inflictor = 0;
		}
		
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action Hooks_OnTouch(int entity, int other)
{
	char entityClassName[64];
	char otherClassName[64];

	GetEdictClassname(entity, entityClassName, sizeof(entityClassName));
	GetEdictClassname(other, otherClassName, sizeof(otherClassName));

	if (g_pfOnPlayerCollisionWithPlayer != INVALID_HANDLE && StrEqual(entityClassName, "player") && StrEqual(otherClassName, "player")) 
	{
		Player player1 = new Player(entity);
		Player player2 = new Player(other);

		if (player1.IsValid && player2.IsValid && player1.IsAlive && player2.IsAlive && player1.Team != player2.Team)
		{
			Call_StartForward(g_pfOnPlayerCollisionWithPlayer);
			Call_PushCell(entity);
			Call_PushCell(other);
			Call_Finish();
		}
	}

	return Plugin_Continue;
}