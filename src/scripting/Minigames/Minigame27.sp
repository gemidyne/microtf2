/**
 * MicroTF2 - Minigame 27
 *
 * Hit someone! 
 */

bool g_bMinigame27UseBleedingMode = false;

public void Minigame27_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame27_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame27_OnMinigameSelected);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Minigame27_OnPlayerTakeDamage);
}

public void Minigame27_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 27)
	{
		g_eDamageBlockMode = EDamageBlockMode_Nothing;
		g_bMinigame27UseBleedingMode = GetRandomInt(0, 1) == 1;
	}
}

public void Minigame27_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 27)
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
		player.Class = TFClass_Scout;
		player.RemoveAllWeapons();
		player.SetGodMode(false);
		
		if (g_bMinigame27UseBleedingMode)
		{
			player.SetHealth(25);
			player.GiveWeapon(812);
			player.SetWeaponPrimaryAmmoCount(g_iActiveParticipantCount > 10 ? 1 : 2);
		}
		else
		{
			player.SetHealth(40);
			player.GiveWeapon(325);
		}
	}
}

public DamageBlockResults Minigame27_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 27)
	{
		Player victim = new Player(victimId);
		Player attacker = new Player(attackerId);

		if (attacker.IsValid && attacker.IsParticipating && victim.IsValid && victim.IsParticipating && victim.ClientId != attacker.ClientId)
		{
			attacker.TriggerSuccess();
		}
	}

	return EDamageBlockResult_DoNothing;
}