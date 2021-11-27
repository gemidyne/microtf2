/**
 * MicroTF2 - Bossgame 6
 * 
 * Target Practice Arena
 */

#define BOSSGAME6_ENTITYSPAWN_COUNT 32

int g_iBossgame6Entities[BOSSGAME6_ENTITYSPAWN_COUNT];
bool g_bBossgame6IsEntityBarrel[BOSSGAME6_ENTITYSPAWN_COUNT];

int g_iBossgame6Timer = 6;
int g_iBossgame6ParticipatingPlayerCount;
int g_iBossgame6PlayerScore[MAXPLAYERS+1];
char g_sBossgame6EntityModels[][] =
{
	"models/props_hydro/keg_large.mdl",
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_farm/tractor_tire001.mdl",
	"models/props_farm/spool_rope.mdl",
	"models/props_farm/spool_wire.mdl",
	"models/props_gameplay/haybale.mdl",
	"models/props_2fort/milkjug001.mdl",
	"models/props_spytech/watercooler.mdl",
	"models/props_mvm/clipboard.mdl"
};

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
	for (int i = 0; i < sizeof(g_sBossgame6EntityModels); i++)
	{
		PrecacheModel(g_sBossgame6EntityModels[i]);
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
			g_iBossgame6Entities[i] = 0;
		}

		for (int i = 0; i < MAXPLAYERS; i++)
		{
			g_iBossgame6PlayerScore[i] = 0;
		}

		g_iBossgame6ParticipatingPlayerCount = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				g_iBossgame6ParticipatingPlayerCount++;
			}
		}
		
		g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
		g_bIsBlockingKillCommands = true;

		Bossgame6_SendDoorInput("Close");

		g_iBossgame6Timer = 5;
		CreateTimer(1.0, Bossgame6_SwitchTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
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
	int posa = 360 / g_iBossgame6ParticipatingPlayerCount * client;
	float pos[3];
	float ang[3];

	pos[0] = -2943.0 + (Cosine(DegToRad(float(posa))) * 768.0);
	pos[1] = 1791.0 - (Sine(DegToRad(float(posa))) * 768.0);
	pos[2] = -1098.0;

	ang[0] = 0.0;
	ang[1] = float(180 - posa);
	ang[2] = 0.0;

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

			if (player.IsValid && player.IsParticipating && g_iBossgame6PlayerScore[player.ClientId] > threshold)
			{
				threshold = g_iBossgame6PlayerScore[player.ClientId];
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
		switch (g_iBossgame6Timer)
		{
			case 5: 
			{
				Bossgame6_SendDoorInput("Close");
				Bossgame6_ShowPlayerScores();
			}
				
			case 4: 
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

			case 3: 
			{
				Bossgame6_SendDoorInput("Open");
			}

			case 0:
			{
				g_iBossgame6Timer = 6;
			}
		}

		g_iBossgame6Timer--;
		return Plugin_Continue;
	}

	g_iBossgame6Timer = 6;
	return Plugin_Stop; 
}

public void Bossgame6_DoEntitySpawns()
{
	float positions[BOSSGAME6_ENTITYSPAWN_COUNT][3];
	int barrelCount = 0;
	int minimumBarrelCount = GetRandomInt(1, 3) == 2 && g_iBossgame6ParticipatingPlayerCount < BOSSGAME6_ENTITYSPAWN_COUNT
		? g_iBossgame6ParticipatingPlayerCount
		: g_iBossgame6ParticipatingPlayerCount / 2;

	if (minimumBarrelCount < 1)
	{
		minimumBarrelCount = 1;
	}

	int count = GetRandomInt(minimumBarrelCount, BOSSGAME6_ENTITYSPAWN_COUNT);

	for (int i = 0; i < count; i++)
	{
		bool validPosition = false;
		float position[3];
		float angle[3];
		int calculationAttempts = 0;

		while (!validPosition)
		{
			validPosition = true;
			calculationAttempts++;

			if (calculationAttempts > 32)
			{
				return;
			}

			int posa = 360 / BOSSGAME6_ENTITYSPAWN_COUNT * GetRandomInt(1, 32);
			float outer = GetRandomFloat(64.0, 512.0);

			position[0] = -2943.0 + (Cosine(DegToRad(float(posa))) * outer);
			position[1] = 1791.0 - (Sine(DegToRad(float(posa))) * outer);
			position[2] = -1381.0;

			angle[0] = 0.0;
			angle[1] = float(180 - posa);
			angle[2] = 0.0;

			for (int j = 0; j < BOSSGAME6_ENTITYSPAWN_COUNT; j++)
			{
				if (j == i)
				{
					continue;
				}

				float distance = GetVectorDistance(position, positions[j]);

				if (distance <= 100.0)
				{
					validPosition = false;
				}
			}
		}

		int entity = CreateEntityByName("prop_physics_override");

		if (IsValidEdict(entity))
		{
			char buffer[64];
			bool hook = false;
			
			if (barrelCount < minimumBarrelCount)
			{
				strcopy(buffer, sizeof(buffer), "models/props_farm/wooden_barrel.mdl");
				hook = true;
				barrelCount++;
			}
			else
			{
				strcopy(buffer, sizeof(buffer), g_sBossgame6EntityModels[GetRandomInt(0, sizeof(g_sBossgame6EntityModels)-1)]);
			}
			
			DispatchKeyValue(entity, "model", buffer);
			DispatchSpawn(entity);

			TeleportEntity(entity, position, angle, NULL_VECTOR);

			positions[i] = position;
			g_bBossgame6IsEntityBarrel[i] = hook;

			if (hook)
			{
				SDKHook(entity, SDKHook_OnTakeDamage, Bossgame6_Barrel_OnTakeDamage);
			}
		}

		g_iBossgame6Entities[i] = entity;
	}
}

public Action Bossgame6_Barrel_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	Player player = new Player(attacker);

	if (player.IsValid)
	{
		PlaySoundToPlayer(player.ClientId, "ui/hitsound_retro1.wav");
		g_iBossgame6PlayerScore[player.ClientId]++;

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
		int entity = g_iBossgame6Entities[i];

		if (IsValidEdict(entity) && entity > MaxClients)
		{
			AcceptEntityInput(entity, "Kill");

			if (g_bBossgame6IsEntityBarrel[i]) 
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
			int score = g_iBossgame6PlayerScore[player.ClientId];

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

    Format(scoreText, sizeof(scoreText), "%T", "Hud_Score_Barrels", player.ClientId, g_iBossgame6PlayerScore[player.ClientId]);

    if (g_iSpecialRoundId == 19)
    {
        char rewritten[32];
        ReverseString(scoreText, sizeof(scoreText), rewritten);
        strcopy(scoreText, sizeof(scoreText), rewritten);
    }

    player.SetCustomHudText(scoreText);
}