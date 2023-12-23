/**
 * MicroTF2 - Bossgame 9
 * 
 * Dodgeball
 * Credit to Damizean for the original dodgeball/rocket code
 */

#define BOSSGAME9_SFX_ROCKET_SPAWN "weapons/sentry_rocket.wav"
#define BOSSGAME9_SFX_ROCKET_SPAWN_NUKE "items/bomb_warning.wav"
#define BOSSGAME9_SFX_ROCKET_RETARGET "weapons/sentry_scan.wav"

#define BOSSGAME9_LOGIC_RATE 20.0
#define BOSSGAME9_LOGIC_INTERVAL 1.0 / BOSSGAME9_LOGIC_RATE
#define BOSSGAME9_NUKE_SPAWN_START_TIME 60.0 // Start spawning nuke (big rockets) after this time

#define BOSSGAME9_ROCKET_DAMAGE 200.0
#define BOSSGAME9_ROCKET_BASE_SPEED 600.0
#define BOSSGAME9_ROCKET_SPEED_INCREMENT 112.5
#define BOSSGAME9_NUKE_BASE_SPEED 433.3
#define BOSSGAME9_NUKE_SPEED_INCREMENT 180.7
#define BOSSGAME9_ROCKET_TURN_RATE 0.233
#define BOSSGAME9_ROCKET_TURN_RATE_INCREMENT 0.0275
#define BOSSGAME9_NUKE_TURN_RATE 0.133
#define BOSSGAME9_NUKE_TURN_RATE_INCREMENT 0.0135
#define BOSSGAME9_ROCKET_ELEV_RATE 0.1237
#define BOSSGAME9_ROCKET_CTRL_DELAY 0.1 // 0.01
#define BOSSGAME9_ROCKET_SPAWN_INTERVAL 1.0

Handle g_hBossgame9LogicTimer;
DodgeballRocket g_iBossgame9RocketEntity;
float g_fBossgame9RocketDirection[3];
float g_fBossgame9RocketSpeed;
float g_fBossgame9NextRocketSpawnTime;
float g_fBossgame9RocketLastDeflectionTime;
int g_iBossgame9RocketLastDeflectionCount;
int g_iBossgame9RocketsFiredCount;
int g_iBossgame9RocketTargetPlayer;
int g_iBossgame9ParticipantCount;
TFTeam g_eBossgame9LastDeadTeam = TFTeam_Unassigned;
bool g_bBossgame9SpawnNukes = false;
bool g_bBossgame9NukeSpawned = false;

public void Bossgame9_EntryPoint() 
{
    g_pfOnMapStart.AddFunction(INVALID_HANDLE, Bossgame9_OnMapStart);
    g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, Bossgame9_OnMinigameSelectedPre);
    g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, Bossgame9_OnMinigameSelected);
    g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, Bossgame9_OnMinigameFinish);
    g_pfOnBossStopAttempt.AddFunction(INVALID_HANDLE, Bossgame9_OnBossStopAttempt);
    g_pfOnPlayerDeath.AddFunction(INVALID_HANDLE, Bossgame9_OnPlayerDeath);
}

public void Bossgame9_OnMapStart()
{
    PreloadSound(BOSSGAME9_SFX_ROCKET_SPAWN);
    PreloadSound(BOSSGAME9_SFX_ROCKET_SPAWN_NUKE);
    PreloadSound(BOSSGAME9_SFX_ROCKET_RETARGET);
}

