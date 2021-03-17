/**
 * MicroTF2 - Bossgame 6
 * 
 * Target Practice
 */

#define BOSSGAME6_ENTITYSPAWN_COUNT 32
#define BOSSGAME6_RNGMODELS_COUNT 10

int Bossgame6_EntityIndexes[BOSSGAME6_ENTITYSPAWN_COUNT];
bool Bossgame6_Entity_IsBarrel[BOSSGAME6_ENTITYSPAWN_COUNT];

int Bossgame6_Timer;
int Bossgame6_PlayerScore[MAXPLAYERS+1] = 0;
char Bossgame6_RngModels[BOSSGAME6_RNGMODELS_COUNT][64];

public void Bossgame6_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame6_OnMapStart);
	AddToForward(g_pfOnTfRoundStart, INVALID_HANDLE, Bossgame6_OnTfRoundStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame6_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame6_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Bossgame6_OnMinigameFinish);
	AddToForward(g_pfOnRenderHudFrame, INVALID_HANDLE, Bossgame6_OnRenderHudFrame);
}

public void Bossgame6_OnMapStart()
{
	Bossgame6_RngModels[0] = "models/props_hydro/keg_large.mdl";
	Bossgame6_RngModels[1] = "models/props_gameplay/orange_cone001.mdl";
	Bossgame6_RngModels[2] = "models/props_gameplay/ball001.mdl";
	Bossgame6_RngModels[3] = "models/props_farm/tractor_tire001.mdl";
	Bossgame6_RngModels[4] = "models/props_farm/spool_rope.mdl";
	Bossgame6_RngModels[5] = "models/props_farm/spool_wire.mdl";
	Bossgame6_RngModels[6] = "models/props_gameplay/haybale.mdl";
	Bossgame6_RngModels[7] = "models/props_2fort/milkjug001.mdl";
	Bossgame6_RngModels[8] = "models/props_spytech/watercooler.mdl";
	Bossgame6_RngModels[9] = "models/props_mvm/clipboard.mdl";

	for (int i = 0; i < BOSSGAME6_RNGMODELS_COUNT; i++)
	{
		PrecacheModel(Bossgame6_RngModels[i]);
	}
}

public void Bossgame6_OnTfRoundStart()
{
	Bossgame6_SendDoorInput("Close");
}

public void Bossgame6_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId == 6)
	{
		for (int i = 0; i < BOSSGAME6_ENTITYSPAWN_COUNT; i++)
		{
			Bossgame6_EntityIndexes[i] = 0;
		}

		for (int i = 0; i < MAXPLAYERS; i++)
		{
			Bossgame6_PlayerScore[i] = 0;
		}

		g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
		g_bIsBlockingKillCommands = true;

		Bossgame6_SendDoorInput("Close");

		Bossgame6_Timer = 9;
		CreateTimer(0.5, Bossgame6_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Bossgame6_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 6)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}

	player.RemoveAllWeapons();
	player.Class = TFClass_Spy;
	player.SetGodMode(true);
	player.SetCollisionsEnabled(false);
	player.ResetHealth();
	player.GiveWeapon(24);
	player.SetAmmo(2);

	float vel[3] = { 0.0, 0.0, 0.0 };
	float ang[3] = { 0.0, 0.0, 0.0 };
	float pos[3];

	int column = client;
	int row = 0;

	if (player.Team == TFTeam_Red)
	{
		pos[0] = -4015.0 + float(column*60); 
		pos[1] = 959.0 - float(row*100);
		pos[2] = -1093.0;
		ang[1] = 90.0;
	}
	else if (player.Team == TFTeam_Blue)
	{
		pos[0] = -4052.0 + float(column*60); 
		pos[1] = 2783.0 - float(row*100);
		pos[2] = -1093.0;
	}

	TeleportEntity(client, pos, ang, vel);
}

public void Bossgame6_OnMinigameFinish()
{
	if (g_iActiveBossgameId == 6 && g_bIsMinigameActive) 
	{
		Bossgame6_SendDoorInput("Close");
		Bossgame6_CleanupEntities();

		int threshold = 0;
		int winningClient = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating && Bossgame6_PlayerScore[player.ClientId] > threshold)
			{
				threshold = Bossgame6_PlayerScore[player.ClientId];
				winningClient = player.ClientId;
			}
		}

		Player winner = new Player(winningClient);
		winner.Status = PlayerStatus_Winner;
	}
}

public Action Bossgame6_SwitchTimer(Handle timer)
{
	if (g_iActiveBossgameId == 6 && g_bIsMinigameActive && !g_bIsMinigameEnding) 
	{
		switch (Bossgame6_Timer)
		{
			case 8: 
			{
				Bossgame6_SendDoorInput("Close");
				Bossgame6_ShowPlayerScores();
			}
				
			case 7: 
			{
				Bossgame6_CleanupEntities();

				for (int i = 1; i <= MaxClients; i++)
				{
					Player player = new Player(i);

					if (player.IsValid && player.IsParticipating)
					{
						player.SetWeaponPrimaryAmmoCount(2);
						player.SetWeaponClipAmmoCount(0);
					}
				}

				Bossgame6_DoEntitySpawns();
			}

			case 5: 
			{
				Bossgame6_SendDoorInput("Open");
			}

			case 0:
			{
				Bossgame6_Timer = 9;
			}
		}

		Bossgame6_Timer--;
		return Plugin_Continue;
	}

	Bossgame6_Timer = 9;
	return Plugin_Stop; 
}

