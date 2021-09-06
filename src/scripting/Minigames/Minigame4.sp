/**
 * MicroTF2 - Minigame 4
 * 
 * Airblast!
 */

int g_iMinigame4PlayerIndex;

public void Minigame4_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame4_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame4_OnMinigameSelected);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Minigame4_OnPlayerDeath);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame4_OnMinigameFinish);
}

public void Minigame4_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 4)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		g_bIsBlockingKillCommands = false;
		g_iMinigame4PlayerIndex = 0;
	}
}

public void Minigame4_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 4)
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
		player.SetGodMode(false);
		player.SetHealth(1000);
		player.SetCollisionsEnabled(false);

		player.Class = TFClass_Pyro;
		player.RemoveAllWeapons();

		player.Status = PlayerStatus_Winner;

		g_iMinigame4PlayerIndex++;

		player.GiveWeapon(21);
		player.SetWeaponPrimaryAmmoCount(200);

		float vel[3] = { 0.0, 0.0, 0.0 };
		int posa = 360 / g_iActiveParticipantCount * (g_iMinigame4PlayerIndex-1);
		float pos[3];
		float ang[3];

		pos[0] = -7567.6 + (Cosine(DegToRad(float(posa)))*300.0);
		pos[1] = 3183.0 - (Sine(DegToRad(float(posa)))*300.0);
		pos[2] = -282.0;

		ang[0] = 0.0;
		ang[1] = float(180-posa);
		ang[2] = 0.0;

		TeleportEntity(client, pos, ang, vel);
		SDKHook(client, SDKHook_PreThink, Minigame4_RemoveLeftClick);
	}
}

public void Minigame4_OnPlayerDeath(int client, int attacker)
{
	if (g_iActiveMinigameId != 4)
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
		player.Status = PlayerStatus_Failed;

		Player attackerPlayer = new Player(attacker);

		if (attackerPlayer.IsValid)
		{
			attackerPlayer.Status = PlayerStatus_Winner;
		}
	}
}

public void Minigame4_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Status = (player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed);

				SDKUnhook(i, SDKHook_PreThink, Minigame4_RemoveLeftClick);
				player.Respawn();
			}
		}
	}
}

public void Minigame4_RemoveLeftClick(int client)
{
	int buttons = GetClientButtons(client);

	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}