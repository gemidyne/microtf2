/**
 * MicroTF2 - Minigame 31
 * 
 * Land Safely!
 */

int g_iMinigame31PlayerIndex;

public void Minigame31_EntryPoint()
{
    g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Minigame31_OnMinigameSelectedPre);
    g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Minigame31_OnMinigameSelected);
    g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, Minigame31_OnMinigameFinish);
}

public void Minigame31_OnMinigameSelectedPre() 
{
    if (g_iActiveMinigameId == 31)
    {
        g_iMinigame31PlayerIndex = 0;
    }
}

public void Minigame31_OnMinigameSelected(int client)
{
    if (g_iActiveMinigameId != 31)
    {
        return;
    }

    if (!g_bIsMinigameActive)
    {
        return;
    }

    Player player = new Player(client);

    if (player.IsValid)
    {
        player.Class = TFClass_DemoMan;
        player.SetGodMode(false);
        player.SetHealth(10);
        player.RemoveAllWeapons();
        player.GiveWeapon(1101);
        player.SetCollisionsEnabled(true);

        g_iMinigame31PlayerIndex++;
        
        // Teleport center point is 5388 396 -180
        float vel[3] = { 0.0, 0.0, 0.0 };
        int posa = 360 / g_iActiveParticipantCount * (g_iMinigame31PlayerIndex-1);
        float pos[3];
        float ang[3];

        pos[0] = 5388.0 + (Cosine(DegToRad(float(posa)))*300.0);
        pos[1] = 396.0 - (Sine(DegToRad(float(posa)))*300.0);
        pos[2] = -180.0;

        ang[0] = 0.0;
        ang[1] = float(180-posa);
        ang[2] = 0.0;

        TeleportEntity(client, pos, ang, vel);
    }
}

public void Minigame31_OnMinigameFinish()
{
	if (g_bIsMinigameActive && g_iActiveMinigameId == 31)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			Player player = new Player(i);

			if (player.IsValid && player.IsParticipating)
			{
				player.Status = (player.IsAlive ? PlayerStatus_Winner : PlayerStatus_Failed);
			}
		}
	}
}