public void Bossgame6_DoEntitySpawns()
{
	float Bossgame6_SpawnedEntityPositions[BOSSGAME6_ENTITYSPAWN_COUNT][3];
	int count = GetRandomInt(1, BOSSGAME6_ENTITYSPAWN_COUNT);

	for (int i = 0; i < count; i++)
	{
		bool validPosition = false;
		float position[3];
		int calculationAttempts = 0;

		while (!validPosition)
		{
			validPosition = true;
			calculationAttempts++;

			if (calculationAttempts > 32)
			{
				return;
			}

			position[0] = GetRandomFloat(-1807.0, -4063.0);
			position[1] = GetRandomFloat(2495.0, 1199.0);
			position[2] = -1350.0;

			for (int j = 0; j < 32; j++)
			{
				if (j == i)
				{
					continue;
				}

				float distance = GetVectorDistance(position, Bossgame6_SpawnedEntityPositions[j]);

				if (distance <= 100)
				{
					validPosition = false;
				}
			}
		}

		int entity = CreateEntityByName("prop_physics_override");

		if (IsValidEdict(entity))
		{
			// TODO: Random model here

			char buffer[64];
			bool hook = false;
			
			if (GetRandomInt(0, 2) == 2)
			{
				strcopy(buffer, sizeof(buffer), "models/props_farm/wooden_barrel.mdl");
				hook = true;
			}
			else
			{
				strcopy(buffer, sizeof(buffer), Bossgame6_RngModels[GetRandomInt(0, BOSSGAME6_RNGMODELS_COUNT-1)]);
			}
			
			DispatchKeyValue(entity, "model", buffer);
			DispatchSpawn(entity);

			TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);

			Bossgame6_Entity_IsBarrel[i] = hook;

			if (hook)
			{
				SDKHook(entity, SDKHook_OnTakeDamage, Bossgame6_Barrel_OnTakeDamage);
			}
		}

		Bossgame6_EntityIndexes[i] = entity;
	}
}

public Action Bossgame6_Barrel_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	Player player = new Player(attacker);

	if (player.IsValid)
	{
		PlaySoundToPlayer(player.ClientId, "ui/hitsound_retro1.wav");
		Bossgame6_PlayerScore[player.ClientId]++;

		SDKUnhook(victim, SDKHook_OnTakeDamage, Bossgame6_Barrel_OnTakeDamage);
		CreateParticle(victim, "bombinomicon_flash", 1.0);

		CreateTimer(0.05, Timer_RemoveEntity, victim);
		return Plugin_Continue;
	}
	else
	{
		damage = 0.0;
		return Plugin_Changed;
	}
}

public void Bossgame6_CleanupEntities()
{
	for (int i = 0; i < BOSSGAME6_ENTITYSPAWN_COUNT; i++)
	{
		int entity = Bossgame6_EntityIndexes[i];

		if (IsValidEdict(entity) && entity > MaxClients)
		{
			AcceptEntityInput(entity, "Kill");

			if (Bossgame6_Entity_IsBarrel[i]) 
			{
				SDKUnhook(entity, SDKHook_OnTakeDamage, Bossgame6_Barrel_OnTakeDamage);
			}
		}
	}
}

public void Bossgame6_SendDoorInput(const char[] input)
{
	int entity = -1;
	char entityName[32];
	
	while ((entity = FindEntityByClassname(entity, "func_door")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, "plugin_TPBoss_Door") == 0)
		{
			AcceptEntityInput(entity, input, -1, -1, -1);
			//break;
		}
	}
}

public void Bossgame6_ShowPlayerScores()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			int score = Bossgame6_PlayerScore[player.ClientId];

			for (int j = 1; j <= MaxClients; j++)
			{
				if (j == i)
				{
					continue;
				}

				Player annotationViewer = new Player(j);

				if (annotationViewer.IsInGame && !annotationViewer.IsBot)
				{
					char text[32];
					Format(text, sizeof(text), "%T", "Hud_Score_Barrels", j, score);

					annotationViewer.ShowAnnotation(player.ClientId, 2.0, text);
				}
			}
		}
	}
}

public void Bossgame6_OnRenderHudFrame(int client)
{
    if (g_iActiveBossgameId != 6)
    {
        return;
    }

    if (!g_bIsMinigameActive)
    {
        return;
    }

    Player player = new Player(client);

    if (!player.IsValid)
    {
        return;
    }

    char scoreText[32];

    Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Barrels", player.ClientId, Bossgame6_PlayerScore[player.ClientId]);

    if (g_iSpecialRoundId == 19)
    {
        char rewritten[32];
        ReverseString(scoreText, sizeof(scoreText), rewritten);
        strcopy(scoreText, sizeof(scoreText), rewritten);
    }

    player.SetCustomHudText(scoreText);
}