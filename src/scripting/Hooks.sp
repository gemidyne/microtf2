//#define USE_MAXSPEED_HOOK

public void AttachPlayerHooks(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Hooks_OnTakeDamage);
	SDKHook(client, SDKHook_Touch, Hooks_OnTouch);

	#if defined USE_MAXSPEED_HOOK
	SDKHook(client, SDKHook_PreThink, Hooks_OnPreThink);
	#endif
}

public void DetachPlayerHooks(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, Hooks_OnTakeDamage);
	SDKUnhook(client, SDKHook_Touch, Hooks_OnTouch);

	#if defined USE_MAXSPEED_HOOK
	SDKUnhook(client, SDKHook_PreThink, Hooks_OnPreThink);
	#endif
}

public Action Hooks_OnTakeDamage(int victim, int &attackerId, int &inflictor, float &damage, int &damagetype)
{
	if (!IsPluginEnabled)
	{
		return Plugin_Continue;
	}

	if (GlobalForward_OnPlayerTakeDamage != INVALID_HANDLE)
	{
		Call_StartForward(GlobalForward_OnPlayerTakeDamage);
		Call_PushCell(victim);
		Call_PushCell(attackerId);
		Call_PushFloat(damage);
		Call_Finish();
	}

	bool doBlock = false;

	switch (DamageBlockMode)
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

			doBlock = IsBonusRound && player.IsWinner;
		}

		case EDamageBlockMode_All:
		{
			doBlock = true;
		}
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

	if (GlobalForward_OnPlayerCollisionWithPlayer != INVALID_HANDLE && StrEqual(entityClassName, "player") && StrEqual(otherClassName, "player")) 
	{
		Player player1 = new Player(entity);
		Player player2 = new Player(other);

		if (player1.IsValid && player2.IsValid && player1.IsAlive && player2.IsAlive && player1.Team != player2.Team)
		{
			Call_StartForward(GlobalForward_OnPlayerCollisionWithPlayer);
			Call_PushCell(entity);
			Call_PushCell(other);
			Call_Finish();
		}
	}
}


#if defined USE_MAXSPEED_HOOK
public void Hooks_OnPreThink(int client)
{
    if (!IsPluginEnabled)
    {
        return;
    }
    
    Player player = new Player(client);

    if (ApplyMaxSpeedOverrides)
    {
        player.MaxSpeed = MaxSpeedOverride[player.ClientId];
    }
    // else if (MaxSpeedDefaults[player.ClientId] == 0)
    // {
    //     MaxSpeedDefaults
    // }
}
#endif