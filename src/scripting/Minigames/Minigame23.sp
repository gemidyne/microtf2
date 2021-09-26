/**
 * MicroTF2 - Minigame 23
 *
 * Taunt Kill!
 */

public void Minigame23_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Minigame23_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Minigame23_OnMinigameSelected);
	g_pfOnPlayerDeath.AddFunction(INVALID_HANDLE, Minigame23_OnPlayerDeath);
	g_pfOnPlayerTakeDamage.AddFunction(INVALID_HANDLE, Minigame23_OnPlayerTakeDamage);
}

public void Minigame23_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId != 23)
	{
		return;
	}

	g_bIsBlockingTaunts = false;
	g_bIsBlockingKillCommands = false;
}

public void Minigame23_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 23)
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
		player.Class = TFClass_Soldier;
		player.RemoveAllWeapons();
		player.GiveWeapon(775);
		player.SetGodMode(false);
	}
}

public void Minigame23_OnPlayerDeath(int victimId, int attackerId)
{
	if (g_iActiveMinigameId != 23)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player victim = new Player(victimId);
	Player attacker = new Player(attackerId);

	if (victim.IsValid && attacker.IsValid && victim.IsParticipating && attacker.IsParticipating)
	{
		victim.Status = PlayerStatus_Failed;
		attacker.Status = PlayerStatus_Winner;
	}
}

public DamageBlockResults Minigame23_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 23)
	{
		Player victim = new Player(victimId);
		Player attacker = new Player(attackerId);

		bool victimValid = victim.IsValid && victim.IsParticipating;
		bool attackerValid = attacker.IsValid && attacker.IsParticipating;

		if (attackerValid && victimValid && victim.ClientId != attacker.ClientId && damageCustom == TF_CUSTOM_TAUNT_GRENADE)
		{
			attacker.TriggerSuccess();

			return EDamageBlockResult_AllowDamage;
		}
	}

	return EDamageBlockResult_DoNothing;
}