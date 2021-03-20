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
	for (int i = 0; i < 4; i++)
	{
		PrecacheModel(g_sMinigame18TargetModels[i], true);
	}

	char buffer[32];

	for (int i = 1; i < 9; i++)
	{
		Format(buffer, sizeof(buffer), "vo/scout_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/medic_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);
	}

	for (int i = 1; i < 8; i++)
	{
		Format(buffer, sizeof(buffer), "vo/demoman_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);
	}

	for (int i = 1; i < 7; i++)
	{
		Format(buffer, sizeof(buffer), "vo/scout_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);
	}

	for (int i = 1; i < 5; i++)
	{
		Format(buffer, sizeof(buffer), "vo/demoman_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/sniper_painsharp0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/sniper_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);

		Format(buffer, sizeof(buffer), "vo/medic_painsevere0%d.mp3", i);
		PrecacheSound(buffer, true);
	}
}

public void Minigame18_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 18)
	{
		g_iMinigame18TargetEntity = CreateEntityByName("prop_physics");

		if (IsValidEntity(g_iMinigame18TargetEntity))
		{
			g_iMinigame18SelectedTargetModel = GetRandomInt(0,3);

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
			case 0: PlayScoutHurtSound(attacker);
			case 1: PlayDemoHurtSound(attacker);
			case 2: PlaySniperHurtSound(attacker);
			case 3: PlayMedicHurtSound(attacker);
		}
	}
}

public void PlayScoutHurtSound(int attacker)
{
	switch (GetRandomInt(0, 13))
	{
		case 0: EmitSoundToClient(attacker, "vo/scout_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/scout_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/scout_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/scout_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/scout_painsharp05.mp3");
		case 5: EmitSoundToClient(attacker, "vo/scout_painsharp06.mp3");
		case 6: EmitSoundToClient(attacker, "vo/scout_painsharp07.mp3");
		case 7: EmitSoundToClient(attacker, "vo/scout_painsharp08.mp3");
		case 8: EmitSoundToClient(attacker, "vo/scout_painsevere01.mp3");
		case 9: EmitSoundToClient(attacker, "vo/scout_painsevere02.mp3");
		case 10: EmitSoundToClient(attacker, "vo/scout_painsevere03.mp3");
		case 11: EmitSoundToClient(attacker, "vo/scout_painsevere04.mp3");
		case 12: EmitSoundToClient(attacker, "vo/scout_painsevere05.mp3");
		case 13: EmitSoundToClient(attacker, "vo/scout_painsevere06.mp3");
	}
}

public void PlayDemoHurtSound(int attacker)
{
	switch (GetRandomInt(0, 10))
	{
		case 0: EmitSoundToClient(attacker, "vo/demoman_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/demoman_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/demoman_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/demoman_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/demoman_painsharp05.mp3");
		case 5: EmitSoundToClient(attacker, "vo/demoman_painsharp06.mp3");
		case 6: EmitSoundToClient(attacker, "vo/demoman_painsharp07.mp3");
		case 7: EmitSoundToClient(attacker, "vo/demoman_painsevere01.mp3");
		case 8: EmitSoundToClient(attacker, "vo/demoman_painsevere02.mp3");
		case 9: EmitSoundToClient(attacker, "vo/demoman_painsevere03.mp3");
		case 10: EmitSoundToClient(attacker, "vo/demoman_painsevere04.mp3");
	}
}

public void PlaySniperHurtSound(int attacker)
{
	switch (GetRandomInt(0, 7))
	{
		case 0: EmitSoundToClient(attacker, "vo/sniper_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/sniper_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/sniper_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/sniper_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/sniper_painsevere01.mp3");
		case 5: EmitSoundToClient(attacker, "vo/sniper_painsevere02.mp3");
		case 6: EmitSoundToClient(attacker, "vo/sniper_painsevere03.mp3");
		case 7: EmitSoundToClient(attacker, "vo/sniper_painsevere04.mp3");
	}
}

public void PlayMedicHurtSound(int attacker)
{
	switch (GetRandomInt(0, 11))
	{
		case 0: EmitSoundToClient(attacker, "vo/medic_painsharp01.mp3");
		case 1: EmitSoundToClient(attacker, "vo/medic_painsharp02.mp3");
		case 2: EmitSoundToClient(attacker, "vo/medic_painsharp03.mp3");
		case 3: EmitSoundToClient(attacker, "vo/medic_painsharp04.mp3");
		case 4: EmitSoundToClient(attacker, "vo/medic_painsharp05.mp3");
		case 5: EmitSoundToClient(attacker, "vo/medic_painsharp06.mp3");
		case 6: EmitSoundToClient(attacker, "vo/medic_painsharp07.mp3");
		case 7: EmitSoundToClient(attacker, "vo/medic_painsharp08.mp3");
		case 8: EmitSoundToClient(attacker, "vo/medic_painsevere01.mp3");
		case 9: EmitSoundToClient(attacker, "vo/medic_painsevere02.mp3");
		case 10: EmitSoundToClient(attacker, "vo/medic_painsevere03.mp3");
		case 11: EmitSoundToClient(attacker, "vo/medic_painsevere04.mp3");
	}
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