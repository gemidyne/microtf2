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

    property bool HasDynamicCaption
    {
        public get()
        {
            return BossgameCaptionIsDynamic[this.Id];
        }
    }

    property float Duration
    {
        public get()
        {
            return BossgameLength[this.Id];
        }
    }

    public void GetDynamicCaptionFunctionName(char[] buffer, int size)
    {
        strcopy(buffer, size, BossgameDynamicCaptionFunctions[this.Id]);
    }

    public void GetBgmPath(char[] buffer, int size)
    {
        strcopy(buffer, size, BossgameMusic[this.Id]);
    }
}