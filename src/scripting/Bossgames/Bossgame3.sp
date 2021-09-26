/**
 * MicroTF2 - Bossgame 3
 * 
 * Disappearing Blocks
 */

#define BOSSGAME3_STARTING_COUNTDOWN_DURATION 2.5
#define BOSSGAME3_COUNTDOWN_DECAY 0.15
#define BOSSGAME3_COUNTDOWN_LIMIT 1.25

#define BOSSGAME3_STARTING_INTERVAL_DURATION 2.0
#define BOSSGAME3_INTERVAL_DECAY 0.2
#define BOSSGAME3_INTERVAL_LIMIT 0.5

int g_iBossgame3TotalParticipantCount = 0;
int g_iBossgame3PlayerIndex = 0;

int g_iBossgame3SelectedBlockId = 0;
float g_fBossgame3CountdownDuration = BOSSGAME3_STARTING_COUNTDOWN_DURATION;
float g_fBossgame3IntervalDuration = BOSSGAME3_STARTING_INTERVAL_DURATION;

public void Bossgame3_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame3_OnMapStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame3_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame3_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Bossgame3_OnMinigameFinish);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Bossgame3_OnPlayerDeath);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame3_OnBossStopAttempt);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Bossgame3_OnPlayerTakeDamage);
}

public void Bossgame3_OnMapStart()
{
	PreloadSound("ui/hitsound_retro1.wav");
	PreloadSound("ui/killsound_retro.wav");
	PreloadSound(BOSSGAME_SFX_BBCOUNT);
}

public void Bossgame3_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId == 3)
	{
		g_bIsBlockingKillCommands = true;
		g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
		g_iBossgame3TotalParticipantCount = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				g_iBossgame3TotalParticipantCount++;
			}
		}

		g_fBossgame3CountdownDuration = BOSSGAME3_STARTING_COUNTDOWN_DURATION;
		g_fBossgame3IntervalDuration = BOSSGAME3_STARTING_INTERVAL_DURATION;
		CreateTimer(3.5, Bossgame3_BeginWarningSequence);
		Bossgame3_EnableBlocks();
	}
}

public void Bossgame3_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 3)
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
	player.Class = TFClass_Heavy;
	player.SetGodMode(false);
	player.ResetHealth();
	player.ResetWeapon(false);
	player.SetCollisionsEnabled(false);

	g_iBossgame3PlayerIndex++;

	float vel[3] = { 0.0, 0.0, 0.0 };
	int posa = 360 / g_iBossgame3TotalParticipantCount * (g_iBossgame3PlayerIndex-1);
	float pos[3];
	float ang[3];

	pos[0] = 6632.0 + (Cosine(DegToRad(float(posa)))*300.0);
	pos[1] = 754.0 - (Sine(DegToRad(float(posa)))*300.0);
	pos[2] = -606.0;

	ang[0] = 0.0;
	ang[1] = float(180-posa);
	ang[2] = 0.0;

	TeleportEntity(client, pos, ang, vel);
}

public void Bossgame3_OnPlayerDeath(int victimId, int attackerId)
{
	if (g_iActiveBossgameId != 3)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player victim = new Player(victimId);

	if (!victim.IsValid)
	{
		return;
	}

	victim.Status = PlayerStatus_Failed;
}

public void Bossgame3_OnMinigameFinish()
{
	if (g_iActiveBossgameId != 3)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsAlive && player.Status != PlayerStatus_Failed)
		{
			player.Status = PlayerStatus_Winner;
		}
	}
}

public void Bossgame3_OnBossStopAttempt()
{
	if (g_iActiveBossgameId != 3)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	int alivePlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.IsAlive)
		{
			alivePlayers++;
		}
	}

	if (alivePlayers <= 1)
	{
		EndBoss();
	}
}

public DamageBlockResults Bossgame3_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_iActiveBossgameId != 3)
	{
		return EDamageBlockResult_DoNothing;
	}

	if (!g_bIsMinigameActive)
	{
		return EDamageBlockResult_DoNothing;
	}

	Player attacker = new Player(attackerId);
	Player victim = new Player(victimId);

	if (attacker.IsValid && victim.IsValid)
	{
		float vel[3];

		GetEntPropVector(victimId, Prop_Data, "m_vecVelocity", vel);

		vel[0] -= vel[0] * 0.5;
		vel[1] -= vel[1] * 0.5;
		vel[2] -= vel[2] * 0.5;

		TeleportEntity(victimId, NULL_VECTOR, NULL_VECTOR, vel);
	}

	return EDamageBlockResult_DoNothing;
}


