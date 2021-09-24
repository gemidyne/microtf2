/*
 * MicroTF2 - Minigame 18
 * 
 * Hit the Target!
 */

char g_sMinigame18TargetModels[][] = 
{
	"models/props_training/target_scout.mdl",
	"models/props_training/target_soldier.mdl",
	"models/props_training/target_pyro.mdl",
	"models/props_training/target_demoman.mdl",
	"models/props_training/target_heavy.mdl",
	"models/props_training/target_engineer.mdl",
	"models/props_training/target_medic.mdl",
	"models/props_training/target_sniper.mdl",
	"models/props_training/target_spy.mdl"
};

char g_sMinigame18ScoutHurtSfx[][] =
{
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
	"vo/scout_painsevere01.mp3",
	"vo/scout_painsevere02.mp3",
	"vo/scout_painsevere03.mp3",
	"vo/scout_painsevere04.mp3",
	"vo/scout_painsevere05.mp3",
	"vo/scout_painsevere06.mp3"
};

char g_sMinigame18SoldierHurtSfx[][] =
{
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3",
	"vo/soldier_painsevere01.mp3",
	"vo/soldier_painsevere02.mp3",
	"vo/soldier_painsevere03.mp3",
	"vo/soldier_painsevere04.mp3",
	"vo/soldier_painsevere05.mp3",
	"vo/soldier_painsevere06.mp3"
};

char g_sMinigame18PyroHurtSfx[][] =
{
	"vo/pyro_painsevere01.mp3",
	"vo/pyro_painsevere02.mp3",
	"vo/pyro_painsevere03.mp3",
	"vo/pyro_painsevere04.mp3",
	"vo/pyro_painsevere05.mp3",
	"vo/pyro_painsevere06.mp3",
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3",
	"vo/pyro_painsharp06.mp3",
	"vo/pyro_painsharp07.mp3"
};

char g_sMinigame18DemoManHurtSfx[][] =
{
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3",
	"vo/demoman_painsevere01.mp3",
	"vo/demoman_painsevere02.mp3",
	"vo/demoman_painsevere03.mp3",
	"vo/demoman_painsevere04.mp3"
};

char g_sMinigame18HeavyHurtSfx[][] =
{
	"vo/heavy_painsevere01.mp3",
	"vo/heavy_painsevere02.mp3",
	"vo/heavy_painsevere03.mp3",
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};

char g_sMinigame18EngineerHurtSfx[][] =
{
	"vo/engineer_painsevere01.mp3",
	"vo/engineer_painsevere02.mp3",
	"vo/engineer_painsevere03.mp3",
	"vo/engineer_painsevere04.mp3",
	"vo/engineer_painsevere05.mp3",
	"vo/engineer_painsevere06.mp3",
	"vo/engineer_painsevere07.mp3",
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3"
};

char g_sMinigame18SniperHurtSfx[][] =
{
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
	"vo/sniper_painsevere01.mp3",
	"vo/sniper_painsevere02.mp3",
	"vo/sniper_painsevere03.mp3",
	"vo/sniper_painsevere04.mp3"
};

char g_sMinigame18MedicHurtSfx[][] = 
{
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
	"vo/medic_painsharp05.mp3",
	"vo/medic_painsharp06.mp3",
	"vo/medic_painsharp07.mp3",
	"vo/medic_painsharp08.mp3",
	"vo/medic_painsevere01.mp3",
	"vo/medic_painsevere02.mp3",
	"vo/medic_painsevere03.mp3",
	"vo/medic_painsevere04.mp3"
};

char g_sMinigame18SpyHurtSfx[][] =
{
	"vo/spy_painsevere01.mp3",
	"vo/spy_painsevere02.mp3",
	"vo/spy_painsevere03.mp3",
	"vo/spy_painsevere04.mp3",
	"vo/spy_painsevere05.mp3",
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

int g_iMinigame18TargetEntity = -1;
int g_iMinigame18SelectedTargetModel = 0;

public void Minigame18_EntryPoint()
{
	AddToForward(g_pfOnMapStart, INVALID_HANDLE, Minigame18_OnMapStart);
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, Minigame18_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, Minigame18_OnMinigameSelected);
	AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, Minigame18_OnMinigameFinish);
}

public void Minigame18_OnMapStart()
{
	for (int i = 0; i < sizeof(g_sMinigame18TargetModels); i++)
	{
		PrecacheModel(g_sMinigame18TargetModels[i], true);
	}

	for (int i = 0; i < sizeof(g_sMinigame18ScoutHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18ScoutHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18SoldierHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18SoldierHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18PyroHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18PyroHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18DemoManHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18DemoManHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18HeavyHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18HeavyHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18EngineerHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18EngineerHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18SniperHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18SniperHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18MedicHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18MedicHurtSfx[i]);
	}

	for (int i = 0; i < sizeof(g_sMinigame18SpyHurtSfx); i++)
	{
		PreloadSound(g_sMinigame18SpyHurtSfx[i]);
	}
}