public void Bossgame9_OnMinigameSelectedPre()
{
    if (g_iActiveBossgameId == 9)
    {
        g_eDamageBlockMode = EDamageBlockMode_Nothing;
        g_bIsBlockingKillCommands = false;

        g_hBossgame9LogicTimer = CreateTimer(BOSSGAME9_LOGIC_INTERVAL, Bossgame9_RocketLogicTimer, _, TIMER_REPEAT);
        g_fBossgame9NextRocketSpawnTime = GetGameTime();
        g_iBossgame9RocketsFiredCount = 0;
        g_iBossgame9ParticipantCount = 0;
        g_fBossgame9RocketSpeed = 0.0;
        g_fBossgame9RocketDirection = { 0.0, 0.0, 0.0 };
        g_fBossgame9RocketLastDeflectionTime = 0.0;
        g_iBossgame9RocketLastDeflectionCount = 0;
        g_iBossgame9RocketTargetPlayer = -1;
        g_bBossgame9SpawnNukes = false;
        g_bBossgame9NukeSpawned = false;
        g_iBossgame9RocketEntity = new DodgeballRocket(-1); // Force spawn 
        g_eBossgame9LastDeadTeam = GetOppositeTeam(g_eBossgame9LastDeadTeam);
        CreateTimer(BOSSGAME9_NUKE_SPAWN_START_TIME, Bossgame9_NukeSpawnStartTimer);
    }
}

public void Bossgame9_OnMinigameSelected(int client) 
{
    if (g_iActiveBossgameId != 9)
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
        player.Class = TFClass_Pyro;
        player.RemoveAllWeapons();

        player.SetGodMode(false);
        player.SetHealth(1000);
        player.SetCollisionsEnabled(true);

        player.GiveWeapon(21);
        player.SetWeaponPrimaryAmmoCount(200);
        player.Status = PlayerStatus_Winner; // This will get set to Failed on death

        SDKHook(client, SDKHook_PreThink, Bossgame9_RemoveLeftClick);
        g_iBossgame9ParticipantCount++;

        int column = player.ClientId;
        int row = 0;

        while (column > 11)
        {
            column = column - 11;
            row = row + 1;
        }

        float pos[3];
        float ang[3];

        if (player.Team == TFTeam_Red)
        {
            pos[0] = -4793.0 + float(column*120);
            pos[1] = -2625.0 - float(row*120);
            pos[2] = -582.0;

            ang[0] = 0.0;
            ang[1] = 90.0;
            ang[2] = 0.0;
        }
        else
        {
            pos[0] = -3450.0 - float(column*120);
            pos[1] = -1400.0 + float(row*120);
            pos[2] = -582.0;

            ang[0] = 0.0;
            ang[1] = -90.0;
            ang[2] = 0.0;
        }

        float vel[3] = { 0.0, 0.0, 0.0 };

        TeleportEntity(client, pos, ang, vel);
    }
}

public void Bossgame9_OnPlayerDeath(int victimId, int attackerId, int inflictor)
{
    if (g_iActiveBossgameId != 9)
    {
        return;
    }

    if (!g_bIsMinigameActive)
    {
        return;
    }

    Player victim = new Player(victimId);

    if (!victim.IsValid)
    {
        return;
    }

    // We always want to set the player to failed
    // to cover fall damage / hit by rocket etc.
    victim.Status = PlayerStatus_Failed;

    if (inflictor == g_iBossgame9RocketEntity.Id)
    {
        g_eBossgame9LastDeadTeam = victim.Team;
        g_iBossgame9RocketEntity = new DodgeballRocket(-1); // Mark rocket as invalid to spawn a new one

        if (g_bBossgame9NukeSpawned)
        {
            float victimPosition[3];
            victim.GetAbsoluteOrigin(victimPosition);

            for (int i = 1; i <= MaxClients; i++)
            {
                if (i == victimId)
                {
                    continue;
                }

                Player player = new Player(i);

                if (player.IsValid && player.IsParticipating && player.IsAlive)
                {
                    float playerPosition[3];
                    player.GetEyePosition(playerPosition);

                    float distance = GetVectorDistance(victimPosition, playerPosition);

                    if (distance > 600)
                    {
                        continue;
                    }

                    float damage = 300.0;
                    damage = damage * (700.0 - distance) / 700.0;

                    SDKHooks_TakeDamage(player.ClientId, player.ClientId, attackerId, damage, DMG_BLAST);
                }
            }
        }
    }
}

