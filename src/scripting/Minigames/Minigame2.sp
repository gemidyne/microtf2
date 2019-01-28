/**
 * MicroTF2 - Minigame 2
 * 
 * Kill an Enemy
 */

int Minigame2_Class = -1;

public void Minigame2_EntryPoint()
{
	AddToForward(GlobalForward_OnMinigameSelectedPre, INVALID_HANDLE, Minigame2_OnSelectionPre);
	AddToForward(GlobalForward_OnMinigameSelected, INVALID_HANDLE, Minigame2_OnSelection);
	AddToForward(GlobalForward_OnPlayerDeath, INVALID_HANDLE, Minigame2_OnPlayerDeath);
}

public void Minigame2_OnSelectionPre()
{
	if (MinigameID == 2)
	{
		SetConVarInt(ConVar_FriendlyFire, 1);

		Minigame2_Class = GetRandomInt(0, 7);
		IsBlockingDamage = false;
		IsBlockingDeathCommands = true;
	}
}

public void Minigame2_OnSelection(int client)
{
	if (MinigameID != 2)
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
		TFClassType class;
		int weapon = 0;

		switch (Minigame2_Class)
		{
			case 0:
			{
				class = TFClass_Scout;
				weapon = 13;
			}
			case 1:
			{
				class = TFClass_Soldier;
				weapon = 10;
			}
			case 2: 
			{
				class = TFClass_Pyro;
				weapon = 12;
			}
			case 3:
			{
				class = TFClass_DemoMan;
				weapon = 1;
			}
			case 4:
			{
				class = TFClass_Heavy;
				weapon = 11;
			}
			case 5:
			{
				class = TFClass_Engineer;
				weapon = 9;
			}
			case 6:
			{
				class = TFClass_Sniper;
				weapon = 16;
			}
			case 7:
			{
				class = TFClass_Spy;
				weapon = 24;
			}
		}

		player.Class = class;
		player.SetHealth(1);
		player.SetGodMode(false);

		ResetWeapon(client, true);
		GiveWeapon(client, weapon);
	}
}

public void Minigame2_OnPlayerDeath(int victimId, int attackerId)
{
	if (MinigameID != 2)
	{
		return;
	}

	if (!IsMinigameActive)
	{
		return;
	}

	Player victim = new Player(victimId);
	Player attacker = new Player(attackerId);

	if (victim.IsValid && victim.IsParticipating && attacker.IsValid && attacker.IsParticipating)
	{
		if (victim.Status == PlayerStatus_NotWon)
		{
			victim.Status = PlayerStatus_Failed;
		}

		ClientWonMinigame(attackerId);
	}
}