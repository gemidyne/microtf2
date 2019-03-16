Handle g_hWeaponData = INVALID_HANDLE;

Handle g_hGameConfig = INVALID_HANDLE;
Handle g_hWeaponEquip = INVALID_HANDLE;

stock void InitialiseWeapons() 
{
	g_hGameConfig = LoadGameConfigFile("microtf2");
	
	if (!g_hGameConfig)
	{
		SetFailState("Missing gamedata file \"microtf2.txt\".");
	}	

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Virtual, "CBasePlayer::Weapon_Equip");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hWeaponEquip = EndPrepSDKCall();

	if (!g_hWeaponEquip)
	{
		SetFailState("Failed to prepare the SDKCall for weapon equipment. Try updating gamedata or restarting your server.");
	}

	LoadWeaponData();
}

// stock SetItemAlpha(item, alpha)
// {
// 	if (item > -1 && IsValidEdict(item))
// 	{
// 		// Don't bother checking the classname, it's always tf_weapon_[something] in TF2 for GetPlayerWeaponSlot
// 		SetEntityRenderMode(item, RENDER_TRANSCOLOR);
// 		SetEntityRenderColor(item, 255, 255, 255, alpha);
		
// 		new String:classname[65];
// 		GetEntityClassname(item, classname, sizeof(classname));
		
// 		if (strncmp(classname, "tf_weapon_", 10) == 0)
// 		{
// 			new extraWearable = GetEntPropEnt(item, Prop_Send, "m_hExtraWearable");
// 			if (extraWearable > -1 && IsValidEdict(extraWearable))
// 			{
// 				SetEntityRenderMode(extraWearable, RENDER_TRANSCOLOR);
// 				SetEntityRenderColor(extraWearable, 255, 255, 255, alpha);
// 			}
			
// 			extraWearable = GetEntPropEnt(item, Prop_Send, "m_hExtraWearableViewModel");
// 			if (extraWearable > -1 && IsValidEdict(extraWearable))
// 			{
// 				SetEntityRenderMode(extraWearable, RENDER_TRANSCOLOR);
// 				SetEntityRenderColor(extraWearable, 255, 255, 255, alpha);
// 			}
// 		}
// 	}
// }

// public TF2Items_OnGiveNamedItem_Post(client, String:classname[], itemDefinitionIndex, itemLevel, itemQuality, entityIndex)
// {
// 	if (IsValidEntity(entityIndex))
// 	{
// 		SetItemAlpha(entityIndex, 255);
// 	}
// }

stock void GiveWeapon(int iClient, int weaponLookupIndex)
{
	int weaponSlot;
	char formatBuffer[32];
	Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "slot");

	bool isValidItem = GetTrieValue(g_hWeaponData, formatBuffer, weaponSlot);
	
	if (!isValidItem)
	{
		ThrowError("GiveWeapon() Error: isValidItem = False");
	}
	else
	{
		char weaponClassname[64];
		int weaponIndex;
		int weaponQuality;
		int weaponLevel;
		int weaponAmmo;
		char weaponAttribs[256];

		Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "classname");
		GetTrieString(g_hWeaponData, formatBuffer, weaponClassname, 64);

		Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "index");
		GetTrieValue(g_hWeaponData, formatBuffer, weaponIndex);

		Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "quality");
		GetTrieValue(g_hWeaponData, formatBuffer, weaponQuality);

		Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "level");
		GetTrieValue(g_hWeaponData, formatBuffer, weaponLevel);

		Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "ammo");
		GetTrieValue(g_hWeaponData, formatBuffer, weaponAmmo);

		Format(formatBuffer, 32, "%d_%s", weaponLookupIndex, "attribs");
		GetTrieString(g_hWeaponData, formatBuffer, weaponAttribs, 256);

		TF2_RemoveWeaponSlot(iClient, weaponSlot);

		CreateNamedItem(iClient, weaponLookupIndex, weaponClassname, weaponLevel, weaponQuality);

		int entityID = GetPlayerWeaponSlot(iClient, weaponSlot);

		char weaponAttribsArray[32][32];
		int attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);

		if (attribCount > 1) 
		{
			for (int i = 0; i < attribCount; i+=2) 
			{
				TF2Attrib_SetByDefIndex(entityID, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			}
		} 

		if (weaponAmmo > -1) 
		{
			SetSpeshulAmmo(iClient, entityID, weaponAmmo);
		}

		SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", entityID);
	}
}

