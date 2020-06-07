public void AttachPlayerHooks(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, Hooks_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, Hooks_OnPreThink);
}

public void DetachPlayerHooks(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, Hooks_OnTakeDamage);
	SDKUnhook(client, SDKHook_PreThink, Hooks_OnPreThink);
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

	Player attacker = new Player(inflictor);

	if (IsBlockingDamage || (IsBonusRound && !IsPlayerWinner[attackerId]) || !IsBlockingDamage && IsOnlyBlockingDamageByPlayers && attacker.IsValid && attacker.IsParticipating)
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