/**
 * MicroTF2 - Minigame 2
 * 
 * Kill an Enemy
 */

TFClassType g_cMinigame2ClassType;

public void Minigame2_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame2_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame2_OnMinigameSelected);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Minigame2_OnPlayerDeath);
}

public void Minigame2_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 2)
	{
		g_hConVarFriendlyFire.BoolValue = true;

		g_cMinigame2ClassType = view_as<TFClassType>(GetRandomInt(1, 9));
		g_eDamageBlockMode = EDamageBlockMode_Nothing;
		g_bIsBlockingKillCommands = true;
	}
}

public void Minigame2_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 2)
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
		int weapon = 0;
		int ammo = -1;

		switch (g_cMinigame2ClassType)
		{
			case TFClass_Scout:
			{
				weapon = 13;
				ammo = 32;
			}

			case TFClass_Soldier:
			{
				weapon = 10;
				ammo = 32;
			}

			case TFClass_Pyro: 
			{
				weapon = 12;
				ammo = 32;
			}

			case TFClass_DemoMan:
			{
				weapon = 1;
			}

			case TFClass_Heavy:
			{
				weapon = 11;
				ammo = 32;
			}

			case TFClass_Engineer:
			{
				weapon = 9;
				ammo = 32;
			}

			case TFClass_Sniper:
			{
				weapon = 16;
				ammo = 75;
			}

			case TFClass_Medic:
			{
				weapon = 8;
			}

			case TFClass_Spy:
			{
				weapon = 24;
				ammo = 24;
			}
		}

		player.RemoveAllWeapons();

		player.Class = g_cMinigame2ClassType;
		player.SetHealth(1);
		player.SetGodMode(false);
		player.GiveWeapon(weapon);

		if (ammo > -1)
		{
			player.SetWeaponPrimaryAmmoCount(ammo);
		}
	}
}

public void Minigame2_OnPlayerDeath(int victimId, int attackerId)
{
	if (g_iActiveMinigameId != 2)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player victim = new Player(victimId);
	Player attacker = new Player(attackerId);

	if (victim.IsValid && victim.IsParticipating && attacker.IsValid && attacker.IsParticipating)
	{
		if (victim.Status == PlayerStatus_NotWon)
		{
			victim.Status = PlayerStatus_Failed;
		}

		attacker.TriggerSuccess();
	}
}