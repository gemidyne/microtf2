/**
 * MicroTF2 - Minigame 17
 * 
 * Hit a Heavy / Get Hit by a Medic
 */

TFTeam g_tMinigame17MedicTeam;

public void Minigame17_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame17_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame17_OnMinigameSelected);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Minigame17_OnPlayerTakeDamage);
}

public void Minigame17_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 17)
	{
		g_tMinigame17MedicTeam = view_as<TFTeam>(GetRandomInt(2, 3));
	}
}

public void Minigame17_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 17)
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
		if (player.Team == g_tMinigame17MedicTeam)
		{
			player.Class = TFClass_Medic;
			player.SetGodMode(true);
			player.ResetWeapon(true);
		}
		else
		{
			player.Class = TFClass_Heavy;
			player.SetGodMode(false);
			player.SetHealth(1000);
			player.ResetWeapon(false);
		}
	}
}

public void Minigame17_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		char text[64];

		if (player.Team == g_tMinigame17MedicTeam)
		{
			Format(text, sizeof(text), "%T", "Minigame17_Caption_HitAHeavy", client);
		}
		else
		{
			Format(text, sizeof(text), "%T", "Minigame17_Caption_GetHitByMedic", client);
		}

		player.SetCaption(text);
	}
}

public DamageBlockResults Minigame17_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 17)
	{
		Player victim = new Player(victimId);
		Player attacker = new Player(attackerId);

		bool attackerValid = attacker.IsValid && attacker.IsParticipating;
		bool victimValid = victim.IsValid && victim.IsParticipating;

		if (attackerValid && victimValid && attacker.Team == g_tMinigame17MedicTeam && victim.Team != g_tMinigame17MedicTeam)
		{
			attacker.TriggerSuccess();
			victim.TriggerSuccess();
		}
	}

	return EDamageBlockResult_DoNothing;
}