public void Minigame18_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 18)
	{
		g_iMinigame18TargetEntity = CreateEntityByName("prop_physics");

		if (IsValidEntity(g_iMinigame18TargetEntity))
		{
			g_iMinigame18SelectedTargetModel = GetRandomInt(0, sizeof(g_sMinigame18TargetModels)-1);

			char skin[4];
			Format(skin, sizeof(skin), "%i", GetRandomInt(0, 1));

			DispatchKeyValue(g_iMinigame18TargetEntity, "model", g_sMinigame18TargetModels[g_iMinigame18SelectedTargetModel]);
			DispatchKeyValue(g_iMinigame18TargetEntity, "skin", skin);
			DispatchSpawn(g_iMinigame18TargetEntity);

			SetEntityMoveType(g_iMinigame18TargetEntity, MOVETYPE_NONE);   

			SDKHook(g_iMinigame18TargetEntity, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage2);
			
			float pos[3];
			float ang[3] = { 0.0, -90.0, 0.0 };

			pos[0] = GetRandomFloat(10240.0, 12322.0);
			pos[1] = GetRandomFloat(7845.0, 8969.0);
			pos[2] = -330.0;

			if (IsValidEntity(g_iMinigame18TargetEntity))
			{
				TeleportEntity(g_iMinigame18TargetEntity, pos, ang, NULL_VECTOR);
				CreateParticle(g_iMinigame18TargetEntity, "bombinomicon_flash", 1.0);
			}
		}
	}
}

public void Minigame18_OnMinigameSelected(int client)
{
	if (g_iActiveMinigameId != 18)
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
		player.RemoveAllWeapons();
		player.Class = TFClass_Sniper;

		player.GiveWeapon(14);
		player.SetWeaponPrimaryAmmoCount(25);

		float vel[3] = { 0.0, 0.0, 0.0 };
		float ang[3] = { 0.0, 90.0, 0.0 };
		float pos[3];

		int column = client;
		int row = 0;

		pos[0] = 10406.0 + float(column*60); 
		pos[1] = 7100.0 - float(row*100);
		pos[2] = -260.0;

		TeleportEntity(client, pos, ang, vel);
		SDKHook(client, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage);
	}
}

public void Minigame18_OnMinigameFinish()
{
	if (g_iActiveMinigameId == 18 && g_bIsMinigameActive)
	{
		SDKUnhook(g_iMinigame18TargetEntity, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage2);

		if (IsValidEntity(g_iMinigame18TargetEntity))
		{
			AcceptEntityInput(g_iMinigame18TargetEntity, "Kill");
		}

		g_iMinigame18TargetEntity = -1;

		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Respawn();
				SDKUnhook(i, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage);
			}
		}
	}
}


public Action Minigame18_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	damage = 0.0;
	Minigame18_HitTarget(attacker);
	return Plugin_Changed;
}

public Action Minigame18_OnTakeDamage2(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	damage = 0.0;
	Minigame18_HitTarget(attacker);
	return Plugin_Changed;
}

public void Minigame18_HitTarget(int attacker)
{
	Player player = new Player(attacker);

	if (player.IsValid)
	{
		player.TriggerSuccess();

		switch (g_iMinigame18SelectedTargetModel)
		{
			case 0: Minigame18_PlayScoutHurtSfx(attacker);
			case 1: Minigame18_PlaySoldierHurtSfx(attacker);
			case 2: Minigame18_PlayPyroHurtSfx(attacker);
			case 3: Minigame18_PlayDemoHurtSfx(attacker);
			case 4: Minigame18_PlayHeavyHurtSfx(attacker);
			case 5: Minigame18_PlayEngineerHurtSfx(attacker);
			case 6: Minigame18_PlayMedicHurtSfx(attacker);
			case 7: Minigame18_PlaySniperHurtSfx(attacker);
			case 8: Minigame18_PlaySpyHurtSfx(attacker);
		}
	}
}

void Minigame18_PlayScoutHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18ScoutHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18ScoutHurtSfx)-1)]);
}

void Minigame18_PlaySoldierHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18SoldierHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18SoldierHurtSfx)-1)]);
}

void Minigame18_PlayPyroHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18PyroHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18PyroHurtSfx)-1)]);
}

void Minigame18_PlayDemoHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18DemoManHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18DemoManHurtSfx)-1)]);
}

void Minigame18_PlayHeavyHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18HeavyHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18HeavyHurtSfx)-1)]);
}

void Minigame18_PlayEngineerHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18EngineerHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18EngineerHurtSfx)-1)]);
}

void Minigame18_PlayMedicHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18MedicHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18MedicHurtSfx)-1)]);
}

void Minigame18_PlaySniperHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18SniperHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18SniperHurtSfx)-1)]);
}

void Minigame18_PlaySpyHurtSfx(int attacker)
{
	PlaySoundToPlayer(attacker, g_sMinigame18SpyHurtSfx[GetRandomInt(0, sizeof(g_sMinigame18SpyHurtSfx)-1)]);
}

public void DoSniperDamageCheck(int client, int weapon, char[] weaponname)
{
	if (strncmp(weaponname, "tf_weapon_sniperrifle", 21, false) != 0) return;

	float pos[3];
	float dist;

	int target = GetClientAimEntity3(client, dist, pos);

	if (target <= 0 || !IsValidEdict(target)) return;
	if (dist > 8192) return;

	char classname[32];
	GetEdictClassname(target, classname, sizeof(classname));

	if (StrContains(classname, "pumpkin", false) == -1 && StrContains(classname, "breakable", false) == -1 && StrContains(classname, "physics", false) == -1 && StrContains(classname, "physbox", false) == -1 && StrContains(classname, "button", false) == -1)
	{
		return;
	}

	Minigame18_HitTarget(client);
}