// Credit to nosoop - original: https://github.com/nosoop/stocksoup/blob/master/tf/annotations.inc
// Just changed a little to work in with this codebase's style

methodmap Annotation < Event
{
	public Annotation() 
    {
		Annotation event = view_as<Annotation>(CreateEvent("show_annotation"));

		__Annotation_InitDefaults(event);
		
		return event;
	}
	
	property bool ShowEffect
    {
		public get()
        {
			return this.GetBool("show_effect");
		}
		public set(bool show) 
        {
			this.SetBool("show_effect", show);
		}
	}
	
	property bool ShowDistance
    {
		public get()
        {
			return this.GetBool("show_distance");
		}
		public set(bool show)
        {
			this.SetBool("show_distance", show);
		}
	}
	
	property int VisibilityBits
    {
		public get()
        {
			return this.GetInt("visibilityBitfield");
		}
		public set(int visibilityBitfield)
        {
			this.SetInt("visibilityBitfield", visibilityBitfield);
		}
	}
	
	property int FollowEntity
    {
		public get()
        {
			return this.GetInt("follow_entindex");
		}
		public set(int entity)
        {
			this.SetInt("follow_entindex", entity);
		}
	}
	
	property int Id
    {
		public set(int id)
        {
			this.SetInt("id", id);
		}
	}
	
	property float Lifetime
    {
		public set(float lifetime)
        {
			this.SetFloat("lifetime", lifetime);
		}
	}
	
	public void SetClientVisibility(int client, bool visible = true)
    {
		if (visible)
		{
			this.VisibilityBits |= 1 << client;
		}
		else
		{
			this.VisibilityBits &= ~(1 << client);
		}
	}

	public void SetVisibleForAllExcluding(int client)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				this.SetClientVisibility(client, client != i);
			}
		}
	}

	public void SetInvisibleForAllExcluding(int client)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				this.SetClientVisibility(client, client == i);
			}
		}
	}
	
	public void SetSound(const char[] sound)
    {
		this.SetString("play_sound", sound);
	}
	
	public void SetPosition(const float position[3])
    {
		this.SetFloat("worldPosX", position[0]);
		this.SetFloat("worldPosY", position[1]);
		this.SetFloat("worldPosZ", position[2]);
	}
	
	public void SetNormal(const float normal[3])
    {
		this.SetFloat("worldNormalX", normal[0]);
		this.SetFloat("worldNormalY", normal[1]);
		this.SetFloat("worldNormalZ", normal[2]);
	}
	
	public void SetText(const char[] text)
    {
		this.SetString("text", text);
	}

	public void GetText(char[] text, int maxlen)
    {
		this.GetString("text", text, maxlen);
	}
}

static stock void __Annotation_InitDefaults(Annotation annotation)
{
	annotation.Lifetime = 5.0;
	annotation.SetSound("misc/null.wav");
}