Handle g_hGameConfig = INVALID_HANDLE;
Handle g_hWearableEquip = INVALID_HANDLE;

stock void InitialiseWeapons() 
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

stock void GiveWeapon(int iClient, int weaponLookupIndex)
{
	if (!TF2Econ_IsValidItemDefinition(weaponLookupIndex))
	{
		LogError("Unknown weapon index: %i", weaponLookupIndex);
		return;
	}

	Player player = new Player(iClient);

	if (!player.IsInGame)
	{
		return;
	}

	int weaponSlot;
	char weaponClassname[64];
	int weaponQuality;
	int minWeaponLevel;
	int weaponLevel;

	weaponSlot = TF2Econ_GetItemSlot(weaponLookupIndex, player.Class);
	TF2Econ_GetItemClassName(weaponLookupIndex, weaponClassname, sizeof(weaponClassname));
	weaponQuality = TF2Econ_GetItemQuality(weaponLookupIndex);
	TF2Econ_GetItemLevelRange(weaponLookupIndex, minWeaponLevel, weaponLevel);

	ArrayList attributes = TF2Econ_GetItemStaticAttributes(weaponLookupIndex);

	TF2_RemoveWeaponSlot(iClient, weaponSlot);

	int entityID = CreateNamedItem(iClient, weaponLookupIndex, weaponClassname, weaponLevel, weaponQuality);

	if (StrEqual(weaponClassname, "tf_weapon_builder", false) || StrEqual(weaponClassname, "tf_weapon_sapper", false))
	{
		if (weaponSlot == TFWeaponSlot_Secondary)
		{
			SetEntProp(entityID, Prop_Send, "m_iObjectType", 3);
			SetEntProp(entityID, Prop_Data, "m_iSubType", 3);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
		}
		else
		{
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
			SetEntProp(entityID, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
		}
	}

	if (attributes.Length > 1) 
	{
		for (int i = 0; i < attributes.Length; i++) 
		{
			int id = attributes.Get(i, 0);
			float value = attributes.Get(i, 1);

			TF2Attrib_SetByDefIndex(entityID, id, value);
		}
	} 

	delete attributes;

	SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", entityID);

	player.SetWeaponVisible(true);
	player.SetViewModelVisible(true);
}

stock int CreateNamedItem(int client, int itemindex, const char[] classname, int level, int quality)
{
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
	
	if (StrEqual(classname, "tf_weapon_builder", true) || StrEqual(classname, "tf_weapon_sapper", true))
	{
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
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
