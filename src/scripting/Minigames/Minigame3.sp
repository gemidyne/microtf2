/**
 * MicroTF2 - Minigame 2
 * 
 * Break the Barrels
 */

#define MINIGAME3_BARRELMDL "models/props_farm/gibs/wooden_barrel_break01.mdl"

public void Minigame3_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Minigame3_MapStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame3_OnSelectionPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame3_OnSelection);
	AddToForward(g_pfOnPropBroken, INVALID_HANDLE, Minigame3_OnPropBroken);
}

public void Minigame3_MapStart()
{
	PrecacheModel(MINIGAME3_BARRELMDL, true);
}

public void Minigame3_OnSelectionPre()
{
	if (g_iActiveMinigameId == 3)
	{
		int count = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				count++;
			}
		}

		if (count > 1)
		{
			count = count / 2;
		}

		for (int i = 1; i <= count; i++)
		{
			int posa = 360 / count * (i-1);
			float pos[3];

			pos[0] = -31.6 + (Cosine(DegToRad(float(posa)))*375.0);
			pos[1] = -7665.0 - (Sine(DegToRad(float(posa)))*375.0);
			pos[2] = -130.0;

			int entity = CreatePropEntity(pos, MINIGAME3_BARRELMDL, 10, 4.0);

			CreateParticle(entity, "bombinomicon_flash", 1.0);
		}
	}
}

public void Minigame3_OnSelection(int client)
{
	if (g_iActiveMinigameId != 3)
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
		player.ResetWeapon(true);
	}
}

public void Minigame3_OnPropBroken(int client)
{
	if (g_iActiveMinigameId != 3)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		player.TriggerSuccess();
	}
}