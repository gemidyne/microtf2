public bool TimelimitManager_HasTimeLimit()
{
    return GetConVarBool(ConVar_MTF2UseServerMapTimelimit);
}

public bool TimelimitManager_HasExceededTimeLimit()
{
    int remainingSeconds = 0;

    if (!GetMapTimeLeft(remainingSeconds))
    {
        return true;
    }

    return remainingSeconds <= 0;
}