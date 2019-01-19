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

    public void RemoveAllWeapons()
    {
        TF2_RemoveAllWeapons(this.ClientId);
    }

    public void Respawn()
    {
        TF2_RespawnPlayer(this.ClientId);
    }

    public void SetClass(TFClassType class)
    {
        TF2_SetPlayerClass(this.ClientId, class);
    }

    public void SetRandomClass()
    {
        TFClassType newClass = view_as<TFClassType>(GetRandomInt(1, 9));

        this.SetClass(newClass);
    }

    public void SetGodMode(bool enabled)
    {
        SetEntProp(this.ClientId, Prop_Data, "m_takedamage", enabled ? 0 : 2, 1);
    }

    public void SetCollisionsEnabled(bool enabled)
    {
        SetEntData(this.ClientId, Offset_Collision, enabled ? 5 : 2, 4, true);
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
}