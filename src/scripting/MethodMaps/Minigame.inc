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
            return g_bMinigameHasDynamicCaption[this.Id];
        }
    }

    property float Duration
    {
        public get()
        {
            return g_fMinigameBgmLength[this.Id];
        }
    }

    public void GetDynamicCaptionFunctionName(char[] buffer, int size)
    {
        strcopy(buffer, size, g_sDynamicCaptionFunctionName[this.Id]);
    }

    public void GetBgmPath(char[] buffer, int size)
    {
        strcopy(buffer, size, g_sMinigameBgm[this.Id]);
    }
}