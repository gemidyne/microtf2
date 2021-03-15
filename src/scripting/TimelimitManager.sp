public bool TimelimitManager_HasTimeLimit()
{
    return g_hConVarPluginUseServerMapTimelimit.BoolValue;
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