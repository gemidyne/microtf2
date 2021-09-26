/**
 * MicroTF2 - Minigame 30
 * 
 * Heal the Medics / Eat a Sandvich
 */

TFTeam g_tMinigame30MedicTeam;

public void Minigame30_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Minigame30_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Minigame30_OnMinigameSelected);
	g_pfOnEntityCreated.AddFunction(INVALID_HANDLE, Minigame30_OnEntityCreated);
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
			player.ChargeLevel = 1.0;
			player.SetWeaponPrimaryAmmoCount(1);
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

public void Minigame30_OnEntityCreated(int entity, const char[] classname)
{
	if (g_iActiveMinigameId != 30)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	if (strncmp("item_healthkit_", classname, strlen("item_healthkit_"), false) == 0)
	{
		SDKHook(entity, SDKHook_StartTouch, Minigame30_OnLunchboxTouch);
	}
}

public Action Minigame30_OnLunchboxTouch(int entity, int other)
{
	if (g_iActiveMinigameId != 30)
	{
		return Plugin_Continue;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}

	if (HasEntProp(entity, Prop_Send, "m_hOwnerEntity"))
	{
		Player target = new Player(other);
		Player owner = new Player(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"));

		bool targetValid = target.IsValid && target.IsParticipating;
		bool ownerValid = owner.IsValid && owner.IsParticipating;

		if (targetValid && ownerValid && target.Class == TFClass_Medic && owner.Class == TFClass_Heavy)
		{
			target.TriggerSuccess();
			owner.TriggerSuccess();

			SDKUnhook(entity, SDKHook_StartTouch, Minigame30_OnLunchboxTouch);

			if (entity != -1)
			{
				RemoveEntity(entity);
			}
		}
	}
	else
	{
		SDKUnhook(entity, SDKHook_StartTouch, Minigame30_OnLunchboxTouch);
	}

	return Plugin_Continue;
}