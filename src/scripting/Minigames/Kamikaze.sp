/**
 * MicroTF2 - Minigame 10
 * 
 * Avoid the Kamikaze! / Explode a Player
 */

#define MINIGAME10_SFX_FINALTICK "weapons/mortar/mortar_shell_incomming1.wav"
#define MINIGAME10_SFX_EXPLOSION "ambient/explosions/explode_3.wav"

int g_iMinigame10KillCount = 0;

int g_iMinigame10Serial = 0;
int g_iMinigame10KamikazePlayer;

int g_iMinigame10KamikazeSerial[MAXPLAYERS+1] = { 0, ... };
int g_iMinigame10KamikazeTime[MAXPLAYERS+1] = { 0, ... };

public void Minigame10_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Minigame10_OnMapStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame10_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame10_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame10_OnMinigameFinish);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Minigame10_OnPlayerDeath);
}

public void Minigame10_OnMapStart()
{
	PreloadSound(MINIGAME10_SFX_FINALTICK);
	PreloadSound(MINIGAME10_SFX_EXPLOSION);
}

public void Minigame10_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 10)
	{
		Minigame10_Timebomb_Init();

		g_bIsBlockingKillCommands = true;
	}
}

public void Minigame10_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 10)
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
		if (player.ClientId != g_iMinigame10KamikazePlayer)
		{
			player.Class = TFClass_Heavy;
		}
		else
		{
			player.Class = TFClass_Scout;
		}

		player.RemoveAllWeapons();
		player.Status = PlayerStatus_NotWon;
		player.SetHealth(100);
		player.ResetWeapon(false);
	}
}

public void Minigame10_GetDynamicCaption(int client)
{
	Player player = new Player(client);

	if (player.IsValid)
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		char text[64];

		if (player.ClientId == g_iMinigame10KamikazePlayer)
		{
			Format(text, sizeof(text), "%T", "Minigame10_Caption_ExplodeAsMany", client);
		}
		else
		{
			Format(text, sizeof(text), "%T", "Minigame10_Caption_RunFromKamikaze", client);
		}

		player.SetCaption(text);
	}
}

public void Minigame10_OnPlayerDeath(int client)
{
	if (g_iActiveMinigameId != 10)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && player.ClientId != g_iMinigame10KamikazePlayer)
	{
		player.Status = PlayerStatus_Failed;
		g_iMinigame10KillCount += 1;
	}
}

public void Minigame10_OnMinigameFinish()
{
	if (g_iActiveMinigameId == 10)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				if (player.ClientId == g_iMinigame10KamikazePlayer && g_iMinigame10KillCount >= 1) 
				{
					player.Status = PlayerStatus_Winner;
				}
				else if (player.ClientId != g_iMinigame10KamikazePlayer && player.IsAlive) 
				{
					player.TriggerSuccess();
				}
			}
		}
	}
}

public void Minigame10_Timebomb_Init()
{
	if (g_iActiveMinigameId == 10)
	{
		int[] arrayPlayers = new int[MaxClients + 1];
		int index = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating) 
			{
				arrayPlayers[index] = i;
				index++;
			}
		}

		if (index > 0)
		{
			int victim = arrayPlayers[GetRandomInt(0, index-1)];
			Player timebomb = new Player(victim);

			if (timebomb.IsValid && timebomb.IsAlive)
			{
				g_iMinigame10KamikazePlayer = timebomb.ClientId;
				g_iMinigame10KillCount = 0;

				g_iMinigame10KamikazeSerial[timebomb.ClientId] = ++g_iMinigame10Serial;
				CreateTimer(1.0, Minigame10_Timebomb_Timer, timebomb.ClientId | (g_iMinigame10Serial << 7), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				g_iMinigame10KamikazeTime[timebomb.ClientId] = 3;

				char particle[64];

				Format(particle, sizeof(particle), timebomb.Team == TFTeam_Red ? "burningplayer_red" : "burningplayer_blue");

				CreateParticle(timebomb.ClientId, particle, 4.0);
				CreateParticle(timebomb.ClientId, "rockettrail", 4.0);

				for (int i = 1; i <= MaxClients; i++)
				{
					Player player = new Player(i);

					if (player.IsInGame && !player.IsBot)
					{
						char buffer[32];
						Format(buffer, sizeof(buffer), "%T", "Minigame10_KamikazeIsHere", player.ClientId);
						player.ShowAnnotation(timebomb.ClientId, 3.0, buffer);
					}
				}

				SetVariantString("models/bots/demo/bot_sentry_buster.mdl");
				AcceptEntityInput(timebomb.ClientId, "SetCustomModel");
				SetEntProp(timebomb.ClientId, Prop_Send, "m_bUseClassAnimations", 1);

			}
			else
			{
				Minigame10_Timebomb_Init();
			}
		}
	}
}

public Action Minigame10_Timebomb_Timer(Handle timer, int value)
{
	int client = value & 0x7f;
	int serial = value >> 7;
	
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || serial != g_iMinigame10KamikazeSerial[client])
	{
		Minigame10_Timebomb_Kill(client);
		return Plugin_Stop;
	}
	
	g_iMinigame10KamikazeTime[client]--;
	
	float vec[3];
	GetClientEyePosition(client, vec);
	
	if (g_iMinigame10KamikazeTime[client] > 0)
	{
		if (g_iMinigame10KamikazeTime[client] > 1)
		{
			char particle[64];

			if (GetClientTeam(client) == 2)
			{
				Format(particle, sizeof(particle), "K_Pre_BoltsRed");
			}
			else
			{
				Format(particle, sizeof(particle), "K_Pre_BoltsBlue");
			}

			CreateParticle(client, particle, 1.1);
		}
		else
		{
			EmitAmbientSound(MINIGAME10_SFX_FINALTICK, vec, client, SNDLEVEL_RAIDSIREN);

			char particle[64];

			if (GetClientTeam(client) == 2)
			{
				Format(particle, sizeof(particle), "K_Pre_ChargeRed");
			}
			else
			{
				Format(particle, sizeof(particle), "K_Pre_ChargeBlue");
			}

			CreateParticle(client, particle, 1.0);
		}
		
		GetClientAbsOrigin(client, vec);
		vec[2] += 10;

		return Plugin_Continue;
	}
	else
	{
		g_bIsBlockingKillCommands = false;
		g_eDamageBlockMode = EDamageBlockMode_Nothing;
		
		EmitAmbientSound(MINIGAME10_SFX_EXPLOSION, vec, client, SNDLEVEL_RAIDSIREN);
		char particle[64];

		if (GetClientTeam(client) == 2)
		{
			strcopy(particle, sizeof(particle), "K_Kamikaze");
		}
		else
		{
			strcopy(particle, sizeof(particle), "K_Kamikaze_Blue");
		}

		CreateParticle(client, particle, 8.0);
		
		ForcePlayerSuicide(client);
		Minigame10_Timebomb_Kill(client);

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (!player.IsValid || !player.IsAlive || !player.IsParticipating || i == client)
			{
				continue;
			}

			float pos[3];
			GetClientEyePosition(i, pos);
			
			float distance = GetVectorDistance(vec, pos);
			
			if (distance > 600)	
			{
				continue;
			}

			player.SetGodMode(false);
			
			float damage = 250.0; 
			damage = damage * (700.0 - distance) / 700.0;
			
			SDKHooks_TakeDamage(player.ClientId, player.ClientId, client, damage, DMG_BLAST);
		}
	}
	return Plugin_Stop;
}

public void Minigame10_Timebomb_Kill(int client)
{
	g_iMinigame10KamikazeSerial[client] = 0;
	if (IsClientInGame(client)) 
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}
