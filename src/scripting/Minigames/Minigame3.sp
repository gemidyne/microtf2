/**
 * MicroTF2 - Minigame 2
 * 
 * Break the Barrels
 */

#define MINIGAME3_BARRELMDL "models/props_farm/gibs/wooden_barrel_break01.mdl"

float Minigame3_Positions[9][3];

public void Minigame3_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame3_MapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame3_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame3_OnSelection);
	AddToForward(GlobalForward_OnPropBroken, INVALID_HANDLE, Minigame3_OnPropBroken);

	Minigame3_Positions[0][0] = 1.1;
	Minigame3_Positions[0][1] = 2.4;

	Minigame3_Positions[1][0] = -18.0;
	Minigame3_Positions[1][1] = 396.0;

	Minigame3_Positions[2][0] = -286.0;
	Minigame3_Positions[2][1] = 286.0;

	Minigame3_Positions[3][0] = -418.0;
	Minigame3_Positions[3][1] = 2.9;

	Minigame3_Positions[4][0] = -294.0;
	Minigame3_Positions[4][1] = -303.0;

	Minigame3_Positions[5][0] = -4.0;
	Minigame3_Positions[5][1] = -433.0;

	Minigame3_Positions[6][0] = 270.0;
	Minigame3_Positions[6][1] = -254.0;

	Minigame3_Positions[7][0] = 382.0;
	Minigame3_Positions[7][1] = 0.0;

	Minigame3_Positions[8][0] = 281.0;
	Minigame3_Positions[8][1] = 278.0;
}

public void Minigame3_MapStart()
{
	PrecacheModel(MINIGAME3_BARRELMDL, true);
}

public bool Minigame3_OnCheck()
{
	if (GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
	{
		return false;
	}

	return true;
}

public void Minigame3_OnSelectionPre()
{
	if (MinigameID == 3)
	{
		int indice;

		for (int i = 0; i < GetTeamClientCount(2); i++)
		{
			indice = GetRandomInt(0, 8);

			Minigame3_Positions[indice][2] = -30.0;
			int entity = CreatePropEntity(Minigame3_Positions[indice], MINIGAME3_BARRELMDL, 10, 4.0);

			CreateParticle(entity, "bombinomicon_flash", 1.0);
		}
	}
}

public void Minigame3_OnSelection(int client)
{
	if (IsMinigameActive && MinigameID == 3 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Scout);
		ResetWeapon(client, true);
	}
}

public void Minigame3_OnPropBroken(int client)
{
	if (IsMinigameActive && MinigameID == 3)
	{
		if (IsClientValid(client) && IsPlayerParticipant[client])
		{
			ClientWonMinigame(client);
		}
	}
}