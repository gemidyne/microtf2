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
            return IsClientInGame(this.ClientId);
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
            return IsPlayerParticipant[this.ClientId];
        }
        public set(bool value)
        {
            IsPlayerParticipant[this.ClientId] = value;
        }
    }

    property int Score
    {
        public get()
        {
            return PlayerScore[this.ClientId];
        }
        public set(int value)
        {
            PlayerScore[this.ClientId] = value;
        }
    }

    property PlayerStatuses Status
    {
        public get()
        {
            return PlayerStatus[this.ClientId];
        }
        public set(PlayerStatuses value)
        {
            PlayerStatus[this.ClientId] = value;
        }
    }

    property int MinigamesWon
    {
        public get()
        {
            return PlayerMinigamesWon[this.ClientId];
        }
        public set(int value)
        {
            PlayerMinigamesWon[this.ClientId] = value;
        }
    }

    property int MinigamesLost
    {
        public get()
        {
            return PlayerMinigamesLost[this.ClientId];
        }
        public set(int value)
        {
            PlayerMinigamesLost[this.ClientId] = value;
        }
    }

    property bool IsWinner
    {
        public get()
        {
            return IsPlayerWinner[this.ClientId];
        }
        public set(bool value)
        {
            IsPlayerWinner[this.ClientId] = value;
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
        SetEntData(this.ClientId, Offset_Collision, enabled ? 5 : 2, 4, true);
    }

    public void SetGravity(float gravity)
    {
        SetEntityGravity(this.ClientId, gravity);
    }

    public void SetHealth(int health)
    {
		int maxHealthOffset = FindDataMapInfo(this.ClientId, "m_iMaxHealth");
		int healthOffset = FindDataMapInfo(this.ClientId, "m_iHealth");

		if (maxHealthOffset == -1 || healthOffset == -1)
		{
			SetFailState("Failed to find m_iMaxHealth / m_iHealth on CTFPlayer.");
		}

		SetEntData(this.ClientId, maxHealthOffset, health, 4, true);
		SetEntData(this.ClientId, healthOffset, health, 4, true);
    }

    public void ResetHealth()
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
		
		this.SetHealth(health);
    }

    public void Kill()
    {
        ForcePlayerSuicide(this.ClientId);
    }

    public void SetGlow(bool enabled)
    {
        SetEntProp(this.ClientId, Prop_Send, "m_bGlowEnabled", enabled ? 1 : 0);
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
        if (enabled)
        {
            int flags = GetCommandFlags("thirdperson");

            SetCommandFlags("thirdperson", flags & (~FCVAR_CHEAT));
            ClientCommand(this.ClientId, "thirdperson");
            SetCommandFlags("thirdperson", flags);
        }
        else
        {
            int flags = GetCommandFlags("firstperson");

            SetCommandFlags("firstperson", flags & (~FCVAR_CHEAT));
            ClientCommand(this.ClientId, "firstperson");
            SetCommandFlags("firstperson", flags);
        }
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

    public void SetAmmo(int ammoCount, bool primaryAmmo = true, bool clipAmmo = true)
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

        int ammoType = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
        int ammo = FindSendPropInfo("CTFPlayer", "m_iAmmo");
        int clip = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");

        if (ammo <= 0)
        {
            return;
        }

        if (clip <= 0)
        {
            return;
        }

        if (clipAmmo)
        {
            SetEntData(entity, clip, ammoCount, 4, true);
        }

        if (primaryAmmo)
        {
            SetEntData(this.ClientId, ammoType+ammo, ammoCount, 4, true);
        }
    }

    public void RemoveWearables()
    {
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

    public void PrintChatText(const char[] text)
    {
        CPrintToChat(this.ClientId, "%s%s", PLUGIN_PREFIX, text);
    }
}