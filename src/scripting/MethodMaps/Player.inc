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
		SetPlayerHealth(this.ClientId, health);
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

    public void SetAmmo(int ammoCount)
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

        SetEntData(entity, clip, ammoCount, 4, true);
        SetEntData(this.ClientId, ammoType+ammo, ammoCount, 4, true);
    }
}