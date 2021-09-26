/**
 * MicroTF2 - Minigame 26
 *
 * No laughing! / Make them laugh
 */

bool g_bMinigame26IsPlayerSelected[MAXPLAYERS+1];
TFClassType g_cMinigame26VictimPlayerClass;

public void Minigame26_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame26_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame26_OnMinigameSelected);
	AddToForward(g_pfOnPlayerConditionAdded, INVALID_HANDLE, Minigame26_OnPlayerConditionAdded);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Minigame26_OnPlayerTakeDamage);
}

public void Minigame26_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 26)
	{
		int count = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				g_bMinigame26IsPlayerSelected[player.ClientId] = false;
				count++;
			}
		}

		if (count > 1)
		{
			count = RoundToCeil(count * 0.25);
		}

		while (count > 0)
		{
			int i = GetRandomInt(1, MaxClients);

			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				g_bMinigame26IsPlayerSelected[player.ClientId] = true;
				count--;
			}
		}

		do
		{
			g_cMinigame26VictimPlayerClass = view_as<TFClassType>(GetRandomInt(1, 9));
		}
		while (g_cMinigame26VictimPlayerClass == TFClass_Heavy);

		g_eDamageBlockMode = EDamageBlockMode_All;
	}
}

public void Minigame26_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		char text[64];

		if (g_bMinigame26IsPlayerSelected[player.ClientId])
		{
			char key[64];

			switch (g_cMinigame26VictimPlayerClass)
			{
				case TFClass_Scout:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Scout");
				}

				case TFClass_Soldier:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Soldier");
				}

				case TFClass_Pyro: 
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Pyro");
				}

				case TFClass_DemoMan:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Demoman");
				}

				case TFClass_Engineer:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Engineer");
				}

				case TFClass_Medic:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Medic");
				}

				case TFClass_Sniper:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Sniper");
				}

				case TFClass_Spy:
				{
					Format(key, sizeof(key), "Minigame26_Caption_MakeThemLaugh_Spy");
				}
			}

			Format(text, sizeof(text), "%T", key, client);
		}
		else
		{
			
			Format(text, sizeof(text), "%T", "Minigame26_Caption_DontLaugh", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame26_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 26)
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
		if (g_bMinigame26IsPlayerSelected[player.ClientId])
		{
			Minigame26_SetupAttacker(player);
		}
		else
		{
			Minigame26_SetupTarget(player);
		}
	}
}

public void Minigame26_OnPlayerConditionAdded(int client, int conditionId)
{
	if (g_iActiveMinigameId != 26)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	if (!player.IsParticipating)
	{
		return;
	}

	TFCond condition = view_as<TFCond>(conditionId);

	if (condition == TFCond_Taunting)
	{
		player.Status = PlayerStatus_Failed;
	}
}

public DamageBlockResults Minigame26_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_iActiveMinigameId != 26)
	{
		return EDamageBlockResult_DoNothing;
	}

	if (!g_bIsMinigameActive)
	{
		return EDamageBlockResult_DoNothing;
	}

	Player victim = new Player(victimId);
	Player attacker = new Player(attackerId);

	if (!attacker.IsValid || !victim.IsValid)
	{
		return EDamageBlockResult_DoNothing;
	}

	if (!attacker.IsParticipating || !victim.IsParticipating)
	{
		return EDamageBlockResult_DoNothing;
	}

	if (g_bMinigame26IsPlayerSelected[attacker.ClientId] && !g_bMinigame26IsPlayerSelected[victim.ClientId])
	{
		attacker.Status = PlayerStatus_Winner;
		victim.Status = PlayerStatus_Failed;
	}

	return EDamageBlockResult_DoNothing;
}

void Minigame26_SetupAttacker(Player player)
{
	player.Class = TFClass_Heavy;
	player.RemoveAllWeapons();
	player.SetGodMode(false);
	player.SetHealth(3000);
	player.GiveWeapon(656);
	player.Status = PlayerStatus_NotWon;

	player.AddCondition(TFCond_CritCola, 4.0);
	player.AddCondition(TFCond_HalloweenCritCandy, 4.0);
	player.AddCondition(TFCond_RuneHaste, 4.0);
}

void Minigame26_SetupTarget(Player player)
{
	player.Class = g_cMinigame26VictimPlayerClass;
	player.ResetHealth();
	player.RemoveAllWeapons();
	player.SetGodMode(false);
	player.ResetWeapon(false);
	player.Status = PlayerStatus_Winner;
}