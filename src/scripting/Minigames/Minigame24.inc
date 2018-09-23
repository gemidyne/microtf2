/**
 * MicroTF2 - Minigame 24
 *
 * Needlejump!
 * Requested by some. Credit to those responsible for the needlejump code.
 */

int Minigame24_NeedleFireDelay[MAXPLAYERS+1];

public void Minigame24_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame24_OnMinigameSelected);
	AddToForward(GlobalForward_OnGameFrame, INVALID_HANDLE, Minigame24_OnGameFrame);
}

public bool Minigame24_OnCheck()
{
	if (SpeedLevel > 1.5)
	{
		return false;
	}
	
	return true;
}

public void Minigame24_OnMinigameSelected(int client)
{
	if (IsMinigameActive && MinigameID == 24 && IsClientValid(client))
	{
		TF2_SetPlayerClass(client, TFClass_Medic);
		GiveWeapon(client, 17);
		IsViewModelVisible(client, true);

		Minigame24_NeedleFireDelay[client] = 50;
	}
}

public void Minigame24_OnGameFrame()
{
	if (IsMinigameActive && MinigameID == 24)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerAlive(i) && IsPlayerParticipant[i] && PlayerStatus[i] == PlayerStatus_NotWon)
			{
				Minigame24_PerformNeedlejump(i);

				float clientPos[3];
				GetClientAbsOrigin(i, clientPos);

				if (clientPos[2] > 0.0) 
				{
					ClientWonMinigame(i);
					ResetWeapon(i, false); // Stops lag
				}
			}
		}
	}
}

public void Minigame24_PerformNeedlejump(i)
{
	float fEyeAngle[3];
	float fVelocity[3];

	if (Minigame24_NeedleFireDelay[i] > 0) Minigame24_NeedleFireDelay[i] -= 1;

	if (IsClientValid(i) && (GetClientButtons(i) & IN_ATTACK) && (Minigame24_NeedleFireDelay[i] <= 0))
	{
		int iWeapon = GetPlayerWeaponSlot(i, 0);

		if (IsValidEdict(iWeapon) && GetEntData(iWeapon, FindSendPropInfo("CTFWeaponBase", "m_iClip1")) != 0)
		{
			GetClientEyeAngles(i, fEyeAngle);
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);

			float multi = GetSpeedMultiplier(1.0);
			fVelocity[0] += (10.0 * Cosine(DegToRad(fEyeAngle[1])) * -1.0) / multi;
			fVelocity[1] += (10.0 * Sine(DegToRad(fEyeAngle[1])) * -1.0) / multi;
			fVelocity[2] -= (40.0 * Sine(DegToRad(fEyeAngle[0])) * -1.0) / multi;

			if (FloatAbs(fVelocity[0]) > 400.0)
			{
				if (fVelocity[0] > 0.0) 
					fVelocity[0] = 400.0;
				else 
					fVelocity[0] = -400.0;
			}

			if(FloatAbs(fVelocity[1]) > 400.0)
			{
				if (fVelocity[1] > 0.0) 
					fVelocity[1] = 400.0;
				else 
					fVelocity[1] = -400.0;
			}

			if (fVelocity[2] > 400.0) 
				fVelocity[2] = 400.0;

			TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, fVelocity);
			Minigame24_NeedleFireDelay[i] = 3;
        }
    }
}