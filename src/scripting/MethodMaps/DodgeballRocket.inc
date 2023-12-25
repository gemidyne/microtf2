methodmap DodgeballRocket __nullable__ < Entity
{
    public static DodgeballRocket Create()
    {
        Entity entity = Entity.Create("tf_projectile_rocket");

        return new DodgeballRocket(entity.Id);
    }

    public DodgeballRocket(int entityId) 
    {
        return view_as<DodgeballRocket>(new Entity(entityId));
    }

    property bool IsCritical
    {
        public get()
        {
            return this.GetPropInt(Prop_Send, "m_bCritical") == 1;
        }

        public set(bool value)
        {
            this.SetPropInt(Prop_Send, "m_bCritical", value ? 1 : 0, 1);
        }
    }

    property int DeflectionCount
    {
        public get()
        {
            return this.GetPropInt(Prop_Send, "m_iDeflected");
        }

        public set(int value)
        {
            this.SetPropInt(Prop_Send, "m_iDeflected", value);
        }
    }

    property TFTeam Team
    {
        public get()
        {
            return view_as<TFTeam>(this.GetPropInt(Prop_Send, "m_iTeamNum"));
        }
        public set(TFTeam value)
        {
            this.SetPropInt(Prop_Send, "m_iTeamNum", view_as<int>(value), 1);
            this.SetPropInt(Prop_Send, "m_nSkin", value == TFTeam_Blue ? 0 : 1);
        }
    }

    property int Owner
    {
        public get()
        {
            Entity entity = this.GetPropEntity(Prop_Send, "m_hOwnerEntity");

            return entity.Id;
        }

        public set(int value)
        {
            this.SetPropEntityId(Prop_Send, "m_hOwnerEntity", value);
        }
    }

    public void SetVelocity(float velocity[3])
    {
        this.SetPropVector(Prop_Data, "m_vecAbsVelocity", velocity);
    }

    public void SetAngles(float angles[3])
    {
        this.SetPropVector(Prop_Send, "m_angRotation", angles);
    }

    public void SetDamage(float damage)
    {
        SetEntDataFloat(this.Id, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, damage, true);
    }
}