public void Bossgame9_OnMinigameFinish()
{
    if (g_iActiveBossgameId == 9)
    {
        if (g_hBossgame9LogicTimer != INVALID_HANDLE)
        {
            KillTimer(g_hBossgame9LogicTimer);
            g_hBossgame9LogicTimer = INVALID_HANDLE;
        }

        g_iBossgame9RocketEntity.Kill();

        for (int i = 1; i <= MaxClients; i++)
        {
            Player player = new Player(i);

            if (player.IsValid)
            {
                SDKUnhook(i, SDKHook_PreThink, Bossgame9_RemoveLeftClick);
            }
        }
    }
}

public void Bossgame9_OnBossStopAttempt()
{
    if (g_iActiveBossgameId != 9)
    {
        return;
    }

    if (!g_bIsMinigameActive)
    {
        return;
    }

    int aliveBluePlayers = 0;
    int aliveRedPlayers = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        Player player = new Player(i);

        if (player.IsValid && player.IsParticipating && player.IsAlive)
        {
            if (player.Team == TFTeam_Blue)
            {
                aliveBluePlayers++;
            }
            else if (player.Team == TFTeam_Red)
            {
                aliveRedPlayers++;
            }
        }
    }

    if (aliveBluePlayers <= 0 || aliveRedPlayers <= 0)
    {
        EndBoss();
    }
}

public void Bossgame9_RemoveLeftClick(int client)
{
    int buttons = GetClientButtons(client);

    if ((buttons & IN_ATTACK))
    {
        buttons &= ~IN_ATTACK;
        SetEntProp(client, Prop_Data, "m_nButtons", buttons);
    }
}

public Action Bossgame9_RocketLogicTimer(Handle timer)
{
    if (g_iActiveBossgameId != 9)
    {
        return Plugin_Handled;
    }

    if (!g_bIsMinigameActive)
    {
        return Plugin_Handled;
    }

    if (GetGameTime() >= g_fBossgame9NextRocketSpawnTime && !g_iBossgame9RocketEntity.IsValid)
    {
        SpawnRocket(g_eBossgame9LastDeadTeam);
    }

    if (g_iBossgame9RocketEntity.IsValid)
    {
        RunRocketLogic();
    }

    return Plugin_Continue;
}

public Action Bossgame9_NukeSpawnStartTimer(Handle timer)
{
    if (g_iActiveBossgameId != 9)
    {
        return Plugin_Handled;
    }

    if (!g_bIsMinigameActive)
    {
        return Plugin_Handled;
    }

    g_bBossgame9SpawnNukes = true;

    return Plugin_Handled;
}