public Action Bossgame3_BeginWarningSequence(Handle timer)
{
	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}

	if (g_iActiveBossgameId != 3)
	{
		return Plugin_Handled;
	}

	g_iBossgame3SelectedBlockId = GetRandomInt(1, 9);

	Bossgame3_HighlightSelectedBlock();
	PlaySoundToAll("ui/hitsound_retro1.wav");

	CreateTimer(g_fBossgame3CountdownDuration, Bossgame3_BeginSwitchSequence);
	CreateTimer(g_fBossgame3CountdownDuration * 0.2, Bossgame3_DoTickSfx);
	CreateTimer(g_fBossgame3CountdownDuration * 0.4, Bossgame3_DoTickSfx);
	CreateTimer(g_fBossgame3CountdownDuration * 0.6, Bossgame3_DoTickSfx);
	CreateTimer(g_fBossgame3CountdownDuration * 0.8, Bossgame3_DoTickSfx);
	return Plugin_Handled;
}

public Action Bossgame3_BeginSwitchSequence(Handle timer)
{
	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}

	if (g_iActiveBossgameId != 3)
	{
		return Plugin_Handled;
	}

	Bossgame3_DisableBlocks();
	
	PlaySoundToAll("ui/killsound_retro.wav");

	CreateTimer(2.0, Bossgame3_BeginIntervalSequence);
	g_fBossgame3CountdownDuration -= BOSSGAME3_COUNTDOWN_DECAY;
	g_fBossgame3IntervalDuration -= BOSSGAME3_INTERVAL_DECAY;

	if (g_fBossgame3CountdownDuration <= BOSSGAME3_COUNTDOWN_LIMIT)
	{
		g_fBossgame3CountdownDuration = BOSSGAME3_COUNTDOWN_LIMIT;
	}

	if (g_fBossgame3IntervalDuration <= BOSSGAME3_INTERVAL_LIMIT)
	{
		g_fBossgame3IntervalDuration = BOSSGAME3_INTERVAL_LIMIT;
	}

	return Plugin_Handled;
}

public Action Bossgame3_BeginIntervalSequence(Handle timer)
{
	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}

	if (g_iActiveBossgameId != 3)
	{
		return Plugin_Handled;
	}

	Bossgame3_EnableBlocks();

	CreateTimer(g_fBossgame3IntervalDuration, Bossgame3_BeginWarningSequence);
	return Plugin_Handled;
}

public Action Bossgame3_DoTickSfx(Handle timer)
{
	PlaySoundToAll(BOSSGAME_SFX_BBCOUNT);
	return Plugin_Handled;
}

void Bossgame3_HighlightSelectedBlock()
{
	for (int i = 1; i <= 9; i++)
	{
		if (g_iBossgame3SelectedBlockId == i)
		{
			Bossgame3_DoHighlightBlock(i);
		}
		else
		{
			Bossgame3_DoUnhighlightBlock(i);
		}
	}
}

void Bossgame3_DisableBlocks()
{
	for (int i = 1; i <= 9; i++)
	{
		if (g_iBossgame3SelectedBlockId == i)
		{
			Bossgame3_DoHighlightBlock(i);
		}
		else
		{
			Bossgame3_DoDisableBlock(i);
		}
	}
}

void Bossgame3_EnableBlocks()
{
	for (int i = 1; i <= 9; i++)
	{
		Bossgame3_DoUnhighlightBlock(i);
	}
}

void Bossgame3_DoDisableBlock(int blockId)
{
	Bossgame3_SendUnselectedBlockInput(blockId, "Disable");
	Bossgame3_SendSelectedBlockInput(blockId, "Disable");
}

void Bossgame3_DoHighlightBlock(int blockId)
{
	Bossgame3_SendUnselectedBlockInput(blockId, "Disable");
	Bossgame3_SendSelectedBlockInput(blockId, "Enable");
}

void Bossgame3_DoUnhighlightBlock(int blockId)
{
	Bossgame3_SendUnselectedBlockInput(blockId, "Enable");
	Bossgame3_SendSelectedBlockInput(blockId, "Disable");
}

void Bossgame3_SendUnselectedBlockInput(int blockId, const char[] input)
{
	char name[32];
	Format(name, sizeof(name), "plugin_Bossgame3_C%i", blockId);
	Bossgame3_SendBlockInput(name, input);
}

void Bossgame3_SendSelectedBlockInput(int blockId, const char[] input)
{
	char name[32];
	Format(name, sizeof(name), "plugin_Bossgame3_B%i", blockId);
	Bossgame3_SendBlockInput(name, input);
}

void Bossgame3_SendBlockInput(const char[] name, const char[] input)
{
	int entity = -1;
	char entityName[32];

	while ((entity = FindEntityByClassname(entity, "func_brush")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, name) == 0)
		{
			AcceptEntityInput(entity, input, -1, -1, -1);
		}
	}
}