/**
 * MicroTF2 - Bossgame 4
 * 
 * Smash Arena
 */

#define BOSSGAME4_SFX_SMALLHIT_FORMATTABLE "gemidyne/warioware/{version}/bosses/sfx/ff_small%d.mp3"
#define BOSSGAME4_SFX_SMALLHIT1 "gemidyne/warioware/{version}/bosses/sfx/ff_small1.mp3"
#define BOSSGAME4_SFX_SMALLHIT2 "gemidyne/warioware/{version}/bosses/sfx/ff_small2.mp3"

#define BOSSGAME4_SFX_MEDIUMHIT_FORMATTABLE "gemidyne/warioware/{version}/bosses/sfx/ff_mod%d.mp3"
#define BOSSGAME4_SFX_MEDIUMHIT1 "gemidyne/warioware/{version}/bosses/sfx/ff_mod1.mp3"
#define BOSSGAME4_SFX_MEDIUMHIT2 "gemidyne/warioware/{version}/bosses/sfx/ff_mod2.mp3"

#define BOSSGAME4_SFX_STRONGHIT_FORMATTABLE "gemidyne/warioware/{version}/bosses/sfx/ff_stro%d.mp3"
#define BOSSGAME4_SFX_STRONGHIT1 "gemidyne/warioware/{version}/bosses/sfx/ff_stro1.mp3"
#define BOSSGAME4_SFX_STRONGHIT2 "gemidyne/warioware/{version}/bosses/sfx/ff_stro2.mp3"

float g_fBossgame4PlayerDamageAccumulated[MAXPLAYERS];

public void Bossgame4_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Bossgame4_OnMapStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Bossgame4_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Bossgame4_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Bossgame4_OnMinigameFinish);
	AddToForward(g_pfOnPlayerDeath, INVALID_HANDLE, Bossgame4_OnPlayerDeath);
	AddToForward(g_pfOnPlayerTakeDamage, INVALID_HANDLE, Bossgame4_OnPlayerTakeDamage);
	AddToForward(g_pfOnBossStopAttempt, INVALID_HANDLE, Bossgame4_OnBossStopAttempt);
}

public void Bossgame4_OnMapStart()
{
	PreloadSound(BOSSGAME4_SFX_SMALLHIT1);
	PreloadSound(BOSSGAME4_SFX_SMALLHIT2);
	PreloadSound(BOSSGAME4_SFX_MEDIUMHIT1);
	PreloadSound(BOSSGAME4_SFX_MEDIUMHIT2);
	PreloadSound(BOSSGAME4_SFX_STRONGHIT1);
	PreloadSound(BOSSGAME4_SFX_STRONGHIT2);
}

public void Bossgame4_OnMinigameSelectedPre()
{
	if (g_iActiveBossgameId != 4)
	{
		return;
	}

	g_bIsBlockingKillCommands = true;
	g_eDamageBlockMode = EDamageBlockMode_AllPlayers;
}

public void Bossgame4_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 4)
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

	player.SetRandomClass();

	while (player.Class == TFClass_Scout || player.Class == TFClass_Spy)
	{
		player.SetRandomClass();
	}

	player.SetGodMode(false);
	player.SetHealth(1000);
	player.ResetWeapon(true);

	g_fBossgame4PlayerDamageAccumulated[player.ClientId] = 175.0;

	float vel[3] = { 0.0, 0.0, 0.0 };
	float pos[3];

	int column = client;
	int row = 0;
	while (column > 6)
	{
		column = column - 6;
		row = row + 1;
	}

	pos[0] = -863.0 + float(row*80);
	pos[1] = 190.0 + float(column*80);
	pos[2] = -1345.0;

	TeleportEntity(client, pos, NULL_VECTOR, vel);

	float center[3] = { -699.0, 440.0, -1275.0 };
	float angle[3];
	float direction[3];

	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, angle);

	MakeVectorFromPoints(pos, center, direction);
	GetVectorAngles(direction, direction);

	angle[0] += NormalizeAngle(direction[0] - angle[0]);
	angle[1] += NormalizeAngle(direction[1] - angle[1]);

	TeleportEntity(client, NULL_VECTOR, angle, vel);
}

