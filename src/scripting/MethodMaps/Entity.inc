methodmap Entity __nullable__
{
    public Entity(const char[] className)
    {
        int entity = CreateEntityByName(className);

        return view_as<Entity>(entity);
    }

    property int Id
    {
        public get() 
        {
            return view_as<int>(this);
        }
    }

    public void Kill()
    {
        if (IsValidEntity(this.Id))
        {
            RemoveEntity(this.Id);
        }
    }

    public void KeyValue(const char[] keyName, const char[] value)
    {
        DispatchKeyValue(this.Id, keyName, value);
    }

    public void Dispatch()
    {
        DispatchSpawn(this.Id);
    }

    public void Activate()
    {
        ActivateEntity(this.Id);
    }

    public void Teleport(const float origin[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, const float velocity[3] = NULL_VECTOR)
    {
        TeleportEntity(this.Id, origin, angles, velocity);
    }

    public void SetEffects(int value)
    {
        SetEntProp(this.Id, Prop_Send, "m_fEffects", value);
    }

    public void SetParent(int entity)
    {
        SetVariantEntity(entity);
        AcceptEntityInput(this.Id, "SetParent");
    }

    /* 
     * Sets this entity to expire after the given duration
     */
    public void SetExpiry(float duration)
    {
        CreateTimer(duration, Timer_RemoveEntity, this.Id);
    }
}