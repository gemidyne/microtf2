/**
 * MicroTF2 - Minigame 10
 * 
 * Avoid the Kamikaze! / Explode a Player
 */

#define DEFAULT_TIMER_FLAGS TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE
#define SOUND_BEEP "vo/scout_award01.wav"
#define SOUND_BEEPTWO "vo/scout_award02.wav"
#define SOUND_BEEPTHR "vo/scout_award03.wav"
#define SOUND_FINAL "weapons/mortar/mortar_shell_incomming1.wav"
#define SOUND_BOOM "ambient/explosions/explode_3.wav"

new MinigameTen_KillCount = 0;

new MinigameTen_BeamSprite = -1;
new MinigameTen_HaloSprite = -1;
new MinigameTen_Serial = 0;
new MinigameTen_ExplosionSprite = -1;

new bool:MinigameTen_IsTimebomb[MAXPLAYERS+1];
new MinigameTen_TimebombSerial[MAXPLAYERS+1] = { 0, ... };
new MinigameTen_TimebombTime[MAXPLAYERS+1] = { 0, ... };

new MinigameTen_White[4] = {255, 255, 255, 255};
new MinigameTen_Grey[4] = {128, 128, 128, 255};

public Minigame10_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, MinigameTen_OnMapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, MinigameTen_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, MinigameTen_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, MinigameTen_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, MinigameTen_OnPlayerDeath);
}

public MinigameTen_OnMapStart()
{
	MinigameTen_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	MinigameTen_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	MinigameTen_ExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");
	
	PrecacheSound(SOUND_BEEP, true);
	PrecacheSound(SOUND_BEEPTWO, true);
	PrecacheSound(SOUND_BEEPTHR, true);
	PrecacheSound(SOUND_FINAL, true);
	PrecacheSound(SOUND_BOOM, true);
}

public bool:Minigame10_OnCheck()
{
	if (SpecialRoundID == 12)
	{
		return false;
	}

	if (GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
	{
		return false;
	}

	// If we get here, the minigame can run! 
	return true;
}

public MinigameTen_OnMinigameSelectedPre()
{
	if (MinigameID == 10)
	{
		Timebomb_Initialize();
	}
}

public MinigameTen_OnMinigameSelected(client)
{
	if (IsMinigameActive && MinigameID == 10 && IsClientValid(client))
	{
		if (!MinigameTen_IsTimebomb[client])
		{
			TF2_SetPlayerClass(client, TFClass_Heavy);
		}
		else
		{
			TF2_SetPlayerClass(client, TFClass_Scout);
		}

		TF2_RemoveAllWeapons(client);
		ResetWeapon(client, false);
					
		PlayerStatus[client] = PlayerStatus_NotWon;
		SetPlayerHealth(client, 100);
	}
}

public Minigame10_GetDynamicCaption(client)
{
	if (IsClientValid(client))
	{
		// HudTextParams are already set at this point. All we need to do is ShowSyncHudText.
		decl String:text[64];

		if (MinigameTen_IsTimebomb[client])
		{
			text = "EXPLODE AS MANY PEOPLE AS YOU CAN!";
		}
		else
		{
			text = "RUN FROM THE KAMIKAZE!";
		}

		TrainingMessageToClient(client, text, "", 3.0);			
	}
}

public MinigameTen_OnPlayerDeath(client)
{
	if (IsMinigameActive && MinigameID == 10 && IsClientValid(client))
	{
		if (!MinigameTen_IsTimebomb[client])
		{
			PlayerStatus[client] = PlayerStatus_Failed;
			MinigameTen_KillCount += 1;
		}
	}
}

public MinigameTen_OnMinigameFinish()
{
	if (MinigameID == 10)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerParticipant[i])
			{
				if (MinigameTen_IsTimebomb[i] && MinigameTen_KillCount >= 1) 
				{
					PlayerStatus[i] = PlayerStatus_Winner;
				}
				else if (!MinigameTen_IsTimebomb[i] && IsPlayerAlive(i)) 
				{
					ClientWonMinigame(i);
				}
			}
		}
	}
}

public Timebomb_Initialize()
{
	if (MinigameID == 10)
	{
		new arrayPlayers[MaxClients];
		new index = 0;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientValid(i) && IsPlayerParticipant[i]) 
			{
				arrayPlayers[index] = i;
				index++;

				MinigameTen_IsTimebomb[i] = false;
			}
		}

		if (index > 0)
		{
			new victim = arrayPlayers[GetRandomInt(0, index-1)];
			if (ForceRandom(victim))
			{
				TimebombPlayer(victim);

				MinigameTen_IsTimebomb[victim] = true;
				MinigameTen_KillCount = 0;
			}
			else
			{
				Timebomb_Initialize();
			}
		}
	}
}

