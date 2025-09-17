methodmap Particle __nullable__ < Entity
{
    public Particle()
    {
        return view_as<Particle>(Entity.Create("info_particle_system"));
    }

    public void SetParticleEffect(const char[] effectName)
    {
        this.KeyValue("effect_name", effectName);
    }

    public void Create()
    {
        this.DispatchSpawn();
        this.Activate();
        this.SendInput("start");
    }
}