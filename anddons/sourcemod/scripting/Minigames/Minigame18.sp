/*
 * MicroTF2 - Minigame 18
 * 
 * Hit the Target!
 */

char Minigame18_SniperTargets[4][64];
int Minigame18_TargetEntIndex = -1;
int Minigame18_TargetModel = 0;

public void Minigame18_EntryPoint()
{
	Minigame18_SniperTargets[0] = "models/props_training/target_scout.mdl";
	Minigame18_SniperTargets[1] = "models/props_training/target_demoman.mdl";
	Minigame18_SniperTargets[2] = "models/props_training/target_sniper.mdl";
	Minigame18_SniperTargets[3] = "models/props_training/target_medic.mdl";

	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame18_OnMapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame18_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame18_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame18_OnMinigameFinish);
}

public void Minigame18_OnMapStart()
{
	for (int i = 0; i < 4; i++)
	{
		PrecacheModel(Minigame18_SniperTargets[i], true);
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
	if (MinigameID == 18)
	{
		Minigame18_TargetEntIndex = CreateEntityByName("prop_physics");

		if (IsValidEntity(Minigame18_TargetEntIndex))
		{
			Minigame18_TargetModel = GetRandomInt(0,3);

			DispatchKeyValue(Minigame18_TargetEntIndex, "model", Minigame18_SniperTargets[Minigame18_TargetModel]);
			DispatchSpawn(Minigame18_TargetEntIndex);

			SetEntityMoveType(Minigame18_TargetEntIndex, MOVETYPE_NONE);   

			SDKHook(Minigame18_TargetEntIndex, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage2);
			
			float pos[3];
			float ang[3] = { 0.0, -90.0, 0.0 };

			pos[0] = GetRandomFloat(10240.0, 12322.0);
			pos[1] = GetRandomFloat(7845.0, 8969.0);
			pos[2] = -330.0;

			if (IsValidEntity(Minigame18_TargetEntIndex))
			{
				TeleportEntity(Minigame18_TargetEntIndex, pos, ang, NULL_VECTOR);
				CreateParticle(Minigame18_TargetEntIndex, "bombinomicon_flash", 1.0);
			}
		}
	}
}

public void Minigame18_OnMinigameSelected(int client)
{
	if (MinigameID != 18)
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
	if (MinigameID == 18 && IsMinigameActive)
	{
		SDKUnhook(Minigame18_TargetEntIndex, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage2);

		if (IsValidEntity(Minigame18_TargetEntIndex))
		{
			AcceptEntityInput(Minigame18_TargetEntIndex, "Kill");
		}

		Minigame18_TargetEntIndex = -1;

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
		ClientWonMinigame(attacker);

		switch (Minigame18_TargetModel)
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