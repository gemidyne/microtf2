/**
 * MicroTF2 - Minigame 32
 * 
 * Bump them off
 */

int g_iMinigame32PlayerIndex;

public void Minigame32_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame32_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame32_OnMinigameSelected);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Minigame32_OnPlayerDeath);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame32_OnMinigameFinish);
}

public void Minigame32_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 32)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		g_bIsBlockingKillCommands = false;
		g_iMinigame32PlayerIndex = 0;
	}
}

public void Minigame32_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 32)
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
		player.ResetWeapon(false);

		player.Status = PlayerStatus_Winner;

		g_iMinigame32PlayerIndex++;

		float vel[3] = { 0.0, 0.0, 0.0 };
		int posa = 360 / g_iActiveParticipantCount * (g_iMinigame32PlayerIndex-1);
		float pos[3];
		float ang[3];

		pos[0] = -7567.6 + (Cosine(DegToRad(float(posa)))*300.0);
		pos[1] = 3183.0 - (Sine(DegToRad(float(posa)))*300.0);
		pos[2] = -246.0;

		ang[0] = 0.0;
		ang[1] = float(180-posa);
		ang[2] = 0.0;

		TeleportEntity(client, pos, ang, vel);
		player.AddCondition(TFCond_HalloweenKart);
		SetEntProp(player.ClientId, Prop_Send, "m_iKartHealth", 0);
		SetEntPropFloat(player.ClientId, Prop_Send, "m_flKartNextAvailableBoost", 0.0);

		SDKHook(client, SDKHook_PreThink, Minigame32_RemoveLeftClick);
	}
}

public void Minigame32_OnPlayerDeath(int client, int attacker)
{
	if (g_iActiveMinigameId != 32)
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

public void Minigame32_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 32)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Status = (player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed);

				SDKUnhook(i, SDKHook_PreThink, Minigame32_RemoveLeftClick);
				player.RemoveCondition(TFCond_HalloweenKart);
				player.Respawn();
			}
		}
	}
}

public void Minigame32_RemoveLeftClick(int client)
{
	int buttons = GetClientButtons(client);

	if ((buttons & IN_ATTACK))
	{
		buttons &= ~IN_ATTACK;
		SetEntProp(client, Prop_Data, "m_nButtons", buttons);
	}
}