stock bool CreateNamedItem(int client, int itemindex, const char[] classname, int level, int quality)
{
	int weapon = CreateEntityByName(classname);
	
	if (!IsValidEntity(weapon))
	{
		return false;
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
	SDKCall(g_hWeaponEquip, client, weapon);

	return true;
} 

//DarthNinja..
stock void SetSpeshulAmmo(int client, int weaponEntityId, int newAmmo)
{
	if (IsValidEntity(weaponEntityId))
	{
		int offset = GetEntProp(weaponEntityId, Prop_Send, "m_iPrimaryAmmoType", 1)*4;

		SetEntData(client, Offset_PlayerAmmo+offset, newAmmo, 4, true);
	}
}

void LoadWeaponData()
{
	g_hWeaponData = CreateTrie();

//bat
	SetTrieString(g_hWeaponData, "0_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "0_index", 0);
	SetTrieValue(g_hWeaponData, "0_slot", 2);
	SetTrieValue(g_hWeaponData, "0_quality", 0);
	SetTrieValue(g_hWeaponData, "0_level", 1);
	SetTrieString(g_hWeaponData, "0_attribs", "");
	SetTrieValue(g_hWeaponData, "0_ammo", -1);

//bottle
	SetTrieString(g_hWeaponData, "1_classname", "tf_weapon_bottle");
	SetTrieValue(g_hWeaponData, "1_index", 1);
	SetTrieValue(g_hWeaponData, "1_slot", 2);
	SetTrieValue(g_hWeaponData, "1_quality", 0);
	SetTrieValue(g_hWeaponData, "1_level", 1);
	SetTrieString(g_hWeaponData, "1_attribs", "");
	SetTrieValue(g_hWeaponData, "1_ammo", -1);

//fire axe
	SetTrieString(g_hWeaponData, "2_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "2_index", 2);
	SetTrieValue(g_hWeaponData, "2_slot", 2);
	SetTrieValue(g_hWeaponData, "2_quality", 0);
	SetTrieValue(g_hWeaponData, "2_level", 1);
	SetTrieString(g_hWeaponData, "2_attribs", "");
	SetTrieValue(g_hWeaponData, "2_ammo", -1);

//kukri
	SetTrieString(g_hWeaponData, "3_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "3_index", 3);
	SetTrieValue(g_hWeaponData, "3_slot", 2);
	SetTrieValue(g_hWeaponData, "3_quality", 0);
	SetTrieValue(g_hWeaponData, "3_level", 1);
	SetTrieString(g_hWeaponData, "3_attribs", "");
	SetTrieValue(g_hWeaponData, "3_ammo", -1);

//knife
	SetTrieString(g_hWeaponData, "4_classname", "tf_weapon_knife");
	SetTrieValue(g_hWeaponData, "4_index", 4);
	SetTrieValue(g_hWeaponData, "4_slot", 2);
	SetTrieValue(g_hWeaponData, "4_quality", 0);
	SetTrieValue(g_hWeaponData, "4_level", 1);
	SetTrieString(g_hWeaponData, "4_attribs", "");
	SetTrieValue(g_hWeaponData, "4_ammo", -1);

//fists
	SetTrieString(g_hWeaponData, "5_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "5_index", 5);
	SetTrieValue(g_hWeaponData, "5_slot", 2);
	SetTrieValue(g_hWeaponData, "5_quality", 0);
	SetTrieValue(g_hWeaponData, "5_level", 1);
	SetTrieString(g_hWeaponData, "5_attribs", "");
	SetTrieValue(g_hWeaponData, "5_ammo", -1);

//shovel
	SetTrieString(g_hWeaponData, "6_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "6_index", 6);
	SetTrieValue(g_hWeaponData, "6_slot", 2);
	SetTrieValue(g_hWeaponData, "6_quality", 0);
	SetTrieValue(g_hWeaponData, "6_level", 1);
	SetTrieString(g_hWeaponData, "6_attribs", "");
	SetTrieValue(g_hWeaponData, "6_ammo", -1);

//wrench
	SetTrieString(g_hWeaponData, "7_classname", "tf_weapon_wrench");
	SetTrieValue(g_hWeaponData, "7_index", 7);
	SetTrieValue(g_hWeaponData, "7_slot", 2);
	SetTrieValue(g_hWeaponData, "7_quality", 0);
	SetTrieValue(g_hWeaponData, "7_level", 1);
	SetTrieString(g_hWeaponData, "7_attribs", "");
	SetTrieValue(g_hWeaponData, "7_ammo", -1);

//bonesaw
	SetTrieString(g_hWeaponData, "8_classname", "tf_weapon_bonesaw");
	SetTrieValue(g_hWeaponData, "8_index", 8);
	SetTrieValue(g_hWeaponData, "8_slot", 2);
	SetTrieValue(g_hWeaponData, "8_quality", 0);
	SetTrieValue(g_hWeaponData, "8_level", 1);
	SetTrieString(g_hWeaponData, "8_attribs", "");
	SetTrieValue(g_hWeaponData, "8_ammo", -1);

//shotgun engineer
	SetTrieString(g_hWeaponData, "9_classname", "tf_weapon_shotgun_primary");
	SetTrieValue(g_hWeaponData, "9_index", 9);
	SetTrieValue(g_hWeaponData, "9_slot", 0);
	SetTrieValue(g_hWeaponData, "9_quality", 0);
	SetTrieValue(g_hWeaponData, "9_level", 1);
	SetTrieString(g_hWeaponData, "9_attribs", "");
	SetTrieValue(g_hWeaponData, "9_ammo", 32);

//shotgun soldier
	SetTrieString(g_hWeaponData, "10_classname", "tf_weapon_shotgun_soldier");
	SetTrieValue(g_hWeaponData, "10_index", 10);
	SetTrieValue(g_hWeaponData, "10_slot", 1);
	SetTrieValue(g_hWeaponData, "10_quality", 0);
	SetTrieValue(g_hWeaponData, "10_level", 1);
	SetTrieString(g_hWeaponData, "10_attribs", "");
	SetTrieValue(g_hWeaponData, "10_ammo", 32);

//shotgun heavy
	SetTrieString(g_hWeaponData, "11_classname", "tf_weapon_shotgun_hwg");
	SetTrieValue(g_hWeaponData, "11_index", 11);
	SetTrieValue(g_hWeaponData, "11_slot", 1);
	SetTrieValue(g_hWeaponData, "11_quality", 0);
	SetTrieValue(g_hWeaponData, "11_level", 1);
	SetTrieString(g_hWeaponData, "11_attribs", "");
	SetTrieValue(g_hWeaponData, "11_ammo", 32);

//shotgun pyro
	SetTrieString(g_hWeaponData, "12_classname", "tf_weapon_shotgun_pyro");
	SetTrieValue(g_hWeaponData, "12_index", 12);
	SetTrieValue(g_hWeaponData, "12_slot", 1);
	SetTrieValue(g_hWeaponData, "12_quality", 0);
	SetTrieValue(g_hWeaponData, "12_level", 1);
	SetTrieString(g_hWeaponData, "12_attribs", "");
	SetTrieValue(g_hWeaponData, "12_ammo", 32);

//scattergun
	SetTrieString(g_hWeaponData, "13_classname", "tf_weapon_scattergun");
	SetTrieValue(g_hWeaponData, "13_index", 13);
	SetTrieValue(g_hWeaponData, "13_slot", 0);
	SetTrieValue(g_hWeaponData, "13_quality", 0);
	SetTrieValue(g_hWeaponData, "13_level", 1);
	SetTrieString(g_hWeaponData, "13_attribs", "");
	SetTrieValue(g_hWeaponData, "13_ammo", 32);

//sniper rifle
	SetTrieString(g_hWeaponData, "14_classname", "tf_weapon_sniperrifle");
	SetTrieValue(g_hWeaponData, "14_index", 14);
	SetTrieValue(g_hWeaponData, "14_slot", 0);
	SetTrieValue(g_hWeaponData, "14_quality", 0);
	SetTrieValue(g_hWeaponData, "14_level", 1);
	SetTrieString(g_hWeaponData, "14_attribs", "");
	SetTrieValue(g_hWeaponData, "14_ammo", 25);

//minigun
	SetTrieString(g_hWeaponData, "15_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "15_index", 15);
	SetTrieValue(g_hWeaponData, "15_slot", 0);
	SetTrieValue(g_hWeaponData, "15_quality", 0);
	SetTrieValue(g_hWeaponData, "15_level", 1);
	SetTrieString(g_hWeaponData, "15_attribs", "");
	SetTrieValue(g_hWeaponData, "15_ammo", 200);

//smg
	SetTrieString(g_hWeaponData, "16_classname", "tf_weapon_smg");
	SetTrieValue(g_hWeaponData, "16_index", 16);
	SetTrieValue(g_hWeaponData, "16_slot", 1);
	SetTrieValue(g_hWeaponData, "16_quality", 0);
	SetTrieValue(g_hWeaponData, "16_level", 1);
	SetTrieString(g_hWeaponData, "16_attribs", "");
	SetTrieValue(g_hWeaponData, "16_ammo", 75);

//syringe gun
	SetTrieString(g_hWeaponData, "17_classname", "tf_weapon_syringegun_medic");
	SetTrieValue(g_hWeaponData, "17_index", 17);
	SetTrieValue(g_hWeaponData, "17_slot", 0);
	SetTrieValue(g_hWeaponData, "17_quality", 0);
	SetTrieValue(g_hWeaponData, "17_level", 1);
	SetTrieString(g_hWeaponData, "17_attribs", "");
	SetTrieValue(g_hWeaponData, "17_ammo", 150);

//rocket launcher
	SetTrieString(g_hWeaponData, "18_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "18_index", 18);
	SetTrieValue(g_hWeaponData, "18_slot", 0);
	SetTrieValue(g_hWeaponData, "18_quality", 0);
	SetTrieValue(g_hWeaponData, "18_level", 1);
	SetTrieString(g_hWeaponData, "18_attribs", "");
	SetTrieValue(g_hWeaponData, "18_ammo", 20);

//grenade launcher
	SetTrieString(g_hWeaponData, "19_classname", "tf_weapon_grenadelauncher");
	SetTrieValue(g_hWeaponData, "19_index", 19);
	SetTrieValue(g_hWeaponData, "19_slot", 0);
	SetTrieValue(g_hWeaponData, "19_quality", 0);
	SetTrieValue(g_hWeaponData, "19_level", 1);
	SetTrieString(g_hWeaponData, "19_attribs", "");
	SetTrieValue(g_hWeaponData, "19_ammo", 16);

//sticky launcher
	SetTrieString(g_hWeaponData, "20_classname", "tf_weapon_pipebomblauncher");
	SetTrieValue(g_hWeaponData, "20_index", 20);
	SetTrieValue(g_hWeaponData, "20_slot", 1);
	SetTrieValue(g_hWeaponData, "20_quality", 0);
	SetTrieValue(g_hWeaponData, "20_level", 1);
	SetTrieString(g_hWeaponData, "20_attribs", "");
	SetTrieValue(g_hWeaponData, "20_ammo", 24);

//flamethrower
	SetTrieString(g_hWeaponData, "21_classname", "tf_weapon_flamethrower");
	SetTrieValue(g_hWeaponData, "21_index", 21);
	SetTrieValue(g_hWeaponData, "21_slot", 0);
	SetTrieValue(g_hWeaponData, "21_quality", 0);
	SetTrieValue(g_hWeaponData, "21_level", 1);
	SetTrieString(g_hWeaponData, "21_attribs", "");
	SetTrieValue(g_hWeaponData, "21_ammo", 200);

//pistol engineer
	SetTrieString(g_hWeaponData, "22_classname", "tf_weapon_pistol");
	SetTrieValue(g_hWeaponData, "22_index", 22);
	SetTrieValue(g_hWeaponData, "22_slot", 1);
	SetTrieValue(g_hWeaponData, "22_quality", 0);
	SetTrieValue(g_hWeaponData, "22_level", 1);
	SetTrieString(g_hWeaponData, "22_attribs", "");
	SetTrieValue(g_hWeaponData, "22_ammo", 200);

//pistol scout
	SetTrieString(g_hWeaponData, "23_classname", "tf_weapon_pistol_scout");
	SetTrieValue(g_hWeaponData, "23_index", 23);
	SetTrieValue(g_hWeaponData, "23_slot", 1);
	SetTrieValue(g_hWeaponData, "23_quality", 0);
	SetTrieValue(g_hWeaponData, "23_level", 1);
	SetTrieString(g_hWeaponData, "23_attribs", "");
	SetTrieValue(g_hWeaponData, "23_ammo", 36);

//revolver
	SetTrieString(g_hWeaponData, "24_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "24_index", 24);
	SetTrieValue(g_hWeaponData, "24_slot", 0);
	SetTrieValue(g_hWeaponData, "24_quality", 0);
	SetTrieValue(g_hWeaponData, "24_level", 1);
	SetTrieString(g_hWeaponData, "24_attribs", "");
	SetTrieValue(g_hWeaponData, "24_ammo", 24);

//build pda engineer
	SetTrieString(g_hWeaponData, "25_classname", "tf_weapon_pda_engineer_build");
	SetTrieValue(g_hWeaponData, "25_index", 25);
	SetTrieValue(g_hWeaponData, "25_slot", 3);
	SetTrieValue(g_hWeaponData, "25_quality", 0);
	SetTrieValue(g_hWeaponData, "25_level", 1);
	SetTrieString(g_hWeaponData, "25_attribs", "");
	SetTrieValue(g_hWeaponData, "25_ammo", -1);

//destroy pda engineer
	SetTrieString(g_hWeaponData, "26_classname", "tf_weapon_pda_engineer_destroy");
	SetTrieValue(g_hWeaponData, "26_index", 26);
	SetTrieValue(g_hWeaponData, "26_slot", 4);
	SetTrieValue(g_hWeaponData, "26_quality", 0);
	SetTrieValue(g_hWeaponData, "26_level", 1);
	SetTrieString(g_hWeaponData, "26_attribs", "");
	SetTrieValue(g_hWeaponData, "26_ammo", -1);

//disguise kit spy
	SetTrieString(g_hWeaponData, "27_classname", "tf_weapon_pda_spy");
	SetTrieValue(g_hWeaponData, "27_index", 27);
	SetTrieValue(g_hWeaponData, "27_slot", 3);
	SetTrieValue(g_hWeaponData, "27_quality", 0);
	SetTrieValue(g_hWeaponData, "27_level", 1);
	SetTrieString(g_hWeaponData, "27_attribs", "");
	SetTrieValue(g_hWeaponData, "27_ammo", -1);

//builder
	SetTrieString(g_hWeaponData, "28_classname", "tf_weapon_builder");
	SetTrieValue(g_hWeaponData, "28_index", 28);
	SetTrieValue(g_hWeaponData, "28_slot", 5);
	SetTrieValue(g_hWeaponData, "28_quality", 0);
	SetTrieValue(g_hWeaponData, "28_level", 1);
	SetTrieString(g_hWeaponData, "28_attribs", "");
	SetTrieValue(g_hWeaponData, "28_ammo", -1);

//medigun
	SetTrieString(g_hWeaponData, "29_classname", "tf_weapon_medigun");
	SetTrieValue(g_hWeaponData, "29_index", 29);
	SetTrieValue(g_hWeaponData, "29_slot", 1);
	SetTrieValue(g_hWeaponData, "29_quality", 0);
	SetTrieValue(g_hWeaponData, "29_level", 1);
	SetTrieString(g_hWeaponData, "29_attribs", "");
	SetTrieValue(g_hWeaponData, "29_ammo", -1);

//invis watch
	SetTrieString(g_hWeaponData, "30_classname", "tf_weapon_invis");
	SetTrieValue(g_hWeaponData, "30_index", 30);
	SetTrieValue(g_hWeaponData, "30_slot", 4);
	SetTrieValue(g_hWeaponData, "30_quality", 0);
	SetTrieValue(g_hWeaponData, "30_level", 1);
	SetTrieString(g_hWeaponData, "30_attribs", "");
	SetTrieValue(g_hWeaponData, "30_ammo", -1);

/*flaregun engineerpistol
	SetTrieString(g_hWeaponData, "31_classname", "tf_weapon_flaregun");
	SetTrieValue(g_hWeaponData, "31_index", 31);
	SetTrieValue(g_hWeaponData, "31_slot", 1);
	SetTrieValue(g_hWeaponData, "31_quality", 0);
	SetTrieValue(g_hWeaponData, "31_level", 1);
	SetTrieString(g_hWeaponData, "31_attribs", "");
	SetTrieValue(g_hWeaponData, "31_ammo", 16);*/

//kritzkrieg
	SetTrieString(g_hWeaponData, "35_classname", "tf_weapon_medigun");
	SetTrieValue(g_hWeaponData, "35_index", 35);
	SetTrieValue(g_hWeaponData, "35_slot", 1);
	SetTrieValue(g_hWeaponData, "35_quality", 6);
	SetTrieValue(g_hWeaponData, "35_level", 8);
	SetTrieString(g_hWeaponData, "35_attribs", "18 ; 1.0 ; 10 ; 1.25");
	SetTrieValue(g_hWeaponData, "35_ammo", -1);

//blutsauger
	SetTrieString(g_hWeaponData, "36_classname", "tf_weapon_syringegun_medic");
	SetTrieValue(g_hWeaponData, "36_index", 36);
	SetTrieValue(g_hWeaponData, "36_slot", 0);
	SetTrieValue(g_hWeaponData, "36_quality", 6);
	SetTrieValue(g_hWeaponData, "36_level", 5);
	SetTrieString(g_hWeaponData, "36_attribs", "16 ; 3.0 ; 129 ; -2.0");
	SetTrieValue(g_hWeaponData, "36_ammo", 150);

//ubersaw
	SetTrieString(g_hWeaponData, "37_classname", "tf_weapon_bonesaw");
	SetTrieValue(g_hWeaponData, "37_index", 37);
	SetTrieValue(g_hWeaponData, "37_slot", 2);
	SetTrieValue(g_hWeaponData, "37_quality", 6);
	SetTrieValue(g_hWeaponData, "37_level", 10);
	SetTrieString(g_hWeaponData, "37_attribs", "17 ; 0.25 ; 5 ; 1.2 ; 144 ; 1");
	SetTrieValue(g_hWeaponData, "37_ammo", -1);

//axetinguisher
	SetTrieString(g_hWeaponData, "38_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "38_index", 38);
	SetTrieValue(g_hWeaponData, "38_slot", 2);
	SetTrieValue(g_hWeaponData, "38_quality", 6);
	SetTrieValue(g_hWeaponData, "38_level", 10);
	SetTrieString(g_hWeaponData, "38_attribs", "20 ; 1.0 ; 21 ; 0.5 ; 22 ; 1.0");
	SetTrieValue(g_hWeaponData, "38_ammo", -1);

//flaregun pyro
	SetTrieString(g_hWeaponData, "39_classname", "tf_weapon_flaregun");
	SetTrieValue(g_hWeaponData, "39_index", 39);
	SetTrieValue(g_hWeaponData, "39_slot", 1);
	SetTrieValue(g_hWeaponData, "39_quality", 6);
	SetTrieValue(g_hWeaponData, "39_level", 10);
	SetTrieString(g_hWeaponData, "39_attribs", "25 ; 0.5");
	SetTrieValue(g_hWeaponData, "39_ammo", 16);

//backburner
	SetTrieString(g_hWeaponData, "40_classname", "tf_weapon_flamethrower");
	SetTrieValue(g_hWeaponData, "40_index", 40);
	SetTrieValue(g_hWeaponData, "40_slot", 0);
	SetTrieValue(g_hWeaponData, "40_quality", 6);
	SetTrieValue(g_hWeaponData, "40_level", 10);
//	SetTrieString(g_hWeaponData, "40_attribs", "23 ; 1.0 ; 24 ; 1.0 ; 28 ; 0.0 ; 2 ; 1.15");	//these are the old backburner attribs (before april 14th, 2011)
	SetTrieString(g_hWeaponData, "40_attribs", "170 ; 2.5 ; 24 ; 1.0 ; 28 ; 0.0 ; 2 ; 1.10");
	SetTrieValue(g_hWeaponData, "40_ammo", 200);

//natascha
	SetTrieString(g_hWeaponData, "41_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "41_index", 41);
	SetTrieValue(g_hWeaponData, "41_slot", 0);
	SetTrieValue(g_hWeaponData, "41_quality", 6);
	SetTrieValue(g_hWeaponData, "41_level", 5);
	SetTrieString(g_hWeaponData, "41_attribs", "32 ; 1.0 ; 1 ; 0.75 ; 86 ; 1.3 ; 144 ; 1");
	SetTrieValue(g_hWeaponData, "41_ammo", 200);

//sandvich
	SetTrieString(g_hWeaponData, "42_classname", "tf_weapon_lunchbox");
	SetTrieValue(g_hWeaponData, "42_index", 42);
	SetTrieValue(g_hWeaponData, "42_slot", 1);
	SetTrieValue(g_hWeaponData, "42_quality", 6);
	SetTrieValue(g_hWeaponData, "42_level", 1);
	SetTrieString(g_hWeaponData, "42_attribs", "");
	SetTrieValue(g_hWeaponData, "42_ammo", 1);

//killing gloves of boxing
	SetTrieString(g_hWeaponData, "43_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "43_index", 43);
	SetTrieValue(g_hWeaponData, "43_slot", 2);
	SetTrieValue(g_hWeaponData, "43_quality", 6);
	SetTrieValue(g_hWeaponData, "43_level", 7);
	SetTrieString(g_hWeaponData, "43_attribs", "31 ; 5.0 ; 5 ; 1.2");
	SetTrieValue(g_hWeaponData, "43_ammo", -1);

//sandman
	SetTrieString(g_hWeaponData, "44_classname", "tf_weapon_bat_wood");
	SetTrieValue(g_hWeaponData, "44_index", 44);
	SetTrieValue(g_hWeaponData, "44_slot", 2);
	SetTrieValue(g_hWeaponData, "44_quality", 6);
	SetTrieValue(g_hWeaponData, "44_level", 15);
	SetTrieString(g_hWeaponData, "44_attribs", "38 ; 1.0 ; 125 ; -15.0");
	SetTrieValue(g_hWeaponData, "44_ammo", 1);

//force a nature
	SetTrieString(g_hWeaponData, "45_classname", "tf_weapon_scattergun");
	SetTrieValue(g_hWeaponData, "45_index", 45);
	SetTrieValue(g_hWeaponData, "45_slot", 0);
	SetTrieValue(g_hWeaponData, "45_quality", 6);
	SetTrieValue(g_hWeaponData, "45_level", 10);
	SetTrieString(g_hWeaponData, "45_attribs", "44 ; 1.0 ; 6 ; 0.5 ; 45 ; 1.2 ; 1 ; 0.9 ; 3 ; 0.4 ; 43 ; 1.0");
	SetTrieValue(g_hWeaponData, "45_ammo", 32);

//bonk atomic punch
	SetTrieString(g_hWeaponData, "46_classname", "tf_weapon_lunchbox_drink");
	SetTrieValue(g_hWeaponData, "46_index", 46);
	SetTrieValue(g_hWeaponData, "46_slot", 1);
	SetTrieValue(g_hWeaponData, "46_quality", 6);
	SetTrieValue(g_hWeaponData, "46_level", 5);
	SetTrieString(g_hWeaponData, "46_attribs", "");
	SetTrieValue(g_hWeaponData, "46_ammo", 1);

//huntsman
	SetTrieString(g_hWeaponData, "56_classname", "tf_weapon_compound_bow");
	SetTrieValue(g_hWeaponData, "56_index", 56);
	SetTrieValue(g_hWeaponData, "56_slot", 0);
	SetTrieValue(g_hWeaponData, "56_quality", 6);
	SetTrieValue(g_hWeaponData, "56_level", 10);
	SetTrieString(g_hWeaponData, "56_attribs", "37 ; 0.5");
	SetTrieValue(g_hWeaponData, "56_ammo", 12);

//razorback (broken NO LONGER)
	SetTrieString(g_hWeaponData, "57_classname", "tf_wearable");
	SetTrieValue(g_hWeaponData, "57_index", 57);
	SetTrieValue(g_hWeaponData, "57_slot", 1);
	SetTrieValue(g_hWeaponData, "57_quality", 6);
	SetTrieValue(g_hWeaponData, "57_level", 10);
	SetTrieString(g_hWeaponData, "57_attribs", "52 ; 1");

//jarate
	SetTrieString(g_hWeaponData, "58_classname", "tf_weapon_jar");
	SetTrieValue(g_hWeaponData, "58_index", 58);
	SetTrieValue(g_hWeaponData, "58_slot", 1);
	SetTrieValue(g_hWeaponData, "58_quality", 6);
	SetTrieValue(g_hWeaponData, "58_level", 5);
	SetTrieString(g_hWeaponData, "58_attribs", "56 ; 1.0 ; 292 ; 4.0");
	SetTrieValue(g_hWeaponData, "58_ammo", 1);

//dead ringer
	SetTrieString(g_hWeaponData, "59_classname", "tf_weapon_invis");
	SetTrieValue(g_hWeaponData, "59_index", 59);
	SetTrieValue(g_hWeaponData, "59_slot", 4);
	SetTrieValue(g_hWeaponData, "59_quality", 6);
	SetTrieValue(g_hWeaponData, "59_level", 5);
	SetTrieString(g_hWeaponData, "59_attribs", "33 ; 1.0 ; 34 ; 1.6 ; 35 ; 1.8");
	SetTrieValue(g_hWeaponData, "59_ammo", -1);

//cloak and dagger
	SetTrieString(g_hWeaponData, "60_classname", "tf_weapon_invis");
	SetTrieValue(g_hWeaponData, "60_index", 60);
	SetTrieValue(g_hWeaponData, "60_slot", 4);
	SetTrieValue(g_hWeaponData, "60_quality", 6);
	SetTrieValue(g_hWeaponData, "60_level", 5);
	SetTrieString(g_hWeaponData, "60_attribs", "48 ; 2.0 ; 35 ; 2.0");
	SetTrieValue(g_hWeaponData, "60_ammo", -1);

//ambassador
	SetTrieString(g_hWeaponData, "61_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "61_index", 61);
	SetTrieValue(g_hWeaponData, "61_slot", 0);
	SetTrieValue(g_hWeaponData, "61_quality", 6);
	SetTrieValue(g_hWeaponData, "61_level", 5);
	SetTrieString(g_hWeaponData, "61_attribs", "51 ; 1.0 ; 1 ; 0.85 ; 5 ; 1.2");
	SetTrieValue(g_hWeaponData, "61_ammo", 24);

//direct hit
	SetTrieString(g_hWeaponData, "127_classname", "tf_weapon_rocketlauncher_directhit");
	SetTrieValue(g_hWeaponData, "127_index", 127);
	SetTrieValue(g_hWeaponData, "127_slot", 0);
	SetTrieValue(g_hWeaponData, "127_quality", 6);
	SetTrieValue(g_hWeaponData, "127_level", 1);
	SetTrieString(g_hWeaponData, "127_attribs", "100 ; 0.3 ; 103 ; 1.8 ; 2 ; 1.25 ; 114 ; 1.0");
	SetTrieValue(g_hWeaponData, "127_ammo", 20);

//equalizer
	SetTrieString(g_hWeaponData, "128_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "128_index", 128);
	SetTrieValue(g_hWeaponData, "128_slot", 2);
	SetTrieValue(g_hWeaponData, "128_quality", 6);
	SetTrieValue(g_hWeaponData, "128_level", 10);
	SetTrieString(g_hWeaponData, "128_attribs", "115 ; 1.0");
	SetTrieValue(g_hWeaponData, "128_ammo", -1);

//buff banner
	SetTrieString(g_hWeaponData, "129_classname", "tf_weapon_buff_item");
	SetTrieValue(g_hWeaponData, "129_index", 129);
	SetTrieValue(g_hWeaponData, "129_slot", 1);
	SetTrieValue(g_hWeaponData, "129_quality", 6);
	SetTrieValue(g_hWeaponData, "129_level", 5);
	SetTrieString(g_hWeaponData, "129_attribs", "116 ; 1");
	SetTrieValue(g_hWeaponData, "129_ammo", -1);

//scottish resistance
	SetTrieString(g_hWeaponData, "130_classname", "tf_weapon_pipebomblauncher");
	SetTrieValue(g_hWeaponData, "130_index", 130);
	SetTrieValue(g_hWeaponData, "130_slot", 1);
	SetTrieValue(g_hWeaponData, "130_quality", 6);
	SetTrieValue(g_hWeaponData, "130_level", 5);
	SetTrieString(g_hWeaponData, "130_attribs", "6 ; 0.75 ; 119 ; 1.0 ; 121 ; 1.0 ; 78 ; 1.5 ; 88 ; 6.0 ; 120 ; 0.8");
	SetTrieValue(g_hWeaponData, "130_ammo", 24);

//chargin targe (broken NO LONGER)
	SetTrieString(g_hWeaponData, "131_classname", "tf_wearable_demoshield");
	SetTrieValue(g_hWeaponData, "131_index", 131);
	SetTrieValue(g_hWeaponData, "131_slot", 1);
	SetTrieValue(g_hWeaponData, "131_quality", 6);
	SetTrieValue(g_hWeaponData, "131_level", 10);
	SetTrieString(g_hWeaponData, "131_attribs", "60 ; 0.5 ; 64 ; 0.6");

//eyelander
	SetTrieString(g_hWeaponData, "132_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "132_index", 132);
	SetTrieValue(g_hWeaponData, "132_slot", 2);
	SetTrieValue(g_hWeaponData, "132_quality", 6);
	SetTrieValue(g_hWeaponData, "132_level", 5);
	SetTrieString(g_hWeaponData, "132_attribs", "15 ; 0 ; 125 ; -25 ; 219 ; 1.0");
	SetTrieValue(g_hWeaponData, "132_ammo", -1);

//gunboats (broken NO LONGER)
	SetTrieString(g_hWeaponData, "133_classname", "tf_wearable");
	SetTrieValue(g_hWeaponData, "133_index", 133);
	SetTrieValue(g_hWeaponData, "133_slot", 1);
	SetTrieValue(g_hWeaponData, "133_quality", 6);
	SetTrieValue(g_hWeaponData, "133_level", 10);
	SetTrieString(g_hWeaponData, "133_attribs", "135 ; 0.4");

//wrangler
	SetTrieString(g_hWeaponData, "140_classname", "tf_weapon_laser_pointer");
	SetTrieValue(g_hWeaponData, "140_index", 140);
	SetTrieValue(g_hWeaponData, "140_slot", 1);
	SetTrieValue(g_hWeaponData, "140_quality", 6);
	SetTrieValue(g_hWeaponData, "140_level", 5);
	SetTrieString(g_hWeaponData, "140_attribs", "");
	SetTrieValue(g_hWeaponData, "140_ammo", -1);

//frontier justice
	SetTrieString(g_hWeaponData, "141_classname", "tf_weapon_sentry_revenge");
	SetTrieValue(g_hWeaponData, "141_index", 141);
	SetTrieValue(g_hWeaponData, "141_slot", 0);
	SetTrieValue(g_hWeaponData, "141_quality", 6);
	SetTrieValue(g_hWeaponData, "141_level", 5);
	SetTrieString(g_hWeaponData, "141_attribs", "136 ; 1 ; 15 ; 0 ; 3 ; 0.5");
	SetTrieValue(g_hWeaponData, "141_ammo", 32);

//gunslinger
	SetTrieString(g_hWeaponData, "142_classname", "tf_weapon_robot_arm");
	SetTrieValue(g_hWeaponData, "142_index", 142);
	SetTrieValue(g_hWeaponData, "142_slot", 2);
	SetTrieValue(g_hWeaponData, "142_quality", 6);
	SetTrieValue(g_hWeaponData, "142_level", 15);
	SetTrieString(g_hWeaponData, "142_attribs", "124 ; 1 ; 26 ; 25.0 ; 15 ; 0");
	SetTrieValue(g_hWeaponData, "142_ammo", -1);

//homewrecker
	SetTrieString(g_hWeaponData, "153_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "153_index", 153);
	SetTrieValue(g_hWeaponData, "153_slot", 2);
	SetTrieValue(g_hWeaponData, "153_quality", 6);
	SetTrieValue(g_hWeaponData, "153_level", 5);
	SetTrieString(g_hWeaponData, "153_attribs", "137 ; 2.0 ; 138 ; 0.75 ; 146 ; 1");
	SetTrieValue(g_hWeaponData, "153_ammo", -1);

//pain train
	SetTrieString(g_hWeaponData, "154_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "154_index", 154);
	SetTrieValue(g_hWeaponData, "154_slot", 2);
	SetTrieValue(g_hWeaponData, "154_quality", 6);
	SetTrieValue(g_hWeaponData, "154_level", 5);
	SetTrieString(g_hWeaponData, "154_attribs", "68 ; 1 ; 67 ; 1.1");
	SetTrieValue(g_hWeaponData, "154_ammo", -1);

//southern hospitality
	SetTrieString(g_hWeaponData, "155_classname", "tf_weapon_wrench");
	SetTrieValue(g_hWeaponData, "155_index", 155);
	SetTrieValue(g_hWeaponData, "155_slot", 2);
	SetTrieValue(g_hWeaponData, "155_quality", 6);
	SetTrieValue(g_hWeaponData, "155_level", 20);
	SetTrieString(g_hWeaponData, "155_attribs", "15 ; 0 ; 149 ; 5 ; 61 ; 1.20");
	SetTrieValue(g_hWeaponData, "155_ammo", -1);

//dalokohs bar
	SetTrieString(g_hWeaponData, "159_classname", "tf_weapon_lunchbox");
	SetTrieValue(g_hWeaponData, "159_index", 159);
	SetTrieValue(g_hWeaponData, "159_slot", 1);
	SetTrieValue(g_hWeaponData, "159_quality", 6);
	SetTrieValue(g_hWeaponData, "159_level", 1);
	SetTrieString(g_hWeaponData, "159_attribs", "139 ; 1");
	SetTrieValue(g_hWeaponData, "159_ammo", 1);

//lugermorph
	SetTrieString(g_hWeaponData, "160_classname", "tf_weapon_pistol");
	SetTrieValue(g_hWeaponData, "160_index", 160);
	SetTrieValue(g_hWeaponData, "160_slot", 1);
	SetTrieValue(g_hWeaponData, "160_quality", 3);
	SetTrieValue(g_hWeaponData, "160_level", 5);
	SetTrieString(g_hWeaponData, "160_attribs", "");
	SetTrieValue(g_hWeaponData, "160_ammo", 36);

//big kill
	SetTrieString(g_hWeaponData, "161_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "161_index", 161);
	SetTrieValue(g_hWeaponData, "161_slot", 0);
	SetTrieValue(g_hWeaponData, "161_quality", 6);
	SetTrieValue(g_hWeaponData, "161_level", 5);
	SetTrieString(g_hWeaponData, "161_attribs", "");
	SetTrieValue(g_hWeaponData, "161_ammo", 24);

//crit a cola
	SetTrieString(g_hWeaponData, "163_classname", "tf_weapon_lunchbox_drink");
	SetTrieValue(g_hWeaponData, "163_index", 163);
	SetTrieValue(g_hWeaponData, "163_slot", 1);
	SetTrieValue(g_hWeaponData, "163_quality", 6);
	SetTrieValue(g_hWeaponData, "163_level", 5);
	SetTrieString(g_hWeaponData, "163_attribs", "144 ; 2");
	SetTrieValue(g_hWeaponData, "163_ammo", 1);

//golden wrench
	SetTrieString(g_hWeaponData, "169_classname", "tf_weapon_wrench");
	SetTrieValue(g_hWeaponData, "169_index", 169);
	SetTrieValue(g_hWeaponData, "169_slot", 2);
	SetTrieValue(g_hWeaponData, "169_quality", 6);
	SetTrieValue(g_hWeaponData, "169_level", 25);
	SetTrieString(g_hWeaponData, "169_attribs", "150 ; 1");
	SetTrieValue(g_hWeaponData, "169_ammo", -1);

//tribalmans shiv
	SetTrieString(g_hWeaponData, "171_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "171_index", 171);
	SetTrieValue(g_hWeaponData, "171_slot", 2);
	SetTrieValue(g_hWeaponData, "171_quality", 6);
	SetTrieValue(g_hWeaponData, "171_level", 5);
	SetTrieString(g_hWeaponData, "171_attribs", "149 ; 6 ; 1 ; 0.5");
	SetTrieValue(g_hWeaponData, "171_ammo", -1);

//scotsmans skullcutter
	SetTrieString(g_hWeaponData, "172_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "172_index", 172);
	SetTrieValue(g_hWeaponData, "172_slot", 2);
	SetTrieValue(g_hWeaponData, "172_quality", 6);
	SetTrieValue(g_hWeaponData, "172_level", 5);
	SetTrieString(g_hWeaponData, "172_attribs", "2 ; 1.2 ; 54 ; 0.85");
	SetTrieValue(g_hWeaponData, "172_ammo", -1);

//The Vita-Saw
	SetTrieString(g_hWeaponData, "173_classname", "tf_weapon_bonesaw");
	SetTrieValue(g_hWeaponData, "173_index", 173);
	SetTrieValue(g_hWeaponData, "173_slot", 2);
	SetTrieValue(g_hWeaponData, "173_quality", 6);
	SetTrieValue(g_hWeaponData, "173_level", 5);
	SetTrieString(g_hWeaponData, "173_attribs", "188 ; 20 ; 125 ; -10 ; 144 ; 2.0");
	SetTrieValue(g_hWeaponData, "173_ammo", -1);

//Upgradeable bat
	SetTrieString(g_hWeaponData, "190_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "190_index", 190);
	SetTrieValue(g_hWeaponData, "190_slot", 2);
	SetTrieValue(g_hWeaponData, "190_quality", 6);
	SetTrieValue(g_hWeaponData, "190_level", 1);
	SetTrieString(g_hWeaponData, "190_attribs", "");
	SetTrieValue(g_hWeaponData, "190_ammo", -1);

//Upgradeable bottle
	SetTrieString(g_hWeaponData, "191_classname", "tf_weapon_bottle");
	SetTrieValue(g_hWeaponData, "191_index", 191);
	SetTrieValue(g_hWeaponData, "191_slot", 2);
	SetTrieValue(g_hWeaponData, "191_quality", 6);
	SetTrieValue(g_hWeaponData, "191_level", 1);
	SetTrieString(g_hWeaponData, "191_attribs", "");
	SetTrieValue(g_hWeaponData, "191_ammo", -1);

//Upgradeable fire axe
	SetTrieString(g_hWeaponData, "192_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "192_index", 192);
	SetTrieValue(g_hWeaponData, "192_slot", 2);
	SetTrieValue(g_hWeaponData, "192_quality", 6);
	SetTrieValue(g_hWeaponData, "192_level", 1);
	SetTrieString(g_hWeaponData, "192_attribs", "");
	SetTrieValue(g_hWeaponData, "192_ammo", -1);

//Upgradeable kukri
	SetTrieString(g_hWeaponData, "193_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "193_index", 193);
	SetTrieValue(g_hWeaponData, "193_slot", 2);
	SetTrieValue(g_hWeaponData, "193_quality", 6);
	SetTrieValue(g_hWeaponData, "193_level", 1);
	SetTrieString(g_hWeaponData, "193_attribs", "");
	SetTrieValue(g_hWeaponData, "193_ammo", -1);

//Upgradeable knife
	SetTrieString(g_hWeaponData, "194_classname", "tf_weapon_knife");
	SetTrieValue(g_hWeaponData, "194_index", 194);
	SetTrieValue(g_hWeaponData, "194_slot", 2);
	SetTrieValue(g_hWeaponData, "194_quality", 6);
	SetTrieValue(g_hWeaponData, "194_level", 1);
	SetTrieString(g_hWeaponData, "194_attribs", "");
	SetTrieValue(g_hWeaponData, "194_ammo", -1);

//Upgradeable fists
	SetTrieString(g_hWeaponData, "195_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "195_index", 195);
	SetTrieValue(g_hWeaponData, "195_slot", 2);
	SetTrieValue(g_hWeaponData, "195_quality", 6);
	SetTrieValue(g_hWeaponData, "195_level", 1);
	SetTrieString(g_hWeaponData, "195_attribs", "");
	SetTrieValue(g_hWeaponData, "195_ammo", -1);

//Upgradeable shovel
	SetTrieString(g_hWeaponData, "196_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "196_index", 196);
	SetTrieValue(g_hWeaponData, "196_slot", 2);
	SetTrieValue(g_hWeaponData, "196_quality", 6);
	SetTrieValue(g_hWeaponData, "196_level", 1);
	SetTrieString(g_hWeaponData, "196_attribs", "");
	SetTrieValue(g_hWeaponData, "196_ammo", -1);

//Upgradeable wrench
	SetTrieString(g_hWeaponData, "197_classname", "tf_weapon_wrench");
	SetTrieValue(g_hWeaponData, "197_index", 197);
	SetTrieValue(g_hWeaponData, "197_slot", 2);
	SetTrieValue(g_hWeaponData, "197_quality", 6);
	SetTrieValue(g_hWeaponData, "197_level", 1);
	SetTrieString(g_hWeaponData, "197_attribs", "292 ; 3.0 ; 293 ; 0.0");
	SetTrieValue(g_hWeaponData, "197_ammo", -1);

//Upgradeable bonesaw
	SetTrieString(g_hWeaponData, "198_classname", "tf_weapon_bonesaw");
	SetTrieValue(g_hWeaponData, "198_index", 198);
	SetTrieValue(g_hWeaponData, "198_slot", 2);
	SetTrieValue(g_hWeaponData, "198_quality", 6);
	SetTrieValue(g_hWeaponData, "198_level", 1);
	SetTrieString(g_hWeaponData, "198_attribs", "");
	SetTrieValue(g_hWeaponData, "198_ammo", -1);

//Upgradeable shotgun engineer
	SetTrieString(g_hWeaponData, "199_classname", "tf_weapon_shotgun_primary");
	SetTrieValue(g_hWeaponData, "199_index", 199);
	SetTrieValue(g_hWeaponData, "199_slot", 0);
	SetTrieValue(g_hWeaponData, "199_quality", 6);
	SetTrieValue(g_hWeaponData, "199_level", 1);
	SetTrieString(g_hWeaponData, "199_attribs", "");
	SetTrieValue(g_hWeaponData, "199_ammo", 32);

//Upgradeable shotgun other classes
	SetTrieString(g_hWeaponData, "4199_classname", "tf_weapon_shotgun_soldier");
	SetTrieValue(g_hWeaponData, "4199_index", 199);
	SetTrieValue(g_hWeaponData, "4199_slot", 1);
	SetTrieValue(g_hWeaponData, "4199_quality", 6);
	SetTrieValue(g_hWeaponData, "4199_level", 1);
	SetTrieString(g_hWeaponData, "4199_attribs", "");
	SetTrieValue(g_hWeaponData, "4199_ammo", 32);

//Upgradeable scattergun
	SetTrieString(g_hWeaponData, "200_classname", "tf_weapon_scattergun");
	SetTrieValue(g_hWeaponData, "200_index", 200);
	SetTrieValue(g_hWeaponData, "200_slot", 0);
	SetTrieValue(g_hWeaponData, "200_quality", 6);
	SetTrieValue(g_hWeaponData, "200_level", 1);
	SetTrieString(g_hWeaponData, "200_attribs", "");
	SetTrieValue(g_hWeaponData, "200_ammo", 32);

//Upgradeable sniper rifle
	SetTrieString(g_hWeaponData, "201_classname", "tf_weapon_sniperrifle");
	SetTrieValue(g_hWeaponData, "201_index", 201);
	SetTrieValue(g_hWeaponData, "201_slot", 0);
	SetTrieValue(g_hWeaponData, "201_quality", 6);
	SetTrieValue(g_hWeaponData, "201_level", 1);
	SetTrieString(g_hWeaponData, "201_attribs", "");
	SetTrieValue(g_hWeaponData, "201_ammo", 25);

//Upgradeable minigun
	SetTrieString(g_hWeaponData, "202_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "202_index", 202);
	SetTrieValue(g_hWeaponData, "202_slot", 0);
	SetTrieValue(g_hWeaponData, "202_quality", 6);
	SetTrieValue(g_hWeaponData, "202_level", 1);
	SetTrieString(g_hWeaponData, "202_attribs", "");
	SetTrieValue(g_hWeaponData, "202_ammo", 200);

//Upgradeable smg
	SetTrieString(g_hWeaponData, "203_classname", "tf_weapon_smg");
	SetTrieValue(g_hWeaponData, "203_index", 203);
	SetTrieValue(g_hWeaponData, "203_slot", 1);
	SetTrieValue(g_hWeaponData, "203_quality", 6);
	SetTrieValue(g_hWeaponData, "203_level", 1);
	SetTrieString(g_hWeaponData, "203_attribs", "");
	SetTrieValue(g_hWeaponData, "203_ammo", 75);

//Upgradeable syringe gun
	SetTrieString(g_hWeaponData, "204_classname", "tf_weapon_syringegun_medic");
	SetTrieValue(g_hWeaponData, "204_index", 204);
	SetTrieValue(g_hWeaponData, "204_slot", 0);
	SetTrieValue(g_hWeaponData, "204_quality", 6);
	SetTrieValue(g_hWeaponData, "204_level", 1);
	SetTrieString(g_hWeaponData, "204_attribs", "");
	SetTrieValue(g_hWeaponData, "204_ammo", 150);

//Upgradeable rocket launcher
	SetTrieString(g_hWeaponData, "205_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "205_index", 205);
	SetTrieValue(g_hWeaponData, "205_slot", 0);
	SetTrieValue(g_hWeaponData, "205_quality", 6);
	SetTrieValue(g_hWeaponData, "205_level", 1);
	SetTrieString(g_hWeaponData, "205_attribs", "");
	SetTrieValue(g_hWeaponData, "205_ammo", 20);

//Upgradeable grenade launcher
	SetTrieString(g_hWeaponData, "206_classname", "tf_weapon_grenadelauncher");
	SetTrieValue(g_hWeaponData, "206_index", 206);
	SetTrieValue(g_hWeaponData, "206_slot", 0);
	SetTrieValue(g_hWeaponData, "206_quality", 6);
	SetTrieValue(g_hWeaponData, "206_level", 1);
	SetTrieString(g_hWeaponData, "206_attribs", "");
	SetTrieValue(g_hWeaponData, "206_ammo", 16);

//Upgradeable sticky launcher
	SetTrieString(g_hWeaponData, "207_classname", "tf_weapon_pipebomblauncher");
	SetTrieValue(g_hWeaponData, "207_index", 207);
	SetTrieValue(g_hWeaponData, "207_slot", 1);
	SetTrieValue(g_hWeaponData, "207_quality", 6);
	SetTrieValue(g_hWeaponData, "207_level", 1);
	SetTrieString(g_hWeaponData, "207_attribs", "");
	SetTrieValue(g_hWeaponData, "207_ammo", 24);

//Upgradeable flamethrower
	SetTrieString(g_hWeaponData, "208_classname", "tf_weapon_flamethrower");
	SetTrieValue(g_hWeaponData, "208_index", 208);
	SetTrieValue(g_hWeaponData, "208_slot", 0);
	SetTrieValue(g_hWeaponData, "208_quality", 6);
	SetTrieValue(g_hWeaponData, "208_level", 1);
	SetTrieString(g_hWeaponData, "208_attribs", "");
	SetTrieValue(g_hWeaponData, "208_ammo", 200);

//Upgradeable pistol
	SetTrieString(g_hWeaponData, "209_classname", "tf_weapon_pistol");
	SetTrieValue(g_hWeaponData, "209_index", 209);
	SetTrieValue(g_hWeaponData, "209_slot", 1);
	SetTrieValue(g_hWeaponData, "209_quality", 6);
	SetTrieValue(g_hWeaponData, "209_level", 1);
	SetTrieString(g_hWeaponData, "209_attribs", "");
	SetTrieValue(g_hWeaponData, "209_ammo", 100); //36 for scout, 200 for engy, but idk what to use.

//Upgradeable revolver
	SetTrieString(g_hWeaponData, "210_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "210_index", 210);
	SetTrieValue(g_hWeaponData, "210_slot", 0);
	SetTrieValue(g_hWeaponData, "210_quality", 6);
	SetTrieValue(g_hWeaponData, "210_level", 1);
	SetTrieString(g_hWeaponData, "210_attribs", "");
	SetTrieValue(g_hWeaponData, "210_ammo", 24);

//Upgradeable medigun
	SetTrieString(g_hWeaponData, "211_classname", "tf_weapon_medigun");
	SetTrieValue(g_hWeaponData, "211_index", 211);
	SetTrieValue(g_hWeaponData, "211_slot", 1);
	SetTrieValue(g_hWeaponData, "211_quality", 6);
	SetTrieValue(g_hWeaponData, "211_level", 1);
	SetTrieString(g_hWeaponData, "211_attribs", "292 ; 1.0 ; 293 ; 2.0");
	SetTrieValue(g_hWeaponData, "211_ammo", -1);

//Upgradeable invis watch
	SetTrieString(g_hWeaponData, "212_classname", "tf_weapon_invis");
	SetTrieValue(g_hWeaponData, "212_index", 212);
	SetTrieValue(g_hWeaponData, "212_slot", 4);
	SetTrieValue(g_hWeaponData, "212_quality", 6);
	SetTrieValue(g_hWeaponData, "212_level", 1);
	SetTrieString(g_hWeaponData, "212_attribs", "");
	SetTrieValue(g_hWeaponData, "212_ammo", -1);

//The Powerjack
	SetTrieString(g_hWeaponData, "214_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "214_index", 214);
	SetTrieValue(g_hWeaponData, "214_slot", 2);
	SetTrieValue(g_hWeaponData, "214_quality", 6);
	SetTrieValue(g_hWeaponData, "214_level", 5);
//	SetTrieString(g_hWeaponData, "214_attribs", "180 ; 75 ; 2 ; 1.25 ; 15 ; 0");	//old attribs (before april 14, 2011)
	SetTrieString(g_hWeaponData, "214_attribs", "180 ; 75 ; 206 ; 1.2");
	SetTrieValue(g_hWeaponData, "214_ammo", -1);

//The Degreaser
	SetTrieString(g_hWeaponData, "215_classname", "tf_weapon_flamethrower");
	SetTrieValue(g_hWeaponData, "215_index", 215);
	SetTrieValue(g_hWeaponData, "215_slot", 0);
	SetTrieValue(g_hWeaponData, "215_quality", 6);
	SetTrieValue(g_hWeaponData, "215_level", 10);
	SetTrieString(g_hWeaponData, "215_attribs", "178 ; 0.35 ; 72 ; 0.75");
	SetTrieValue(g_hWeaponData, "215_ammo", 200);

//The Shortstop
	SetTrieString(g_hWeaponData, "220_classname", "tf_weapon_handgun_scout_primary");
	SetTrieValue(g_hWeaponData, "220_index", 220);
	SetTrieValue(g_hWeaponData, "220_slot", 0);
	SetTrieValue(g_hWeaponData, "220_quality", 6);
	SetTrieValue(g_hWeaponData, "220_level", 1);
	SetTrieString(g_hWeaponData, "220_attribs", "");
	SetTrieValue(g_hWeaponData, "220_ammo", 36);

//The Holy Mackerel
	SetTrieString(g_hWeaponData, "221_classname", "tf_weapon_bat_fish");
	SetTrieValue(g_hWeaponData, "221_index", 221);
	SetTrieValue(g_hWeaponData, "221_slot", 2);
	SetTrieValue(g_hWeaponData, "221_quality", 6);
	SetTrieValue(g_hWeaponData, "221_level", 42);
	SetTrieString(g_hWeaponData, "221_attribs", "");
	SetTrieValue(g_hWeaponData, "221_ammo", -1);

//Mad Milk
	SetTrieString(g_hWeaponData, "222_classname", "tf_weapon_jar_milk");
	SetTrieValue(g_hWeaponData, "222_index", 222);
	SetTrieValue(g_hWeaponData, "222_slot", 1);
	SetTrieValue(g_hWeaponData, "222_quality", 6);
	SetTrieValue(g_hWeaponData, "222_level", 5);
	SetTrieString(g_hWeaponData, "222_attribs", "");
	SetTrieValue(g_hWeaponData, "222_ammo", 1);

//L'Etranger
	SetTrieString(g_hWeaponData, "224_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "224_index", 224);
	SetTrieValue(g_hWeaponData, "224_slot", 0);
	SetTrieValue(g_hWeaponData, "224_quality", 6);
	SetTrieValue(g_hWeaponData, "224_level", 5);
	SetTrieString(g_hWeaponData, "224_attribs", "166 ; 15.0 ; 1 ; 0.8");
	SetTrieValue(g_hWeaponData, "224_ammo", 24);

//Your Eternal Reward
	SetTrieString(g_hWeaponData, "225_classname", "tf_weapon_knife");
	SetTrieValue(g_hWeaponData, "225_index", 225);
	SetTrieValue(g_hWeaponData, "225_slot", 2);
	SetTrieValue(g_hWeaponData, "225_quality", 6);
	SetTrieValue(g_hWeaponData, "225_level", 1);
	SetTrieString(g_hWeaponData, "225_attribs", "154 ; 1.0 ; 156 ; 1.0 ; 155 ; 1.0 ; 144 ; 1.0");
	SetTrieValue(g_hWeaponData, "225_ammo", -1);

//The Battalion's Backup
	SetTrieString(g_hWeaponData, "226_classname", "tf_weapon_buff_item");
	SetTrieValue(g_hWeaponData, "226_index", 226);
	SetTrieValue(g_hWeaponData, "226_slot", 1);
	SetTrieValue(g_hWeaponData, "226_quality", 6);
	SetTrieValue(g_hWeaponData, "226_level", 10);
	SetTrieString(g_hWeaponData, "226_attribs", "116 ; 2.0");
	SetTrieValue(g_hWeaponData, "226_ammo", -1);

//The Black Box
	SetTrieString(g_hWeaponData, "228_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "228_index", 228);
	SetTrieValue(g_hWeaponData, "228_slot", 0);
	SetTrieValue(g_hWeaponData, "228_quality", 6);
	SetTrieValue(g_hWeaponData, "228_level", 5);
	SetTrieString(g_hWeaponData, "228_attribs", "16 ; 15.0 ; 3 ; 0.75");
	SetTrieValue(g_hWeaponData, "228_ammo", 20);

//The Sydney Sleeper
	SetTrieString(g_hWeaponData, "230_classname", "tf_weapon_sniperrifle");
	SetTrieValue(g_hWeaponData, "230_index", 230);
	SetTrieValue(g_hWeaponData, "230_slot", 0);
	SetTrieValue(g_hWeaponData, "230_quality", 6);
	SetTrieValue(g_hWeaponData, "230_level", 1);
	SetTrieString(g_hWeaponData, "230_attribs", "42 ; 1.0 ; 175 ; 8.0 ; 15 ; 0 ; 41 ; 1.25");
	SetTrieValue(g_hWeaponData, "230_ammo", 25);

//darwin's danger shield (broken NO LONGER)
	SetTrieString(g_hWeaponData, "231_classname", "tf_wearable");
	SetTrieValue(g_hWeaponData, "231_index", 231);
	SetTrieValue(g_hWeaponData, "231_slot", 1);
	SetTrieValue(g_hWeaponData, "231_quality", 6);
	SetTrieValue(g_hWeaponData, "231_level", 10);
	SetTrieString(g_hWeaponData, "231_attribs", "26 ; 25");

//The Bushwacka
	SetTrieString(g_hWeaponData, "232_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "232_index", 232);
	SetTrieValue(g_hWeaponData, "232_slot", 2);
	SetTrieValue(g_hWeaponData, "232_quality", 6);
	SetTrieValue(g_hWeaponData, "232_level", 5);
	SetTrieString(g_hWeaponData, "232_attribs", "179 ; 1 ; 61 ; 1.2");
	SetTrieValue(g_hWeaponData, "232_ammo", -1);

//Rocket Jumper
	SetTrieString(g_hWeaponData, "237_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "237_index", 237);
	SetTrieValue(g_hWeaponData, "237_slot", 0);
	SetTrieValue(g_hWeaponData, "237_quality", 6);
	SetTrieValue(g_hWeaponData, "237_level", 1);
	SetTrieString(g_hWeaponData, "237_attribs", "1 ; 0.0 ; 181 ; 1.0 ; 76 ; 3.0 ; 65 ; 2.0 ; 67 ; 2.0 ; 61 ; 2.0");
	SetTrieValue(g_hWeaponData, "237_ammo", 60);

//gloves of running urgently 
	SetTrieString(g_hWeaponData, "239_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "239_index", 239);
	SetTrieValue(g_hWeaponData, "239_slot", 2);
	SetTrieValue(g_hWeaponData, "239_quality", 6);
	SetTrieValue(g_hWeaponData, "239_level", 10);
	SetTrieString(g_hWeaponData, "239_attribs", "128 ; 1.0 ; 107 ; 1.3 ; 1 ; 0.5 ; 191 ; -6.0 ; 144 ; 2.0");
	SetTrieValue(g_hWeaponData, "239_ammo", -1);

//Frying Pan (Now if only it had augment slots)
	SetTrieString(g_hWeaponData, "264_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "264_index", 264);
	SetTrieValue(g_hWeaponData, "264_slot", 2);
	SetTrieValue(g_hWeaponData, "264_quality", 6);
	SetTrieValue(g_hWeaponData, "264_level", 5);
	SetTrieString(g_hWeaponData, "264_attribs", "195 ; 1");
	SetTrieValue(g_hWeaponData, "264_ammo", -1);

//sticky jumper
	SetTrieString(g_hWeaponData, "265_classname", "tf_weapon_pipebomblauncher");
	SetTrieValue(g_hWeaponData, "265_index", 265);
	SetTrieValue(g_hWeaponData, "265_slot", 1);
	SetTrieValue(g_hWeaponData, "265_quality", 6);
	SetTrieValue(g_hWeaponData, "265_level", 1);
	SetTrieString(g_hWeaponData, "265_attribs", "1 ; 0.0 ; 181 ; 1.0 ; 78 ; 3.0 ; 65 ; 2.0 ; 67 ; 2.0 ; 61 ; 2.0");
	SetTrieValue(g_hWeaponData, "265_ammo", 72);

//horseless headless horsemann's headtaker
	SetTrieString(g_hWeaponData, "266_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "266_index", 266);
	SetTrieValue(g_hWeaponData, "266_slot", 2);
	SetTrieValue(g_hWeaponData, "266_quality", 5);
	SetTrieValue(g_hWeaponData, "266_level", 5);
	SetTrieString(g_hWeaponData, "266_attribs", "15 ; 0 ; 125 ; -25 ; 219 ; 1.0");
	SetTrieValue(g_hWeaponData, "266_ammo", -1);

//lugermorph from Poker Night
	SetTrieString(g_hWeaponData, "294_classname", "tf_weapon_pistol");
	SetTrieValue(g_hWeaponData, "294_index", 294);
	SetTrieValue(g_hWeaponData, "294_slot", 1);
	SetTrieValue(g_hWeaponData, "294_quality", 6);
	SetTrieValue(g_hWeaponData, "294_level", 5);
	SetTrieString(g_hWeaponData, "294_attribs", "");
	SetTrieValue(g_hWeaponData, "294_ammo", 36);

//Enthusiast's Timepiece
	SetTrieString(g_hWeaponData, "297_classname", "tf_weapon_invis");
	SetTrieValue(g_hWeaponData, "297_index", 297);
	SetTrieValue(g_hWeaponData, "297_slot", 4);
	SetTrieValue(g_hWeaponData, "297_quality", 6);
	SetTrieValue(g_hWeaponData, "297_level", 5);
	SetTrieString(g_hWeaponData, "297_attribs", "");
	SetTrieValue(g_hWeaponData, "297_ammo", -1);

//The Iron Curtain
	SetTrieString(g_hWeaponData, "298_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "298_index", 298);
	SetTrieValue(g_hWeaponData, "298_slot", 0);
	SetTrieValue(g_hWeaponData, "298_quality", 6);
	SetTrieValue(g_hWeaponData, "298_level", 5);
	SetTrieString(g_hWeaponData, "298_attribs", "");
	SetTrieValue(g_hWeaponData, "298_ammo", 200);

//Amputator
	SetTrieString(g_hWeaponData, "304_classname", "tf_weapon_bonesaw");
	SetTrieValue(g_hWeaponData, "304_index", 304);
	SetTrieValue(g_hWeaponData, "304_slot", 2);
	SetTrieValue(g_hWeaponData, "304_quality", 6);
	SetTrieValue(g_hWeaponData, "304_level", 15);
	SetTrieString(g_hWeaponData, "304_attribs", "200 ; 1 ; 144 ; 3.0");
	SetTrieValue(g_hWeaponData, "304_ammo", -1);

//Crusader's Crossbow
	SetTrieString(g_hWeaponData, "305_classname", "tf_weapon_crossbow");
	SetTrieValue(g_hWeaponData, "305_index", 305);
	SetTrieValue(g_hWeaponData, "305_slot", 0);
	SetTrieValue(g_hWeaponData, "305_quality", 6);
	SetTrieValue(g_hWeaponData, "305_level", 15);
	SetTrieString(g_hWeaponData, "305_attribs", "199 ; 1.0 ; 42 ; 1.0 ; 77 ; 0.25");
	SetTrieValue(g_hWeaponData, "305_ammo", 38);

//Ullapool Caber
	SetTrieString(g_hWeaponData, "307_classname", "tf_weapon_stickbomb");
	SetTrieValue(g_hWeaponData, "307_index", 307);
	SetTrieValue(g_hWeaponData, "307_slot", 2);
	SetTrieValue(g_hWeaponData, "307_quality", 6);
	SetTrieValue(g_hWeaponData, "307_level", 10);
	SetTrieString(g_hWeaponData, "307_attribs", "15 ; 0");
	SetTrieValue(g_hWeaponData, "307_ammo", -1);

//Loch-n-Load
	SetTrieString(g_hWeaponData, "308_classname", "tf_weapon_grenadelauncher");
	SetTrieValue(g_hWeaponData, "308_index", 308);
	SetTrieValue(g_hWeaponData, "308_slot", 0);
	SetTrieValue(g_hWeaponData, "308_quality", 6);
	SetTrieValue(g_hWeaponData, "308_level", 10);
	SetTrieString(g_hWeaponData, "308_attribs", "3 ; 0.4 ; 2 ; 1.2 ; 103 ; 1.25 ; 207 ; 1.25 ; 127 ; 2.0");
	SetTrieValue(g_hWeaponData, "308_ammo", 16);

//Warrior's Spirit
	SetTrieString(g_hWeaponData, "310_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "310_index", 310);
	SetTrieValue(g_hWeaponData, "310_slot", 2);
	SetTrieValue(g_hWeaponData, "310_quality", 6);
	SetTrieValue(g_hWeaponData, "310_level", 10);
	SetTrieString(g_hWeaponData, "310_attribs", "2 ; 1.3 ; 125 ; -20");
	SetTrieValue(g_hWeaponData, "310_ammo", -1);

//Buffalo Steak Sandvich
	SetTrieString(g_hWeaponData, "311_classname", "tf_weapon_lunchbox");
	SetTrieValue(g_hWeaponData, "311_index", 311);
	SetTrieValue(g_hWeaponData, "311_slot", 1);
	SetTrieValue(g_hWeaponData, "311_quality", 6);
	SetTrieValue(g_hWeaponData, "311_level", 1);
	SetTrieString(g_hWeaponData, "311_attribs", "144 ; 2");
	SetTrieValue(g_hWeaponData, "311_ammo", 1);

//Brass Beast
	SetTrieString(g_hWeaponData, "312_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "312_index", 312);
	SetTrieValue(g_hWeaponData, "312_slot", 0);
	SetTrieValue(g_hWeaponData, "312_quality", 6);
	SetTrieValue(g_hWeaponData, "312_level", 5);
	SetTrieString(g_hWeaponData, "312_attribs", "2 ; 1.2 ; 86 ; 1.5 ; 183 ; 0.4");
	SetTrieValue(g_hWeaponData, "312_ammo", 200);

//Candy Cane
	SetTrieString(g_hWeaponData, "317_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "317_index", 317);
	SetTrieValue(g_hWeaponData, "317_slot", 2);
	SetTrieValue(g_hWeaponData, "317_quality", 6);
	SetTrieValue(g_hWeaponData, "317_level", 25);
	SetTrieString(g_hWeaponData, "317_attribs", "203 ; 1.0 ; 65 ; 1.25");
	SetTrieValue(g_hWeaponData, "317_ammo", -1);

//Boston Basher
	SetTrieString(g_hWeaponData, "325_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "325_index", 325);
	SetTrieValue(g_hWeaponData, "325_slot", 2);
	SetTrieValue(g_hWeaponData, "325_quality", 6);
	SetTrieValue(g_hWeaponData, "325_level", 25);
	SetTrieString(g_hWeaponData, "325_attribs", "149 ; 5.0 ; 204 ; 1.0");
	SetTrieValue(g_hWeaponData, "325_ammo", -1);

//Backscratcher
	SetTrieString(g_hWeaponData, "326_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "326_index", 326);
	SetTrieValue(g_hWeaponData, "326_slot", 2);
	SetTrieValue(g_hWeaponData, "326_quality", 6);
	SetTrieValue(g_hWeaponData, "326_level", 10);
	SetTrieString(g_hWeaponData, "326_attribs", "2 ; 1.25 ; 69 ; 0.25 ; 108 ; 1.5");
	SetTrieValue(g_hWeaponData, "326_ammo", -1);

//Claidheamh M�r
	SetTrieString(g_hWeaponData, "327_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "327_index", 327);
	SetTrieValue(g_hWeaponData, "327_slot", 2);
	SetTrieValue(g_hWeaponData, "327_quality", 6);
	SetTrieValue(g_hWeaponData, "327_level", 5);
	SetTrieString(g_hWeaponData, "327_attribs", "15 ; 0.0 ; 202 ; 0.5 ; 125 ; -15");
	SetTrieValue(g_hWeaponData, "327_ammo", -1);

//Jag
	SetTrieString(g_hWeaponData, "329_classname", "tf_weapon_wrench");
	SetTrieValue(g_hWeaponData, "329_index", 329);
	SetTrieValue(g_hWeaponData, "329_slot", 2);
	SetTrieValue(g_hWeaponData, "329_quality", 6);
	SetTrieValue(g_hWeaponData, "329_level", 15);
	SetTrieString(g_hWeaponData, "329_attribs", "92 ; 1.3 ; 1 ; 0.75 ; 292 ; 3.0 ; 293 ; 0.0");
	SetTrieValue(g_hWeaponData, "329_ammo", -1);

//Fists of Steel
	SetTrieString(g_hWeaponData, "331_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "331_index", 331);
	SetTrieValue(g_hWeaponData, "331_slot", 2);
	SetTrieValue(g_hWeaponData, "331_quality", 6);
	SetTrieValue(g_hWeaponData, "331_level", 10);
	SetTrieString(g_hWeaponData, "331_attribs", "205 ; 0.6 ; 206 ; 2.0 ; 177 ; 1.2");
	SetTrieValue(g_hWeaponData, "331_ammo", -1);

//Sharpened Volcano Fragment
	SetTrieString(g_hWeaponData, "348_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "348_index", 348);
	SetTrieValue(g_hWeaponData, "348_slot", 2);
	SetTrieValue(g_hWeaponData, "348_quality", 6);
	SetTrieValue(g_hWeaponData, "348_level", 10);
	SetTrieString(g_hWeaponData, "348_attribs", "208 ; 1.0 ; 1 ; 0.8");
	SetTrieValue(g_hWeaponData, "348_ammo", -1);

//Sun on a Stick
	SetTrieString(g_hWeaponData, "349_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "349_index", 349);
	SetTrieValue(g_hWeaponData, "349_slot", 2);
	SetTrieValue(g_hWeaponData, "349_quality", 6);
	SetTrieValue(g_hWeaponData, "349_level", 10);
//	SetTrieString(g_hWeaponData, "349_attribs", "209 ; 1.0 ; 1 ; 0.85 ; 153 ; 1.0");	//old pre april 14, 2011 attribs
	SetTrieString(g_hWeaponData, "349_attribs", "20 ; 1.0 ; 1 ; 0.75");
	SetTrieValue(g_hWeaponData, "349_ammo", -1);

//Detonator
	SetTrieString(g_hWeaponData, "351_classname", "tf_weapon_flaregun");
	SetTrieValue(g_hWeaponData, "351_index", 351);
	SetTrieValue(g_hWeaponData, "351_slot", 1);
	SetTrieValue(g_hWeaponData, "351_quality", 6);
	SetTrieValue(g_hWeaponData, "351_level", 10);
	SetTrieString(g_hWeaponData, "351_attribs", "25 ; 0.5 ; 207 ; 1.25 ; 144 ; 1.0");	//207 used to be 65
	SetTrieValue(g_hWeaponData, "351_ammo", 16);

//Soldier's Sashimono - The Concheror
	SetTrieString(g_hWeaponData, "354_classname", "tf_weapon_buff_item");
	SetTrieValue(g_hWeaponData, "354_index", 354);
	SetTrieValue(g_hWeaponData, "354_slot", 1);
	SetTrieValue(g_hWeaponData, "354_quality", 6);
	SetTrieValue(g_hWeaponData, "354_level", 5);
	SetTrieString(g_hWeaponData, "354_attribs", "116 ; 3.0");
	SetTrieValue(g_hWeaponData, "354_ammo", -1);

//Gunbai - Fan o'War
	SetTrieString(g_hWeaponData, "355_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "355_index", 355);
	SetTrieValue(g_hWeaponData, "355_slot", 2);
	SetTrieValue(g_hWeaponData, "355_quality", 6);
	SetTrieValue(g_hWeaponData, "355_level", 5);
	SetTrieString(g_hWeaponData, "355_attribs", "218 ; 1.0 ; 1 ; 0.1");
	SetTrieValue(g_hWeaponData, "355_ammo", -1);

//Kunai - Conniver's Kunai
	SetTrieString(g_hWeaponData, "356_classname", "tf_weapon_knife");
	SetTrieValue(g_hWeaponData, "356_index", 356);
	SetTrieValue(g_hWeaponData, "356_slot", 2);
	SetTrieValue(g_hWeaponData, "356_quality", 6);
	SetTrieValue(g_hWeaponData, "356_level", 1);
	SetTrieString(g_hWeaponData, "356_attribs", "217 ; 1.0 ; 125 ; -65 ; 144 ; 1");
	SetTrieValue(g_hWeaponData, "356_ammo", -1);

//Soldier Katana - The Half-Zatoichi
	SetTrieString(g_hWeaponData, "357_classname", "tf_weapon_katana");
	SetTrieValue(g_hWeaponData, "357_index", 357);
	SetTrieValue(g_hWeaponData, "357_slot", 2);
	SetTrieValue(g_hWeaponData, "357_quality", 6);
	SetTrieValue(g_hWeaponData, "357_level", 5);
	SetTrieString(g_hWeaponData, "357_attribs", "219 ; 1.0 ; 220 ; 100.0 ; 226 ; 1");
	SetTrieValue(g_hWeaponData, "357_ammo", -1);

//Shahanshah
	SetTrieString(g_hWeaponData, "401_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "401_index", 401);
	SetTrieValue(g_hWeaponData, "401_slot", 2);
	SetTrieValue(g_hWeaponData, "401_quality", 6);
	SetTrieValue(g_hWeaponData, "401_level", 5);
	SetTrieString(g_hWeaponData, "401_attribs", "224 ; 1.25 ; 225 ; 0.75");
	SetTrieValue(g_hWeaponData, "401_ammo", -1);

//Bazaar Bargain
	SetTrieString(g_hWeaponData, "402_classname", "tf_weapon_sniperrifle_decap");
	SetTrieValue(g_hWeaponData, "402_index", 402);
	SetTrieValue(g_hWeaponData, "402_slot", 0);
	SetTrieValue(g_hWeaponData, "402_quality", 6);
	SetTrieValue(g_hWeaponData, "402_level", 10);
	SetTrieString(g_hWeaponData, "402_attribs", "268 ; 1.2");
	SetTrieValue(g_hWeaponData, "402_ammo", 25);

//Persian Persuader
	SetTrieString(g_hWeaponData, "404_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "404_index", 404);
	SetTrieValue(g_hWeaponData, "404_slot", 2);
	SetTrieValue(g_hWeaponData, "404_quality", 6);
	SetTrieValue(g_hWeaponData, "404_level", 10);
	SetTrieString(g_hWeaponData, "404_attribs", "249 ; 2.0 ; 258 ; 1.0 ; 15 ; 0.0");
	SetTrieValue(g_hWeaponData, "404_ammo", -1);

//Ali Baba's Wee Booties
	SetTrieString(g_hWeaponData, "405_classname", "tf_wearable");
	SetTrieValue(g_hWeaponData, "405_index", 405);
	SetTrieValue(g_hWeaponData, "405_slot", 0);
	SetTrieValue(g_hWeaponData, "405_quality", 6);
	SetTrieValue(g_hWeaponData, "405_level", 10);
	SetTrieString(g_hWeaponData, "405_attribs", "246 ; 2.0 ; 26 ; 25.0");
	SetTrieValue(g_hWeaponData, "405_ammo", -1);

//Splendid Screen
	SetTrieString(g_hWeaponData, "406_classname", "tf_wearable_demoshield");
	SetTrieValue(g_hWeaponData, "406_index", 406);
	SetTrieValue(g_hWeaponData, "406_slot", 1);
	SetTrieValue(g_hWeaponData, "406_quality", 6);
	SetTrieValue(g_hWeaponData, "406_level", 10);
	SetTrieString(g_hWeaponData, "406_attribs", "247 ; 1.0 ; 248 ; 1.7 ; 60 ; 0.8 ; 64 ; 0.85");
	SetTrieValue(g_hWeaponData, "406_ammo", -1);

//Quick Fix
	SetTrieString(g_hWeaponData, "411_classname", "tf_weapon_medigun");
	SetTrieValue(g_hWeaponData, "411_index", 411);
	SetTrieValue(g_hWeaponData, "411_slot", 1);
	SetTrieValue(g_hWeaponData, "411_quality", 6);
	SetTrieValue(g_hWeaponData, "411_level", 8);
	SetTrieString(g_hWeaponData, "411_attribs", "231 ; 2.0 ; 8 ; 1.4 ; 10 ; 1.25 ; 144 ; 2.0");
	SetTrieValue(g_hWeaponData, "411_ammo", -1);

//Overdose
	SetTrieString(g_hWeaponData, "412_classname", "tf_weapon_syringegun_medic");
	SetTrieValue(g_hWeaponData, "412_index", 412);
	SetTrieValue(g_hWeaponData, "412_slot", 0);
	SetTrieValue(g_hWeaponData, "412_quality", 6);
	SetTrieValue(g_hWeaponData, "412_level", 5);
	SetTrieString(g_hWeaponData, "412_attribs", "144 ; 1.0 ; 1 ; 0.9");
	SetTrieValue(g_hWeaponData, "412_ammo", 150);

//Solemn Vow (Also known as Hippocrates)
	SetTrieString(g_hWeaponData, "413_classname", "tf_weapon_bonesaw");
	SetTrieValue(g_hWeaponData, "413_index", 413);
	SetTrieValue(g_hWeaponData, "413_slot", 2);
	SetTrieValue(g_hWeaponData, "413_quality", 6);
	SetTrieValue(g_hWeaponData, "413_level", 10);
	SetTrieString(g_hWeaponData, "413_attribs", "269 ; 1.0");
	SetTrieValue(g_hWeaponData, "413_ammo", -1);

//Liberty Launcher
	SetTrieString(g_hWeaponData, "414_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "414_index", 414);
	SetTrieValue(g_hWeaponData, "414_slot", 0);
	SetTrieValue(g_hWeaponData, "414_quality", 6);
	SetTrieValue(g_hWeaponData, "414_level", 25);
	SetTrieString(g_hWeaponData, "414_attribs", "103 ; 1.4 ; 3 ; 0.75");
	SetTrieValue(g_hWeaponData, "414_ammo", 20);

//Reserve Shooter
	SetTrieString(g_hWeaponData, "415_classname", "tf_weapon_shotgun_soldier");
	SetTrieValue(g_hWeaponData, "415_index", 415);
	SetTrieValue(g_hWeaponData, "415_slot", 1);
	SetTrieValue(g_hWeaponData, "415_quality", 6);
	SetTrieValue(g_hWeaponData, "415_level", 10);
	SetTrieString(g_hWeaponData, "415_attribs", "178 ; 0.85 ; 265 ; 3.0 ; 3 ; 0.5");
	SetTrieValue(g_hWeaponData, "415_ammo", 32);

//Market Gardener
	SetTrieString(g_hWeaponData, "416_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "416_index", 416);
	SetTrieValue(g_hWeaponData, "416_slot", 2);
	SetTrieValue(g_hWeaponData, "416_quality", 6);
	SetTrieValue(g_hWeaponData, "416_level", 10);
	SetTrieString(g_hWeaponData, "416_attribs", "267 ; 1.0 ; 15 ; 0.0");
	SetTrieValue(g_hWeaponData, "416_ammo", -1);

//Saxxy
	SetTrieString(g_hWeaponData, "423_classname", "saxxy");
	SetTrieValue(g_hWeaponData, "423_index", 423);
	SetTrieValue(g_hWeaponData, "423_slot", 2);
	SetTrieValue(g_hWeaponData, "423_quality", 6);
	SetTrieValue(g_hWeaponData, "423_level", 25);
	SetTrieString(g_hWeaponData, "423_attribs", "150 ; 1.0");
	SetTrieValue(g_hWeaponData, "423_ammo", -1);

//Tomislav
	SetTrieString(g_hWeaponData, "424_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "424_index", 424);
	SetTrieValue(g_hWeaponData, "424_slot", 0);
	SetTrieValue(g_hWeaponData, "424_quality", 6);
	SetTrieValue(g_hWeaponData, "424_level", 5);
	SetTrieString(g_hWeaponData, "424_attribs", "87 ; 0.6 ; 238 ; 1.0 ; 5 ; 1.2");
	SetTrieValue(g_hWeaponData, "424_ammo", 200);

//Family Business
	SetTrieString(g_hWeaponData, "425_classname", "tf_weapon_shotgun_hwg");
	SetTrieValue(g_hWeaponData, "425_index", 425);
	SetTrieValue(g_hWeaponData, "425_slot", 1);
	SetTrieValue(g_hWeaponData, "425_quality", 6);
	SetTrieValue(g_hWeaponData, "425_level", 10);
	SetTrieString(g_hWeaponData, "425_attribs", "4 ; 1.4 ; 1 ; 0.85");
	SetTrieValue(g_hWeaponData, "425_ammo", 32);

//Eviction Notice
	SetTrieString(g_hWeaponData, "426_classname", "tf_weapon_fists");
	SetTrieValue(g_hWeaponData, "426_index", 426);
	SetTrieValue(g_hWeaponData, "426_slot", 2);
	SetTrieValue(g_hWeaponData, "426_quality", 6);
	SetTrieValue(g_hWeaponData, "426_level", 10);
	SetTrieString(g_hWeaponData, "426_attribs", "6 ; 0.5 ; 1 ; 0.4");
	SetTrieValue(g_hWeaponData, "426_ammo", -1);

//Fishcake
	SetTrieString(g_hWeaponData, "433_classname", "tf_weapon_lunchbox");
	SetTrieValue(g_hWeaponData, "433_index", 433);
	SetTrieValue(g_hWeaponData, "433_slot", 1);
	SetTrieValue(g_hWeaponData, "433_quality", 6);
	SetTrieValue(g_hWeaponData, "433_level", 1);
	SetTrieString(g_hWeaponData, "433_attribs", "139 ; 1");
	SetTrieValue(g_hWeaponData, "433_ammo", 1);

//Cow Mangler 5000
	SetTrieString(g_hWeaponData, "441_classname", "tf_weapon_particle_cannon");
	SetTrieValue(g_hWeaponData, "441_index", 441);
	SetTrieValue(g_hWeaponData, "441_slot", 0);
	SetTrieValue(g_hWeaponData, "441_quality", 6);
	SetTrieValue(g_hWeaponData, "441_level", 30);
	SetTrieString(g_hWeaponData, "441_attribs", "281 ; 1.0 ; 282 ; 1.0 ; 15 ; 0.0 ; 284 ; 1.0 ; 1 ; 0.9 ; 288 ; 1.0 ; 96 ; 1.05");
	SetTrieValue(g_hWeaponData, "441_ammo", -1);

//Righteous Bison
	SetTrieString(g_hWeaponData, "442_classname", "tf_weapon_raygun");
	SetTrieValue(g_hWeaponData, "442_index", 442);
	SetTrieValue(g_hWeaponData, "442_slot", 1);
	SetTrieValue(g_hWeaponData, "442_quality", 6);
	SetTrieValue(g_hWeaponData, "442_level", 30);
	SetTrieString(g_hWeaponData, "442_attribs", "281 ; 1.0 ; 283 ; 1.0 ; 285 ; 0.0 ; 284 ; 1.0");
	SetTrieValue(g_hWeaponData, "442_ammo", -1);

//Mantreads
	SetTrieString(g_hWeaponData, "444_classname", "tf_wearable");
	SetTrieValue(g_hWeaponData, "444_index", 444);
	SetTrieValue(g_hWeaponData, "444_slot", 1);
	SetTrieValue(g_hWeaponData, "444_quality", 6);
	SetTrieValue(g_hWeaponData, "444_level", 10);
	SetTrieString(g_hWeaponData, "444_attribs", "252 ; 0.25 ; 259 ; 1.0");
	SetTrieValue(g_hWeaponData, "444_ammo", -1);

//Disciplinary Action
	SetTrieString(g_hWeaponData, "447_classname", "tf_weapon_shovel");
	SetTrieValue(g_hWeaponData, "447_index", 447);
	SetTrieValue(g_hWeaponData, "447_slot", 2);
	SetTrieValue(g_hWeaponData, "447_quality", 6);
	SetTrieValue(g_hWeaponData, "447_level", 10);
	SetTrieString(g_hWeaponData, "447_attribs", "251 ; 1.0 ; 1 ; 0.75 ; 264 ; 1.7 ; 263 ; 1.55");
	SetTrieValue(g_hWeaponData, "447_ammo", -1);

//Soda Popper
	SetTrieString(g_hWeaponData, "448_classname", "tf_weapon_soda_popper");
	SetTrieValue(g_hWeaponData, "448_index", 448);
	SetTrieValue(g_hWeaponData, "448_slot", 0);
	SetTrieValue(g_hWeaponData, "448_quality", 6);
	SetTrieValue(g_hWeaponData, "448_level", 10);
	SetTrieString(g_hWeaponData, "448_attribs", "6 ; 0.5 ; 97 ; 0.75 ; 3 ; 0.4 ; 15 ; 0.0 ; 43 ; 1.0");
	SetTrieValue(g_hWeaponData, "448_ammo", 32);

//Winger
	SetTrieString(g_hWeaponData, "449_classname", "tf_weapon_handgun_scout_secondary");
	SetTrieValue(g_hWeaponData, "449_index", 449);
	SetTrieValue(g_hWeaponData, "449_slot", 1);
	SetTrieValue(g_hWeaponData, "449_quality", 6);
	SetTrieValue(g_hWeaponData, "449_level", 15);
	SetTrieString(g_hWeaponData, "449_attribs", "2 ; 1.15 ; 3 ; 0.4");
	SetTrieValue(g_hWeaponData, "449_ammo", 36);

//Atomizer
	SetTrieString(g_hWeaponData, "450_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "450_index", 450);
	SetTrieValue(g_hWeaponData, "450_slot", 2);
	SetTrieValue(g_hWeaponData, "450_quality", 6);
	SetTrieValue(g_hWeaponData, "450_level", 10);
	SetTrieString(g_hWeaponData, "450_attribs", "250 ; 1.0 ; 5 ; 1.3 ; 138 ; 0.8");
	SetTrieValue(g_hWeaponData, "450_ammo", -1);

//Three-Rune Blade
	SetTrieString(g_hWeaponData, "452_classname", "tf_weapon_bat");
	SetTrieValue(g_hWeaponData, "452_index", 452);
	SetTrieValue(g_hWeaponData, "452_slot", 2);
	SetTrieValue(g_hWeaponData, "452_quality", 6);
	SetTrieValue(g_hWeaponData, "452_level", 10);
	SetTrieString(g_hWeaponData, "452_attribs", "149 ; 5.0 ; 204 ; 1.0");
	SetTrieValue(g_hWeaponData, "452_ammo", -1);

//Postal Pummeler
	SetTrieString(g_hWeaponData, "457_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "457_index", 457);
	SetTrieValue(g_hWeaponData, "457_slot", 2);
	SetTrieValue(g_hWeaponData, "457_quality", 6);
	SetTrieValue(g_hWeaponData, "457_level", 10);
	SetTrieString(g_hWeaponData, "457_attribs", "20 ; 1.0 ; 21 ; 0.5 ; 22 ; 1.0");
	SetTrieValue(g_hWeaponData, "457_ammo", -1);

//Enforcer
	SetTrieString(g_hWeaponData, "460_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "460_index", 460);
	SetTrieValue(g_hWeaponData, "460_slot", 0);
	SetTrieValue(g_hWeaponData, "460_quality", 6);
	SetTrieValue(g_hWeaponData, "460_level", 5);
	SetTrieString(g_hWeaponData, "460_attribs", "2 ; 1.2 ; 253 ; 0.5");
	SetTrieValue(g_hWeaponData, "460_ammo", 24);

//Big Earner
	SetTrieString(g_hWeaponData, "461_classname", "tf_weapon_knife");
	SetTrieValue(g_hWeaponData, "461_index", 461);
	SetTrieValue(g_hWeaponData, "461_slot", 2);
	SetTrieValue(g_hWeaponData, "461_quality", 6);
	SetTrieValue(g_hWeaponData, "461_level", 1);
	SetTrieString(g_hWeaponData, "461_attribs", "158 ; 30 ; 125 ; -25");
	SetTrieValue(g_hWeaponData, "461_ammo", -1);

//Maul
	SetTrieString(g_hWeaponData, "466_classname", "tf_weapon_fireaxe");
	SetTrieValue(g_hWeaponData, "466_index", 466);
	SetTrieValue(g_hWeaponData, "466_slot", 2);
	SetTrieValue(g_hWeaponData, "466_quality", 6);
	SetTrieValue(g_hWeaponData, "466_level", 5);
	SetTrieString(g_hWeaponData, "466_attribs", "137 ; 2.0 ; 138 ; 0.75 ; 146 ; 1");
	SetTrieValue(g_hWeaponData, "466_ammo", -1);

//Nessie's Nine Iron
	SetTrieString(g_hWeaponData, "482_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "482_index", 482);
	SetTrieValue(g_hWeaponData, "482_slot", 2);
	SetTrieValue(g_hWeaponData, "482_quality", 6);
	SetTrieValue(g_hWeaponData, "482_level", 5);
	SetTrieString(g_hWeaponData, "482_attribs", "15 ; 0 ; 125 ; -25 ; 219 ; 1.0");
	SetTrieValue(g_hWeaponData, "482_ammo", -1);

//The Original
	SetTrieString(g_hWeaponData, "513_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "513_index", 513);
	SetTrieValue(g_hWeaponData, "513_slot", 0);
	SetTrieValue(g_hWeaponData, "513_quality", 6);
	SetTrieValue(g_hWeaponData, "513_level", 5);
	SetTrieString(g_hWeaponData, "513_attribs", "289 ; 1");
	SetTrieValue(g_hWeaponData, "513_ammo", 20);

//The Diamondback
	SetTrieString(g_hWeaponData, "525_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "525_index", 525);
	SetTrieValue(g_hWeaponData, "525_slot", 0);
	SetTrieValue(g_hWeaponData, "525_quality", 6);
	SetTrieValue(g_hWeaponData, "525_level", 5);
	SetTrieString(g_hWeaponData, "525_attribs", "296 ; 1.0 ; 1 ; 0.85 ; 15 ; 0.0");
	SetTrieValue(g_hWeaponData, "525_ammo", 24);

//The Machina
	SetTrieString(g_hWeaponData, "526_classname", "tf_weapon_sniperrifle");
	SetTrieValue(g_hWeaponData, "526_index", 526);
	SetTrieValue(g_hWeaponData, "526_slot", 0);
	SetTrieValue(g_hWeaponData, "526_quality", 6);
	SetTrieValue(g_hWeaponData, "526_level", 5);
	SetTrieString(g_hWeaponData, "526_attribs", "304 ; 1.15 ; 308 ; 1.0 ; 297 ; 1.0 ; 305 ; 1.0");
	SetTrieValue(g_hWeaponData, "526_ammo", 25);

//The Widowmaker
	SetTrieString(g_hWeaponData, "527_classname", "tf_weapon_shotgun_primary");
	SetTrieValue(g_hWeaponData, "527_index", 527);
	SetTrieValue(g_hWeaponData, "527_slot", 0);
	SetTrieValue(g_hWeaponData, "527_quality", 6);
	SetTrieValue(g_hWeaponData, "527_level", 5);
	SetTrieString(g_hWeaponData, "527_attribs", "299 ; 100.0 ; 307 ; 1.0 ; 303 ; -1.0 ; 298 ; 60.0 ; 301 ; 1.0");
	SetTrieValue(g_hWeaponData, "527_ammo", 200);

//The Short Circuit
	SetTrieString(g_hWeaponData, "528_classname", "tf_weapon_mechanical_arm");
	SetTrieValue(g_hWeaponData, "528_index", 528);
	SetTrieValue(g_hWeaponData, "528_slot", 1);
	SetTrieValue(g_hWeaponData, "528_quality", 6);
	SetTrieValue(g_hWeaponData, "528_level", 5);
	SetTrieString(g_hWeaponData, "528_attribs", "300 ; 1.0 ; 307 ; 1.0 ; 303 ; -1.0 ; 15 ; 0.0 ; 298 ; 35.0 ; 301 ; 1.0 ; 312 ; 1.0");
	SetTrieValue(g_hWeaponData, "528_ammo", 200);

//The Thermal Thruster
	SetTrieString(g_hWeaponData, "1179_classname", "tf_weapon_rocketpack");
	SetTrieValue(g_hWeaponData, "1179_index", 1179);
	SetTrieValue(g_hWeaponData, "1179_slot", 1);
	SetTrieValue(g_hWeaponData, "1179_quality", 6);
	SetTrieValue(g_hWeaponData, "1179_level", 5);
	SetTrieString(g_hWeaponData, "1179_attribs", "");
	SetTrieValue(g_hWeaponData, "1179_ammo", 200);

//valve rocket launcher
	SetTrieString(g_hWeaponData, "9018_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "9018_index", 18);
	SetTrieValue(g_hWeaponData, "9018_slot", 0);
	SetTrieValue(g_hWeaponData, "9018_quality", 8);
	SetTrieValue(g_hWeaponData, "9018_level", 100);
	SetTrieString(g_hWeaponData, "9018_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9018_ammo", 200);

//valve sticky launcher
	SetTrieString(g_hWeaponData, "9020_classname", "tf_weapon_pipebomblauncher");
	SetTrieValue(g_hWeaponData, "9020_index", 20);
	SetTrieValue(g_hWeaponData, "9020_slot", 1);
	SetTrieValue(g_hWeaponData, "9020_quality", 8);
	SetTrieValue(g_hWeaponData, "9020_level", 100);
	SetTrieString(g_hWeaponData, "9020_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9020_ammo", 200);

//valve sniper rifle
	SetTrieString(g_hWeaponData, "9014_classname", "tf_weapon_sniperrifle");
	SetTrieValue(g_hWeaponData, "9014_index", 14);
	SetTrieValue(g_hWeaponData, "9014_slot", 0);
	SetTrieValue(g_hWeaponData, "9014_quality", 8);
	SetTrieValue(g_hWeaponData, "9014_level", 100);
	SetTrieString(g_hWeaponData, "9014_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9014_ammo", 200);

//valve scattergun
	SetTrieString(g_hWeaponData, "9013_classname", "tf_weapon_scattergun");
	SetTrieValue(g_hWeaponData, "9013_index", 13);
	SetTrieValue(g_hWeaponData, "9013_slot", 0);
	SetTrieValue(g_hWeaponData, "9013_quality", 8);
	SetTrieValue(g_hWeaponData, "9013_level", 100);
	SetTrieString(g_hWeaponData, "9013_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9013_ammo", 200);

//valve flamethrower
	SetTrieString(g_hWeaponData, "9021_classname", "tf_weapon_flamethrower");
	SetTrieValue(g_hWeaponData, "9021_index", 21);
	SetTrieValue(g_hWeaponData, "9021_slot", 0);
	SetTrieValue(g_hWeaponData, "9021_quality", 8);
	SetTrieValue(g_hWeaponData, "9021_level", 100);
	SetTrieString(g_hWeaponData, "9021_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9021_ammo", 400);

//valve syringe gun
	SetTrieString(g_hWeaponData, "9017_classname", "tf_weapon_syringegun_medic");
	SetTrieValue(g_hWeaponData, "9017_index", 17);
	SetTrieValue(g_hWeaponData, "9017_slot", 0);
	SetTrieValue(g_hWeaponData, "9017_quality", 8);
	SetTrieValue(g_hWeaponData, "9017_level", 100);
	SetTrieString(g_hWeaponData, "9017_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9017_ammo", 300);

//valve minigun
	SetTrieString(g_hWeaponData, "9015_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "9015_index", 15);
	SetTrieValue(g_hWeaponData, "9015_slot", 0);
	SetTrieValue(g_hWeaponData, "9015_quality", 8);
	SetTrieValue(g_hWeaponData, "9015_level", 100);
	SetTrieString(g_hWeaponData, "9015_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9015_ammo", 400);

//valve revolver
	SetTrieString(g_hWeaponData, "9024_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "9024_index", 24);
	SetTrieValue(g_hWeaponData, "9024_slot", 0);
	SetTrieValue(g_hWeaponData, "9024_quality", 8);
	SetTrieValue(g_hWeaponData, "9024_level", 100);
	SetTrieString(g_hWeaponData, "9024_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9024_ammo", 100);

//valve shotgun engineer
	SetTrieString(g_hWeaponData, "9009_classname", "tf_weapon_shotgun_primary");
	SetTrieValue(g_hWeaponData, "9009_index", 9);
	SetTrieValue(g_hWeaponData, "9009_slot", 0);
	SetTrieValue(g_hWeaponData, "9009_quality", 8);
	SetTrieValue(g_hWeaponData, "9009_level", 100);
	SetTrieString(g_hWeaponData, "9009_attribs", "2 ; 1.15 ; 4 ; 1.5 ; 6 ; 0.85 ; 110 ; 15.0 ; 20 ; 1.0 ; 26 ; 50.0 ; 31 ; 5.0 ; 32 ; 0.30 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.15 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9009_ammo", 100);

//valve medigun
	SetTrieString(g_hWeaponData, "9029_classname", "tf_weapon_medigun");
	SetTrieValue(g_hWeaponData, "9029_index", 29);
	SetTrieValue(g_hWeaponData, "9029_slot", 1);
	SetTrieValue(g_hWeaponData, "9029_quality", 8);
	SetTrieValue(g_hWeaponData, "9029_level", 100);
	SetTrieString(g_hWeaponData, "9029_attribs", "8 ; 1.15 ; 10 ; 1.15 ; 13 ; 0.0 ; 26 ; 50.0 ; 53 ; 1.0 ; 60 ; 0.85 ; 123 ; 1.5 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9029_ammo", -1);

//ludmila
	SetTrieString(g_hWeaponData, "2041_classname", "tf_weapon_minigun");
	SetTrieValue(g_hWeaponData, "2041_index", 41);
	SetTrieValue(g_hWeaponData, "2041_slot", 0);
	SetTrieValue(g_hWeaponData, "2041_quality", 10);
	SetTrieValue(g_hWeaponData, "2041_level", 5);
	SetTrieString(g_hWeaponData, "2041_attribs", "29 ; 1 ; 86 ; 1.2 ; 5 ; 1.1");
	SetTrieValue(g_hWeaponData, "2041_ammo", 200);

//spycrab pda
	SetTrieString(g_hWeaponData, "9027_classname", "tf_weapon_pda_spy");
	SetTrieValue(g_hWeaponData, "9027_index", 27);
	SetTrieValue(g_hWeaponData, "9027_slot", 3);
	SetTrieValue(g_hWeaponData, "9027_quality", 2);
	SetTrieValue(g_hWeaponData, "9027_level", 100);
	SetTrieString(g_hWeaponData, "9027_attribs", "128 ; 1.0 ; 60 ; 0.0 ; 62 ; 0.0 ; 64 ; 0.0 ; 66 ; 0.0 ; 169 ; 0.0 ; 205 ; 0.0 ; 206 ; 0.0 ; 70 ; 2.0 ; 53 ; 1.0 ; 68 ; -1.0 ; 134 ; 9.0");
	SetTrieValue(g_hWeaponData, "9027_ammo", -1);

//fire retardant suit (revolver does no damage)
	SetTrieString(g_hWeaponData, "2061_classname", "tf_weapon_revolver");
	SetTrieValue(g_hWeaponData, "2061_index", 61);
	SetTrieValue(g_hWeaponData, "2061_slot", 0);
	SetTrieValue(g_hWeaponData, "2061_quality", 10);
	SetTrieValue(g_hWeaponData, "2061_level", 5);
	SetTrieString(g_hWeaponData, "2061_attribs", "168 ; 1.0 ; 1 ; 0.0");
	SetTrieValue(g_hWeaponData, "2061_ammo", -1);

//valve cheap rocket launcher
	SetTrieString(g_hWeaponData, "8018_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "8018_index", 18);
	SetTrieValue(g_hWeaponData, "8018_slot", 0);
	SetTrieValue(g_hWeaponData, "8018_quality", 8);
	SetTrieValue(g_hWeaponData, "8018_level", 100);
	SetTrieString(g_hWeaponData, "8018_attribs", "2 ; 100.0 ; 4 ; 91.0 ; 6 ; 0.25 ; 110 ; 500.0 ; 26 ; 250.0 ; 31 ; 10.0 ; 107 ; 3.0 ; 97 ; 0.4 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "8018_ammo", 200);

//PCG cheap Community rocket launcher
	SetTrieString(g_hWeaponData, "7018_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "7018_index", 18);
	SetTrieValue(g_hWeaponData, "7018_slot", 0);
	SetTrieValue(g_hWeaponData, "7018_quality", 7);
	SetTrieValue(g_hWeaponData, "7018_level", 100);
	SetTrieString(g_hWeaponData, "7018_attribs", "26 ; 500.0 ; 110 ; 500.0 ; 6 ; 0.25 ; 4 ; 200.0 ; 2 ; 100.0 ; 97 ; 0.2 ; 134 ; 4.0");
	SetTrieValue(g_hWeaponData, "7018_ammo", 200);

//derpFaN
	SetTrieString(g_hWeaponData, "8045_classname", "tf_weapon_scattergun");
	SetTrieValue(g_hWeaponData, "8045_index", 45);
	SetTrieValue(g_hWeaponData, "8045_slot", 0);
	SetTrieValue(g_hWeaponData, "8045_quality", 8);
	SetTrieValue(g_hWeaponData, "8045_level", 99);
	SetTrieString(g_hWeaponData, "8045_attribs", "44 ; 1.0 ; 6 ; 0.25 ; 45 ; 2.0 ; 2 ; 10.0 ; 4 ; 100.0 ; 43 ; 1.0 ; 26 ; 500.0 ; 110 ; 500.0 ; 97 ; 0.2 ; 31 ; 10.0 ; 107 ; 3.0 ; 134 ; 4.0");
	SetTrieValue(g_hWeaponData, "8045_ammo", 200);

//Trilby's Rebel Pack - Texas Ten-Shot
	SetTrieString(g_hWeaponData, "2141_classname", "tf_weapon_sentry_revenge");
	SetTrieValue(g_hWeaponData, "2141_index", 141);
	SetTrieValue(g_hWeaponData, "2141_slot", 0);
	SetTrieValue(g_hWeaponData, "2141_quality", 10);
	SetTrieValue(g_hWeaponData, "2141_level", 10);
	SetTrieString(g_hWeaponData, "2141_attribs", "4 ; 1.66 ; 19 ; 0.15 ; 76 ; 1.25 ; 96 ; 1.8 ; 134 ; 3");
	SetTrieValue(g_hWeaponData, "2141_ammo", 40);

//Trilby's Rebel Pack - Texan Love
	SetTrieString(g_hWeaponData, "2161_classname", "tf_weapon_shotgun_pyro");
	SetTrieValue(g_hWeaponData, "2161_index", 460);
	SetTrieValue(g_hWeaponData, "2161_slot", 1);
	SetTrieValue(g_hWeaponData, "2161_quality", 10);
	SetTrieValue(g_hWeaponData, "2161_level", 10);
	SetTrieString(g_hWeaponData, "2161_attribs", "2 ; 1.4 ; 106 ; 0.65 ; 6 ; 0.80 ; 146 ; 1.0 ; 96 ; 1.2 ; 69 ; 0.80 ; 45 ; 0.3 ; 106 ; 0.0");
	SetTrieValue(g_hWeaponData, "2161_ammo", 24);

//direct hit LaN
	SetTrieString(g_hWeaponData, "2127_classname", "tf_weapon_rocketlauncher_directhit");
	SetTrieValue(g_hWeaponData, "2127_index", 127);
	SetTrieValue(g_hWeaponData, "2127_slot", 0);
	SetTrieValue(g_hWeaponData, "2127_quality", 10);
	SetTrieValue(g_hWeaponData, "2127_level", 1);
	SetTrieString(g_hWeaponData, "2127_attribs", "3 ; 0.5 ; 103 ; 1.8 ; 2 ; 1.25 ; 114 ; 1.0 ; 67 ; 1.1");
	SetTrieValue(g_hWeaponData, "2127_ammo", 20);

//dalokohs bar Effect
	SetTrieString(g_hWeaponData, "2159_classname", "tf_weapon_lunchbox");
	SetTrieValue(g_hWeaponData, "2159_index", 159);
	SetTrieValue(g_hWeaponData, "2159_slot", 1);
	SetTrieValue(g_hWeaponData, "2159_quality", 6);
	SetTrieValue(g_hWeaponData, "2159_level", 1);
	SetTrieString(g_hWeaponData, "2159_attribs", "140 ; 50 ; 139 ; 1");
	SetTrieValue(g_hWeaponData, "2159_ammo", 1);

//fishcake Effect
	SetTrieString(g_hWeaponData, "2433_classname", "tf_weapon_lunchbox");
	SetTrieValue(g_hWeaponData, "2433_index", 433);
	SetTrieValue(g_hWeaponData, "2433_slot", 1);
	SetTrieValue(g_hWeaponData, "2433_quality", 6);
	SetTrieValue(g_hWeaponData, "2433_level", 1);
	SetTrieString(g_hWeaponData, "2433_attribs", "140 ; 50 ; 139 ; 1");
	SetTrieValue(g_hWeaponData, "2433_ammo", 1);

//The Army of One
	SetTrieString(g_hWeaponData, "2228_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "2228_index", 228);
	SetTrieValue(g_hWeaponData, "2228_slot", 0);
	SetTrieValue(g_hWeaponData, "2228_quality", 10);
	SetTrieValue(g_hWeaponData, "2228_level", 5);
	SetTrieString(g_hWeaponData, "2228_attribs", "2 ; 5.0 ; 99 ; 3.0 ; 3 ; 0.25 ; 104 ; 0.3 ; 37 ; 0.0");
	SetTrieValue(g_hWeaponData, "2228_ammo", 0);
	SetTrieString(g_hWeaponData, "2228_model", "models/advancedweaponiser/fbomb/c_fbomb.mdl");

//Shotgun for all
	SetTrieString(g_hWeaponData, "2009_classname", "tf_weapon_sentry_revenge");
	SetTrieValue(g_hWeaponData, "2009_index", 141);
	SetTrieValue(g_hWeaponData, "2009_slot", 0);
	SetTrieValue(g_hWeaponData, "2009_quality", 0);
	SetTrieValue(g_hWeaponData, "2009_level", 1);
	SetTrieString(g_hWeaponData, "2009_attribs", "");
	SetTrieValue(g_hWeaponData, "2009_ammo", 32);

//Another weapon by Trilby- Fighter's Falcata
	SetTrieString(g_hWeaponData, "2193_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "2193_index", 193);
	SetTrieValue(g_hWeaponData, "2193_slot", 2);
	SetTrieValue(g_hWeaponData, "2193_quality", 10);
	SetTrieValue(g_hWeaponData, "2193_level", 5);
	SetTrieString(g_hWeaponData, "2193_attribs", "6 ; 0.8 ; 2 ; 1.1 ; 15 ; 0 ; 98 ; -15");
	SetTrieValue(g_hWeaponData, "2193_ammo", -1);

//Khopesh Climber- MECHA!
	SetTrieString(g_hWeaponData, "2171_classname", "tf_weapon_club");
	SetTrieValue(g_hWeaponData, "2171_index", 171);
	SetTrieValue(g_hWeaponData, "2171_slot", 2);
	SetTrieValue(g_hWeaponData, "2171_quality", 10);
	SetTrieValue(g_hWeaponData, "2171_level", 11);
	SetTrieString(g_hWeaponData, "2171_attribs", "1 ; 0.9 ; 5 ; 1.95");
	SetTrieValue(g_hWeaponData, "2171_ammo", -1);
	SetTrieString(g_hWeaponData, "2171_model", "models/advancedweaponiser/w_sickle_sniper.mdl");
//	SetTrieString(g_hWeaponData, "2171_viewmodel", "models/advancedweaponiser/v_sickle_sniper.mdl");

//Robin's new cheap Rocket Launcher
	SetTrieString(g_hWeaponData, "9205_classname", "tf_weapon_rocketlauncher");
	SetTrieValue(g_hWeaponData, "9205_index", 205);
	SetTrieValue(g_hWeaponData, "9205_slot", 0);
	SetTrieValue(g_hWeaponData, "9205_quality", 8);
	SetTrieValue(g_hWeaponData, "9205_level", 100);
	SetTrieString(g_hWeaponData, "9205_attribs", "2 ; 10100.0 ; 4 ; 1100.0 ; 6 ; 0.25 ; 16 ; 250.0 ; 31 ; 10.0 ; 103 ; 1.5 ; 107 ; 2.0 ; 134 ; 2.0");
	SetTrieValue(g_hWeaponData, "9205_ammo", 200);

//Trilby's Rebel Pack - Rebel's Curse
	SetTrieString(g_hWeaponData, "2197_classname", "tf_weapon_wrench");
	SetTrieValue(g_hWeaponData, "2197_index", 197);
	SetTrieValue(g_hWeaponData, "2197_slot", 2);
	SetTrieValue(g_hWeaponData, "2197_quality", 10);
	SetTrieValue(g_hWeaponData, "2197_level", 13);
	SetTrieString(g_hWeaponData, "2197_attribs", "156 ; 1 ; 2 ; 1.05 ; 107 ; 1.1 ; 62 ; 0.90 ; 64 ; 0.90 ; 125 ; -10 ; 5 ; 1.2 ; 81 ; 0.75");
	SetTrieValue(g_hWeaponData, "2197_ammo", -1);
	SetTrieString(g_hWeaponData, "2197_model", "models/custom/weapons/rebelscurse/c_wrench_v2.mdl");
	SetTrieString(g_hWeaponData, "2197_viewmodel", "models/custom/weapons/rebelscurse/v_wrench_engineer_v2.mdl");

//Jar of Ants
	SetTrieString(g_hWeaponData, "2058_classname", "tf_weapon_jar");
	SetTrieValue(g_hWeaponData, "2058_index", 58);
	SetTrieValue(g_hWeaponData, "2058_slot", 1);
	SetTrieValue(g_hWeaponData, "2058_quality", 10);
	SetTrieValue(g_hWeaponData, "2058_level", 6);
	SetTrieString(g_hWeaponData, "2058_attribs", "149 ; 10.0");
	SetTrieValue(g_hWeaponData, "2058_ammo", 1);

//The Horsemann's Axe
	SetTrieString(g_hWeaponData, "9266_classname", "tf_weapon_sword");
	SetTrieValue(g_hWeaponData, "9266_index", 266);
	SetTrieValue(g_hWeaponData, "9266_slot", 2);
	SetTrieValue(g_hWeaponData, "9266_quality", 5);
	SetTrieValue(g_hWeaponData, "9266_level", 100);
	SetTrieString(g_hWeaponData, "9266_attribs", "15 ; 0 ; 26 ; 600.0 ; 2 ; 999.0 ; 107 ; 4.0 ; 109 ; 0.0 ; 57 ; 50.0 ; 69 ; 0.0 ; 68 ; -1 ; 53 ; 1.0 ; 27 ; 1.0 ; 180 ; -25 ; 219 ; 1.0 ; 134 ; 8.0");
	SetTrieValue(g_hWeaponData, "9266_ammo", -1);

//Goldslinger
	SetTrieString(g_hWeaponData, "5142_classname", "tf_weapon_robot_arm");
	SetTrieValue(g_hWeaponData, "5142_index", 142);
	SetTrieValue(g_hWeaponData, "5142_slot", 2);
	SetTrieValue(g_hWeaponData, "5142_quality", 6);
	SetTrieValue(g_hWeaponData, "5142_level", 25);
	SetTrieString(g_hWeaponData, "5142_attribs", "124 ; 1 ; 26 ; 25.0 ; 15 ; 0 ; 150 ; 1");
	SetTrieValue(g_hWeaponData, "5142_ammo", -1);
	SetTrieString(g_hWeaponData, "5142_model", "models/custom/weapons/goldslinger/engineer_v2.mdl");
	SetTrieString(g_hWeaponData, "5142_viewmodel", "models/custom/weapons/goldslinger/c_engineer_arms.mdl");
}
