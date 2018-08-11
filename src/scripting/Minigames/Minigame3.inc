/**
 * MicroTF2 - Minigame 2
 * 
 * Break the Barrels
 */

#define BARREL_MODEL "models/props_farm/gibs/wooden_barrel_break01.mdl"

new Float:_PositionsBarrel[9][3];

public Minigame3_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, MinigameThree_MapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameThree_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameThree_OnSelection);
	AddToForward(GlobalForward_OnPropBroken, INVALID_HANDLE, MinigameThree_OnPropBroken);
}

public MinigameThree_MapStart()
{
	PrecacheModel(BARREL_MODEL, true);
}

public bool:Minigame3_OnCheck()
{
	if (GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
	{
		return false;
	}

	// If we get here, the minigame can run! 
	return true;
}

public MinigameThree_OnSelectionPre()
{
	if (MinigameID == 3)
	{
		_PositionsBarrel[0][0] = 1.1;
		_PositionsBarrel[0][1] = 2.4;

		_PositionsBarrel[1][0] = -18.0;
		_PositionsBarrel[1][1] = 396.0;

		_PositionsBarrel[2][0] = -286.0;
		_PositionsBarrel[2][1] = 286.0;

		_PositionsBarrel[3][0] = -418.0;
		_PositionsBarrel[3][1] = 2.9;

		_PositionsBarrel[4][0] = -294.0;
		_PositionsBarrel[4][1] = -303.0;

		_PositionsBarrel[5][0] = -4.0;
		_PositionsBarrel[5][1] = -433.0;

		_PositionsBarrel[6][0] = 270.0;
		_PositionsBarrel[6][1] = -254.0;

		_PositionsBarrel[7][0] = 382.0;
		_PositionsBarrel[7][1] = 0.0;

		_PositionsBarrel[8][0] = 281.0;
		_PositionsBarrel[8][1] = 278.0;
	
		new a;

		for (new i = 0; i < GetTeamClientCount(2); i++)
		{
			a = GetRandomInt(0, 8);

			_PositionsBarrel[a][2] = -30.0;
			new entity = CreatePropEntity(_PositionsBarrel[a], BARREL_MODEL, 10, 4.0);

			CreateParticle(entity, "bombinomicon_flash", 1.0);
		}
	}
}

public MinigameThree_OnSelection(client)
{
	if (IsMinigameActive && MinigameID == 3 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Scout);
		ResetWeapon(client, true);
	}
}

public MinigameThree_OnPropBroken(client)
{
	if (IsMinigameActive && MinigameID == 3)
	{
		if (IsClientValid(client) && IsPlayerParticipant[client])
		{
			ClientWonMinigame(client);
		}
	}
}