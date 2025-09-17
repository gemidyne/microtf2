methodmap PathTrack __nullable__ < Entity
{
    public PathTrack()
    {
        return view_as<PathTrack>(Entity.Create("path_track"));
    }

    public void SetName(const char[] name)
    {
        this.KeyValue("targetname", name);
    }

    public void SetNextTarget(const char[] nextTargetName)
    {
        this.KeyValue("target", nextTargetName);
    }

    public void Build(const float position[3])
    {
        this.DispatchSpawn();
        this.Activate();
        this.Teleport(position, NULL_VECTOR, NULL_VECTOR);
    }
}