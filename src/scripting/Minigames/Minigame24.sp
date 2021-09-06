/**
 * MicroTF2 - Minigame 24
 *
 * Needlejump!
 * Requested by some. Credit to those responsible for the needlejump code.
 */

int g_iMinigame24NeedleFireDelay[MAXPLAYERS+1];

public void Minigame24_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame24_OnMinigameSelected);
	AddToForward(g_pfOnGameFrame, INVALID_HANDLE, Minigame24_OnGameFrame);
}

public void Minigame24_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 24)
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
		player.RemoveAllWeapons();
		player.Class = TFClass_Medic;
		player.GiveWeapon(17);
		player.SetWeaponPrimaryAmmoCount(150);

		g_iMinigame24NeedleFireDelay[client] = 50;
	}
}

public void Minigame24_OnGameFrame()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 24)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && player.IsAlive && player.Status == PlayerStatus_NotWon)
			{
				Minigame24_PerformNeedlejump(i);

				float clientPos[3];
				GetClientAbsOrigin(i, clientPos);

				if (clientPos[2] > 0.0) 
				{
					player.TriggerSuccess();
					player.ResetWeapon(false); // Stops lag
				}
			}
		}
	}
}

public void Minigame24_PerformNeedlejump(int i)
{
	float fEyeAngle[3];
	float fVelocity[3];

	if (g_iMinigame24NeedleFireDelay[i] > 0) 
	{
		g_iMinigame24NeedleFireDelay[i] -= 1;
	}

	if ((GetClientButtons(i) & IN_ATTACK) && (g_iMinigame24NeedleFireDelay[i] <= 0))
	{
		int iWeapon = GetPlayerWeaponSlot(i, 0);

		if (IsValidEdict(iWeapon) && GetEntData(iWeapon, g_oWeaponBaseClip1) != 0)
		{
			GetClientEyeAngles(i, fEyeAngle);
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);

			float multi = GetSpeedMultiplier(1.0);
			fVelocity[0] += (10.0 * Cosine(DegToRad(fEyeAngle[1])) * -1.0) / multi;
			fVelocity[1] += (10.0 * Sine(DegToRad(fEyeAngle[1])) * -1.0) / multi;
			fVelocity[2] -= (40.0 * Sine(DegToRad(fEyeAngle[0])) * -1.0) / multi;

			if (FloatAbs(fVelocity[0]) > 400.0)
			{
				fVelocity[0] = fVelocity[0] > 0.0
					? 400.0
					: -400.0;
			}

			if (FloatAbs(fVelocity[1]) > 400.0)
			{
				fVelocity[1] = fVelocity[1] > 0.0
					? 400.0
					: -400.0;
			}

			if (fVelocity[2] > 400.0)
			{
				fVelocity[2] = 400.0;
			}

			TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, fVelocity);
			g_iMinigame24NeedleFireDelay[i] = 3;
        }
    }
}