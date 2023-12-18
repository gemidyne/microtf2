/**
 * MicroTF2 - Bossgame 9
 * 
 * Dodgeball
 */

public void Bossgame9_EntryPoint() 
{
    // TODO
    g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Bossgame9_OnMinigameSelectedPre);
    g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Bossgame9_OnMinigameSelected);
    g_pfOnBossStopAttempt.AddFunction(INVALID_HANDLE, Bossgame9_OnBossStopAttempt);
    g_pfOnPlayerDeath.AddFunction(INVALID_HANDLE, Bossgame9_OnPlayerDeath);
}

public void Bossgame9_OnMinigameSelectedPre()
{
    if (g_iActiveBossgameId == 9)
    {
        g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
        g_bIsBlockingKillCommands = false;
    }
}

public void Bossgame9_OnMinigameSelected(int client) 
{
    if (g_iActiveBossgameId != 9)
    {
        return;
    }

    if (!g_bIsMinigameActive)
    {
        return;
    }

    Player player = new Player(client);

    if (player.IsValid)
    {
        player.Class = TFClass_Pyro;
        player.RemoveAllWeapons();

        player.SetGodMode(false);
        player.SetHealth(1000);
        player.SetCollisionsEnabled(false);

        g_iMinigame4PlayerIndex++;

        player.GiveWeapon(21);
        player.SetWeaponPrimaryAmmoCount(200);

        SDKHook(client, SDKHook_PreThink, Bossgame9_RemoveLeftClick);
    }
}

public void Bossgame9_OnPlayerDeath(int victimId, int attackerId)
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player victim = new Player(victimId);

	if (!victim.IsValid)
	{
		return;
	}

	victim.Status = PlayerStatus_Failed;
}


public void Bossgame9_OnMinigameFinish()
{
    if (g_bIsMinigameActive && g_iActiveBossgameId == 9)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            Player player = new Player(i);

            if (player.IsValid && player.IsParticipating)
            {
                player.Status = (player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed);

                SDKUnhook(i, SDKHook_PreThink, Bossgame9_RemoveLeftClick);
                player.Respawn();
            }
        }
    }
}

public void Bossgame9_OnBossStopAttempt()
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	int alivePlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.IsAlive)
		{
			alivePlayers++;
		}
	}

	if (alivePlayers <= 1)
	{
		EndBoss();
	}
}

public void Bossgame9_RemoveLeftClick(int client)
{
    int buttons = GetClientButtons(client);

    if ((buttons & IN_ATTACK))
    {
        buttons &= ~IN_ATTACK;
        SetEntProp(client, Prop_Data, "m_nButtons", buttons);
    }
}