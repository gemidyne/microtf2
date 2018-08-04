#define IWA_URL "http://iwa.millenium.stsv.gemini.software/"
#define IWA_MSGPREFIX "\x07356AA0[ \x0744A8D9Connect \x07356AA0] \x01"

new bool:IsSteamLoaded;

public Steam_FullyLoaded()
{
	IsSteamLoaded = true;
}

public Steam_Shutdown()
{
	IsSteamLoaded = false;
}

#include "InternalWebAPI.PlayerScores.inc"
#include "InternalWebAPI.PrecacheManifest.inc"