void SpawnRocket(TFTeam owningTeam)
{
    // If we're spawning a rocket, immediately choose a new target on the opposite team
    g_iBossgame9RocketTargetPlayer = SelectRocketTarget(GetOppositeTeam(owningTeam));

    Player target = new Player(g_iBossgame9RocketTargetPlayer);

    if (!target.IsValid || !target.IsParticipating || !target.IsAlive)
    {
        // We can't choose anyone so we can't spawn any rockets
        return;
    }

    DodgeballRocket rocket = DodgeballRocket.Create();

    if (rocket.IsValid)
    {
        float origin[3];
        float rotation[3] = { -90.0, 0.0, 0.0 };
        float direction[3];
        float velocity[3] = { 0.0, 0.0, 0.0 };
        float modifier = GetRocketModifier();

        if (owningTeam == TFTeam_Blue)
        {
            if (GetRandomInt(0, 1) == 1)
            {
                origin = { -4908.0, -994.0, -400.0 };
            }
            else
            {
                origin = { -3267.0, -1000.0, -400.0 };
            }
        }
        else
        {
            if (GetRandomInt(0, 1) == 1)
            {
                origin = { -3276.0, -3097.0, -400.0 };
            }
            else
            {
                origin = { -4924.0, -3097.0, -400.0 };
            }
        }

        GetAngleVectors(rotation, direction, NULL_VECTOR, NULL_VECTOR);

        rocket.Owner = 0;
        rocket.IsCritical = true;
        rocket.Team = owningTeam;
        rocket.DeflectionCount = 1;
        rocket.SetNukeFlag(g_bBossgame9SpawnNukes);
        rocket.Teleport(origin, rotation, velocity);

        g_fBossgame9RocketDirection[0] = direction[0];
        g_fBossgame9RocketDirection[1] = direction[1];
        g_fBossgame9RocketDirection[2] = direction[2];

        rocket.SetDamage(GetRocketDamage(modifier));
        rocket.DispatchSpawn();

        g_iBossgame9RocketsFiredCount++;
        g_iBossgame9RocketLastDeflectionCount = 0;
        g_fBossgame9RocketSpeed = GetRocketSpeed(modifier);
        g_iBossgame9RocketEntity = rocket;
        g_fBossgame9NextRocketSpawnTime = GetGameTime() + BOSSGAME9_ROCKET_SPAWN_INTERVAL;

        if (g_bBossgame9SpawnNukes)
        {
            g_bBossgame9NukeSpawned = true; // Applies faster nuke speed
            EmitSoundToAll(BOSSGAME9_SFX_ROCKET_SPAWN_NUKE);
        }
        else
        {
            EmitSoundToAll(BOSSGAME9_SFX_ROCKET_SPAWN, rocket.Id);
        }
        
        EmitSoundToAll(BOSSGAME9_SFX_ROCKET_RETARGET, rocket.Id);
        EmitSoundToClient(target.ClientId, BOSSGAME9_SFX_ROCKET_RETARGET);
    }
}

void RunRocketLogic()
{
    TFTeam ownerTeam = g_iBossgame9RocketEntity.Team;
    TFTeam targetTeam = GetOppositeTeam(ownerTeam);
    int deflectionCount = g_iBossgame9RocketEntity.DeflectionCount - 1;
    float modifier = GetRocketModifier();

    if (deflectionCount > g_iBossgame9RocketLastDeflectionCount)
    {
        // Rocket has been deflected
        Player deflector = new Player(g_iBossgame9RocketEntity.Owner);

        if (deflector.IsValid)
        {
            float viewAngles[3];
            float direction[3];

            deflector.GetEyeViewAngles(viewAngles);
            
            GetAngleVectors(viewAngles, direction, NULL_VECTOR, NULL_VECTOR);

            g_fBossgame9RocketDirection[0] = direction[0];
            g_fBossgame9RocketDirection[1] = direction[1];
            g_fBossgame9RocketDirection[2] = direction[2];

            g_iBossgame9RocketEntity.Team = deflector.Team;
        }

        g_iBossgame9RocketTargetPlayer = SelectRocketTarget(targetTeam);
        g_fBossgame9RocketLastDeflectionTime = GetGameTime();
        g_fBossgame9RocketSpeed = GetRocketSpeed(modifier);
        g_iBossgame9RocketLastDeflectionCount = deflectionCount;

        g_iBossgame9RocketEntity.SetDamage(GetRocketDamage(modifier));

        EmitSoundToAll(BOSSGAME9_SFX_ROCKET_RETARGET, g_iBossgame9RocketEntity.Id);

        Player newTarget = new Player(g_iBossgame9RocketTargetPlayer);

        if (newTarget.IsValid)
        {
            EmitSoundToClient(g_iBossgame9RocketTargetPlayer, BOSSGAME9_SFX_ROCKET_RETARGET);
        }
    }
    else
    {
        if ((GetGameTime() - g_fBossgame9RocketLastDeflectionTime) >= BOSSGAME9_ROCKET_CTRL_DELAY)
        {
            Player target = new Player(g_iBossgame9RocketTargetPlayer);

            if (!target.IsValid || !target.IsParticipating || !target.IsAlive)
            {
                // Need to choose a new target
                g_iBossgame9RocketTargetPlayer = SelectRocketTarget(targetTeam);

                target = new Player(g_iBossgame9RocketTargetPlayer);

                if (!target.IsValid || !target.IsParticipating || !target.IsAlive)
                {
                    // We can't choose anyone, so we can't process this tick
                    return;
                }
            }

            float turnRate = g_bBossgame9NukeSpawned 
                ? BOSSGAME9_NUKE_TURN_RATE + BOSSGAME9_NUKE_TURN_RATE_INCREMENT * modifier
                : BOSSGAME9_ROCKET_TURN_RATE + BOSSGAME9_ROCKET_TURN_RATE_INCREMENT * modifier;
            float directionToTarget[3];
            float rocketPos[3];

            g_iBossgame9RocketEntity.GetPropVector(Prop_Send, "m_vecOrigin", rocketPos);
            target.GetEyePosition(directionToTarget);

            MakeVectorFromPoints(rocketPos, directionToTarget, directionToTarget);
            NormalizeVector(directionToTarget, directionToTarget);
            LerpVectors(g_fBossgame9RocketDirection, directionToTarget, g_fBossgame9RocketDirection, turnRate);
        }
    }

    float rocketAngles[3];
    float rocketVelocity[3];

    GetVectorAngles(g_fBossgame9RocketDirection, rocketAngles);
    
    rocketVelocity[0] = g_fBossgame9RocketDirection[0];
    rocketVelocity[1] = g_fBossgame9RocketDirection[1];
    rocketVelocity[2] = g_fBossgame9RocketDirection[2];

    ScaleVector(rocketVelocity, g_fBossgame9RocketSpeed);

    g_iBossgame9RocketEntity.SetVelocity(rocketVelocity);
    g_iBossgame9RocketEntity.SetAngles(rocketAngles);
}

