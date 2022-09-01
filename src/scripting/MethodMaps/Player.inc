methodmap Player __nullable__
{
    public Player(int client)
    {
        return view_as<Player>(client);
    }

    property int ClientId
    {
        public get() 
        {
            return view_as<int>(this);
        }
    }

    property bool IsInGame
    {
        public get()
        {
            return this.ClientId > 0 && this.ClientId <= MaxClients && IsClientInGame(this.ClientId) && !IsClientSourceTV(this.ClientId) && !IsClientInKickQueue(this.ClientId);
        }
    }

    property bool IsBot
    {
        public get()
        {
            return IsFakeClient(this.ClientId);
        }
    }

    property bool IsAlive
    {
        public get()
        {
            return IsPlayerAlive(this.ClientId);
        }
    }

    property TFTeam Team
    {
        public get()
        {
            return view_as<TFTeam>(GetClientTeam(this.ClientId));
        }
    }

    property TFClassType Class
    {
        public get()
        {
            return TF2_GetPlayerClass(this.ClientId);
        }
        public set(TFClassType value)
        {
            TF2_SetPlayerClass(this.ClientId, value);
            TF2_RemoveAllWeapons(this.ClientId);
        }
    }

    property float Scale
    {
        public get()
        {
            return GetEntPropFloat(this.ClientId, Prop_Send, "m_flModelScale");
        }
        public set(float value)
        {
            SetEntPropFloat(this.ClientId, Prop_Send, "m_flModelScale", value);
            SetEntPropFloat(this.ClientId, Prop_Send, "m_flStepSize", 18.0 * value);
        }
    }

    property float HeadScale
    {
        public get()
        {
            return GetEntPropFloat(this.ClientId, Prop_Send, "m_flHeadScale");
        }
        public set(float value)
        {
            SetEntPropFloat(this.ClientId, Prop_Send, "m_flHeadScale", value);
        }
    }

    property float TorsoScale
    {
        public get()
        {
            return GetEntPropFloat(this.ClientId, Prop_Send, "m_flTorsoScale");
        }
        public set(float value)
        {
            SetEntPropFloat(this.ClientId, Prop_Send, "m_flTorsoScale", value);
        }
    }

    property float HandScale
    {
        public get()
        {
            return GetEntPropFloat(this.ClientId, Prop_Send, "m_flHandScale");
        }
        public set(float value)
        {
            SetEntPropFloat(this.ClientId, Prop_Send, "m_flHandScale", value);
        }
    }

    property float MaxSpeed
    {
        public get()
        {
            return GetEntPropFloat(this.ClientId, Prop_Send, "m_flMaxspeed");
        }
        public set(float value)
        {
	        SetEntPropFloat(this.ClientId, Prop_Send, "m_flMaxspeed", value);
        }
    }

    property bool IsValid
    {
        public get()
        {
            if (this.ClientId <= 0 || this.ClientId > MaxClients)
            {
                return false;
            }

            if (!this.IsInGame)
            {
                return false;
            }

            TFTeam team = this.Team;

            return team == TFTeam_Red || team == TFTeam_Blue;
        }
    }

    property bool IsParticipating
    {
        public get()
        {
            return g_bIsPlayerParticipant[this.ClientId];
        }
        public set(bool value)
        {
            g_bIsPlayerParticipant[this.ClientId] = value;
        }
    }

    property int Score
    {
        public get()
        {
            return g_iPlayerScore[this.ClientId];
        }
        public set(int value)
        {
            g_iPlayerScore[this.ClientId] = value;
        }
    }

    property PlayerStatuses Status
    {
        public get()
        {
            return g_ePlayerStatus[this.ClientId];
        }
        public set(PlayerStatuses value)
        {
            g_ePlayerStatus[this.ClientId] = value;
        }
    }

    property int MinigamesWon
    {
        public get()
        {
            return g_iPlayerMinigamesWon[this.ClientId];
        }
        public set(int value)
        {
            g_iPlayerMinigamesWon[this.ClientId] = value;
        }
    }

    property int MinigamesLost
    {
        public get()
        {
            return g_iPlayerMinigamesLost[this.ClientId];
        }
        public set(int value)
        {
            g_iPlayerMinigamesLost[this.ClientId] = value;
        }
    }

    property bool IsWinner
    {
        public get()
        {
            return g_bIsPlayerWinner[this.ClientId];
        }
        public set(bool value)
        {
            g_bIsPlayerWinner[this.ClientId] = value;
        }
    }

    property bool IsUsingLegacyDirectX
    {
        public get()
        {
            return g_bIsPlayerUsingLegacyDirectX[this.ClientId];
        }
        public set(bool value)
        {
            g_bIsPlayerUsingLegacyDirectX[this.ClientId] = value;
        }
    }

    public void DisplayOverlay(const char[] path)
    {
        SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
        ClientCommand(this.ClientId, "r_screenoverlay \"%s\"", path);
        SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (FCVAR_CHEAT));
    }

    public void RemoveAllWeapons()
    {
        TF2_RemoveAllWeapons(this.ClientId);
    }

    public void Respawn()
    {
        TF2_RespawnPlayer(this.ClientId);
    }

    public void Regenerate()
    {
        TF2_RegeneratePlayer(this.ClientId);
    }

    public void SetRandomClass()
    {
        this.Class = view_as<TFClassType>(GetRandomInt(1, 9));
    }

    public void SetGodMode(bool enabled)
    {
        SetEntProp(this.ClientId, Prop_Data, "m_takedamage", enabled ? 0 : 2, 1);
    }

    public void SetCollisionsEnabled(bool enabled)
    {
        SetEntData(this.ClientId, g_oCollisionGroup, enabled ? 5 : 2, 4, true);
    }

    public void SetGravity(float gravity)
    {
        SetEntityGravity(this.ClientId, gravity);
    }

    property int DefaultHealth
    {
        public get() 
        {
            int health = 125;

            switch (this.Class)
            {
                case TFClass_Soldier: health = 200;
                case TFClass_Pyro: health = 175;
                case TFClass_DemoMan: health = 175;
                case TFClass_Heavy: health = 300;
                case TFClass_Medic: health = 150;
            }

            return health;
        }
    }

    public void SetHealth(int health)
    {
        int maxHealthOffset = FindDataMapInfo(this.ClientId, "m_iMaxHealth");
        int healthOffset = FindDataMapInfo(this.ClientId, "m_iHealth");

        if (maxHealthOffset == -1 || healthOffset == -1)
        {
            SetFailState("Failed to find m_iMaxHealth / m_iHealth on CTFPlayer.");
        }
        
        int maxHealth = health;

        if (health < this.DefaultHealth)
        {
            maxHealth = this.DefaultHealth;
        }

        SetEntData(this.ClientId, maxHealthOffset, maxHealth, 4, true);
        SetEntData(this.ClientId, healthOffset, health, 4, true);
    }

    property int Health 
    {
        public get()
        {
            return GetClientHealth(this.ClientId);
        }
        public set(int value)
        {
            this.SetHealth(value);
        }
    }

    property int ActiveWeaponEntityEdict
    {
        public get()
        {
            //Credit to Tylerst & Powerlord for this code.
            int weapon = GetEntDataEnt2(this.ClientId, g_oPlayerActiveWeapon);

            if (IsValidEntity(weapon))
            {
                return weapon;
            }
            else
            {
                return -1;
            }
        }
    }

    property int ActiveWeaponItemIndex
    {
        public get()
        {
            int entity = this.ActiveWeaponEntityEdict;

            if (entity == -1)
            {
                return -1;
            }

            return GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
        }
    }

    property int Metal
    {
        public get()
        {
	        return GetEntProp(this.ClientId, Prop_Data, "m_iAmmo", 4, 3);
        }

        public set(int value)
        {
            SetEntProp(this.ClientId, Prop_Data, "m_iAmmo", value, 4, 3);
        }
    }

    property float ChargeMeter
    {
        public get()
        {
            return GetEntPropFloat(this.ClientId, Prop_Send, "m_flChargeMeter");
        }

        public set(float value)
        {
            // Float scale: 0.0 = 0%, 100.0 = 100%
	        SetEntPropFloat(this.ClientId, Prop_Send, "m_flChargeMeter", value);
        }
    }

    property float ChargeLevel
    {
        public get()
        {
            int secondaryWeapon = GetPlayerWeaponSlot(this.ClientId, 1);

            if (IsValidEntity(secondaryWeapon) && HasEntProp(secondaryWeapon, Prop_Send, "m_flChargeLevel"))
            {
                return GetEntPropFloat(secondaryWeapon, Prop_Send, "m_flChargeLevel");
            }

            return 0.0;
        }

        public set(float value)
        {
            int secondaryWeapon = GetPlayerWeaponSlot(this.ClientId, 1);

            if (IsValidEntity(secondaryWeapon) && HasEntProp(secondaryWeapon, Prop_Send, "m_flChargeLevel"))
            {
                // Float scale: 0.0 = 0%, 1.0 = 100%
                SetEntPropFloat(secondaryWeapon, Prop_Send, "m_flChargeLevel", value);
            }
        }
    }

    public void ResetHealth()
    {
		this.SetHealth(this.DefaultHealth);
    }

    public void Kill()
    {
        ForcePlayerSuicide(this.ClientId);
    }

    public void SetGlow(bool enabled)
    {
        SetEntProp(this.ClientId, Prop_Send, "m_bGlowEnabled", enabled ? 1 : 0);
    }

    public void SetItemChargeMeter(float value)
    {
        SetEntPropFloat(this.ClientId, Prop_Send, "m_flItemChargeMeter", value, 1);
    }

    public void SetVisible(bool visible)
    {
        SetEntityRenderMode(this.ClientId, visible
            ? RENDER_NORMAL 
            : RENDER_NONE);

        int entity = -1;
        while ((entity = FindEntityByClassname(entity, "tf_*")) != -1)
        {
            if (!HasEntProp(entity, Prop_Send, "m_hOwnerEntity"))
            {
                continue;
            }

            if (GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != this.ClientId)
            {
                continue;
            }

            SetEntityRenderMode(entity, visible 
                ? RENDER_NORMAL 
                : RENDER_NONE);
        }
    }

    public void SetThirdPersonMode(bool enabled)
    {
        SetVariantInt(view_as<int>(enabled));
        AcceptEntityInput(this.ClientId, "SetForcedTauntCam");
    }

    public void SetViewModelVisible(bool visible)
    {
        SetEntProp(this.ClientId, Prop_Send, "m_bDrawViewmodel", (visible ? 1 : 0));
    }

    public void SetWeaponVisible(bool visible)
    {
        int weapon = GetEntPropEnt(this.ClientId, Prop_Send, "m_hActiveWeapon");

        if (IsValidEntity(weapon))
        {
            SetEntityRenderColor(weapon, 255, 255, 255, (visible ? 255 : 0));
            SetEntityRenderMode(weapon, (visible ? RENDER_NORMAL : RENDER_TRANSCOLOR));
        }
    }

    public void AddCondition(TFCond condition, float duration = TFCondDuration_Infinite, int inflictor = 0)
    {
        TF2_AddCondition(this.ClientId, condition, duration, inflictor);
    }

    public void RemoveCondition(TFCond condition)
    {
        TF2_RemoveCondition(this.ClientId, condition);
    }

    public void ClearConditions()
    {
        this.RemoveCondition(TFCond_Disguised);
        this.RemoveCondition(TFCond_Disguising);
        this.RemoveCondition(TFCond_Jarated);
        this.RemoveCondition(TFCond_OnFire);
        this.RemoveCondition(TFCond_Bonked);
        this.RemoveCondition(TFCond_Dazed);
        this.RemoveCondition(TFCond_Bleeding);
        this.RemoveCondition(TFCond_RuneHaste);
        this.RemoveCondition(TFCond_CritCola);
        this.RemoveCondition(TFCond_HalloweenCritCandy);
        this.RemoveCondition(TFCond_Taunting);
    }

    public bool HasCondition(TFCond condition)
    {
        return TF2_IsPlayerInCondition(this.ClientId, condition);
    }

    public void TryDestroyPlayerBuilding(bool cleanDestroy, char[] entityClassname, TFObjectMode objectMode = TFObjectMode_None)
    {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, entityClassname)) != INVALID_ENT_REFERENCE)
        {
            if (GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == this.ClientId && (objectMode == TFObjectMode_None || TF2_GetObjectMode(entity) == objectMode))
            {
                if (cleanDestroy)
                {
                    AcceptEntityInput(entity, "Kill");
                }
                else
                {
                    SetVariantInt(1000);
                    AcceptEntityInput(entity, "RemoveHealth");
                }
            }
        }
    }

    public void DestroyPlayerSentryGun(bool cleanDestroy = false)
    {
        this.TryDestroyPlayerBuilding(cleanDestroy, "obj_sentrygun");
    }

    public void DestroyPlayerDispenser(bool cleanDestroy = false)
    {
        this.TryDestroyPlayerBuilding(cleanDestroy, "obj_dispenser");
    }

    public void DestroyPlayerTeleporterEntrance(bool cleanDestroy = false)
    {
        this.TryDestroyPlayerBuilding(cleanDestroy, "obj_teleporter", TFObjectMode_Entrance);
    }

    public void DestroyPlayerTeleporterExit(bool cleanDestroy = false)
    {
        this.TryDestroyPlayerBuilding(cleanDestroy, "obj_teleporter", TFObjectMode_Exit);
    }

    public void DestroyPlayerBuildings(bool cleanDestroy = false)
    {
        this.DestroyPlayerSentryGun(cleanDestroy);
        this.DestroyPlayerDispenser(cleanDestroy);
        this.DestroyPlayerTeleporterEntrance(cleanDestroy);
        this.DestroyPlayerTeleporterExit(cleanDestroy);
    }

    public void SetWeaponPrimaryAmmoCount(int count)
    {
        int weaponHandleId = FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon");

        if (weaponHandleId <= 0)
        {
            return;
        }

        int entity = GetEntDataEnt2(this.ClientId, weaponHandleId);

        if (!IsValidEntity(entity)) 
        {
            return;
        }

        int ammo = FindSendPropInfo("CTFPlayer", "m_iAmmo");

        if (ammo <= 0)
        {
            return;
        }

        int offset = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", 1)*4;

        SetEntData(this.ClientId, g_oPlayerAmmo+offset, count, 4, true);
    }

    public void SetWeaponClipAmmoCount(int count)
    {
        int weaponHandleId = FindSendPropInfo("CAI_BaseNPC", "m_hActiveWeapon");

        if (weaponHandleId <= 0)
        {
            return;
        }

        int entity = GetEntDataEnt2(this.ClientId, weaponHandleId);

        if (!IsValidEntity(entity)) 
        {
            return;
        }

        int clip = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");

        if (clip <= 0)
        {
            return;
        }

        SetEntData(entity, clip, count, 4, true);
    }

        // TODO: Remove because having both in one is dumb
    public void SetAmmo(int ammoCount, bool primaryAmmo = true, bool clipAmmo = true)
    {
        if (clipAmmo)
        {
            this.SetWeaponClipAmmoCount(ammoCount);
        }

        if (primaryAmmo)
        {
            this.SetWeaponPrimaryAmmoCount(ammoCount);
        }
    }

    public void RemoveWearables()
    {
        if (g_bAllowCosmetics) 
        {
            return;
        }

        int entity = -1;
        while ((entity = FindEntityByClassname(entity, "tf_wearable*")) != -1)
        {
            AcceptEntityInput(entity, "kill");
        }

        entity = -1;
        while ((entity = FindEntityByClassname(entity, "tf_powerup_bottle")) != -1)
        {
            AcceptEntityInput(entity, "kill");
        }
        
        entity = -1;
        while ((entity = FindEntityByClassname(entity, "tf_weapon_spellbook")) != -1)
        {
            AcceptEntityInput(entity, "kill");
        }
    }

    public void PrintCenterTextLocalised(const char[] translationKey)
    {
        PrintCenterText(this.ClientId, "%T", translationKey, this.ClientId);
    }

    public void PrintChatText(const char[] text, any ...)
    {
        char buffer[MAX_BUFFER_LENGTH];
        char buffer2[MAX_BUFFER_LENGTH];
        
        SetGlobalTransTarget(this.ClientId);
        Format(buffer, sizeof(buffer), "%s", text);
        VFormat(buffer2, sizeof(buffer2), buffer, 3);

        if (g_iSpecialRoundId == 19)
        {
            char rewritten[MAX_BUFFER_LENGTH];
            ReverseString(buffer2, sizeof(buffer2), rewritten);
            ReplaceString(rewritten, sizeof(rewritten), "}tluafed{", "{default}");
            ReplaceString(rewritten, sizeof(rewritten), "}der{", "{red}");
            ReplaceString(rewritten, sizeof(rewritten), "}eulb{", "{blue}");
            ReplaceString(rewritten, sizeof(rewritten), "}etihw{", "{white}");

            strcopy(buffer2, sizeof(buffer2), rewritten);
        }

        CPrintToChat(this.ClientId, "%s%s", PLUGIN_PREFIX, buffer2);
    }

    public void ShowAnnotation(int attachToEntity, float lifetime, char text[32])
    {
        ShowAnnotation(this.ClientId, attachToEntity, lifetime, text);
    }

    public void PrintHintBox(const char[] text)
    {       
        int params[] = {0x76, 0x6F, 0x69, 0x63, 0x65, 0x5F, 0x73, 0x65, 0x6C, 0x66, 0x00, 0x00};
        Handle msg = StartMessageOne("HudNotifyCustom", this.ClientId);
        BfWriteString(msg, text);
        
        for (int i = 0; i < sizeof(params); i++)
        {
            BfWriteByte(msg, params[i]);
        }

        EndMessage();
    }

    public void SetCaption(const char[] text)
    {
        SetCaption(this.ClientId, text);
    }

    public bool HasCaption()
    {
        return HasCaption(this.ClientId);
    }

    public void SetCustomHudText(const char[] text)
    {
        SetCustomHudText(this.ClientId, text);
    }

    public bool HasCustomHudText()
    {
        return HasCustomHudText(this.ClientId);
    }

    public void TriggerSuccess()
    {
        bool valid = this.IsValid && this.IsParticipating && this.Status == PlayerStatus_NotWon;

        if (!valid)
        {
            return;
        }

        this.Status = PlayerStatus_Winner;

        if (g_iActiveParticipantCount > 12)
        {
            PlaySoundToPlayer(this.ClientId, SYSFX_WINNER);
        }
        else
        {
            PlaySoundToAll(SYSFX_WINNER);
        }

        if (this.Team == TFTeam_Blue)
        {
            CreateParticle(this.ClientId, "Micro_Win_Blue", 6.0);
        }
        else if (this.Team == TFTeam_Red)
        {
            CreateParticle(this.ClientId, "Micro_Win_Red", 6.0);
        }
    }

    public void GiveWeapon(int weaponItemIndex)
    {
        Weapons_EquipWeaponByItemIndex(this.ClientId, weaponItemIndex);
    }

    public void ResetWeapon(bool viewModel)
    {
        Weapons_ResetToMelee(this.ClientId, viewModel);
    }

    public void PlaySound(const char[] sound)
    {
        if (this.IsInGame && !this.IsBot && !g_bIsMapEnding)
        {
            char path[MAX_PATH_LENGTH];
            Sounds_ConvertTokens(sound, path, sizeof(path));

            EmitSoundToClient(this.ClientId, path, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
        }
    }
}