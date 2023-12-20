methodmap Entity __nullable__
{
    public static Entity Create(const char[] className)
    {
        int entity = CreateEntityByName(className);

        return new Entity(entity);
    }

    public Entity(int entityId)
    {
        return view_as<Entity>(entityId);
    }

    property int Id
    {
        public get() 
        {
            return view_as<int>(this);
        }
    }

    property bool IsValid
    {
        public get()
        {
            return IsValidEntity(this.Id);
        }
    }

    public void Kill()
    {
        if (this.IsValid)
        {
            RemoveEntity(this.Id);
        }
    }

    public void KeyValue(const char[] keyName, const char[] value)
    {
        DispatchKeyValue(this.Id, keyName, value);
    }

    public void DispatchSpawn()
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


    // Entity Props
    public int GetPropInt(PropType type, const char[] name, int size = 4, int element = 0)
    {
        return GetEntProp(this.Id, type, name, size, element);
    }

    public void SetPropInt(PropType type, const char[] name, int value, int size = 4, int element = 0)
    {
        SetEntProp(this.Id, type, name, value, size, element);
    }

    public float GetPropFloat(PropType type, const char[] name, int element = 0)
    {
        return GetEntPropFloat(this.Id, type, name, element);
    }

    public void SetPropFloat(PropType type, const char[] name, float value, int element = 0)
    {
        SetEntPropFloat(this.Id, type, name, value, element);
    }

    public Entity GetPropEntity(PropType type, const char[] name, int element = 0)
    {
        int id = GetEntPropEnt(this.Id, type, name, element);

        return new Entity(id);
    }

    public void SetPropEntityId(PropType type, const char[] name, int entityId, int element = 0)
    {
        SetEntPropEnt(this.Id, type, name, entityId, element);
    }

    public void SetPropEntity(PropType type, const char[] name, Entity entity, int element = 0)
    {
        SetEntPropEnt(this.Id, type, name, entity.Id, element);
    }

    public void GetPropVector(PropType type, const char[] name, float buffer[3], int element = 0)
    {
        GetEntPropVector(this.Id, type, name, buffer, element);
    }

    public void SetPropVector(PropType type, const char[] name, float buffer[3], int element = 0)
    {
        SetEntPropVector(this.Id, type, name, buffer, element);
    }

    public void SetModel(const char[] model)
    {
        SetEntityModel(this.Id, model);
    }
}