int SelectRocketTarget(TFTeam team)
{
    float targetWeight = 0.0;
    float weight = 0.0;
    bool useRocketDistance;
    float rocketPosition[3];
    float rocketDirection[3];
    int target = -1;

    if (g_iBossgame9RocketEntity.IsValid)
    {
        g_iBossgame9RocketEntity.GetPropVector(Prop_Send, "m_vecOrigin", rocketPosition);
        rocketDirection[0] = g_fBossgame9RocketDirection[0];
        rocketDirection[1] = g_fBossgame9RocketDirection[1];
        rocketDirection[2] = g_fBossgame9RocketDirection[2];

        useRocketDistance = true;
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        Player potentialTarget = new Player(i);

        bool valid = potentialTarget.IsValid && potentialTarget.IsParticipating && potentialTarget.IsAlive;

        if (!valid)
        {
            continue;
        }

        if (potentialTarget.Team != team)
        {
            continue;
        }

        float newWeight = GetURandomFloatRange(0.0, 100.0);

        if (useRocketDistance)
        {
            float clientPosition[3]; 
            GetClientEyePosition(i, clientPosition);

            float directionToClient[3];
            MakeVectorFromPoints(rocketPosition, clientPosition, directionToClient);

            newWeight += GetVectorDotProduct(rocketPosition, directionToClient) * weight;
        }

        if (target == -1 || newWeight >= targetWeight)
        {
            target = i;
            targetWeight = newWeight;
        }
    }

    return target;
}

float GetRocketModifier()
{
    return g_iBossgame9RocketLastDeflectionCount + (g_iBossgame9RocketsFiredCount * 0.1) + (g_iBossgame9ParticipantCount * 0.01);
}

float GetRocketSpeed(float modifier)
{
    if (g_bBossgame9NukeSpawned)
    {
        return BOSSGAME9_NUKE_BASE_SPEED + BOSSGAME9_NUKE_SPEED_INCREMENT * modifier;
    }

    return BOSSGAME9_ROCKET_BASE_SPEED + BOSSGAME9_ROCKET_SPEED_INCREMENT * modifier;
}

float GetRocketDamage(float modifier)
{
    return (BOSSGAME9_ROCKET_DAMAGE * 2) * modifier;
}