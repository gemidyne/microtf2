/**
 * MicroTF2 - Minigame 28
 *
 * Listen for it!
 */

#define MINIGAME28_MODEL "models/props_spytech/siren001.mdl"

char Minigame28_SirenBgm[][] = 
{ 
	"items/scout_boombox_02.wav",
	"items/scout_boombox_03.wav",
	"items/scout_boombox_04.wav",
	"items/scout_boombox_05.wav",
};

int Minigame28_SelectedSoundEmitterId;
int Minigame28_SoundEmitterEntity = -1;
int Minigame28_SelectedSirenBgmIdx = -1;
bool Minigame28_CanShoot = false;

public void Minigame28_EntryPoint()
{
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, Minigame28_OnMapStart);
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame28_OnMinigameSelectedPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame28_OnMinigameSelected);
	AddToForward(GlobalForward_OnMinigameFinish, INVALID_HANDLE, Minigame28_OnMinigameFinish);
}

public void Minigame28_OnMapStart()
{
	PrecacheModel(MINIGAME28_MODEL, true);

	for (int i = 0; i < sizeof(Minigame28_SirenBgm); i++)
	{
		PrecacheSound(Minigame28_SirenBgm[i], true);
	}
}

public void Minigame28_OnMinigameSelectedPre()
{
	if (MinigameID == 28)
	{
		int spawnableCount = GetRandomInt(3, 5);

		Minigame28_SelectedSoundEmitterId = GetRandomInt(1, spawnableCount);
		Minigame28_CanShoot = false;

		for (int i = 1; i <= spawnableCount; i++)
		{
			int posa = 360 / spawnableCount * (i-1);
			float pos[3];
			float ang[3];

			pos[0] = -31.6 + (Cosine(DegToRad(float(posa)))*600.0);
			pos[1] = -7665.0 - (Sine(DegToRad(float(posa)))*600.0);
			pos[2] = -100.0;
	
			ang[0] = 0.0;
			ang[1] = float(180-posa);
			ang[2] = 0.0;

			int entity = CreatePropEntity(pos, MINIGAME28_MODEL, 100, 6.0, false);

			TeleportEntity(entity, NULL_VECTOR, ang, NULL_VECTOR);

			CreateParticle(entity, "bombinomicon_flash", 1.0);

			if (i == Minigame28_SelectedSoundEmitterId)
			{
				Minigame28_SoundEmitterEntity = entity;
				SDKHook(entity, SDKHook_OnTakeDamage, Minigame28_OnTakeDamage);

				Minigame28_SelectedSirenBgmIdx = GetRandomInt(0, sizeof(Minigame28_SirenBgm)-1);
			}
		}

		CreateTimer(3.0, Minigame28_TimerAllowShooting);
	}
}

public void Minigame28_OnMinigameSelected(int client)
{
	if (MinigameID != 28)
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
		if (player.Class == TFClass_DemoMan || player.Class == TFClass_Medic)
		{
			player.Class = TFClass_Soldier;
			player.RemoveAllWeapons();
			player.ResetWeapon(false);
			player.ResetHealth();
		}

		EmitSoundToClient(player.ClientId, Minigame28_SirenBgm[Minigame28_SelectedSirenBgmIdx], Minigame28_SoundEmitterEntity, SNDCHAN_AUTO, SNDLEVEL_SCREAMING, SND_NOFLAGS, 1.0, GetSoundMultiplier());
	}
}

public Action Minigame28_TimerAllowShooting(Handle timer)
{
	Minigame28_CanShoot = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			int weapon = 0;
			int ammo = -1;

			switch (player.Class)
			{
				case TFClass_Scout:
				{
					weapon = 13;
					ammo = 32;
				}

				case TFClass_Soldier:
				{
					weapon = 10;
					ammo = 32;
				}

				case TFClass_Pyro: 
				{
					weapon = 12;
					ammo = 32;
				}

				case TFClass_Heavy:
				{
					weapon = 11;
					ammo = 32;
				}

				case TFClass_Engineer:
				{
					weapon = 9;
					ammo = 32;
				}

				case TFClass_Sniper:
				{
					weapon = 16;
					ammo = 75;
				}

				case TFClass_Spy:
				{
					weapon = 24;
					ammo = 24;
				}
			}

			player.RemoveAllWeapons();
			player.GiveWeapon(weapon);

			if (ammo > -1)
			{
				player.SetWeaponPrimaryAmmoCount(ammo);
			}
		}
	}

	return Plugin_Handled;
}

public void Minigame28_OnMinigameFinish()
{
	if (MinigameID != 28)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	if (Minigame28_SoundEmitterEntity != -1)
	{
		SDKUnhook(Minigame28_SoundEmitterEntity, SDKHook_OnTakeDamage, Minigame28_OnTakeDamage);

		if (IsValidEntity(Minigame28_SoundEmitterEntity))
		{
			AcceptEntityInput(Minigame28_SoundEmitterEntity, "Kill");
		}

		Minigame28_SoundEmitterEntity = -1;
	}
}

public Action Minigame28_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	damage = 0.0;
	
	if (Minigame28_CanShoot)
	{
		Player player = new Player(attacker);

		if (player.IsValid)
		{
			player.TriggerSuccess();
		}
	}
	
	return Plugin_Changed;
}