public void Bossgame4_OnPlayerDeath(int victim, int attacker)
{
	if (g_iActiveBossgameId != 4)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	Player player = new Player(victim);
	
	if (player.IsValid)
	{
		player.Status = PlayerStatus_Failed;

		CreateTimer(0.05, Bossgame4_OnPlayerDeathTimer, victim);
	}
}

public Action Bossgame4_OnPlayerDeathTimer(Handle timer, int client)
{
	if (g_iActiveBossgameId != 4)
	{
		return Plugin_Handled;
	}

	if (!g_bIsMinigameActive)
	{
		return Plugin_Handled;
	}

	Player player = new Player(client);

	if (player.IsValid)
	{
		player.Respawn();
		player.SetGodMode(true);
		player.ResetHealth();

		if (player.Team == TFTeam_Red)
		{
			float pos[3] = { -1354.0, 464.0, -860.0 };
			float ang[3] = { 0.0, 180.0, 0.0 };

			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}
		else 
		{
			float pos[3] = { 10.0, 464.0, -860.0 };
			float ang[3] = { 0.0, 0.0, 0.0 };

			TeleportEntity(client, pos, ang, NULL_VECTOR);
		}
	}

	return Plugin_Handled;
}

public DamageBlockResults Bossgame4_OnPlayerTakeDamage(int victimId, int attackerId, float damage, int damageCustom)
{
	if (g_iActiveBossgameId != 4)
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
		if (victim.Health >= 1)
		{
			victim.Health -= RoundToFloor(damage);

			if (victim.Health < 1)
			{
				victim.Health = 1;
			}
		}

		g_fBossgame4PlayerDamageAccumulated[victim.ClientId] += damage;

		float ang[3];
		float vel[3];

		GetClientEyeAngles(attackerId, ang);
		GetEntPropVector(victimId, Prop_Data, "m_vecVelocity", vel);

		float baseVelocity = g_fBossgame4PlayerDamageAccumulated[victim.ClientId];
		float baseVelocityZ = g_fBossgame4PlayerDamageAccumulated[victim.ClientId];

		vel[0] -= baseVelocity * Cosine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[1] -= baseVelocity * Sine(DegToRad(ang[1])) * -1.0 * damage*0.01;
		vel[2] += baseVelocityZ;

		TeleportEntity(victimId, NULL_VECTOR, NULL_VECTOR, vel);

		char path[64];

		if (g_fBossgame4PlayerDamageAccumulated[victim.ClientId] < 300.0)
		{
			Format(path, sizeof(path), BOSSGAME4_SFX_SMALLHIT_FORMATTABLE, GetRandomInt(1, 2));
		}
		else if (g_fBossgame4PlayerDamageAccumulated[victim.ClientId] >= 300.0 && g_fBossgame4PlayerDamageAccumulated[victim.ClientId] < 450.0)
		{
			Format(path, sizeof(path), BOSSGAME4_SFX_MEDIUMHIT_FORMATTABLE, GetRandomInt(1, 2));
		}
		else
		{
			Format(path, sizeof(path), BOSSGAME4_SFX_STRONGHIT_FORMATTABLE, GetRandomInt(1, 2));
		}

		char rewritten[MAX_PATH_LENGTH];
		Sounds_ConvertTokens(path, rewritten, sizeof(rewritten));
		EmitSoundToAll(rewritten, victim.ClientId, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
	}

	return EDamageBlockResult_DoNothing;
}

public void Bossgame4_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveBossgameId == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status != PlayerStatus_Failed)
			{
				player.Status = PlayerStatus_Winner;
			}
		}
	}
}

public void Bossgame4_OnBossStopAttempt()
{
	if (g_bIsMinigameActive && g_iActiveBossgameId == 4)
	{
		int alivePlayers = 0;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsAlive && player.IsParticipating && player.Status != PlayerStatus_Failed)
			{
				alivePlayers++;
			}
		}

		if (alivePlayers <= 1)
		{
			EndBoss();
		}
	}
}