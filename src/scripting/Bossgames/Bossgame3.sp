/**
 * MicroTF2 - Bossgame 3
 * 
 * Floor Break boss
 */

int Bossgame3_TotalParticipants = 0;
int Bossgame3_PlayerIndex = 0;

int Bossgame3_SelectedBlockId = 0;

public void Bossgame3_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Bossgame3_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Bossgame3_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Bossgame3_OnMinigameFinish);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Bossgame3_OnPlayerDeath);
	AddToForward(GlobalForward_OnBossStopAttempt, INVALID_HANDLE, Bossgame3_OnBossStopAttempt);
}

public void Bossgame3_OnMinigameSelectedPre()
{
	if (BossgameID == 3)
	{
		IsBlockingDeathCommands = true;
		DamageBlockMode = EDamageBlockMode_AllPlayers;
		Bossgame3_TotalParticipants = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				Bossgame3_TotalParticipants++;
			}
		}

		CreateTimer(3.5, Bossgame3_BeginWarningSequence);
	}
}

public void Bossgame3_OnMinigameSelected(int client)
{
	if (BossgameID != 3)
	{
		return;
	}

	if (!IsMinigameActive)
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
	player.SetCollisionsEnabled(true);

	Bossgame3_PlayerIndex++;

	float vel[3] = { 0.0, 0.0, 0.0 };
	int posa = 360 / Bossgame3_TotalParticipants * (Bossgame3_PlayerIndex-1);
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
	if (BossgameID != 3)
	{
		return;
	}

	if (!IsMinigameActive)
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
	if (BossgameID != 3)
	{
		return;
	}

	if (!IsMinigameActive)
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
	if (BossgameID != 3)
	{
		return;
	}

	if (!IsMinigameActive)
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

public Action Bossgame3_BeginWarningSequence(Handle timer)
{
	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	if (BossgameID != 3)
	{
		return Plugin_Handled;
	}

	Bossgame3_SelectedBlockId = GetRandomInt(1, 9);

	Bossgame3_HighlightSelectedBlock();

	CreateTimer(3.0, Bossgame3_BeginSwitchSequence);
	return Plugin_Handled;
}

public Action Bossgame3_BeginSwitchSequence(Handle timer)
{
	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	if (BossgameID != 3)
	{
		return Plugin_Handled;
	}

	Bossgame3_DisableBlocks();

	CreateTimer(2.0, Bossgame3_BeginIntervalSequence);
	return Plugin_Handled;
}

public Action Bossgame3_BeginIntervalSequence(Handle timer)
{
	if (!IsMinigameActive)
	{
		return Plugin_Handled;
	}

	if (BossgameID != 3)
	{
		return Plugin_Handled;
	}

	Bossgame3_EnableBlocks();

	CreateTimer(3.0, Bossgame3_BeginWarningSequence);
	return Plugin_Handled;
}

void Bossgame3_HighlightSelectedBlock()
{
	for (int i = 1; i <= 9; i++)
	{
		if (Bossgame3_SelectedBlockId == i)
		{
			Bossgame3_DoHighlightBlock(Bossgame3_SelectedBlockId);
		}
		else
		{
			Bossgame3_DoUnhighlightBlock(Bossgame3_SelectedBlockId);
		}
	}
}

void Bossgame3_DisableBlocks()
{
	for (int i = 1; i <= 9; i++)
	{
		if (Bossgame3_SelectedBlockId == i)
		{
			Bossgame3_DoHighlightBlock(Bossgame3_SelectedBlockId);
		}
		else
		{
			Bossgame3_DoDisableBlock(Bossgame3_SelectedBlockId);
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
	Format(name, sizeof(name), "plugin_Bossgame3_B%i", blockId);
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
			break;
		}
	}
}