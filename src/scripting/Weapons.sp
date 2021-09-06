Handle g_hGameConfig = INVALID_HANDLE;
Handle g_hWearableEquip = INVALID_HANDLE;

void InitialiseWeapons() 
{
	g_hGameConfig = LoadGameConfigFile("microtf2");
	
	if (!g_hGameConfig)
	{
		SetFailState("Missing gamedata file \"microtf2.txt\".");
	}	

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Virtual, "CBasePlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hWearableEquip = EndPrepSDKCall();

	if (!g_hWearableEquip)
	{
		SetFailState("Failed to prepare the SDKCall for wearable equipment. Try updating gamedata or restarting your server.");
	}
}

void Weapons_EquipWeaponByItemIndex(int client, int weaponLookupIndex)
{
	if (!TF2Econ_IsValidItemDefinition(weaponLookupIndex))
	{
		LogError("Unknown weapon index: %i", weaponLookupIndex);
		return;
	}

	Player player = new Player(client);

	if (!player.IsInGame)
	{
		return;
	}

	int weaponSlot = TF2Econ_GetItemLoadoutSlot(weaponLookupIndex, player.Class);
	int weaponQuality = TF2Econ_GetItemQuality(weaponLookupIndex);
	char weaponClassname[64];
	int minWeaponLevel;
	int weaponLevel;

	TF2Econ_GetItemClassName(weaponLookupIndex, weaponClassname, sizeof(weaponClassname));
	TF2Econ_TranslateWeaponEntForClass(weaponClassname, sizeof(weaponClassname), player.Class);
	TF2Econ_GetItemLevelRange(weaponLookupIndex, minWeaponLevel, weaponLevel);

	ArrayList attributes = TF2Econ_GetItemStaticAttributes(weaponLookupIndex);

	TF2_RemoveWeaponSlot(player.ClientId, weaponSlot);

	int entityId = Weapons_CreateNamedItem(player.ClientId, weaponLookupIndex, weaponClassname, weaponLevel, weaponQuality, weaponSlot);

	if (attributes.Length > 1) 
	{
		for (int i = 0; i < attributes.Length; i++) 
		{
			int id = attributes.Get(i, 0);
			float value = view_as<float>(attributes.Get(i, 1));

			if (id > 0 && TF2Econ_IsValidAttributeDefinition(id) && !TF2Econ_IsAttributeHidden(id))
			{
				TF2Attrib_SetByDefIndex(entityId, id, value);
			}
		}
	} 

	delete attributes;

	SetEntPropEnt(player.ClientId, Prop_Send, "m_hActiveWeapon", entityId);

	player.SetWeaponVisible(true);
	player.SetViewModelVisible(true);
}

int Weapons_CreateNamedItem(int client, int itemindex, const char[] classname, int level, int quality, int weaponSlot)
{
	// Doing it this way means we can see the actual weapons that are given
	int weapon = CreateEntityByName(classname);
	
	if (!IsValidEntity(weapon))
	{
		return -1;
	}
	
	char entclass[64];

	GetEntityNetClass(weapon, entclass, sizeof(entclass));	
	SetEntData(weapon, FindSendPropInfo(entclass, "m_iItemDefinitionIndex"), itemindex);
	SetEntData(weapon, FindSendPropInfo(entclass, "m_bInitialized"), 1);
	SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityLevel"), level);
	SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), quality);
	
	if (StrEqual(classname, "tf_weapon_builder", false) || StrEqual(classname, "tf_weapon_sapper", false))
	{
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);

		if (weaponSlot == TFWeaponSlot_Secondary)
		{
			SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
		}
		else
		{
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
		}
	}
	
	DispatchSpawn(weapon);
	
	if (StrContains(classname, "tf_wearable") == 0)
	{
		SDKCall(g_hWearableEquip, client, weapon);
	}
	else
	{
		EquipPlayerWeapon(client, weapon);
	}
	
	return weapon;
} 

void Weapons_ResetToMelee(int client, bool viewModelVisible)
{
	Player player = new Player(client);

	if (player.IsInGame)
	{
		if (player.HasCondition(TFCond_Taunting))
		{
			player.RemoveCondition(TFCond_Taunting);
		}

		int weapon = 0;
		int activeWeaponIndex = -1;
		int newWeaponIndex = 0;

		for (int i = 0; i <= 5; i++)
		{
			weapon = GetPlayerWeaponSlot(client, i);

			if (i != 2)
			{
				TF2_RemoveWeaponSlot(client, i);
				continue;
			}
			
			if (weapon != -1)
			{
				activeWeaponIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			}
			else
			{
				activeWeaponIndex = -1;
			}
			
			switch (TF2_GetPlayerClass(client))
			{
				case TFClass_Scout: newWeaponIndex = 0;
				case TFClass_Soldier: newWeaponIndex = 6;
				case TFClass_Pyro: newWeaponIndex = 2;
				case TFClass_DemoMan: newWeaponIndex = 1;
				case TFClass_Heavy: newWeaponIndex = 5;
				case TFClass_Engineer: newWeaponIndex = 7;
				case TFClass_Medic: newWeaponIndex = 8;
				case TFClass_Sniper: newWeaponIndex = 3;
				case TFClass_Spy: newWeaponIndex = 4;
			}

			if (activeWeaponIndex != newWeaponIndex)
			{
				player.GiveWeapon(newWeaponIndex);
			}
		}

		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, 2));

		if (g_iSpecialRoundId != 12)
		{
			player.SetWeaponVisible(viewModelVisible);
			player.SetViewModelVisible(viewModelVisible);
		}
	}
}