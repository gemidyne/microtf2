/**
 * MicroTF2 - Minigame 10
 * 
 * Avoid the Kamikaze! / Explode a Player
 */

#define SOUND_FINAL "weapons/mortar/mortar_shell_incomming1.wav"
#define SOUND_BOOM "ambient/explosions/explode_3.wav"

int Minigame10_KillCount = 0;

int Minigame10_BeamSprite = -1;
int Minigame10_HaloSprite = -1;
int Minigame10_Serial = 0;
int Minigame10_ExplosionSprite = -1;

bool Minigame10_IsTimebomb[MAXPLAYERS+1];
int Minigame10_TimebombSerial[MAXPLAYERS+1] = { 0, ... };
int Minigame10_TimebombTime[MAXPLAYERS+1] = { 0, ... };

int Minigame10_White[4] = {255, 255, 255, 255};
int Minigame10_Grey[4] = {128, 128, 128, 255};

public void Minigame10_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame10_OnMapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame10_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame10_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame10_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Minigame10_OnPlayerDeath);
}

public void Minigame10_OnMapStart()
{
	Minigame10_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	Minigame10_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	Minigame10_ExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");

	PrecacheSound(SOUND_FINAL, true);
	PrecacheSound(SOUND_BOOM, true);
}

public void Minigame10_OnMinigameSelectedPre()
{
	if (MinigameID == 10)
	{
		Minigame10_Timebomb_Init();

		IsBlockingDeathCommands = true;
	}
}

public void Minigame10_OnMinigameSelected(int client)
{
	if (MinigameID != 10)
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
		if (!Minigame10_IsTimebomb[client])
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

		if (Minigame10_IsTimebomb[client])
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
	if (MinigameID != 10)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (player.IsValid && !Minigame10_IsTimebomb[client])
	{
		player.Status = PlayerStatus_Failed;
		Minigame10_KillCount += 1;
	}
}

public void Minigame10_OnMinigameFinish()
{
	if (MinigameID == 10)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				if (Minigame10_IsTimebomb[i] && Minigame10_KillCount >= 1) 
				{
					player.Status = PlayerStatus_Winner;
				}
				else if (!Minigame10_IsTimebomb[i] && player.IsAlive) 
				{
					player.TriggerSuccess();
				}
			}
		}
	}
}

public void Minigame10_Timebomb_Init()
{
	if (MinigameID == 10)
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

				Minigame10_IsTimebomb[i] = false;
			}
		}

		if (index > 0)
		{
			int victim = arrayPlayers[GetRandomInt(0, index-1)];
			
			if (Minigame10_Timebomb_CanApplyToPlayer(victim))
			{
				Minigame10_TimebombPlayer(victim);

				Minigame10_IsTimebomb[victim] = true;
				Minigame10_KillCount = 0;
			}
			else
			{
				Minigame10_Timebomb_Init();
			}
		}
	}
}

public bool Minigame10_Timebomb_CanApplyToPlayer(int client)
{
	if (client <= 0 || !IsClientConnected(client)) return false;
	if (!IsClientInGame(client)) return false;
	if (IsClientInKickQueue(client)) return false;
	if (!IsPlayerAlive(client)) return false;
	// if (IsFakeClient(client)) return false;
	return true;
}

public void Minigame10_TimebombPlayer(int client)
{
	Player timebomb = new Player(client);

	Minigame10_TimebombSerial[client] = ++Minigame10_Serial;
	CreateTimer(1.0, Minigame10_Timebomb_Timer, client | (Minigame10_Serial << 7), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	Minigame10_TimebombTime[client] = 3;

	char particle[64];

	if (GetClientTeam(client) == 2)
	{
		Format(particle, sizeof(particle), "burningplayer_red");
	}
	else
	{
		Format(particle, sizeof(particle), "burningplayer_blue");
	}

	CreateParticle(client, particle, 4.0);
	CreateParticle(client, "rockettrail", 4.0);

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

public Action Minigame10_Timebomb_Timer(Handle timer, int value)
{
	int client = value & 0x7f;
	int serial = value >> 7;
	
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || serial != Minigame10_TimebombSerial[client])
	{
		Minigame10_Timebomb_Kill(client);
		return Plugin_Stop;
	}
	
	Minigame10_TimebombTime[client]--;
	
	float vec[3];
	GetClientEyePosition(client, vec);
	
	if (Minigame10_TimebombTime[client] > 0)
	{
		if (Minigame10_TimebombTime[client] > 1)
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
			EmitAmbientSound(SOUND_FINAL, vec, client, SNDLEVEL_RAIDSIREN);

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
		
		TE_SetupBeamRingPoint(vec, 10.0, 600 / 3.0, Minigame10_BeamSprite, Minigame10_HaloSprite, 0, 15, 0.5, 5.0, 0.0, Minigame10_Grey, 10, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(vec, 10.0, 600 / 3.0, Minigame10_BeamSprite, Minigame10_HaloSprite, 0, 10, 0.6, 10.0, 0.5, Minigame10_White, 10, 0);
		TE_SendToAll();
		return Plugin_Continue;
	}
	else
	{
		if (Minigame10_ExplosionSprite > -1)
		{
			TE_SetupExplosion(vec, Minigame10_ExplosionSprite, 5.0, 1, 0, 600, 5000);
			TE_SendToAll();
		}

		IsBlockingDeathCommands = false;
		IsBlockingDamage = false;
		
		EmitAmbientSound(SOUND_BOOM, vec, client, SNDLEVEL_RAIDSIREN);
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
	Minigame10_TimebombSerial[client] = 0;
	if (IsClientInGame(client)) 
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}
