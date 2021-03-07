/**
 * MicroTF2 - Minigame 17
 * 
 * Hit a Heavy / Get Hit by a Medic
 */

int Minigame17_Selected[MAXPLAYERS+1];
TFTeam Minigame17_ClientTeam;

public void Minigame17_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame17_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame17_OnMinigameSelected);
	AddToForward(GlobalForward_OnPlayerTakeDamage, INVALID_HANDLE, Minigame17_OnPlayerTakeDamage);
}

public void Minigame17_OnMinigameSelectedPre()
{
	if (MinigameID == 17)
	{
		Minigame17_ClientTeam = view_as<TFTeam>(GetRandomInt(2, 3));

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid)
			{
				Minigame17_Selected[i] = 0;
			}
		}
	}
}

public void Minigame17_OnMinigameSelected(int client)
{
	if (MinigameID != 17)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		if (player.Team == Minigame17_ClientTeam)	//Selected Team Has to Hit 
		{
			player.Class = TFClass_Medic;
			player.SetGodMode(true);
			player.ResetWeapon(true);
			Minigame17_Selected[client] = 1;
		}
		else
		{
			player.Class = TFClass_Heavy;
			player.SetGodMode(false);
			player.SetHealth(1000);
			player.ResetWeapon(false);
			Minigame17_Selected[client] = 0;
		}
	}
}

public void Minigame17_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		char text[64];

		if (player.Team == Minigame17_ClientTeam)
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

public void Minigame17_OnPlayerTakeDamage(int victimId, int attackerId, float damage)
{
	if (IsMinigameActive && MinigameID == 17)
	{
		Player victim = new Player(victimId);
		Player attacker = new Player(attackerId);

		if (attacker.IsValid && attacker.IsParticipating && victim.IsValid && victim.IsParticipating)
		{
			if (Minigame17_Selected[attackerId] == 1 && Minigame17_Selected[victimId] == 0)
			{
				attacker.TriggerSuccess();
				victim.TriggerSuccess();
			}
		}
	}
}
