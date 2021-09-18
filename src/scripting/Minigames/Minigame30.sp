/**
 * MicroTF2 - Minigame 30
 * 
 * Heal the Medics / Eat a Sandvich
 */

TFTeam g_tMinigame30MedicTeam;

public void Minigame30_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame30_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame30_OnMinigameSelected);
	AddToForward(g_pfOnPlayerHealed, INVALID_HANDLE, Minigame30_OnPlayerHealed);
}

public void Minigame30_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 30)
	{
		g_tMinigame30MedicTeam = view_as<TFTeam>(GetRandomInt(2, 3));
	}
}

public void Minigame30_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 30)
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
		if (player.Team == g_tMinigame30MedicTeam)
		{
			player.Class = TFClass_Medic;
			player.SetGodMode(true);
			player.ResetWeapon(true);
			player.Health = 1;
		}
		else
		{
			player.Class = TFClass_Heavy;
			player.SetGodMode(true);
			player.ResetHealth();
			player.ResetWeapon(true);
			player.GiveWeapon(42);
			player.ChargeMeter = 100.0;
		}
	}
}

public void Minigame30_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		char text[64];

		if (player.Team == g_tMinigame30MedicTeam)
		{
			Format(text, sizeof(text), "%T", "Minigame30_Caption_EatASandvich", client);
		}
		else
		{
			Format(text, sizeof(text), "%T", "Minigame30_Caption_HealAMedic", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame30_OnPlayerHealed(int targetId, int ownerId)
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 30)
	{
		Player target = new Player(targetId);
		Player owner = new Player(ownerId);

		bool targetValid = target.IsValid && target.IsParticipating;
		bool ownerValid = owner.IsValid && owner.IsParticipating;

		if (targetValid && ownerValid && target.Team == g_tMinigame17MedicTeam && owner.Team != g_tMinigame17MedicTeam)
		{
			target.TriggerSuccess();
			owner.TriggerSuccess();
		}
	}
}
