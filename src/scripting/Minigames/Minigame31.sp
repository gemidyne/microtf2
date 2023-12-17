/**
 * MicroTF2 - Minigame 31
 * 
 * Land Safely!
 */

// TODO: Need to figure out better air control with parachute deployed

#define MINIGAME31_PLATFORM_MIN 1
#define MINIGAME31_PLATFORM_MAX 4

int g_iMinigame31PlayerIndex;

public void Minigame31_EntryPoint()
{
    g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Minigame31_OnMinigameSelectedPre);
    g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Minigame31_OnMinigameSelected);
    g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, Minigame31_OnMinigameFinish);
    g_pfOnTfRoundStart.AddFunction(INVALID_HANDLE, Minigame31_OnTfRoundStart);
}

public void Minigame31_OnTfRoundStart()
{
    int entity = -1;
    char entityName[32];

    while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
    {
        GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

        // try to match entity with name "Minigame31_Platform%d_Trigger"
        if (StrContains(entityName, "Minigame31_Platform") > -1 && StrContains(entityName, "_Trigger") > -1)
        {
            SDKHook(entity, SDKHook_StartTouch, Minigame31_OnPlatformTriggerTouched);
        }
    }
}

public void Minigame31_OnMinigameSelectedPre() 
{
    if (g_iActiveMinigameId == 31)
    {
        g_iMinigame31PlayerIndex = 0;
        g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
        g_bIsBlockingKillCommands = true;

        Minigame31_OpenPlatforms();
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
        player.ResetWeapon(true);
        player.SetCollisionsEnabled(false);
        player.GiveWeapon(1101);

        g_iMinigame31PlayerIndex++;
        
        float vel[3] = { 0.0, 0.0, 0.0 };
        int posa = 360 / g_iActiveParticipantCount * (g_iMinigame31PlayerIndex-1);
        float pos[3];
        float ang[3];

        pos[0] = 5389.0 + (Cosine(DegToRad(float(posa)))*300.0);
        pos[1] = 395.0 - (Sine(DegToRad(float(posa)))*300.0);
        pos[2] = 1150.0;

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
                player.Respawn();
            }
        }

        for (int i = MINIGAME31_PLATFORM_MIN; i <= MINIGAME31_PLATFORM_MAX; i++)
        {
            // Disable platform triggers
            char name[64];
            Format(name, sizeof(name), "Minigame31_Platform%d_Trigger", i);
            SendEntityInput("trigger_multiple", name, "Disable");
        }
    }
}

void Minigame31_OpenPlatforms()
{
    int platform1 = GetRandomInt(MINIGAME31_PLATFORM_MIN, MINIGAME31_PLATFORM_MAX);
    int platform2 = platform1;

    do
    {
        platform2 = GetRandomInt(MINIGAME31_PLATFORM_MIN, MINIGAME31_PLATFORM_MAX);
    }
    while (platform2 == platform1);

    Minigame31_TriggerPlatform(platform1);
    Minigame31_TriggerPlatform(platform2);
}

void Minigame31_TriggerPlatform(int platformId)
{
    char name[64];

    Format(name, sizeof(name), "Minigame31_Platform%d", platformId);
    SendEntityInput("func_door", name, "Open");

    Format(name, sizeof(name), "Minigame31_Platform%d_Trigger", platformId);
    SendEntityInput("trigger_multiple", name, "Enable");
}

public Action Minigame31_OnPlatformTriggerTouched(int entity, int other)
{
    if (g_iActiveMinigameId != 31 || !g_bIsMinigameActive)
    {
        return Plugin_Continue;
    }

    // Defer the check to ensure the player is still alive
    // (So they haven't died from fall damage)
    CreateTimer(0.1, Minigame31_ValidatePlatformTriggerTouch, other);
    return Plugin_Continue;
}

public Action Minigame31_ValidatePlatformTriggerTouch(Handle timer, int client)
{
    if (g_iActiveMinigameId != 31 || !g_bIsMinigameActive)
    {
        return Plugin_Continue;
    }

    Player activator = new Player(client);

    if (activator.IsValid && activator.IsAlive && activator.IsParticipating && activator.Status == PlayerStatus_NotWon)
    {
        // Player landed on the platform safely
        activator.TriggerSuccess();
    }

    return Plugin_Continue;
}