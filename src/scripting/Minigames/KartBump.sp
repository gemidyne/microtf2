/**
 * MicroTF2 - Minigame 33
 * 
 * Shove them off!
 */

int g_iMinigame33PlayerIndex;

public void Minigame33_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame33_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame33_OnMinigameSelected);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Minigame33_OnPlayerDeath);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame33_OnMinigameFinish);
}

public void Minigame33_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 33)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		g_bIsBlockingKillCommands = false;
		g_iMinigame33PlayerIndex = 0;
	}
}

public void Minigame33_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 33)
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
		player.SetCollisionsEnabled(true);

		player.Class = TFClass_Scout;
		player.RemoveAllWeapons();

		player.Status = PlayerStatus_Winner;

		g_iMinigame33PlayerIndex++;

		player.GiveWeapon(220);
		player.SetWeaponPrimaryAmmoCount(4);
		player.SetWeaponClipAmmoCount(32);

		float vel[3] = { 0.0, 0.0, 0.0 };
		int posa = 360 / g_iActiveParticipantCount * (g_iMinigame33PlayerIndex-1);
		float pos[3];
		float ang[3];

		pos[0] = -7567.6 + (Cosine(DegToRad(float(posa)))*300.0);
		pos[1] = 3183.0 - (Sine(DegToRad(float(posa)))*300.0);
		pos[2] = -282.0;

		ang[0] = 0.0;
		ang[1] = float(180-posa);
		ang[2] = 0.0;

		TeleportEntity(client, pos, ang, vel);
		player.AddCondition(TFCond_HalloweenKart);
		SetEntProp(player.ClientId, Prop_Send, "m_iKartHealth", 0);

		SDKHook(client, SDKHook_PreThink, Minigame33_RemoveLeftClick);
	}
}

public void Minigame33_OnPlayerDeath(int client, int attacker)
{
	if (g_iActiveMinigameId != 33)
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

public void Minigame33_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 33)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Status = (player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed);

				SDKUnhook(i, SDKHook_PreThink, Minigame33_RemoveLeftClick);
				player.RemoveCondition(TFCond_HalloweenKart);
				player.Respawn();
			}
		}
	}
}

public void Minigame33_RemoveLeftClick(int client)
{
	int buttons = GetClientButtons(client);

	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}