methodmap Minigame __nullable__
{
    public Minigame(int minigameId)
    {
        return view_as<Minigame>(minigameId);
    }

    property int Id
    {
        public get() 
        {
            return view_as<int>(this);
        }
    }

    property bool HasDynamicCaption
    {
        public get()
        {
            return MinigameCaptionIsDynamic[this.Id];
        }
    }

    property float Duration
    {
        public get()
        {
            return MinigameMusicLength[this.Id];
        }
    }

    public void GetDynamicCaptionFunctionName(char[] buffer, int size)
    {
        strcopy(buffer, size, MinigameDynamicCaptionFunctions[this.Id]);
    }

    public void GetBgmPath(char[] buffer, int size)
    {
        strcopy(buffer, size, MinigameMusic[this.Id]);
    }
}