stock bool:ForceRandom(client)
{
	// Check to see if client is valid
	if (client <= 0 || !IsClientConnected(client)) return false;
	if (!IsClientInGame(client)) return false;
	if (IsClientInKickQueue(client)) return false;
	if (!IsPlayerAlive(client)) return false;
	if (IsFakeClient(client)) return false;
	return true;
}

stock TimebombPlayer(client)
{
	MinigameTen_TimebombSerial[client] = ++MinigameTen_Serial;
	CreateTimer(1.0, Timer_TimeBomb, client | (MinigameTen_Serial << 7), DEFAULT_TIMER_FLAGS);
	MinigameTen_TimebombTime[client] = 3;

	decl String:particle[64];

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

	ShowAnnotation(client, 3.0, "Kamikaze is here!");
}

public Action:Timer_TimeBomb(Handle:timer, any:value)
{
	new client = value & 0x7f;
	new serial = value >> 7;
	
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || serial != MinigameTen_TimebombSerial[client])
	{
		KillTimeBomb(client);
		return Plugin_Stop;
	}
	
	MinigameTen_TimebombTime[client]--;
	
	new Float:vec[3];
	GetClientEyePosition(client, vec);
	
	if (MinigameTen_TimebombTime[client] > 0)
	{
		new color;
		
		if (MinigameTen_TimebombTime[client] > 1)
		{
			color = RoundToFloor(MinigameTen_TimebombTime[client] * (128.0 / 2));
			switch (GetRandomInt(0, 2))
			{
				case 0: EmitAmbientSound(SOUND_BEEP, vec, client, SNDLEVEL_RAIDSIREN);
				case 1: EmitAmbientSound(SOUND_BEEPTWO, vec, client, SNDLEVEL_RAIDSIREN);
				case 2: EmitAmbientSound(SOUND_BEEPTHR, vec, client, SNDLEVEL_RAIDSIREN);
			}

			decl String:particle[64];

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
			color = 0;
			EmitAmbientSound(SOUND_FINAL, vec, client, SNDLEVEL_RAIDSIREN);

			decl String:particle[64];

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
		
		SetEntityRenderColor(client, 255, 128, color, 255);
		
		GetClientAbsOrigin(client, vec);
		vec[2] += 10;
		
		TE_SetupBeamRingPoint(vec, 10.0, 600 / 3.0, MinigameTen_BeamSprite, MinigameTen_HaloSprite, 0, 15, 0.5, 5.0, 0.0, MinigameTen_Grey, 10, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(vec, 10.0, 600 / 3.0, MinigameTen_BeamSprite, MinigameTen_HaloSprite, 0, 10, 0.6, 10.0, 0.5, MinigameTen_White, 10, 0);
		TE_SendToAll();
		return Plugin_Continue;
	}
	else
	{
		if (MinigameTen_ExplosionSprite > -1)
		{
			TE_SetupExplosion(vec, MinigameTen_ExplosionSprite, 5.0, 1, 0, 600, 5000);
			TE_SendToAll();
		}

		IsBlockingDeaths = false;
		IsBlockingDamage = false;
		
		EmitAmbientSound(SOUND_BOOM, vec, client, SNDLEVEL_RAIDSIREN);
		decl String:particle[64];

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
		KillTimeBomb(client);
		SetEntityRenderColor(client, 255, 255, 255, 255);

		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || i == client || !IsPlayerParticipant[i])	continue;
			new Float:pos[3];
			GetClientEyePosition(i, pos);
			
			new Float:distance = GetVectorDistance(vec, pos);
			
			if (distance > 600)	continue;
			
			new damage = 250; //220
			damage = RoundToFloor(damage * (700 - distance) / 700); //600
			
			SlapPlayer(i, damage, false);
			
			if (MinigameTen_ExplosionSprite > -1)
			{
				TE_SetupExplosion(pos, MinigameTen_ExplosionSprite, 0.05, 1, 0, 1, 1);
				TE_SendToAll();	
			}
		}
	}
	return Plugin_Stop;
}

KillTimeBomb(client)
{
	MinigameTen_TimebombSerial[client] = 0;
	if (IsClientInGame(client)) 
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}
