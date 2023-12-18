methodmap TrackTrain __nullable__ < Entity
{
    public TrackTrain()
    {
        return view_as<TrackTrain>(new Entity("func_tracktrain"));
    }

    public void SetName(const char[] name)
    {
        this.KeyValue("targetname", name);
    }

    public void SetTarget(const char[] targetPathTrackName)
    {
        this.KeyValue("target", targetPathTrackName);
    }

    public void SetModel(const char[] model)
    {
        this.KeyValue("model", model);
    }

    public void SetStartSpeed(const char[] speed)
    {
        this.KeyValue("startspeed", speed);
    }

    public void SetSpeed(const char[] speed)
    {
        this.KeyValue("speed", speed);
    }

    public void SetMoveSound(const char[] path)
    {
        this.KeyValue("movesound", path);
    }

    public void SetWheels(const char[] input)
    {
        this.KeyValue("wheels", input);
    }
    
    public void SetBanking(const char[] input)
    {
        this.KeyValue("bank", input);
    }

    public void SetSpawnFlags(const char[] input)
    {
        this.KeyValue("spawnflags", input);
    }
}