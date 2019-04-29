/**
 * MicroTF2 - Minigame 2
 * 
 * Break the Barrels
 */

#define MINIGAME3_BARRELMDL "models/props_farm/gibs/wooden_barrel_break01.mdl"

public void Minigame3_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame3_MapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame3_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame3_OnSelection);
	AddToForward(GlobalForward_OnPropBroken, INVALID_HANDLE, Minigame3_OnPropBroken);
}

public void Minigame3_MapStart()
{
	PrecacheModel(MINIGAME3_BARRELMDL, true);
}

public void Minigame3_OnSelectionPre()
{
	if (MinigameID == 3)
	{
		int count = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid)
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
	if (MinigameID != 3)
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
		player.Class = TFClass_Scout;
		ResetWeapon(client, true);
	}
}

public void Minigame3_OnPropBroken(int client)
{
	if (MinigameID != 3)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		ClientWonMinigame(client);
	}
}