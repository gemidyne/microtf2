methodmap Bossgame __nullable__
{
    public Bossgame(int id)
    {
        return view_as<Bossgame>(id);
    }

    property int Id
    {
        public get() 
        {
            return view_as<int>(this);
        }
    }

    property bool UsesCaption
    {
        public get()
        {
            return g_bBossgameUsesCaption[this.Id];
        }
    }

    property bool HasDynamicCaption
    {
        public get()
        {
            return g_bBossgameHasDynamicCaption[this.Id];
        }
    }

    property float Duration
    {
        public get()
        {
            return g_fBossgameBgmLength[this.Id];
        }
    }

    public void GetDynamicCaptionFunctionName(char[] buffer, int size)
    {
        strcopy(buffer, size, g_sBossgameDynamicCaptionFunctionName[this.Id]);
    }

    public void GetBgmPath(char[] buffer, int size)
    {
        strcopy(buffer, size, g_sBossgameBgm[this.Id]);
    }
}